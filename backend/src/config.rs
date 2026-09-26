use anyhow::Result;
use base64::{engine::general_purpose, Engine as _};
use serde::{Deserialize, Serialize};
use std::env;
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub bind_address: String,
    pub transfer_port: u16,
    pub api_port: u16,
    pub download_dir: PathBuf,
    pub database_path: PathBuf,
    pub encryption_key: String,
    pub max_file_size: u64,
    pub buffer_size: usize,
    pub discovery_timeout: u64,
    pub cleanup_interval: u64,
}

impl Config {
    pub fn load() -> Result<Self> {
        let config_path = Self::get_config_path()?;

        if config_path.exists() {
            let content = fs::read_to_string(&config_path)?;
            let mut config: Config = serde_json::from_str(&content)?;
            config.apply_env_overrides();
            Ok(config)
        } else {
            let mut config = Self::default();
            config.apply_env_overrides();
            config.save()?;
            Ok(config)
        }
    }

    pub fn save(&self) -> Result<()> {
        let config_path = Self::get_config_path()?;

        // Ensure config directory exists
        if let Some(parent) = config_path.parent() {
            fs::create_dir_all(parent)?;
        }

        let content = serde_json::to_string_pretty(self)?;
        fs::write(&config_path, content)?;

        Ok(())
    }

    fn get_config_path() -> Result<PathBuf> {
        let mut path =
            dirs::config_dir().ok_or_else(|| anyhow::anyhow!("Could not find config directory"))?;
        path.push("swiftshare");
        path.push("config.json");
        Ok(path)
    }

    pub fn default() -> Self {
        let mut download_dir = dirs::download_dir().unwrap_or_else(|| PathBuf::from("downloads"));
        download_dir.push("SwiftShare");

        let mut database_path = dirs::data_local_dir().unwrap_or_else(|| PathBuf::from("data"));
        database_path.push("swiftshare");
        database_path.push("swiftshare.db");

        Self {
            bind_address: "0.0.0.0".to_string(),
            api_port: 3001,
            transfer_port: 3002,
            discovery_timeout: 30,
            cleanup_interval: 60,
            download_dir,
            database_path,
            encryption_key: "default-encryption-key-32-bytes-long".to_string(),
            max_file_size: 250 * 1024 * 1024, // 250MB
            buffer_size: 8192,                // 8KB
        }
    }

    fn apply_env_overrides(&mut self) {
        if let Ok(port) = env::var("PORT").or_else(|_| env::var("API_PORT")) {
            if let Ok(port) = port.parse::<u16>() {
                self.api_port = port;
            }
        }

        if let Ok(port) = env::var("TRANSFER_PORT") {
            if let Ok(port) = port.parse::<u16>() {
                self.transfer_port = port;
            }
        }

        if let Ok(bind_address) = env::var("BIND_ADDRESS") {
            self.bind_address = bind_address;
        }

        if let Ok(download_dir) = env::var("DOWNLOAD_DIR") {
            self.download_dir = PathBuf::from(download_dir);
        }

        if let Ok(database_path) = env::var("DATABASE_PATH") {
            self.database_path = PathBuf::from(database_path);
        }

        if let Ok(encryption_key) = env::var("ENCRYPTION_KEY") {
            self.encryption_key = encryption_key;
        }

        if let Ok(max_file_size) = env::var("MAX_FILE_SIZE") {
            if let Ok(max_file_size) = max_file_size.parse::<u64>() {
                self.max_file_size = max_file_size;
            }
        }

        if let Ok(buffer_size) = env::var("BUFFER_SIZE") {
            if let Ok(buffer_size) = buffer_size.parse::<usize>() {
                self.buffer_size = buffer_size;
            }
        }
    }

    pub fn public_base_url(&self) -> String {
        env::var("PUBLIC_BASE_URL")
            .unwrap_or_else(|_| format!("http://localhost:{}", self.api_port))
            .trim_end_matches('/')
            .to_string()
    }

    pub fn allowed_origins(&self) -> Vec<String> {
        let mut origins = vec![
            self.public_base_url(),
            "https://swift-share-tau.vercel.app".to_string(),
            "http://localhost:5173".to_string(),
            "http://localhost:3000".to_string(),
            "http://localhost:8080".to_string(),
            "http://localhost:8081".to_string(),
            "http://localhost:8082".to_string(),
            "http://localhost:8083".to_string(),
            "http://127.0.0.1:5173".to_string(),
            "http://127.0.0.1:3000".to_string(),
            "http://127.0.0.1:8080".to_string(),
            "http://127.0.0.1:8081".to_string(),
            "http://127.0.0.1:8082".to_string(),
            "http://127.0.0.1:8083".to_string(),
        ];

        if let Ok(extra) = env::var("CORS_ALLOWED_ORIGINS") {
            origins.extend(
                extra
                    .split(',')
                    .map(str::trim)
                    .filter(|origin| !origin.is_empty())
                    .map(|origin| origin.trim_end_matches('/').to_string()),
            );
        }

        origins.extend(local_lan_origins());

        origins.sort();
        origins.dedup();
        origins
    }

    fn generate_encryption_key() -> String {
        use rand::Rng;
        let mut rng = rand::thread_rng();
        let key: [u8; 32] = rng.gen();
        general_purpose::STANDARD.encode(key)
    }
}

/// Builds CORS origins for the machine's LAN IPv4 addresses on the usual
/// frontend dev ports, so the app works when opened from another device
/// without hand-editing the allow-list.
fn local_lan_origins() -> Vec<String> {
    use network_interface::NetworkInterfaceConfig;

    const FRONTEND_PORTS: [u16; 6] = [3000, 5173, 8080, 8081, 8082, 8083];

    let mut origins = Vec::new();

    if let Ok(interfaces) = network_interface::NetworkInterface::show() {
        for interface in interfaces {
            if let Some(network_interface::Addr::V4(ipv4)) = interface.addr {
                let ip = ipv4.ip;
                if should_skip_origin_ip(&interface.name, ip) {
                    continue;
                }

                for port in FRONTEND_PORTS {
                    origins.push(format!("http://{}:{}", ip, port));
                }
            }
        }
    }

    origins
}

fn should_skip_origin_ip(name: &str, ip: std::net::Ipv4Addr) -> bool {
    let lower_name = name.to_ascii_lowercase();
    lower_name == "lo"
        || lower_name.starts_with("docker")
        || lower_name.starts_with("br-")
        || lower_name.starts_with("veth")
        || lower_name.starts_with("tun")
        || lower_name.starts_with("tap")
        || ip.is_loopback()
        || ip.is_link_local()
        || ip.is_unspecified()
        || ip.is_broadcast()
}

#[cfg(test)]
mod tests {
    use super::Config;

    #[test]
    fn default_allowed_origins_include_frontend_ports() {
        let config = Config::default();
        let origins = config.allowed_origins();

        assert!(origins.contains(&"http://localhost:8080".to_string()));
        assert!(origins.contains(&"http://localhost:8082".to_string()));
        assert!(origins.contains(&"http://127.0.0.1:8080".to_string()));
        assert!(origins.contains(&"http://127.0.0.1:8082".to_string()));
        assert!(origins.contains(&"http://localhost:5173".to_string()));
    }
}
