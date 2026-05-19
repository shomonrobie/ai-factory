# debug_backend.ps1
Write-Host "DEBUGGING BACKEND API" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "`n[1] Checking if backend is running..." -ForegroundColor Yellow
docker-compose ps backend

Write-Host "`n[2] Checking backend logs for errors..." -ForegroundColor Yellow
docker-compose logs backend --tail=50

Write-Host "`n[3] Testing API directly on backend port (4001)..." -ForegroundColor Yellow

try {
    $health = Invoke-RestMethod -Uri "http://localhost:4001/health" -TimeoutSec 5
    Write-Host "  Health check: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "  Health check FAILED: $_" -ForegroundColor Red
}

try {
    $agents = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/agents/" -TimeoutSec 5
    Write-Host "  Agents API: WORKING - Found $($agents.agents.Count) agents" -ForegroundColor Green
} catch {
    Write-Host "  Agents API: FAILED" -ForegroundColor Red
}

try {
    $admin = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/admin/users" -TimeoutSec 5
    Write-Host "  Admin API: WORKING" -ForegroundColor Green
} catch {
    Write-Host "  Admin API: FAILED - $_" -ForegroundColor Red
}

Write-Host "`n[4] Checking if admin endpoint exists in backend..." -ForegroundColor Yellow
docker-compose exec backend ls -la /app/backend/app/api/v1/ 2>$null

Write-Host "`n[5] Restarting backend and checking again..." -ForegroundColor Yellow
docker-compose restart backend
Start-Sleep -Seconds 10

try {
    $admin2 = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/admin/users" -TimeoutSec 5
    Write-Host "  Admin API after restart: WORKING" -ForegroundColor Green
} catch {
    Write-Host "  Admin API after restart: STILL FAILED" -ForegroundColor Red
}