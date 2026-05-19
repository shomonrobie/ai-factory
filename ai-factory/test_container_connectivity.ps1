# test_container_connectivity.ps1
Write-Host "Testing container connectivity..." -ForegroundColor Cyan

Write-Host "`n1. Check if backend is reachable from frontend container:" -ForegroundColor Yellow
docker exec ai-factory-frontend-1 sh -c "wget -qO- http://backend:4001/health 2>&1 | head -5"

Write-Host "`n2. Check DNS resolution from frontend:" -ForegroundColor Yellow
docker exec ai-factory-frontend-1 sh -c "nslookup backend 2>&1 || echo 'nslookup not available'"

Write-Host "`n3. Check if both containers are on same network:" -ForegroundColor Yellow
docker network inspect factoryos-network --format '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}'

Write-Host "`n4. Alternative - restart frontend and test again:" -ForegroundColor Yellow
docker-compose restart frontend
Start-Sleep -Seconds 5

try {
    $response = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/health" -TimeoutSec 5
    Write-Host "  SUCCESS: API is now working!" -ForegroundColor Green
} catch {
    Write-Host "  FAILED: API still not working" -ForegroundColor Red
}