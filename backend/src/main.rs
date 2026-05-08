use anyhow::Result;
use chrono::Utc;
use futures::stream::SplitSink;
use futures::{SinkExt, StreamExt, TryStreamExt};
use serde_json::json;
use std::convert::Infallible;
use std::sync::Arc;
use std::{collections::HashMap, path::PathBuf};
use tokio::io::AsyncWriteExt;
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
use qr::QRCodeManager;
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
        .and(warp::body::content_length_limit(
            state.config.max_file_size + 1024 * 1024,
        ))
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

    let qr_code = warp::path!("api" / "qr" / String)
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_qr_code);

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
        .or(qr_code)
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

    let mut parts = form;

    while let Some(part_result) = parts.next().await {
        match part_result {
            Ok(mut part) => {
                let name = part.name().to_string();
                info!("Processing part: {}", name);
                match name.as_str() {
                    "file" => {
                        let filename = part
                            .filename()
                            .map(sanitize_filename)
                            .unwrap_or_else(|| format!("upload_{}.bin", Uuid::new_v4()));
                        let content_type = part
                            .content_type()
                            .unwrap_or("application/octet-stream")
                            .to_string();

                        let file_code = loop {
                            let code = format!("{:06}", rand::random::<u32>() % 1000000);
                            let candidate_path = state
                                .config
                                .download_dir
                                .join(format!("{}_{}", &code, &filename));
                            if tokio::fs::metadata(&candidate_path).await.is_err() {
                                break code;
                            }
                        };

                        let file_path = state
                            .config
                            .download_dir
                            .join(format!("{}_{}", &file_code, &filename));

                        info!("Streaming upload for file: {}", filename);
                        info!("Upload directory: {:?}", state.config.download_dir);

                        if let Err(e) = tokio::fs::create_dir_all(&state.config.download_dir).await
                        {
                            error!("Failed to create upload directory: {}", e);
                            return Ok(warp::reply::json(&json!({
                                "success": false,
                                "error": "Failed to create upload directory"
                            })));
                        }

                        let mut file = match tokio::fs::File::create(&file_path).await {
                            Ok(file) => file,
                            Err(e) => {
                                error!("Error creating file: {}", e);
                                return Ok(warp::reply::json(&json!({
                                    "success": false,
                                    "error": "Failed to save file"
                                })));
                            }
                        };

                        let mut size = 0usize;
                        while let Some(chunk_result) = part.data().await {
                            let chunk_data = match chunk_result {
                                Ok(chunk_data) => chunk_data,
                                Err(e) => {
                                    error!("Failed to read file chunk: {}", e);
                                    let _ = tokio::fs::remove_file(&file_path).await;
                                    return Ok(warp::reply::json(&json!({
                                        "success": false,
                                        "error": "Failed to read file data"
                                    })));
                                }
                            };

                            let chunk = chunk_data.chunk();
                            size += chunk.len();

                            if size as u64 > state.config.max_file_size {
                                error!(
                                    "Upload exceeded max file size: {} > {}",
                                    size, state.config.max_file_size
                                );
                                let _ = tokio::fs::remove_file(&file_path).await;
                                return Ok(warp::reply::json(&json!({
                                    "success": false,
                                    "error": "File too large"
                                })));
                            }

                            if let Err(e) = file.write_all(chunk).await {
                                error!("Error writing file chunk: {}", e);
                                let _ = tokio::fs::remove_file(&file_path).await;
                                return Ok(warp::reply::json(&json!({
                                    "success": false,
                                    "error": "Failed to save file"
                                })));
                            }
                        }

                        if let Err(e) = file.flush().await {
                            error!("Error flushing file: {}", e);
                            let _ = tokio::fs::remove_file(&file_path).await;
                            return Ok(warp::reply::json(&json!({
                                "success": false,
                                "error": "Failed to save file"
                            })));
                        }

                        if size == 0 {
                            info!("No file data provided");
                            let _ = tokio::fs::remove_file(&file_path).await;
                            return Ok(warp::reply::json(&json!({
                                "success": false,
                                "error": "No file provided"
                            })));
                        }

                        let file_id = Uuid::new_v4().to_string();

                        info!("File uploaded successfully: {} ({} bytes)", filename, size);

                        let public_base_url = state.config.public_base_url();
                        let uploaded_at = Utc::now();
                        let expires_at = uploaded_at + chrono::Duration::hours(24);
                        let uploaded_file = UploadedFile {
                            id: file_id,
                            code: file_code.clone(),
                            filename,
                            size,
                            content_type,
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

                        return Ok(warp::reply::json(&json!({
                            "success": true,
                            "data": file_payload.clone(),
                            "file": file_payload
                        })));
                    }
                    _ => {
                        info!("Consuming non-file part: {}", name);
                        while part.data().await.is_some() {}
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

    info!("No file part provided");
    Ok(warp::reply::json(&json!({
        "success": false,
        "error": "No file provided"
    })))
}

fn sanitize_filename(filename: &str) -> String {
    let candidate = std::path::Path::new(filename)
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or("upload.bin")
        .trim();

    if candidate.is_empty() {
        format!("upload_{}.bin", Uuid::new_v4())
    } else {
        candidate
            .chars()
            .map(|c| match c {
                '/' | '\\' | '\0' => '_',
                _ => c,
            })
            .collect()
    }
}

async fn locate_uploaded_file_by_code(state: &AppState, code: &str) -> Option<UploadedFile> {
    {
        let uploaded_files = state.uploaded_files.read().await;
        if let Some(uploaded_file) = uploaded_files.get(code).cloned() {
            return Some(uploaded_file);
        }
    }

    let prefix = format!("{}_", code);
    if let Ok(mut dir) = tokio::fs::read_dir(&state.config.download_dir).await {
        while let Ok(Some(entry)) = dir.next_entry().await {
            let file_name = entry.file_name().to_string_lossy().to_string();
            if file_name.starts_with(&prefix) {
                let file_path = entry.path();
                if let Ok(metadata) = tokio::fs::metadata(&file_path).await {
                    let filename = file_name[prefix.len()..].to_string();
                    let found = UploadedFile {
                        id: Uuid::new_v4().to_string(),
                        code: code.to_string(),
                        filename: filename.clone(),
                        size: metadata.len() as usize,
                        content_type: "application/octet-stream".to_string(),
                        path: file_path.clone(),
                        uploaded_at: Utc::now().to_rfc3339(),
                        expires_at: Utc::now().to_rfc3339(),
                    };

                    state
                        .uploaded_files
                        .write()
                        .await
                        .insert(code.to_string(), found.clone());

                    return Some(found);
                }
            }
        }
    }

    None
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
    use tokio_util::codec::{BytesCodec, FramedRead};

    let uploaded_file = locate_uploaded_file_by_code(&state, &code).await;

    let Some(uploaded_file) = uploaded_file else {
        return Ok(warp::http::Response::builder()
            .status(warp::http::StatusCode::NOT_FOUND)
            .header("Content-Type", "application/json")
            .body(warp::hyper::Body::from(
                json!({
                    "success": false,
                    "error": "File not found"
                })
                .to_string(),
            ))
            .unwrap());
    };

    match tokio::fs::File::open(&uploaded_file.path).await {
        Ok(file) => {
            let stream = FramedRead::new(file, BytesCodec::new()).map_ok(|bytes| bytes.freeze());
            let body = warp::hyper::Body::wrap_stream(stream);

            Ok(warp::http::Response::builder()
                .status(warp::http::StatusCode::OK)
                .header("Content-Type", uploaded_file.content_type.as_str())
                .header(
                    "Content-Disposition",
                    format!("attachment; filename=\"{}\"", uploaded_file.filename),
                )
                .body(body)
                .unwrap())
        }
        Err(e) => {
            error!("Failed to read uploaded file {}: {}", uploaded_file.code, e);
            Ok(warp::http::Response::builder()
                .status(warp::http::StatusCode::NOT_FOUND)
                .header("Content-Type", "application/json")
                .body(warp::hyper::Body::from(
                    json!({
                        "success": false,
                        "error": "File not found"
                    })
                    .to_string(),
                ))
                .unwrap())
        }
    }
}

async fn get_file_by_code(
    code: String,
    state: Arc<AppState>,
) -> Result<impl warp::Reply, warp::Rejection> {
    let uploaded_file = locate_uploaded_file_by_code(&state, &code).await;

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

async fn get_qr_code(
    code: String,
    state: Arc<AppState>,
) -> Result<impl warp::Reply, warp::Rejection> {
    let uploaded_file = locate_uploaded_file_by_code(&state, &code).await;

    let Some(uploaded_file) = uploaded_file else {
        return Ok(warp::http::Response::builder()
            .status(warp::http::StatusCode::NOT_FOUND)
            .header("Content-Type", "application/json")
            .body(
                json!({
                    "success": false,
                    "error": "File not found"
                })
                .to_string(),
            )
            .unwrap());
    };

    let public_base_url = state.config.public_base_url();
    let download_url = format!("{}/api/download/{}", public_base_url, uploaded_file.code);

    match QRCodeManager::generate_text_qr(&download_url) {
        Ok(svg) => Ok(warp::http::Response::builder()
            .status(warp::http::StatusCode::OK)
            .header("Content-Type", "image/svg+xml")
            .body(svg)
            .unwrap()),
        Err(e) => {
            error!(
                "Failed to generate QR code for {}: {}",
                uploaded_file.code, e
            );
            Ok(warp::http::Response::builder()
                .status(warp::http::StatusCode::INTERNAL_SERVER_ERROR)
                .header("Content-Type", "application/json")
                .body(
                    json!({
                        "success": false,
                        "error": "Failed to generate QR code"
                    })
                    .to_string(),
                )
                .unwrap())
        }
    }
}
