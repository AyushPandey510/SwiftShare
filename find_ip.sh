#!/bin/bash

echo "SwiftShare IP Address Finder"
echo "============================"
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    echo "Please install Python 3 and try again"
    exit 1
fi

# Make the script executable
chmod +x find_ip.py

# Run the IP finder script
python3 find_ip.py

echo
echo "Press Enter to exit..."
read 