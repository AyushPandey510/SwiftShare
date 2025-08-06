#!/usr/bin/env python3
"""
SwiftShare IP Address Finder
This script helps you find your computer's IP address for backend configuration.
"""

import socket
import subprocess
import platform
import sys

def get_local_ip():
    """Get the local IP address of this computer."""
    try:
        # Connect to a remote address to determine local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception as e:
        print(f"Error getting local IP: {e}")
        return None

def get_network_info():
    """Get detailed network information."""
    system = platform.system()
    
    if system == "Windows":
        return get_windows_network_info()
    elif system == "Darwin":  # macOS
        return get_macos_network_info()
    else:  # Linux
        return get_linux_network_info()

def get_windows_network_info():
    """Get network information on Windows."""
    try:
        result = subprocess.run(['ipconfig'], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        return f"Error getting network info: {e}"

def get_macos_network_info():
    """Get network information on macOS."""
    try:
        result = subprocess.run(['ifconfig'], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        return f"Error getting network info: {e}"

def get_linux_network_info():
    """Get network information on Linux."""
    try:
        result = subprocess.run(['ip', 'addr'], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        return f"Error getting network info: {e}"

def main():
    print("=" * 50)
    print("SwiftShare IP Address Finder")
    print("=" * 50)
    print()
    
    # Get local IP
    local_ip = get_local_ip()
    
    if local_ip:
        print(f"✅ Your computer's IP address: {local_ip}")
        print()
        print("📱 Configure your mobile app with:")
        print(f"   Backend URL: http://{local_ip}:8080")
        print(f"   WebSocket URL: ws://{local_ip}:8080/ws")
        print()
        
        # Check if backend is running
        print("🔍 Checking if backend server is running...")
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2)
            result = sock.connect_ex((local_ip, 8080))
            sock.close()
            
            if result == 0:
                print("✅ Backend server is running on port 8080")
            else:
                print("❌ Backend server is not running on port 8080")
                print("   Start the backend with: cd backend && cargo run")
        except Exception as e:
            print(f"❌ Error checking backend: {e}")
    else:
        print("❌ Could not determine your IP address")
        print("   Please check your network connection")
    
    print()
    print("📋 Network Information:")
    print("-" * 30)
    network_info = get_network_info()
    print(network_info)
    
    print()
    print("🔧 Setup Instructions:")
    print("1. Start the backend server: cd backend && cargo run")
    print("2. Open SwiftShare app on your phone")
    print("3. Go to Settings → Network Settings")
    print("4. Enter the backend URL shown above")
    print("5. Test the connection")
    print()
    print("📖 For more help, see: mobile/REAL_TIME_SETUP.md")

if __name__ == "__main__":
    main() 