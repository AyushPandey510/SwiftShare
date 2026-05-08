use anyhow::Result;
use chrono::Utc;
use futures::stream::SplitSink;
use futures::{SinkExt, StreamExt, TryStreamExt};
use serde_json::json;
use std::convert::Infallible;
use std::sync::Arc;
use std::{collections::HashMap, path::PathBuf};
use tokio::sync::RwLock;
use tracing::{error, info};
use warp::Filter;
// use warp::multipart;  // Commented out as it's not directly used
use warp::ws::{Message, WebSocket, Ws};

mod config;
mod database;
mod discovery;
mod encryption;
mod qr;
mod transfer;

use config::Config;
use database::TransferDatabase;
use discovery::DeviceDiscovery;
use transfer::TransferEngine;

use uuid::Uuid; // Needed for transfer_id and parsing

type ClientSender = SplitSink<WebSocket, Message>;

#[derive(Clone)]
struct UploadedFile {
    id: String,
    code: String,
    filename: String,
    size: usize,
    content_type: String,
    path: PathBuf,
    uploaded_at: String,
    expires_at: String,
}

#[derive(Clone)]
struct AppState {
    config: Config,
    transfer_engine: Arc<TransferEngine>,
    device_discovery: Arc<DeviceDiscovery>,
    database: Arc<TransferDatabase>,
    websocket_clients: Arc<RwLock<HashMap<String, ClientSender>>>,
    uploaded_files: Arc<RwLock<HashMap<String, UploadedFile>>>,
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .with_target(false)
        .with_thread_ids(true)
        .with_thread_names(true)
        .init();

    info!("Starting SwiftShare Backend...");

    let config = Config::load()?;
    info!("Configuration loaded successfully");
    info!("API Port: {}", config.api_port);
    info!("Transfer Port: {}", config.transfer_port);

    let transfer_engine = Arc::new(TransferEngine::new(config.clone()).await?);
    let device_discovery = Arc::new(DeviceDiscovery::new(config.clone()).await?);
    let database = Arc::new(TransferDatabase::new(&config.database_path).await?);

    let app_state = AppState {
        config: config.clone(),
        transfer_engine,
        device_discovery,
        database,
        websocket_clients: Arc::new(RwLock::new(HashMap::new())),
        uploaded_files: Arc::new(RwLock::new(HashMap::new())),
    };

    let device_discovery_clone = app_state.device_discovery.clone();
    tokio::spawn(async move {
        if let Err(e) = device_discovery_clone.start_discovery().await {
            error!("Device discovery failed: {}", e);
        }
    });

    let transfer_engine_clone = app_state.transfer_engine.clone();
    tokio::spawn(async move {
        if let Err(e) = transfer_engine_clone.start_server().await {
            error!("Transfer server failed: {}", e);
        }
    });

    start_api_server(app_state).await?;

    Ok(())
}

async fn start_api_server(state: AppState) -> Result<()> {
    let state = Arc::new(state);

    let health = warp::path("health").and(warp::get()).map(|| {
        warp::reply::json(&json!({
            "status": "healthy",
            "timestamp": Utc::now().to_rfc3339(),
            "message": "SwiftShare Backend is running!"
        }))
    });

    let status = warp::path("status").and(warp::get()).map(|| {
        warp::reply::json(&json!({
            "status": "running",
            "version": env!("CARGO_PKG_VERSION"),
            "uptime": std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap_or_default()
                .as_secs()
        }))
    });

    let devices = warp::path!("api" / "devices")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_devices);

    let transfer = warp::path!("api" / "transfer")
        .and(warp::post())
        .and(warp::multipart::form())
        .and(with_state(state.clone()))
        .and_then(create_transfer_multipart);

    let transfer_status = warp::path!("api" / "transfer" / String)
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_transfer_status);

    let upload = warp::path!("api" / "upload")
        .and(warp::post())
        .and(warp::multipart::form())
        .and(with_state(state.clone()))
        .and_then(upload_file_multipart);

    let ws = warp::path("ws")
        .and(warp::ws())
        .and(with_state(state.clone()))
        .map(|ws: Ws, state: Arc<AppState>| {
            ws.on_upgrade(move |socket| handle_websocket(socket, state))
        });

    let download = warp::path!("api" / "download" / String)
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(download_file);

    let file_by_code = warp::path!("api" / "file" / String)
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_file_by_code);

    let transfers_history = warp::path!("api" / "transfers")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_transfers_history);

    let cors = warp::cors()
        .allow_any_origin()
        .allow_methods(vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"])
        .allow_headers(vec![
            "Content-Type",
            "Authorization",
            "Content-Length",
            "Accept",
            "Accept-Encoding",
            "X-CSRF-Token",
            "X-Requested-With",
        ]);

    let routes = health
        .or(status)
        .or(devices)
        .or(transfer)
        .or(transfer_status)
        .or(upload)
        .or(ws)
        .or(download)
        .or(file_by_code)
        .or(transfers_history)
        .with(cors);

    info!(
        "Starting API server on {}:{}",
        state.config.bind_address, state.config.api_port
    );
    info!(
        "Server will be available at {}/health",
        state.config.public_base_url()
    );
    info!("Press Ctrl+C to stop the server");

    let bind_address: std::net::IpAddr = state
        .config
        .bind_address
        .parse()
        .unwrap_or_else(|_| [0, 0, 0, 0].into());
    warp::serve(routes)
        .run((bind_address, state.config.api_port))
        .await;
    Ok(())
}

fn with_state(
    state: Arc<AppState>,
) -> impl Filter<Extract = (Arc<AppState>,), Error = Infallible> + Clone {
    warp::any().map(move || state.clone())
}

// Dummy stubs to resolve unresolved functions. Replace with actual implementations.
async fn get_devices(state: Arc<AppState>) -> Result<impl warp::Reply, warp::Rejection> {
    let devices = state.device_discovery.get_devices().await;
    Ok(warp::reply::json(&json!({
        "devices": devices,
        "count": devices.len(),
        "timestamp": Utc::now().to_rfc3339()
    })))
}

async fn get_transfer_status(
    transfer_id: String,
    state: Arc<AppState>,
) -> Result<impl warp::Reply, warp::Rejection> {
    if let Some(progress) = state
        .transfer_engine
        .get_transfer_progress(Uuid::parse_str(&transfer_id).unwrap_or_default())
        .await
    {
        Ok(warp::reply::json(&json!({
            "transferId": transfer_id,
            "progress": progress,
            "status": "active"
        })))
    } else {
        Ok(warp::reply::json(&json!({
            "transferId": transfer_id,
            "status": "not_found"
        })))
    }
}

async fn upload_file_multipart(
    form: warp::multipart::FormData,
    state: Arc<AppState>,
) -> Result<impl warp::Reply, warp::Rejection> {
    use bytes::Buf;

    info!("Starting file upload processing");

    let mut filename = String::new();
    let mut file_data = Vec::new();

    // Process multipart form data
    info!("Collecting multipart form parts");
    let parts: Vec<Result<warp::multipart::Part, warp::Error>> = form.collect().await;

    for part_result in parts {
        match part_result {
            Ok(mut part) => {
                let name = part.name().to_string();
                info!("Processing part: {}", name);
                match name.as_str() {
                    "file" => {
                        // Get filename from the part's filename method
                        if let Some(part_filename) = part.filename() {
                            filename = part_filename.to_string();
                            info!("File filename: {}", filename);
                        } else {
                            // If no filename from part, generate one
                            filename = format!("upload_{}.bin", Uuid::new_v4());
                            info!("Generated filename: {}", filename);
                        }

                        // Collect file data
                        info!("Starting to collect file data");
                        while let Some(chunk_result) = part.data().await {
                            match chunk_result {
                                Ok(chunk_data) => {
                                    let chunk_size = chunk_data.chunk().len();
                                    file_data.extend_from_slice(chunk_data.chunk());
                                    info!(
                                        "Collected chunk of {} bytes, total so far: {}",
                                        chunk_size,
                                        file_data.len()
                                    );
                                }
                                Err(e) => {
                                    error!("Failed to read file chunk: {}", e);
                                    return Ok(warp::reply::json(&json!({
                                        "success": false,
                                        "error": "Failed to read file data"
                                    })));
                                }
                            }
                        }
                        info!(
                            "Finished collecting file data, total size: {}",
                            file_data.len()
                        );
                    }
                    _ => {
                        // Consume other fields to avoid hanging
                        info!("Consuming non-file part: {}", name);
                        while let Some(_) = part.data().await {}
                    }
                }
            }
            Err(e) => {
                error!("Multipart form error: {}", e);
                return Ok(warp::reply::json(&json!({
                    "success": false,
                    "error": "Invalid multipart form data"
                })));
            }
        }
    }

    if !file_data.is_empty() {
        info!("File data is not empty, size: {}", file_data.len());
        let file_path = state.config.download_dir.join(&filename);
        let size = file_data.len();

        info!("Upload directory: {:?}", state.config.download_dir);
        info!("File path: {:?}", file_path);

        // Ensure upload directory exists
        if let Err(e) = tokio::fs::create_dir_all(&state.config.download_dir).await {
            error!("Failed to create upload directory: {}", e);
            return Ok(warp::reply::json(&json!({
                "success": false,
                "error": "Failed to create upload directory"
            })));
        }

        // Save file
        info!("Attempting to save file");
        if let Err(e) = tokio::fs::write(&file_path, file_data).await {
            error!("Error saving file: {}", e);
            return Ok(warp::reply::json(&json!({
                "success": false,
                "error": "Failed to save file"
            })));
        }

        // Generate file code (6-digit number)
        let file_code = format!("{:06}", rand::random::<u32>() % 1000000);
        let file_id = Uuid::new_v4().to_string();

        info!("File uploaded successfully: {} ({} bytes)", filename, size);
        info!("Returning success response");

        let public_base_url = state.config.public_base_url();
        let uploaded_at = Utc::now();
        let expires_at = uploaded_at + chrono::Duration::hours(24);
        let uploaded_file = UploadedFile {
            id: file_id,
            code: file_code.clone(),
            filename,
            size,
            content_type: "application/octet-stream".to_string(),
            path: file_path,
            uploaded_at: uploaded_at.to_rfc3339(),
            expires_at: expires_at.to_rfc3339(),
        };

        state
            .uploaded_files
            .write()
            .await
            .insert(file_code, uploaded_file.clone());

        let file_payload = json!({
            "id": &uploaded_file.id,
            "code": &uploaded_file.code,
            "filename": &uploaded_file.filename,
            "size": uploaded_file.size,
            "type": &uploaded_file.content_type,
            "url": format!("{}/api/download/{}", public_base_url, &uploaded_file.code),
            "qrUrl": format!("{}/api/qr/{}", public_base_url, &uploaded_file.code),
            "expiresAt": &uploaded_file.expires_at,
            "downloadCount": 0,
            "maxDownloads": 1,
            "uploadedAt": &uploaded_file.uploaded_at,
            "uploadedBy": "guest"
        });

        let response = json!({
            "success": true,
            "data": file_payload.clone(),
            "file": file_payload
        });

        info!("Response prepared: {}", response);
        Ok(warp::reply::json(&response))
    } else {
        info!("No file data provided");
        Ok(warp::reply::json(&json!({
            "success": false,
            "error": "No file provided"
        })))
    }
}

async fn get_transfers_history(state: Arc<AppState>) -> Result<impl warp::Reply, warp::Rejection> {
    let transfers = state.transfer_engine.get_all_transfers().await;

    let transfer_data: Vec<serde_json::Value> = transfers
        .iter()
        .map(|t| {
            json!({
                "id": t.id.to_string(),
                "filename": t.filename,
                "bytes_transferred": t.bytes_transferred,
                "total_bytes": t.total_bytes,
                "speed": t.speed,
                "status": match t.status {
                    crate::transfer::TransferStatus::Pending => "pending",
                    crate::transfer::TransferStatus::InProgress => "in_progress",
                    crate::transfer::TransferStatus::Completed => "completed",
                    crate::transfer::TransferStatus::Failed => "failed",
                    crate::transfer::TransferStatus::Cancelled => "cancelled",
                },
                "start_time": t.start_time.to_rfc3339(),
                "end_time": t.end_time.map(|t| t.to_rfc3339()),
                "error_message": t.error_message,
            })
        })
        .collect();

    Ok(warp::reply::json(&json!({
        "transfers": transfer_data,
        "count": transfer_data.len(),
        "timestamp": Utc::now().to_rfc3339()
    })))
}

async fn handle_websocket(ws: WebSocket, state: Arc<AppState>) {
    let (ws_sender, mut ws_receiver) = ws.split();
    let client_id = Uuid::new_v4().to_string();

    {
        let mut clients = state.websocket_clients.write().await;
        clients.insert(client_id.clone(), ws_sender);
    }

    info!("WebSocket client connected: {}", client_id);

    while let Some(result) = ws_receiver.next().await {
        match result {
            Ok(msg) => {
                if let Ok(text) = msg.to_str() {
                    info!("Received WebSocket message: {}", text);
                    // Handle different message types here
                }
            }
            Err(e) => {
                error!("WebSocket error: {}", e);
                break;
            }
        }
    }

    {
        let mut clients = state.websocket_clients.write().await;
        clients.remove(&client_id);
    }

    info!("WebSocket client disconnected: {}", client_id);
}

async fn create_transfer_multipart(
    form: warp::multipart::FormData,
    state: Arc<AppState>,
) -> Result<impl warp::Reply, warp::Rejection> {
    use bytes::Buf;

    let mut transfer_id = String::new();
    let mut target_device_id = String::new();
    let mut file_name = String::new();
    let mut file_size = 0u64;
    let mut file_field = None;

    // Collect all parts first
    let parts: Vec<warp::multipart::Part> = form
        .try_collect()
        .await
        .map_err(|_| warp::reject::custom(TransferError))?;

    for mut part in parts {
        let name = part.name().to_string();
        match name.as_str() {
            "transferId" => {
                if let Some(Ok(data)) = part.data().await {
                    transfer_id = String::from_utf8_lossy(data.chunk()).to_string();
                }
            }
            "targetDeviceId" => {
                if let Some(Ok(data)) = part.data().await {
                    target_device_id = String::from_utf8_lossy(data.chunk()).to_string();
                }
            }
            "fileName" => {
                if let Some(Ok(data)) = part.data().await {
                    file_name = String::from_utf8_lossy(data.chunk()).to_string();
                }
            }
            "fileSize" => {
                if let Some(Ok(data)) = part.data().await {
                    let size_str = String::from_utf8_lossy(data.chunk());
                    file_size = size_str.parse().unwrap_or(0);
                }
            }
            "file" => {
                file_field = Some(part);
            }
            _ => {}
        }
    }

    // If we don't have a transfer ID, generate one
    if transfer_id.is_empty() {
        transfer_id = Uuid::new_v4().to_string();
    }

    info!(
        "Received multipart transfer request: {} -> {}",
        file_name, target_device_id
    );

    // Create transfer progress
    let progress = crate::transfer::TransferProgress {
        id: Uuid::parse_str(&transfer_id).unwrap_or_else(|_| Uuid::new_v4()),
        filename: file_name.clone(),
        bytes_transferred: 0,
        total_bytes: file_size,
        speed: 0.0,
        status: crate::transfer::TransferStatus::Pending,
        start_time: Utc::now(),
        end_time: None,
        error_message: None,
    };

    state.transfer_engine.add_transfer(progress.clone()).await;

    // Handle file data if present
    if let Some(mut file_part) = file_field {
        let file_path = state.config.download_dir.join(&file_name);

        // Ensure download directory exists
        if let Err(e) = tokio::fs::create_dir_all(&state.config.download_dir).await {
            error!("Failed to create download directory: {}", e);
            return Ok(warp::reply::json(&json!({
                "success": false,
                "error": "Failed to create download directory"
            })));
        }

        // Save file
        match save_file_from_multipart(&mut file_part, &file_path).await {
            Ok(_) => {
                // Update transfer status to completed
                let mut progress_completed = progress.clone();
                progress_completed.status = crate::transfer::TransferStatus::Completed;
                progress_completed.bytes_transferred = file_size;
                progress_completed.end_time = Some(Utc::now());
                state.transfer_engine.add_transfer(progress_completed).await;

                info!("File transfer {} completed successfully", transfer_id);

                Ok(warp::reply::json(&json!({
                    "success": true,
                    "transferId": transfer_id,
                    "status": "completed",
                    "message": "Transfer completed successfully"
                })))
            }
            Err(e) => {
                error!("Failed to save file: {}", e);

                // Update transfer status to failed
                let mut progress_failed = progress.clone();
                progress_failed.status = crate::transfer::TransferStatus::Failed;
                progress_failed.error_message = Some(e.to_string());
                progress_failed.end_time = Some(Utc::now());
                state.transfer_engine.add_transfer(progress_failed).await;

                Ok(warp::reply::json(&json!({
                    "success": false,
                    "error": e.to_string()
                })))
            }
        }
    } else {
        // No file data, just metadata
        let message = json!({
            "type": "transfer_started",
            "transferId": transfer_id,
            "filename": file_name,
            "targetDeviceId": target_device_id
        });

        if let Ok(message_str) = serde_json::to_string(&message) {
            let mut clients = state.websocket_clients.write().await;
            for (_, client) in clients.iter_mut() {
                if let Err(e) = client.send(Message::text(message_str.clone())).await {
                    error!("Failed to send WebSocket message: {}", e);
                }
            }
        }

        Ok(warp::reply::json(&json!({
            "success": true,
            "transferId": transfer_id,
            "status": "accepted",
            "message": "Transfer initiated successfully"
        })))
    }
}

async fn save_file_from_multipart(
    file_part: &mut warp::multipart::Part,
    file_path: &std::path::Path,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    use bytes::Buf;
    use tokio::io::AsyncWriteExt;

    let mut file = tokio::fs::File::create(file_path).await?;

    // Read all data from the part
    while let Some(Ok(data)) = file_part.data().await {
        file.write_all(data.chunk()).await?;
    }

    file.flush().await?;
    Ok(())
}

#[derive(Debug)]
struct TransferError;

impl warp::reject::Reject for TransferError {}

async fn download_file(
    code: String,
    state: Arc<AppState>,
) -> Result<impl warp::Reply, warp::Rejection> {
    let uploaded_file = {
        let uploaded_files = state.uploaded_files.read().await;
        uploaded_files.get(&code).cloned()
    };

    let Some(uploaded_file) = uploaded_file else {
        return Ok(warp::http::Response::builder()
            .status(warp::http::StatusCode::NOT_FOUND)
            .header("Content-Type", "application/json")
            .body(
                json!({
                    "success": false,
                    "error": "File not found"
                })
                .to_string()
                .into_bytes(),
            )
            .unwrap());
    };

    match tokio::fs::read(&uploaded_file.path).await {
        Ok(contents) => Ok(warp::http::Response::builder()
            .status(warp::http::StatusCode::OK)
            .header("Content-Type", uploaded_file.content_type.as_str())
            .header(
                "Content-Disposition",
                format!("attachment; filename=\"{}\"", uploaded_file.filename),
            )
            .body(contents)
            .unwrap()),
        Err(e) => {
            error!("Failed to read uploaded file {}: {}", uploaded_file.code, e);
            Ok(warp::http::Response::builder()
                .status(warp::http::StatusCode::NOT_FOUND)
                .header("Content-Type", "application/json")
                .body(
                    json!({
                        "success": false,
                        "error": "File not found"
                    })
                    .to_string()
                    .into_bytes(),
                )
                .unwrap())
        }
    }
}

async fn get_file_by_code(
    code: String,
    state: Arc<AppState>,
) -> Result<impl warp::Reply, warp::Rejection> {
    let uploaded_file = {
        let uploaded_files = state.uploaded_files.read().await;
        uploaded_files.get(&code).cloned()
    };

    if let Some(uploaded_file) = uploaded_file {
        let public_base_url = state.config.public_base_url();
        Ok(warp::reply::json(&json!({
            "success": true,
            "data": {
                "id": &uploaded_file.id,
                "code": &uploaded_file.code,
                "filename": &uploaded_file.filename,
                "size": uploaded_file.size,
                "type": &uploaded_file.content_type,
                "url": format!("{}/api/download/{}", public_base_url, code),
                "qrUrl": format!("{}/api/qr/{}", public_base_url, code),
                "expiresAt": &uploaded_file.expires_at,
                "downloadCount": 0,
                "maxDownloads": 1,
                "uploadedAt": &uploaded_file.uploaded_at,
                "uploadedBy": "guest"
            }
        })))
    } else {
        Ok(warp::reply::json(&json!({
            "success": false,
            "error": "File not found"
        })))
    }
}
