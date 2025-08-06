# SwiftShare Auto-Setup Guide

## 🚀 Automatic Backend Configuration

SwiftShare now automatically detects and configures the backend server when you start the app. No manual configuration required!

### What Happens When You Start the App

1. **Splash Screen**: The app shows a beautiful loading screen while detecting the network
2. **Auto-Detection**: SwiftShare automatically scans your network for the backend server
3. **Configuration**: If found, the backend is automatically configured
4. **Ready to Use**: The app starts and you can immediately begin sharing files

### Backend Detection Process

The app tries the following methods in order:

1. **Current Configuration**: Tests if the current backend URL is working
2. **Network Scan**: Scans your local network for devices running the backend
3. **Common URLs**: Tries common network configurations (192.168.1.100, etc.)

### If No Backend is Found

If no backend server is detected, the app will:
- Start in "offline mode"
- Show a disconnected status in Settings
- Allow you to manually detect the backend later

### Manual Configuration (Optional)

If you need to manually configure the backend:

1. Go to **Settings** → **Network Settings**
2. Tap **"Auto-detect Server"** to scan for the backend
3. The app will automatically apply the detected backend URL

### Troubleshooting

**Backend Not Found?**
- Make sure the backend server is running on your computer
- Ensure both devices are on the same network
- Check that the backend is running on port 8080

**Connection Issues?**
- Go to Settings → Network Settings → Test Connection
- Check your network information in Settings
- Try the "Auto-detect Server" option

### Quick Start

1. **Start the Backend**: Run the backend on your computer
2. **Install SwiftShare**: Install the app on your phone
3. **That's It!**: The app will automatically find and connect to the backend

No more manual URL configuration - SwiftShare handles everything automatically! 🎉

---

**Note**: The app will remember the detected backend URL for future use, making subsequent launches even faster. 