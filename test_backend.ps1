# Test SwiftShare Backend
Write-Host "Testing SwiftShare Backend..." -ForegroundColor Green

# Check if backend is running
Write-Host "Checking if backend is running on port 8081..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/health" -Method GET -TimeoutSec 5
    Write-Host "Backend is running!" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "Backend is not responding on port 8081" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Check if backend is running on port 8080
Write-Host "Checking if backend is running on port 8080..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -Method GET -TimeoutSec 5
    Write-Host "Backend is running on port 8080!" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "Backend is not responding on port 8080" -ForegroundColor Red
}

# Check running processes
Write-Host "Checking for SwiftShare processes..." -ForegroundColor Yellow
$processes = Get-Process | Where-Object { $_.ProcessName -like "*swiftshare*" -or $_.ProcessName -like "*cargo*" }
if ($processes) {
    Write-Host "Found processes:" -ForegroundColor Green
    $processes | Format-Table ProcessName, Id, CPU
} else {
    Write-Host "No SwiftShare processes found" -ForegroundColor Red
}

# Check ports
Write-Host "Checking ports 8080 and 8081..." -ForegroundColor Yellow
$ports = netstat -ano | Select-String ":808[01]"
if ($ports) {
    Write-Host "Found processes on ports:" -ForegroundColor Green
    $ports
} else {
    Write-Host "No processes found on ports 8080 or 8081" -ForegroundColor Red
} 