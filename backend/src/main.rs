// Fixed Rust backend code for SwiftShare with all errors resolved

use tracing::{info, error};
use anyhow::Result;
use tokio::sync::RwLock;
use warp::Filter;
use warp::ws::{Message, WebSocket, Ws};
use futures::{SinkExt, StreamExt};
use futures::stream::SplitSink;
use serde_json::json;
use chrono::Utc;
use std::collections::HashMap;
use std::sync::Arc;

mod transfer;
mod discovery;
mod encryption;
mod database;
mod qr;
mod config;

use config::Config;
use transfer::TransferEngine;
use discovery::DeviceDiscovery;
use database::TransferDatabase;

use uuid::Uuid; // Needed for transfer_id and parsing

use warp::http::Response; // Optional, if needed for custom responses

use std::convert::Infallible;

type ClientSender = SplitSink<WebSocket, Message>;

#[derive(Clone)]
struct AppState {
    config: Config,
    transfer_engine: Arc<TransferEngine>,
    device_discovery: Arc<DeviceDiscovery>,
    database: Arc<TransferDatabase>,
    websocket_clients: Arc<RwLock<HashMap<String, ClientSender>>>,
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

    let health = warp::path("health")
        .and(warp::get())
        .map(|| warp::reply::json(&json!({
            "status": "healthy",
            "timestamp": Utc::now().to_rfc3339(),
            "message": "SwiftShare Backend is running!"
        })));

    let status = warp::path("status")
        .and(warp::get())
        .map(|| warp::reply::json(&json!({
            "status": "running",
            "version": env!("CARGO_PKG_VERSION"),
            "uptime": std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap_or_default()
                .as_secs()
        })));

    let devices = warp::path!("api" / "devices")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_devices);

    let transfer = warp::path!("api" / "transfer")
        .and(warp::post())
        .and(warp::body::json())
        .and(with_state(state.clone()))
        .and_then(create_transfer);

    let transfer_status = warp::path!("api" / "transfer" / String)
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_transfer_status);

    let upload = warp::path!("api" / "upload")
        .and(warp::post())
        .and(warp::body::bytes())
        .and(with_state(state.clone()))
        .and_then(upload_file_simple);

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

    let transfers_history = warp::path!("api" / "transfers")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_transfers_history);

    let cors = warp::cors()
        .allow_any_origin()
        .allow_methods(vec!["GET", "POST", "PUT", "DELETE"])
        .allow_headers(vec!["Content-Type", "Authorization"]);

    let routes = health
        .or(status)
        .or(devices)
        .or(transfer)
        .or(transfer_status)
        .or(upload)
        .or(ws)
        .or(download)
        .or(transfers_history)
        .with(cors);

    info!("Starting API server on port {}", state.config.api_port);
    info!("Server will be available at http://localhost:{}/health", state.config.api_port);
    info!("Press Ctrl+C to stop the server");

    warp::serve(routes).run(([127, 0, 0, 1], state.config.api_port)).await;
    Ok(())
}

fn with_state(state: Arc<AppState>) -> impl Filter<Extract = (Arc<AppState>,), Error = Infallible> + Clone {
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
    state: Arc<AppState>
) -> Result<impl warp::Reply, warp::Rejection> {
    if let Some(progress) = state.transfer_engine.get_transfer_progress(Uuid::parse_str(&transfer_id).unwrap_or_default()).await {
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


async fn upload_file_simple(
    body: bytes::Bytes,
    state: Arc<AppState>
) -> Result<impl warp::Reply, warp::Rejection> {
    let filename = format!("upload_{}.bin", Uuid::new_v4());
    let file_path = state.config.download_dir.join(&filename);
    let size = body.len();

    if let Err(e) = tokio::fs::write(&file_path, body).await {
        error!("Error saving file: {}", e);
        return Ok(warp::reply::json(&json!({
            "success": false,
            "error": "Failed to save file"
        })));
    }

    Ok(warp::reply::json(&json!({
        "success": true,
        "filename": filename,
        "size": size
    })))
}


async fn get_transfers_history(
    state: Arc<AppState>
) -> Result<impl warp::Reply, warp::Rejection> {
    let transfers = state.transfer_engine.get_all_transfers().await;

    let transfer_data: Vec<serde_json::Value> = transfers.iter().map(|t| {
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
    }).collect();

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

async fn create_transfer(
    transfer_request: serde_json::Value,
    state: Arc<AppState>
) -> Result<impl warp::Reply, warp::Rejection> {
    let transfer_id_value = transfer_request["transferId"].as_str().map(|s| s.to_string()).unwrap_or_else(|| Uuid::new_v4().to_string());
    let transfer_id = transfer_id_value.clone();
    let target_device_id = transfer_request["targetDeviceId"].as_str().unwrap_or("");
    let file_name = transfer_request["fileName"].as_str().unwrap_or("unknown");
    let file_size = transfer_request["fileSize"].as_str().unwrap_or("0").parse::<u64>().unwrap_or(0);

    info!("Received transfer request: {} -> {}", file_name, target_device_id);

    let progress = crate::transfer::TransferProgress {
        id: Uuid::parse_str(&transfer_id).unwrap_or_else(|_| Uuid::new_v4()),
        filename: file_name.to_string(),
        bytes_transferred: 0,
        total_bytes: file_size,
        speed: 0.0,
        status: crate::transfer::TransferStatus::Pending,
        start_time: Utc::now(),
        end_time: None,
        error_message: None,
    };

    state.transfer_engine.add_transfer(progress).await;

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

async fn download_file(
    _transfer_id: String,
    state: Arc<AppState>
) -> Result<impl warp::Reply, warp::Rejection> {
    let file_path = state.config.download_dir.join("sample.txt");

    if let Ok(contents) = tokio::fs::read_to_string(&file_path).await {
        Ok(warp::reply::with_header(
            contents,
            "Content-Type",
            "text/plain",
        ))
    } else {
        let sample_content = "This is a sample file for testing file transfer.
";
        if tokio::fs::write(&file_path, sample_content).await.is_ok() {
            Ok(warp::reply::with_header(
                sample_content.to_string(),
                "Content-Type",
                "text/plain",
            ))
        } else {
            Err(warp::reject::not_found())
        }
    }
}
