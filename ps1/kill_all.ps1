Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "KILLING PORT 4000 PROCESS AND RESTARTING" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

# Find and kill process using port 4000
Write-Host "[1/5] Finding process using port 4000..." -ForegroundColor Yellow
$processInfo = netstat -ano | findstr :4000 | findstr LISTENING
Write-Host "  $processInfo" -ForegroundColor Gray

if ($processInfo -match "LISTENING\s+(\d+)$") {
    $pid = $matches[1]
    Write-Host "  Killing process PID: $pid" -ForegroundColor Yellow
    taskkill /F /PID $pid 2>$null
    Start-Sleep -Seconds 2
}

# Also kill any Python HTTP servers
Write-Host "[2/5] Killing any Python HTTP servers..." -ForegroundColor Yellow
Get-Process python* -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "[3/5] Stopping all docker containers..." -ForegroundColor Yellow
docker-compose down

Write-Host "[4/5] Removing any hanging containers..." -ForegroundColor Yellow
docker ps -aq | ForEach-Object { docker stop $_ 2>$null; docker rm $_ 2>$null }

Write-Host "[5/5] Starting fresh..." -ForegroundColor Yellow
docker-compose up -d

Start-Sleep -Seconds 15

Write-Host ""
Write-Host "Testing API endpoints..." -ForegroundColor Yellow

$endpoints = @(
    "http://localhost:4001/health",
    "http://localhost:4001/api/v1/agents/",
    "http://localhost:4001/api/v1/admin/users"
)

foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-RestMethod -Uri $endpoint -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  $endpoint - OK" -ForegroundColor Green
    } catch {
        Write-Host "  $endpoint - FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Testing through nginx proxy (port 4000)..." -ForegroundColor Yellow

$proxyEndpoints = @(
    "http://localhost:4000/api/v1/health",
    "http://localhost:4000/api/v1/agents/",
    "http://localhost:4000/api/v1/admin/users"
)

foreach ($endpoint in $proxyEndpoints) {
    try {
        $response = Invoke-RestMethod -Uri $endpoint -TimeoutSec 5 -ErrorAction Stop
        Write-Host "   $endpoint - OK" -ForegroundColor Green
    } catch {
        Write-Host "   $endpoint - FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "RESTART COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Opening admin dashboard..." -ForegroundColor Cyan
Start-Process "http://localhost:4000/admin"
Start-Process "http://localhost:4001/docs"