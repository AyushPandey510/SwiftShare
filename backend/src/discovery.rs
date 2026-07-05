use crate::config::Config;
use anyhow::Result;
use chrono::{DateTime, Utc};
use futures::stream::{self, StreamExt};
use network_interface::NetworkInterfaceConfig;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::env;
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::path::Path;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::RwLock;
use tokio::time::sleep;
use tracing::{debug, error, info, warn};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum DeviceType {
    Desktop,
    Mobile,
    Web,
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Device {
    pub id: Uuid,
    pub name: String,
    pub device_type: DeviceType,
    pub ip: IpAddr,
    pub port: u16,
    pub api_port: u16,
    pub last_seen: DateTime<Utc>,
    pub is_online: bool,
    pub capabilities: Vec<String>,
    pub transfer_speed: Option<f64>, // MB/s
    pub version: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiscoveryConfig {
    pub scan_interval: Duration,
    pub timeout: Duration,
    pub max_devices: usize,
    pub local_network_only: bool,
}

pub struct DeviceDiscovery {
    config: Config,
    devices: Arc<RwLock<HashMap<Uuid, Device>>>,
    discovery_config: DiscoveryConfig,
    is_scanning: Arc<RwLock<bool>>,
    local_device_id: Uuid,
    local_device_name: String,
}

impl DeviceDiscovery {
    pub async fn new(config: Config) -> Result<Self> {
        let local_device_id = Uuid::new_v4();
        let local_device_name = hostname::get()
            .map(|h| h.to_string_lossy().to_string())
            .unwrap_or_else(|_| "Unknown Device".to_string());

        Ok(Self {
            config,
            devices: Arc::new(RwLock::new(HashMap::new())),
            discovery_config: DiscoveryConfig {
                scan_interval: Duration::from_secs(30),
                timeout: Duration::from_secs(5),
                max_devices: 50,
                local_network_only: true,
            },
            is_scanning: Arc::new(RwLock::new(false)),
            local_device_id,
            local_device_name,
        })
    }

    pub async fn start_discovery(&self) -> Result<()> {
        info!("Starting device discovery...");

        // Start mDNS service
        self.start_mdns_service().await?;

        // Start network scanning
        self.start_network_scanning().await?;

        // Start cleanup task
        self.start_cleanup_task().await?;

        Ok(())
    }

    async fn start_mdns_service(&self) -> Result<()> {
        let service_name = "_swiftshare._tcp.local.";
        let port = self.config.api_port;

        info!("Starting mDNS service: {} on port {}", service_name, port);

        // For now, we'll simulate mDNS discovery
        // In a real implementation, you would use the mdns-sd crate
        tokio::spawn(async move {
            loop {
                sleep(Duration::from_secs(60)).await;
                debug!("mDNS service running...");
            }
        });

        Ok(())
    }

    async fn start_network_scanning(&self) -> Result<()> {
        if Self::running_in_container() && !Self::scan_in_container_enabled() {
            info!(
                "Skipping active network scan in container; set SWIFTSHARE_SCAN_IN_CONTAINER=true to enable"
            );
            return Ok(());
        }

        let devices = self.devices.clone();
        let is_scanning = self.is_scanning.clone();
        let config = self.config.clone();
        let discovery_config = self.discovery_config.clone();

        tokio::spawn(async move {
            loop {
                {
                    let mut scanning = is_scanning.write().await;
                    *scanning = true;
                }

                if let Err(e) = Self::scan_local_network(&devices, &config, &discovery_config).await
                {
                    error!("Network scanning error: {}", e);
                }

                {
                    let mut scanning = is_scanning.write().await;
                    *scanning = false;
                }

                sleep(discovery_config.scan_interval).await;
            }
        });

        Ok(())
    }

    async fn scan_local_network(
        devices: &Arc<RwLock<HashMap<Uuid, Device>>>,
        config: &Config,
        discovery_config: &DiscoveryConfig,
    ) -> Result<()> {
        // Get local network interfaces
        let interfaces = network_interface::NetworkInterface::show()?;
        let mut scanned_any = false;

        for interface in interfaces {
            if let Some(addr) = interface.addr {
                if let network_interface::Addr::V4(ipv4) = addr {
                    let local_ip = ipv4.ip;
                    if Self::should_skip_interface(&interface.name, local_ip) {
                        debug!(
                            "Skipping interface {} with address {}",
                            interface.name, local_ip
                        );
                        continue;
                    }

                    let prefix = ipv4
                        .netmask
                        .and_then(Self::ipv4_prefix_len)
                        .unwrap_or(24);

                    if !(16..=30).contains(&prefix) {
                        debug!(
                            "Skipping interface {} with unsupported prefix /{}",
                            interface.name, prefix
                        );
                        continue;
                    }

                    scanned_any = true;
                    info!(
                        "Scanning network interface {}: {}/{}",
                        interface.name, local_ip, prefix
                    );

                    Self::scan_subnet(local_ip, prefix, config.api_port, devices, discovery_config)
                        .await?;
                }
            }
        }

        if !scanned_any {
            debug!("No eligible network interfaces found for active discovery scan");
        }

        Ok(())
    }

    async fn scan_subnet(
        network: Ipv4Addr,
        prefix: u8,
        port: u16,
        devices: &Arc<RwLock<HashMap<Uuid, Device>>>,
        discovery_config: &DiscoveryConfig,
    ) -> Result<()> {
        let local_ip_u32 = u32::from(network);
        let mask = if prefix == 32 {
            u32::MAX
        } else {
            !((1 << (32 - prefix)) - 1)
        };
        let network_start = local_ip_u32 & mask;
        let network_end = network_start + (1 << (32 - prefix)) - 1;

        let candidates = ((network_start + 1)..network_end).filter_map(|ip_u32| {
            if ip_u32 == local_ip_u32 {
                return None;
            }
            let ip = Ipv4Addr::from(ip_u32);
            if Self::should_skip_ip(ip) {
                None
            } else {
                Some(ip)
            }
        });

        let scan = stream::iter(candidates)
            .for_each_concurrent(64, |ip| {
                let devices_clone = devices.clone();
                let discovery_config_clone = discovery_config.clone();
                async move {
                    if let Ok(device) = Self::probe_device(ip, port).await {
                        let mut devices = devices_clone.write().await;
                        if devices.len() < discovery_config_clone.max_devices {
                            devices.insert(device.id, device);
                        }
                    }
                }
            });

        match tokio::time::timeout(discovery_config.timeout, scan).await {
            Ok(_) => {
                debug!("Network scan completed");
            }
            Err(_) => {
                warn!("Network scan timeout");
            }
        }

        Ok(())
    }

    async fn probe_device(ip: Ipv4Addr, port: u16) -> Result<Device> {
        let socket_addr = SocketAddr::new(IpAddr::V4(ip), port);

        match tokio::time::timeout(
            Duration::from_millis(1000),
            tokio::net::TcpStream::connect(socket_addr),
        )
        .await
        {
            Ok(Ok(_)) => {
                // Device is reachable, try to get device info
                if let Ok(device_info) = Self::get_device_info(ip, port).await {
                    return Ok(device_info);
                }
            }
            _ => {}
        }

        Err(anyhow::anyhow!("No SwiftShare service at {}", socket_addr))
    }

    async fn get_device_info(ip: Ipv4Addr, port: u16) -> Result<Device> {
        let url = format!("http://{}:{}/api/status", ip, port);

        let client = reqwest::Client::new();
        let response = client
            .get(&url)
            .timeout(Duration::from_secs(2))
            .send()
            .await?;

        if response.status().is_success() {
            let status: serde_json::Value = response.json().await?;

            return Ok(Device {
                id: Uuid::new_v4(),
                name: status["device_name"]
                    .as_str()
                    .unwrap_or(&format!("Device-{}", ip))
                    .to_string(),
                device_type: DeviceType::Unknown, // Would be determined from response
                ip: IpAddr::V4(ip),
                port,
                api_port: port,
                last_seen: Utc::now(),
                is_online: true,
                capabilities: vec!["file-transfer".to_string()],
                transfer_speed: None,
                version: status["version"].as_str().map(|s| s.to_string()),
            });
        }

        Err(anyhow::anyhow!("Failed to get device info"))
    }

    async fn start_cleanup_task(&self) -> Result<()> {
        let devices = self.devices.clone();

        tokio::spawn(async move {
            loop {
                sleep(Duration::from_secs(60)).await;

                let cutoff = Utc::now() - chrono::Duration::minutes(5);
                let mut devices = devices.write().await;

                devices.retain(|_, device| {
                    if device.last_seen < cutoff {
                        device.is_online = false;
                    }
                    device.last_seen > cutoff
                });
            }
        });

        Ok(())
    }

    pub async fn get_devices(&self) -> Vec<Device> {
        let devices = self.devices.read().await;
        devices.values().cloned().collect()
    }

    pub async fn add_device(&self, device: Device) {
        let mut devices = self.devices.write().await;
        devices.insert(device.id, device);
    }

    pub async fn remove_device(&self, device_id: Uuid) {
        let mut devices = self.devices.write().await;
        devices.remove(&device_id);
    }

    pub async fn update_device(&self, device: Device) {
        let mut devices = self.devices.write().await;
        devices.insert(device.id, device);
    }

    pub async fn get_device(&self, device_id: Uuid) -> Option<Device> {
        let devices = self.devices.read().await;
        devices.get(&device_id).cloned()
    }

    pub async fn get_devices_by_type(&self, device_type: DeviceType) -> Vec<Device> {
        let devices = self.devices.read().await;
        devices
            .values()
            .filter(|d| d.device_type == device_type)
            .cloned()
            .collect()
    }

    pub async fn get_online_devices(&self) -> Vec<Device> {
        let devices = self.devices.read().await;
        devices.values().filter(|d| d.is_online).cloned().collect()
    }

    pub async fn is_scanning(&self) -> bool {
        let scanning = self.is_scanning.read().await;
        *scanning
    }

    pub fn get_local_device_info(&self) -> Device {
        Device {
            id: self.local_device_id,
            name: self.local_device_name.clone(),
            device_type: DeviceType::Desktop,
            ip: IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)),
            port: self.config.transfer_port,
            api_port: self.config.api_port,
            last_seen: Utc::now(),
            is_online: true,
            capabilities: vec!["file-transfer".to_string(), "encryption".to_string()],
            transfer_speed: Some(25.0),
            version: Some(env!("CARGO_PKG_VERSION").to_string()),
        }
    }

    fn running_in_container() -> bool {
        Path::new("/.dockerenv").exists()
            || env::var("container").is_ok()
            || env::var("KUBERNETES_SERVICE_HOST").is_ok()
    }

    fn scan_in_container_enabled() -> bool {
        env::var("SWIFTSHARE_SCAN_IN_CONTAINER")
            .map(|value| matches!(value.as_str(), "1" | "true" | "TRUE" | "yes" | "YES"))
            .unwrap_or(false)
    }

    fn should_skip_interface(name: &str, ip: Ipv4Addr) -> bool {
        let lower_name = name.to_ascii_lowercase();
        lower_name == "lo"
            || lower_name.starts_with("docker")
            || lower_name.starts_with("br-")
            || lower_name.starts_with("veth")
            || lower_name.starts_with("tun")
            || lower_name.starts_with("tap")
            || Self::should_skip_ip(ip)
    }

    fn should_skip_ip(ip: Ipv4Addr) -> bool {
        ip.is_loopback() || ip.is_link_local() || ip.is_unspecified() || ip.is_broadcast()
    }

    fn ipv4_prefix_len(netmask: Ipv4Addr) -> Option<u8> {
        let mask = u32::from(netmask);
        let prefix = mask.count_ones() as u8;
        let expected = if prefix == 0 {
            0
        } else {
            u32::MAX << (32 - prefix)
        };

        if mask == expected {
            Some(prefix)
        } else {
            None
        }
    }
}
