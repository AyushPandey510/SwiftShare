use std::collections::HashMap;
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::sync::RwLock;
use tokio::time::sleep;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use anyhow::Result;
use tracing::{info, error, warn, debug};
use crate::config::Config;
use chrono::{DateTime, Utc};
use network_interface::NetworkInterfaceConfig;

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
                
                if let Err(e) = Self::scan_local_network(&devices, &config, &discovery_config).await {
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
        
        for interface in interfaces {
            if let Some(addr) = interface.addr {
                if let network_interface::Addr::V4(ipv4) = addr {
                    let network = ipv4.ip;
                    let prefix = 24; // Assume /24 network
                    
                    info!("Scanning network: {}/{}", network, prefix);
                    
                    // Scan subnet
                    Self::scan_subnet(
                        network,
                        prefix,
                        config.api_port,
                        devices,
                        discovery_config,
                    ).await?;
                }
            }
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
        let network_u32 = u32::from(network);
        let mask = if prefix == 32 { 0 } else { !((1 << (32 - prefix)) - 1) };
        let network_start = network_u32 & mask;
        let network_end = network_start + (1 << (32 - prefix)) - 1;
        
        let mut tasks = Vec::new();
        
        for ip_u32 in network_start..=network_end {
            let ip = Ipv4Addr::from(ip_u32);
            let socket_addr = SocketAddr::new(IpAddr::V4(ip), port);
            
            let devices_clone = devices.clone();
            let discovery_config_clone = discovery_config.clone();
            
            let task = tokio::spawn(async move {
                if let Ok(device) = Self::probe_device(ip, port).await {
                    let mut devices = devices_clone.write().await;
                    if devices.len() < discovery_config_clone.max_devices {
                        devices.insert(device.id, device);
                    }
                }
            });
            
            tasks.push(task);
        }
        
        // Wait for all probes with timeout
        let timeout = tokio::time::sleep(discovery_config.timeout);
        tokio::select! {
            _ = timeout => {
                warn!("Network scan timeout");
            }
            _ = futures::future::join_all(tasks) => {
                debug!("Network scan completed");
            }
        }
        
        Ok(())
    }

    async fn probe_device(ip: Ipv4Addr, port: u16) -> Result<Device> {
        let socket_addr = SocketAddr::new(IpAddr::V4(ip), port);
        
        // Try to connect to the device
        match tokio::time::timeout(
            Duration::from_millis(1000),
            tokio::net::TcpStream::connect(socket_addr)
        ).await {
            Ok(Ok(_)) => {
                // Device is reachable, try to get device info
                if let Ok(device_info) = Self::get_device_info(ip, port).await {
                    return Ok(device_info);
                }
            }
            _ => {}
        }
        
        // If we can't get device info, create a basic device entry
        Ok(Device {
            id: Uuid::new_v4(),
            name: format!("Device-{}", ip),
            device_type: DeviceType::Unknown,
            ip: IpAddr::V4(ip),
            port,
            api_port: port,
            last_seen: Utc::now(),
            is_online: true,
            capabilities: vec!["file-transfer".to_string()],
            transfer_speed: None,
            version: None,
        })
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
        devices
            .values()
            .filter(|d| d.is_online)
            .cloned()
            .collect()
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
} 