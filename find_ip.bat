@echo off
echo SwiftShare IP Address Finder
echo ============================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Run the IP finder script
python find_ip.py

echo.
echo Press any key to exit...
pause >nul 