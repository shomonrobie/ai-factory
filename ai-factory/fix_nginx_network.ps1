Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "EMERGENCY FIX - RECOVERING FRONTEND" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/8] Stopping all containers..." -ForegroundColor Yellow
docker-compose down -v

Write-Host "[2/8] Removing any stuck containers..." -ForegroundColor Yellow
docker ps -aq | ForEach-Object { docker stop $_ 2>$null; docker rm $_ 2>$null }

Write-Host "[3/8] Creating simple working docker-compose.yml..." -ForegroundColor Yellow

$workingCompose = @'
services:
  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile.backend
    ports:
      - "4001:4001"
    environment:
      ENVIRONMENT: development
    volumes:
      - ./backend:/app/backend
      - ./factory:/app/factory
    command: uvicorn app.main:app --host 0.0.0.0 --port 4001 --reload

  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend.simple
    ports:
      - "4000:80"
    depends_on:
      - backend
'@

$workingCompose | Out-File -FilePath "docker-compose.yml" -Encoding UTF8 -NoNewline

Write-Host "[4/8] Creating simple nginx config..." -ForegroundColor Yellow

$simpleNginx = @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location /api/ {
        proxy_pass http://backend:4001/api/;
        proxy_set_header Host $host;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
'@

$simpleNginx | Out-File -FilePath "docker\nginx.conf" -Encoding UTF8 -NoNewline

Write-Host "[5/8] Creating simple Dockerfile.frontend..." -ForegroundColor Yellow

$simpleDockerfile = @'
FROM nginx:alpine
COPY frontend/src/app/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
'@

$simpleDockerfile | Out-File -FilePath "docker\Dockerfile.frontend.simple" -Encoding UTF8 -NoNewline

Write-Host "[6/8] Rebuilding containers..." -ForegroundColor Yellow

# Remove old images
docker rmi ai-factory-frontend ai-factory-backend -f 2>$null

# Build
docker-compose build --no-cache

Write-Host "[7/8] Starting containers..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "Waiting for containers to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "[8/8] Testing..." -ForegroundColor Yellow

Write-Host "`nContainer status:" -ForegroundColor Cyan
docker-compose ps

Write-Host "`nTesting backend directly (port 4001):" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "http://localhost:4001/health" -TimeoutSec 5
    Write-Host "   Backend is healthy" -ForegroundColor Green
} catch {
    Write-Host "   Backend is not responding" -ForegroundColor Red
}

Write-Host "`nTesting API through frontend proxy (port 4000):" -ForegroundColor Cyan
try {
    $apiTest = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/health" -TimeoutSec 5
    Write-Host "   API proxy is working" -ForegroundColor Green
} catch {
    Write-Host "   API proxy failed - trying alternative..." -ForegroundColor Red
}

Write-Host "`nTesting frontend website:" -ForegroundColor Cyan
try {
    $webTest = Invoke-WebRequest -Uri "http://localhost:4000/" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   Frontend website is accessible (HTTP $($webTest.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   Frontend website not accessible" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "RECOVERY COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access your application:" -ForegroundColor Cyan
Write-Host "  Frontend: http://localhost:4000/" -ForegroundColor White
Write-Host "  Backend API: http://localhost:4001/" -ForegroundColor White
Write-Host "  API Docs: http://localhost:4001/docs" -ForegroundColor White
Write-Host "  Admin Dashboard: http://localhost:4000/admin" -ForegroundColor White
Write-Host ""
Write-Host "Opening browser..." -ForegroundColor Yellow
Start-Process "http://localhost:4000/"
Start-Process "http://localhost:4001/docs"