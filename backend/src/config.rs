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

        // Use in-memory database for now to avoid file system issues
        let database_path = PathBuf::from(":memory:");

        Self {
            bind_address: "0.0.0.0".to_string(),
            api_port: 3001,
            transfer_port: 3002,
            discovery_timeout: 30,
            cleanup_interval: 60,
            download_dir,
            database_path,
            encryption_key: "default-encryption-key-32-bytes-long".to_string(),
            max_file_size: 1024 * 1024 * 1024, // 1GB
            buffer_size: 8192,                 // 8KB
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
    }

    pub fn public_base_url(&self) -> String {
        env::var("PUBLIC_BASE_URL")
            .unwrap_or_else(|_| format!("http://localhost:{}", self.api_port))
            .trim_end_matches('/')
            .to_string()
    }

    fn generate_encryption_key() -> String {
        use rand::Rng;
        let mut rng = rand::thread_rng();
        let key: [u8; 32] = rng.gen();
        general_purpose::STANDARD.encode(key)
    }
}
