use crate::config::Config;
use anyhow::Result;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::net::SocketAddr;
use std::path::PathBuf;
use std::sync::Arc;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::RwLock;
use tracing::{error, info, warn};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum TransferStatus {
    Pending,
    InProgress,
    Completed,
    Failed,
    Cancelled,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransferProgress {
    pub id: Uuid,
    pub filename: String,
    pub bytes_transferred: u64,
    pub total_bytes: u64,
    pub speed: f64, // bytes per second
    pub status: TransferStatus,
    pub start_time: DateTime<Utc>,
    pub end_time: Option<DateTime<Utc>>,
    pub error_message: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransferRequest {
    pub filename: String,
    pub size: u64,
    pub checksum: String,
    pub encrypted: bool,
    pub compressed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransferResponse {
    pub success: bool,
    pub message: String,
    pub transfer_id: Option<Uuid>,
}

pub struct TransferEngine {
    config: Config,
    transfers: Arc<RwLock<HashMap<Uuid, TransferProgress>>>,
    listener: Option<TcpListener>,
    active_transfers: Arc<RwLock<HashMap<Uuid, tokio::task::JoinHandle<()>>>>,
}

impl TransferEngine {
    pub async fn new(config: Config) -> Result<Self> {
        // Ensure download directory exists
        tokio::fs::create_dir_all(&config.download_dir).await?;

        Ok(Self {
            config,
            transfers: Arc::new(RwLock::new(HashMap::new())),
            listener: None,
            active_transfers: Arc::new(RwLock::new(HashMap::new())),
        })
    }

    pub async fn start_server(&self) -> Result<()> {
        let addr = format!("{}:{}", self.config.bind_address, self.config.transfer_port);
        let listener = TcpListener::bind(&addr).await?;
        info!("Transfer server listening on {}", addr);

        let transfers = self.transfers.clone();
        let active_transfers = self.active_transfers.clone();
        let config = self.config.clone();

        loop {
            match listener.accept().await {
                Ok((socket, addr)) => {
                    info!("New connection from {}", addr);

                    let transfers_clone = transfers.clone();
                    let active_transfers_clone = active_transfers.clone();
                    let config_clone = config.clone();

                    tokio::spawn(async move {
                        if let Err(e) = Self::handle_connection(
                            socket,
                            addr,
                            transfers_clone,
                            active_transfers_clone,
                            config_clone,
                        )
                        .await
                        {
                            error!("Connection handler error: {}", e);
                        }
                    });
                }
                Err(e) => {
                    error!("Accept error: {}", e);
                }
            }
        }
    }

    async fn handle_connection(
        mut socket: TcpStream,
        addr: SocketAddr,
        transfers: Arc<RwLock<HashMap<Uuid, TransferProgress>>>,
        active_transfers: Arc<RwLock<HashMap<Uuid, tokio::task::JoinHandle<()>>>>,
        config: Config,
    ) -> Result<()> {
        // Read transfer request
        let mut buffer = Vec::new();
        let mut chunk = [0; 1024];

        loop {
            let n = socket.read(&mut chunk).await?;
            if n == 0 {
                break;
            }
            buffer.extend_from_slice(&chunk[..n]);

            // Check for end of request (simple delimiter)
            if buffer.ends_with(b"\n\n") {
                break;
            }
        }

        // Parse transfer request
        let request_str = String::from_utf8_lossy(&buffer);
        let request: TransferRequest = serde_json::from_str(request_str.trim())?;

        let transfer_id = Uuid::new_v4();
        info!(
            "Starting transfer {} for file: {}",
            transfer_id, request.filename
        );

        // Create transfer progress
        let progress = TransferProgress {
            id: transfer_id,
            filename: request.filename.clone(),
            bytes_transferred: 0,
            total_bytes: request.size,
            speed: 0.0,
            status: TransferStatus::InProgress,
            start_time: Utc::now(),
            end_time: None,
            error_message: None,
        };

        // Store transfer progress
        {
            let mut transfers = transfers.write().await;
            transfers.insert(transfer_id, progress);
        }

        // Send acceptance response
        let response = TransferResponse {
            success: true,
            message: "Transfer accepted".to_string(),
            transfer_id: Some(transfer_id),
        };

        let response_json = serde_json::to_string(&response)?;
        socket.write_all(response_json.as_bytes()).await?;
        socket.write_all(b"\n\n").await?;

        // Handle file transfer
        Self::handle_file_transfer(
            socket,
            request,
            transfer_id,
            transfers,
            active_transfers,
            config,
        )
        .await?;

        Ok(())
    }

    async fn handle_file_transfer(
        mut socket: TcpStream,
        request: TransferRequest,
        transfer_id: Uuid,
        transfers: Arc<RwLock<HashMap<Uuid, TransferProgress>>>,
        active_transfers: Arc<RwLock<HashMap<Uuid, tokio::task::JoinHandle<()>>>>,
        config: Config,
    ) -> Result<()> {
        let file_path = config.download_dir.join(&request.filename);
        let mut file = tokio::fs::File::create(&file_path).await?;

        let mut buffer = [0; 8192];
        let mut total_bytes = 0u64;
        let start_time = std::time::Instant::now();

        loop {
            let n = socket.read(&mut buffer).await?;
            if n == 0 {
                break;
            }

            file.write_all(&buffer[..n]).await?;
            total_bytes += n as u64;

            // Update progress
            {
                let mut transfers = transfers.write().await;
                if let Some(progress) = transfers.get_mut(&transfer_id) {
                    progress.bytes_transferred = total_bytes;

                    let elapsed = start_time.elapsed().as_secs_f64();
                    if elapsed > 0.0 {
                        progress.speed = total_bytes as f64 / elapsed;
                    }
                }
            }

            // Check if transfer is complete
            if total_bytes >= request.size {
                break;
            }
        }

        // Verify file size
        let metadata = file.metadata().await?;
        if metadata.len() != request.size {
            error!(
                "File size mismatch: expected {}, got {}",
                request.size,
                metadata.len()
            );

            // Update transfer status to failed
            {
                let mut transfers = transfers.write().await;
                if let Some(progress) = transfers.get_mut(&transfer_id) {
                    progress.status = TransferStatus::Failed;
                    progress.error_message = Some("File size mismatch".to_string());
                    progress.end_time = Some(Utc::now());
                }
            }

            return Err(anyhow::anyhow!("File size mismatch"));
        }

        // Verify checksum if provided
        if !request.checksum.is_empty() {
            let calculated_checksum = Self::calculate_file_checksum(&file_path).await?;
            if calculated_checksum != request.checksum {
                error!("Checksum mismatch for transfer {}", transfer_id);

                // Update transfer status to failed
                {
                    let mut transfers = transfers.write().await;
                    if let Some(progress) = transfers.get_mut(&transfer_id) {
                        progress.status = TransferStatus::Failed;
                        progress.error_message = Some("Checksum mismatch".to_string());
                        progress.end_time = Some(Utc::now());
                    }
                }

                return Err(anyhow::anyhow!("Checksum mismatch"));
            }
        }

        // Mark transfer as completed
        {
            let mut transfers = transfers.write().await;
            if let Some(progress) = transfers.get_mut(&transfer_id) {
                progress.status = TransferStatus::Completed;
                progress.end_time = Some(Utc::now());
            }
        }

        info!("Transfer {} completed successfully", transfer_id);
        Ok(())
    }

    pub async fn send_file(&self, target_addr: SocketAddr, file_path: PathBuf) -> Result<Uuid> {
        let transfer_id = Uuid::new_v4();
        let filename = file_path
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("unknown")
            .to_string();

        let metadata = tokio::fs::metadata(&file_path).await?;
        let file_size = metadata.len();
        let checksum = Self::calculate_file_checksum(&file_path).await?;

        let request = TransferRequest {
            filename: filename.clone(),
            size: file_size,
            checksum,
            encrypted: false,
            compressed: false,
        };

        // Create transfer progress
        let progress = TransferProgress {
            id: transfer_id,
            filename,
            bytes_transferred: 0,
            total_bytes: file_size,
            speed: 0.0,
            status: TransferStatus::InProgress,
            start_time: Utc::now(),
            end_time: None,
            error_message: None,
        };

        // Store transfer progress
        {
            let mut transfers = self.transfers.write().await;
            transfers.insert(transfer_id, progress);
        }

        // Start transfer in background
        let transfers = self.transfers.clone();
        let active_transfers = self.active_transfers.clone();
        let config = self.config.clone();

        let transfers_clone = transfers.clone();
        let transfers_clone2 = transfers.clone();
        let handle = tokio::spawn(async move {
            if let Err(e) = Self::send_file_data(
                target_addr,
                file_path,
                transfer_id,
                request,
                transfers_clone,
                config,
            )
            .await
            {
                error!("File transfer failed: {}", e);

                // Update transfer status to failed
                {
                    let mut transfers = transfers_clone2.write().await;
                    if let Some(progress) = transfers.get_mut(&transfer_id) {
                        progress.status = TransferStatus::Failed;
                        progress.error_message = Some(e.to_string());
                        progress.end_time = Some(Utc::now());
                    }
                }
            }
        });

        // Store active transfer
        {
            let mut active_transfers = active_transfers.write().await;
            active_transfers.insert(transfer_id, handle);
        }

        Ok(transfer_id)
    }

    async fn send_file_data(
        target_addr: SocketAddr,
        file_path: PathBuf,
        transfer_id: Uuid,
        request: TransferRequest,
        transfers: Arc<RwLock<HashMap<Uuid, TransferProgress>>>,
        config: Config,
    ) -> Result<()> {
        let mut socket = TcpStream::connect(target_addr).await?;

        // Send transfer request
        let request_json = serde_json::to_string(&request)?;
        socket.write_all(request_json.as_bytes()).await?;
        socket.write_all(b"\n\n").await?;

        // Read response
        let mut response_buffer = Vec::new();
        let mut chunk = [0; 1024];

        loop {
            let n = socket.read(&mut chunk).await?;
            if n == 0 {
                break;
            }
            response_buffer.extend_from_slice(&chunk[..n]);

            if response_buffer.ends_with(b"\n\n") {
                break;
            }
        }

        let response_str = String::from_utf8_lossy(&response_buffer);
        let response: TransferResponse = serde_json::from_str(response_str.trim())?;

        if !response.success {
            return Err(anyhow::anyhow!("Transfer rejected: {}", response.message));
        }

        // Send file data
        let mut file = tokio::fs::File::open(&file_path).await?;
        let mut buffer = [0; 8192];
        let mut total_bytes = 0u64;
        let start_time = std::time::Instant::now();

        loop {
            let n = file.read(&mut buffer).await?;
            if n == 0 {
                break;
            }

            socket.write_all(&buffer[..n]).await?;
            total_bytes += n as u64;

            // Update progress
            {
                let mut transfers = transfers.write().await;
                if let Some(progress) = transfers.get_mut(&transfer_id) {
                    progress.bytes_transferred = total_bytes;

                    let elapsed = start_time.elapsed().as_secs_f64();
                    if elapsed > 0.0 {
                        progress.speed = total_bytes as f64 / elapsed;
                    }
                }
            }
        }

        // Mark transfer as completed
        {
            let mut transfers = transfers.write().await;
            if let Some(progress) = transfers.get_mut(&transfer_id) {
                progress.status = TransferStatus::Completed;
                progress.end_time = Some(Utc::now());
            }
        }

        info!("File transfer {} completed successfully", transfer_id);
        Ok(())
    }

    async fn calculate_file_checksum(file_path: &PathBuf) -> Result<String> {
        use sha2::{Digest, Sha256};

        let mut file = tokio::fs::File::open(file_path).await?;
        let mut hasher = Sha256::new();
        let mut buffer = [0; 8192];

        loop {
            let n = file.read(&mut buffer).await?;
            if n == 0 {
                break;
            }
            hasher.update(&buffer[..n]);
        }

        let result = hasher.finalize();
        Ok(hex::encode(result))
    }

    pub async fn get_transfer_progress(&self, transfer_id: Uuid) -> Option<TransferProgress> {
        let transfers = self.transfers.read().await;
        transfers.get(&transfer_id).cloned()
    }

    pub async fn get_all_transfers(&self) -> Vec<TransferProgress> {
        let transfers = self.transfers.read().await;
        transfers.values().cloned().collect()
    }

    pub async fn add_transfer(&self, progress: TransferProgress) {
        let mut transfers = self.transfers.write().await;
        transfers.insert(progress.id, progress);
    }

    pub async fn cancel_transfer(&self, transfer_id: Uuid) -> Result<bool> {
        // Cancel active transfer
        {
            let mut active_transfers = self.active_transfers.write().await;
            if let Some(handle) = active_transfers.remove(&transfer_id) {
                handle.abort();
            }
        }

        // Update transfer status
        {
            let mut transfers = self.transfers.write().await;
            if let Some(progress) = transfers.get_mut(&transfer_id) {
                progress.status = TransferStatus::Cancelled;
                progress.end_time = Some(Utc::now());
                return Ok(true);
            }
        }

        Ok(false)
    }

    pub async fn cleanup_completed_transfers(&self, max_age_hours: u64) -> Result<usize> {
        let cutoff = Utc::now() - chrono::Duration::hours(max_age_hours as i64);
        let mut removed = 0;

        {
            let mut transfers = self.transfers.write().await;
            transfers.retain(|_, progress| {
                if progress.status == TransferStatus::Completed
                    || progress.status == TransferStatus::Failed
                {
                    if let Some(end_time) = progress.end_time {
                        if end_time < cutoff {
                            removed += 1;
                            return false;
                        }
                    }
                }
                true
            });
        }

        Ok(removed)
    }
}

fn sanitize_filename(filename: &str) -> String {
    filename
        .chars()
        .map(|c| {
            if c.is_alphanumeric() || c == '.' || c == '-' || c == '_' {
                c
            } else {
                '_'
            }
        })
        .collect()
}
