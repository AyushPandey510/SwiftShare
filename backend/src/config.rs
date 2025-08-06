use std::path::PathBuf;
use serde::{Deserialize, Serialize};
use anyhow::Result;
use std::fs;
use base64::{Engine as _, engine::general_purpose};

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
            let config: Config = serde_json::from_str(&content)?;
            Ok(config)
        } else {
            let config = Self::default();
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
        let mut path = dirs::config_dir()
            .ok_or_else(|| anyhow::anyhow!("Could not find config directory"))?;
        path.push("swiftshare");
        path.push("config.json");
        Ok(path)
    }

    pub fn default() -> Self {
        let mut download_dir = dirs::download_dir()
            .unwrap_or_else(|| PathBuf::from("downloads"));
        download_dir.push("SwiftShare");
        
        // Use in-memory database for now to avoid file system issues
        let database_path = PathBuf::from(":memory:");
        
        Self {
            bind_address: "127.0.0.1".to_string(),
            api_port: 8082,
            transfer_port: 8083,
            discovery_timeout: 30,
            cleanup_interval: 60,
            download_dir,
            database_path,
            encryption_key: "default-encryption-key-32-bytes-long".to_string(),
            max_file_size: 1024 * 1024 * 1024, // 1GB
            buffer_size: 8192, // 8KB
        }
    }

    fn generate_encryption_key() -> String {
        use rand::Rng;
        let mut rng = rand::thread_rng();
        let key: [u8; 32] = rng.gen();
        general_purpose::STANDARD.encode(key)
    }
} 