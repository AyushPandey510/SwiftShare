# SwiftShare API Documentation

## Overview

The SwiftShare API provides endpoints for device discovery, file transfer management, and application status monitoring. All endpoints return JSON responses and support CORS.

## Base URL

```
http://localhost:8080
```

## Authentication

Currently, the API doesn't require authentication as it's designed for local network use. Future versions may include optional authentication for enhanced security.

## Endpoints

### Health Check

#### GET /health

Check the health status of the backend service.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "uptime": 3600
}
```

### Device Management

#### GET /api/devices

Get a list of discovered devices on the network.

**Response:**
```json
{
  "devices": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "iPhone 13",
      "type": "mobile",
      "ip": "192.168.1.100",
      "port": 8081,
      "lastSeen": "2024-01-15T10:30:00Z",
      "isOnline": true,
      "capabilities": ["file-transfer", "encryption"],
      "transferSpeed": 15.5
    }
  ],
  "count": 1,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Transfer Management

#### POST /api/transfer

Initiate a file transfer to a target device.

**Request Body:**
```json
{
  "id": "transfer-123",
  "files": [
    {
      "name": "document.pdf",
      "size": 1048576,
      "type": "document",
      "path": "/path/to/file",
      "checksum": "sha256-hash"
    }
  ],
  "targetDevice": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "ip": "192.168.1.100",
    "port": 8081
  },
  "encrypted": true,
  "compressed": false
}
```

**Response:**
```json
{
  "success": true,
  "transferId": "transfer-123",
  "status": "accepted",
  "message": "Transfer initiated successfully"
}
```

### Application Status

#### GET /api/status

Get the current status and configuration of the application.

**Response:**
```json
{
  "status": "running",
  "version": "1.0.0",
  "uptime": 3600,
  "localIp": "192.168.1.101",
  "config": {
    "transferPort": 8081,
    "apiPort": 8080,
    "downloadDir": "/downloads",
    "maxFileSize": 1073741824,
    "bufferSize": 8192
  }
}
```

## WebSocket Events

The backend also provides real-time updates via WebSocket connections.

### Connection

Connect to WebSocket at: `ws://localhost:8080`

### Events

#### Transfer Events

**transfer-started**
```json
{
  "type": "transfer-started",
  "transferId": "transfer-123",
  "data": {
    "files": [...],
    "targetDevice": {...}
  }
}
```

**transfer-progress**
```json
{
  "type": "transfer-progress",
  "transferId": "transfer-123",
  "data": {
    "progress": 45,
    "speed": 12.5,
    "bytesTransferred": 5242880,
    "totalBytes": 10485760
  }
}
```

**transfer-completed**
```json
{
  "type": "transfer-completed",
  "transferId": "transfer-123",
  "data": {
    "totalBytes": 10485760,
    "duration": 8.5
  }
}
```

**transfer-failed**
```json
{
  "type": "transfer-failed",
  "transferId": "transfer-123",
  "data": {
    "error": "Connection lost",
    "bytesTransferred": 5242880
  }
}
```

#### Device Events

**device-found**
```json
{
  "type": "device-found",
  "device": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "iPhone 13",
    "type": "mobile",
    "ip": "192.168.1.100",
    "port": 8081,
    "lastSeen": "2024-01-15T10:30:00Z",
    "isOnline": true,
    "capabilities": ["file-transfer", "encryption"]
  }
}
```

**device-lost**
```json
{
  "type": "device-lost",
  "device": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "iPhone 13"
  }
}
```

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200 OK` - Success
- `400 Bad Request` - Invalid request data
- `404 Not Found` - Endpoint not found
- `500 Internal Server Error` - Server error

Error responses include:
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

## Rate Limiting

Currently, no rate limiting is implemented as the API is designed for local network use.

## File Transfer Protocol

### TCP Transfer

File transfers use TCP connections on port 8081 by default.

**Transfer Process:**
1. Client connects to target device on transfer port
2. Client sends transfer metadata (filename, size, checksum)
3. Server responds with acceptance/rejection
4. If accepted, client streams file data
5. Server validates checksum and saves file
6. Transfer completion is confirmed

### Encryption

When encryption is enabled:
- Files are encrypted using AES-GCM
- Encryption key is negotiated during handshake
- Metadata is also encrypted

### Compression

When compression is enabled:
- Files are compressed using zstd
- Compression ratio is typically 20-60%
- Metadata includes original and compressed sizes

## Configuration

The backend configuration is stored in:
- **Windows**: `%APPDATA%\swiftshare\config.json`
- **macOS**: `~/Library/Application Support/swiftshare/config.json`
- **Linux**: `~/.config/swiftshare/config.json`

**Default Configuration:**
```json
{
  "bindAddress": "0.0.0.0",
  "transferPort": 8081,
  "apiPort": 8080,
  "downloadDir": "~/Downloads/SwiftShare",
  "databasePath": "~/.local/share/swiftshare/transfers.db",
  "encryptionKey": "auto-generated",
  "maxFileSize": 1073741824,
  "bufferSize": 8192,
  "discoveryTimeout": 30,
  "cleanupInterval": 60
}
```

## Security Considerations

1. **Local Network Only**: The API is designed for local network use only
2. **No Authentication**: Currently no authentication required
3. **File Validation**: All transferred files are validated using checksums
4. **Encryption**: Optional AES-GCM encryption for sensitive files
5. **Input Validation**: All inputs are validated and sanitized

## Troubleshooting

### Common Issues

1. **Devices not discovered**
   - Ensure devices are on the same network
   - Check firewall settings
   - Verify backend is running on all devices

2. **Transfer failures**
   - Check available disk space
   - Verify network connectivity
   - Check file permissions

3. **API connection issues**
   - Verify backend is running
   - Check port availability
   - Ensure CORS is properly configured

### Logs

Backend logs are available with different verbosity levels:
- `RUST_LOG=info` - Standard logging
- `RUST_LOG=debug` - Detailed debugging
- `RUST_LOG=trace` - Full trace logging

## Future Enhancements

1. **Authentication**: Optional API key authentication
2. **Rate Limiting**: Per-client rate limiting
3. **File Resume**: Resume interrupted transfers
4. **Group Transfers**: Transfer to multiple devices
5. **Web Interface**: Built-in web UI
6. **Mobile API**: RESTful API for mobile apps 