# SwiftShare Startup Script
Write-Host "🚀 Starting SwiftShare..." -ForegroundColor Green

# Function to check if a port is in use
function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("127.0.0.1", $Port)
        $connection.Close()
        return $true
    } catch {
        return $false
    }
}

# Function to kill process on port
function Stop-ProcessOnPort {
    param([int]$Port)
    $processes = netstat -ano | Select-String ":$Port\s" | ForEach-Object {
        ($_ -split '\s+')[-1]
    }
    foreach ($pid in $processes) {
        try {
            Stop-Process -Id $pid -Force
            Write-Host "Killed process $pid on port $Port" -ForegroundColor Yellow
        } catch {
            Write-Host "Failed to kill process $pid" -ForegroundColor Red
        }
    }
}

# Check and clear ports
Write-Host "Checking ports..." -ForegroundColor Yellow
$ports = @(8082, 8083, 8084)
foreach ($port in $ports) {
    if (Test-Port $port) {
        Write-Host "Port $port is in use. Clearing..." -ForegroundColor Yellow
        Stop-ProcessOnPort $port
        Start-Sleep -Seconds 2
    }
}

# Start backend
Write-Host "Starting SwiftShare Backend..." -ForegroundColor Cyan
$backendJob = Start-Job -ScriptBlock {
    Set-Location "C:\Users\pandey\SwiftShare\backend"
    cargo run
}

# Wait for backend to start
Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test backend health
Write-Host "Testing backend health..." -ForegroundColor Yellow
$maxRetries = 10
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8082/health" -Method GET -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Backend is running!" -ForegroundColor Green
            Write-Host "Health response: $($response.Content)" -ForegroundColor Cyan
            break
        }
    } catch {
        Write-Host "Backend not ready yet... (attempt $($retryCount + 1)/$maxRetries)" -ForegroundColor Yellow
        $retryCount++
        Start-Sleep -Seconds 3
    }
}

if ($retryCount -eq $maxRetries) {
    Write-Host "❌ Backend failed to start properly" -ForegroundColor Red
    Stop-Job $backendJob
    Remove-Job $backendJob
    exit 1
}

# Test API endpoints
Write-Host "Testing API endpoints..." -ForegroundColor Yellow
try {
    $devicesResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/devices" -Method GET -TimeoutSec 5
    Write-Host "✅ Devices endpoint working" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Devices endpoint not responding" -ForegroundColor Yellow
}

try {
    $statusResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/status" -Method GET -TimeoutSec 5
    Write-Host "✅ Status endpoint working" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Status endpoint not responding" -ForegroundColor Yellow
}

# Start desktop client (if npm is available)
Write-Host "Starting Desktop Client..." -ForegroundColor Cyan
try {
    Set-Location "C:\Users\pandey\SwiftShare\desktop"
    $desktopJob = Start-Job -ScriptBlock {
        Set-Location "C:\Users\pandey\SwiftShare\desktop"
        npm start
    }
    Write-Host "✅ Desktop client started" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Failed to start desktop client" -ForegroundColor Yellow
}

# Display status
Write-Host "`n📊 SwiftShare Status:" -ForegroundColor Green
Write-Host "Backend: http://localhost:8082" -ForegroundColor Cyan
Write-Host "Health: http://localhost:8082/health" -ForegroundColor Cyan
Write-Host "API: http://localhost:8082/api" -ForegroundColor Cyan
Write-Host "Desktop: http://localhost:3000" -ForegroundColor Cyan

Write-Host "`n🎉 SwiftShare is ready!" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop all services" -ForegroundColor Yellow

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 30
        # Check if backend is still running
        try {
            $health = Invoke-WebRequest -Uri "http://localhost:8082/health" -Method GET -TimeoutSec 5
            Write-Host "✅ Backend is healthy" -ForegroundColor Green
        } catch {
            Write-Host "❌ Backend is not responding" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "`n🛑 Stopping SwiftShare..." -ForegroundColor Yellow
    Stop-Job $backendJob -ErrorAction SilentlyContinue
    Remove-Job $backendJob -ErrorAction SilentlyContinue
    if ($desktopJob) {
        Stop-Job $desktopJob -ErrorAction SilentlyContinue
        Remove-Job $desktopJob -ErrorAction SilentlyContinue
    }
    Write-Host "SwiftShare stopped" -ForegroundColor Green
} 