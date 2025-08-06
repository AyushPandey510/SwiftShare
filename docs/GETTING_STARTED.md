# Getting Started with SwiftShare

Welcome to SwiftShare! This guide will help you set up and run the project on your local machine.

## 🚀 Quick Start

### Prerequisites

Before you begin, make sure you have the following installed:

- **Rust** (1.75+): [Install Rust](https://rustup.rs/)
- **Node.js** (18+): [Install Node.js](https://nodejs.org/)
- **Flutter** (3.19+): [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Git**: [Install Git](https://git-scm.com/)

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/swiftshare.git
cd swiftshare
```

### 2. Install Dependencies

```bash
# Install all dependencies
npm run install:all

# Or install individually:
npm run install:backend
npm run install:desktop
npm run install:web
```

### 3. Build the Backend

```bash
# Build the Rust backend
npm run build:backend

# Or directly:
cd backend
cargo build --release
```

### 4. Start Development Servers

```bash
# Start all services (backend + desktop + mobile)
npm run dev

# Or start individually:
npm run dev:backend    # Backend server
npm run dev:desktop    # Desktop app
npm run dev:mobile     # Mobile app
npm run dev:web        # Web interface
```

## 📱 Running Individual Components

### Backend (Rust)

The backend provides the core file transfer functionality.

```bash
cd backend

# Development mode
cargo run

# Production build
cargo build --release
./target/release/swiftshare-backend

# Run tests
cargo test

# Code formatting
cargo fmt

# Linting
cargo clippy
```

**Backend will be available at:**
- API: http://localhost:8080
- Transfer: localhost:8081
- Health Check: http://localhost:8080/health

### Desktop App (Electron + React)

The desktop application provides a native interface for file sharing.

```bash
cd desktop

# Install dependencies
npm install

# Development mode
npm run electron-dev

# Build for production
npm run electron-pack

# Run tests
npm test

# Linting
npm run lint
```

### Mobile App (Flutter)

The mobile app works on both iOS and Android.

```bash
cd mobile

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Build APK
flutter build apk --release

# Run tests
flutter test
```

### Web Interface (Next.js)

The web interface provides browser-based access.

```bash
cd web

# Install dependencies
npm install

# Development mode
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

**Web interface will be available at:** http://localhost:3000

## 🔧 Configuration

### Backend Configuration

The backend configuration is automatically created on first run:

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

**Configuration locations:**
- **Windows**: `%APPDATA%\swiftshare\config.json`
- **macOS**: `~/Library/Application Support/swiftshare/config.json`
- **Linux**: `~/.config/swiftshare/config.json`

### Environment Variables

Create a `.env` file in the desktop directory:

```env
REACT_APP_API_URL=http://localhost:8080
REACT_APP_WS_URL=ws://localhost:8080
```

## 🐳 Docker Support

### Build and Run with Docker

```bash
# Build the Docker image
docker build -t swiftshare .

# Run the container
docker run -p 8080:8080 -p 8081:8081 swiftshare

# Run with custom configuration
docker run -p 8080:8080 -p 8081:8081 \
  -v /path/to/downloads:/app/downloads \
  -v /path/to/config:/app/config \
  swiftshare
```

### Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  swiftshare:
    build: .
    ports:
      - "8080:8080"
      - "8081:8081"
    volumes:
      - ./downloads:/app/downloads
      - ./config:/app/config
    environment:
      - RUST_LOG=info
```

Run with:
```bash
docker-compose up -d
```

## 🧪 Testing

### Run All Tests

```bash
# Run all tests
npm test

# Run specific component tests
npm run test:backend
npm run test:desktop
npm run test:mobile
npm run test:web
```

### Backend Testing

```bash
cd backend

# Run tests
cargo test

# Run with coverage
cargo tarpaulin

# Run integration tests
cargo test --test integration
```

### Frontend Testing

```bash
cd desktop

# Run tests
npm test

# Run with coverage
npm test -- --coverage

# Run e2e tests
npm run test:e2e
```

## 🔍 Debugging

### Backend Debugging

```bash
# Run with debug logging
RUST_LOG=debug cargo run

# Run with trace logging
RUST_LOG=trace cargo run

# Attach debugger
rust-gdb target/debug/swiftshare-backend
```

### Desktop Debugging

```bash
# Run with DevTools
npm run electron-dev

# Debug main process
npm run electron-dev -- --inspect=5858
```

### Mobile Debugging

```bash
# Run with verbose logging
flutter run --verbose

# Debug mode
flutter run --debug

# Profile mode
flutter run --profile
```

## 📊 Monitoring

### Health Checks

```bash
# Check backend health
curl http://localhost:8080/health

# Check API status
curl http://localhost:8080/api/status

# Get discovered devices
curl http://localhost:8080/api/devices
```

### Logs

```bash
# Backend logs
RUST_LOG=info cargo run

# Desktop logs
# Check DevTools console

# Mobile logs
flutter logs
```

## 🚀 Production Deployment

### Backend Deployment

```bash
# Build for production
cargo build --release

# Create systemd service
sudo cp target/release/swiftshare-backend /usr/local/bin/
sudo cp scripts/swiftshare.service /etc/systemd/system/
sudo systemctl enable swiftshare
sudo systemctl start swiftshare
```

### Desktop Distribution

```bash
cd desktop

# Build for Windows
npm run dist:win

# Build for macOS
npm run dist:mac

# Build for Linux
npm run dist:linux
```

### Mobile Distribution

```bash
cd mobile

# Build Android APK
flutter build apk --release

# Build iOS (requires macOS)
flutter build ios --release
```

## 🐛 Troubleshooting

### Common Issues

1. **Backend won't start**
   ```bash
   # Check if ports are available
   netstat -tulpn | grep :8080
   netstat -tulpn | grep :8081
   
   # Check logs
   RUST_LOG=debug cargo run
   ```

2. **Devices not discovered**
   ```bash
   # Check network connectivity
   ping 192.168.1.1
   
   # Check firewall settings
   sudo ufw status
   ```

3. **File transfer fails**
   ```bash
   # Check disk space
   df -h
   
   # Check file permissions
   ls -la ~/Downloads/SwiftShare
   ```

4. **Desktop app won't start**
   ```bash
   # Clear Electron cache
   rm -rf ~/.config/SwiftShare
   
   # Reinstall dependencies
   npm install
   ```

5. **Mobile app crashes**
   ```bash
   # Clear Flutter cache
   flutter clean
   flutter pub get
   
   # Check device logs
   flutter logs
   ```

### Getting Help

1. **Check the logs**: Look for error messages in the console
2. **Verify dependencies**: Ensure all required software is installed
3. **Check network**: Ensure devices are on the same network
4. **Review configuration**: Verify settings in config files
5. **Update software**: Ensure you're using the latest versions

## 📚 Next Steps

1. **Explore the API**: Check out the [API Documentation](API.md)
2. **Customize the UI**: Modify the desktop and mobile interfaces
3. **Add features**: Implement new functionality
4. **Contribute**: Submit pull requests and issues
5. **Deploy**: Set up production environments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

For more information, see the [Contributing Guidelines](CONTRIBUTING.md).

---

**Happy coding! 🚀** 