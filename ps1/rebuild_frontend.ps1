# rebuild_frontend.ps1
# Completely rebuild frontend container with new files

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "REBUILDING FRONTEND CONTAINER" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/3] Stopping frontend container..." -ForegroundColor Yellow
docker-compose stop frontend

Write-Host "[2/3] Removing frontend container and image..." -ForegroundColor Yellow
docker-compose rm -f frontend
docker rmi ai-factory-frontend -f 2>$null

Write-Host "[3/3] Rebuilding frontend without cache..." -ForegroundColor Yellow
docker-compose build --no-cache frontend

Write-Host "Starting frontend..." -ForegroundColor Yellow
docker-compose up -d frontend

Start-Sleep -Seconds 10

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "FRONTEND REBUILT SUCCESSFULLY!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now opening the new website..." -ForegroundColor Yellow
Start-Process "http://localhost:4000/"