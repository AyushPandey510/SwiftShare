# Real-Time File Sharing Setup Guide

This guide will help you set up real-time file sharing between devices using SwiftShare.

## Prerequisites

1. **Backend Server**: Make sure the Rust backend is running
2. **Network**: Both devices must be on the same local network
3. **Permissions**: The app needs storage and network permissions

## Setup Steps

### 1. Start the Backend Server

First, start the Rust backend server:

```bash
cd backend
cargo run
```

The server will start on port 8080 by default. You should see output like:
```
Starting SwiftShare Backend...
API Port: 8080
Transfer Port: 8081
```

### 2. Configure Network Settings

1. Open the SwiftShare app on both devices
2. Go to **Settings** → **Network Settings**
3. Tap **Auto-detect Server** to automatically find the backend
4. Or manually enter the backend IP address (e.g., `http://192.168.1.100:8080`)

### 3. Test Connection

1. In the Network Settings, tap **Test Connection**
2. You should see "Connection Successful" if everything is configured correctly

### 4. Start File Transfer

1. On the sending device:
   - Go to the **Home** tab
   - Tap **Send File**
   - Select a file to send
   - Choose the target device from the list

2. On the receiving device:
   - The file will appear in the **Transfers** tab
   - Tap to accept the transfer
   - The file will be saved to the Downloads folder

## Troubleshooting

### Backend Not Found

If auto-detection fails:

1. **Check IP Address**: Make sure both devices are on the same network
2. **Manual Configuration**: 
   - Find your computer's IP address
   - In the app, go to Settings → Network Settings → Backend Server
   - Enter: `http://YOUR_COMPUTER_IP:8080`

### Connection Failed

1. **Check Firewall**: Make sure port 8080 is not blocked
2. **Check Network**: Ensure both devices are on the same WiFi network
3. **Restart Backend**: Stop and restart the backend server

### File Transfer Issues

1. **Check Permissions**: Make sure the app has storage permissions
2. **Check Space**: Ensure there's enough storage space
3. **File Size**: Large files may take longer to transfer

## Network Configuration

### Finding Your Computer's IP Address

**Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter.

**Mac/Linux:**
```bash
ifconfig
```
Look for "inet" followed by your IP address.

### Common Network Ranges

- `192.168.1.x` - Most home routers
- `192.168.0.x` - Some home routers
- `10.0.0.x` - Some corporate networks
- `172.16.x.x` - Some networks

## Advanced Configuration

### Custom Backend URL

You can modify the backend URL in the app configuration:

1. Open `mobile/lib/config/app_config.dart`
2. Update the `backendBaseUrl` constant:
   ```dart
   static const String backendBaseUrl = 'http://YOUR_IP:8080';
   ```

### Backend Configuration

The backend can be configured in `backend/src/config.rs`:

- **API Port**: Default 8080
- **Transfer Port**: Default 8081
- **Download Directory**: Where received files are saved

## Features

### Real-Time Features

- ✅ **Live Progress**: Real-time transfer progress updates
- ✅ **WebSocket Communication**: Instant status updates
- ✅ **Device Discovery**: Automatic device detection
- ✅ **File Validation**: Checksum verification
- ✅ **Error Handling**: Robust error recovery

### Supported File Types

- Images: JPG, PNG, GIF, BMP, WebP
- Videos: MP4, AVI, MOV, MKV, WMV, FLV
- Audio: MP3, WAV, AAC, FLAC, OGG
- Documents: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX
- Archives: ZIP, RAR, 7Z
- Text: TXT, RTF

### Transfer Features

- **Resume Support**: Resume interrupted transfers
- **Speed Display**: Real-time transfer speed
- **Progress Tracking**: Detailed progress information
- **File Management**: Organize downloaded files
- **History**: View transfer history

## Security

- **Local Network Only**: All transfers happen on your local network
- **No Cloud Storage**: Files are never uploaded to external servers
- **Encryption Ready**: Framework supports file encryption (optional)
- **Privacy Focused**: No data collection or tracking

## Performance Tips

1. **Use WiFi**: Faster than mobile data
2. **Close Other Apps**: Free up system resources
3. **Large Files**: Consider file compression for very large files
4. **Network Quality**: Better WiFi = faster transfers

## Support

If you encounter issues:

1. Check the network settings in the app
2. Verify the backend server is running
3. Test the connection using the built-in test feature
4. Check the device logs for error messages

## Development

To modify the file transfer implementation:

- **Mobile App**: `mobile/lib/services/file_transfer_service.dart`
- **Backend API**: `backend/src/main.rs`
- **Transfer Engine**: `backend/src/transfer.rs`
- **Configuration**: `mobile/lib/config/app_config.dart` 