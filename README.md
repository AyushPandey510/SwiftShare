# SwiftShare 🚀

A modern, cross-platform file sharing application built with Rust, React, and Flutter.

## 🌟 Features

- **Cross-Platform**: Desktop (Electron/React), Mobile (Flutter), Web (Next.js)
- **Real-Time File Sharing**: Live progress updates and instant file transfers
- **Fast Transfers**: Optimized file transfer with progress tracking
- **Device Discovery**: Automatic network device discovery
- **Encryption**: Optional file encryption for security
- **Real-time Updates**: WebSocket-based real-time communication
- **Modern UI**: Beautiful, responsive interface
- **Multi-Protocol**: Support for various file transfer protocols
- **Network Auto-Detection**: Automatically find and configure backend servers on your network
- **Zero Configuration**: No manual setup required - works out of the box

## 🏗️ Architecture

```
SwiftShare/
├── backend/          # Rust backend (API, transfer engine, discovery)
├── desktop/          # Electron/React desktop app
├── mobile/           # Flutter mobile app
├── web/              # Next.js web interface
├── shared/           # Shared TypeScript types
└── docs/             # Documentation
```

## 🚀 Quick Start

### Prerequisites

- **Rust** (1.70+): [Install Rust](https://rustup.rs/)
- **Node.js** (18+): [Install Node.js](https://nodejs.org/)
- **npm** or **yarn**
- **Flutter** (3.0+): [Install Flutter](https://flutter.dev/docs/get-started/install)

### 1. Clone and Setup

```bash
git clone <repository-url>
cd SwiftShare
```

### 2. Start Backend

```bash
cd backend
cargo run
```

The backend will start on `http://localhost:8080`

**For Real-Time File Sharing:**
The mobile app now automatically detects and configures the backend! No manual setup required.

1. **Start Backend**: `cd backend && cargo run`
2. **Install Mobile App**: The app will automatically find and connect to the backend
3. **Start Sharing**: You're ready to share files!

See `mobile/AUTO_SETUP_GUIDE.md` for more details about the automatic configuration.

### 3. Start Desktop Client

```bash
cd desktop
npm install
npm start
```

The desktop app will open at `http://localhost:3000`

### 4. Start Mobile App (Optional)

```bash
cd mobile
flutter pub get
flutter run
```

## 🔄 Real-Time File Sharing

SwiftShare now supports real-time file sharing between devices on your local network!

### Key Features

- **Live Progress Updates**: See real-time transfer progress
- **WebSocket Communication**: Instant status updates
- **Auto-Detection**: Automatically find backend servers
- **File Validation**: Checksum verification for data integrity
- **Resume Support**: Resume interrupted transfers
- **Speed Display**: Real-time transfer speed monitoring

### Quick Setup

1. **Start Backend**: `cd backend && cargo run`
2. **Install Mobile App**: The app automatically detects and connects to the backend
3. **Start Sharing**: Begin sharing files immediately!
3. **Configure Mobile**: Open app → Settings → Network Settings → Enter backend URL
4. **Start Transfer**: Select files and choose target device

### Supported File Types

- **Images**: JPG, PNG, GIF, BMP, WebP
- **Videos**: MP4, AVI, MOV, MKV, WMV, FLV
- **Audio**: MP3, WAV, AAC, FLAC, OGG
- **Documents**: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX
- **Archives**: ZIP, RAR, 7Z
- **Text**: TXT, RTF

For detailed setup instructions, see: [Real-Time Setup Guide](mobile/REAL_TIME_SETUP.md)

## 🛠️ Development

### Backend (Rust)

```bash
cd backend
cargo run          # Run in development mode
cargo test         # Run tests
cargo build        # Build for production
```

**API Endpoints:**
- `GET /health` - Health check
- `GET /api/status` - Server status
- `GET /api/devices` - List discovered devices
- `POST /api/transfer` - Start file transfer

### Desktop (Electron/React)

```bash
cd desktop
npm install        # Install dependencies
npm start          # Start development server
npm run build      # Build for production
npm run electron   # Run Electron app
```

### Mobile (Flutter)

```bash
cd mobile
flutter pub get    # Install dependencies
flutter run        # Run on connected device/emulator
flutter build apk  # Build Android APK
flutter build ios  # Build iOS app
```

## 📱 Usage

### Desktop App

1. **Launch**: Start the desktop application
2. **Discover Devices**: The app automatically scans for nearby devices
3. **Select Files**: Choose files to share
4. **Send**: Select target device and start transfer
5. **Monitor**: Track transfer progress in real-time

### Mobile App

1. **Install**: Install the mobile app
2. **Connect**: Connect to the same network as other devices
3. **Share**: Select files and choose recipient
4. **Receive**: Accept incoming file transfers

## 🔧 Configuration

### Backend Configuration

The backend configuration is stored in `backend/src/config.rs`:

```rust
pub struct Config {
    pub bind_address: String,      // Server bind address
    pub api_port: u16,            // API server port
    pub transfer_port: u16,        // File transfer port
    pub database_path: PathBuf,    // Database file path
    pub encryption_key: String,    // Encryption key
    pub max_file_size: u64,       // Maximum file size
    // ... more options
}
```

### Desktop Configuration

Edit `desktop/src/store/store.js` to configure:

- API endpoint URL
- WebSocket connection
- File transfer settings

## 🧪 Testing

### Backend Tests

```bash
cd backend
cargo test
```

### Desktop Tests

```bash
cd desktop
npm test
```

### Mobile Tests

```bash
cd mobile
flutter test
```

## 📊 API Documentation

### Health Check

```bash
curl http://localhost:8082/health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": "2025-07-28T11:04:02.870482400+00:00",
  "message": "SwiftShare Backend is running!"
}
```

### Get Devices

```bash
curl http://localhost:8082/api/devices
```

Response:
```json
{
  "devices": [
    {
      "id": "uuid",
      "name": "Device Name",
      "ip": "192.168.1.100",
      "port": 8083,
      "type": "desktop",
      "capabilities": ["file-transfer", "encryption"]
    }
  ],
  "count": 1
}
```

### Start Transfer

```bash
curl -X POST http://localhost:8082/api/transfer \
  -H "Content-Type: application/json" \
  -d '{
    "id": "transfer-uuid",
    "filename": "example.txt",
    "size": 1024,
    "checksum": "sha256-hash",
    "encrypted": false
  }'
```

## 🚀 Deployment

### Backend Deployment

1. **Build for production**:
   ```bash
   cd backend
   cargo build --release
   ```

2. **Run with Docker**:
   ```bash
   docker build -t swiftshare-backend .
   docker run -p 8082:8082 swiftshare-backend
   ```

### Desktop Deployment

1. **Build Electron app**:
   ```bash
   cd desktop
   npm run build
   npm run electron:build
   ```

### Mobile Deployment

1. **Build APK**:
   ```bash
   cd mobile
   flutter build apk --release
   ```

2. **Build iOS**:
   ```bash
   cd mobile
   flutter build ios --release
   ```

## 🔒 Security

- **Encryption**: Optional AES-256-GCM encryption
- **Network Security**: TLS/SSL support
- **File Validation**: Checksum verification
- **Access Control**: Device authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/your-repo/issues)
- **Documentation**: [Wiki](https://github.com/your-repo/wiki)
- **Discussions**: [GitHub Discussions](https://github.com/your-repo/discussions)

## 🎯 Roadmap

- [ ] Web interface (Next.js)
- [ ] Cloud sync integration
- [ ] Advanced encryption options
- [ ] File compression
- [ ] Transfer scheduling
- [ ] Multi-device sync
- [ ] Offline mode
- [ ] Plugin system

---

**SwiftShare** - Fast, secure, and simple file sharing across all your devices! 🚀 #   S w i f t S h a r e  
 