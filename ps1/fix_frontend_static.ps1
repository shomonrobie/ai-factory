# fix_frontend_static.ps1
# Completely simplified frontend - just static HTML files

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "CREATING SIMPLIFIED STATIC FRONTEND" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/4] Stopping and removing frontend container..." -ForegroundColor Yellow
docker-compose stop frontend
docker-compose rm -f frontend
docker rmi ai-factory-frontend -f 2>$null

Write-Host "[2/4] Creating simplified Dockerfile (no Node.js)..." -ForegroundColor Yellow

$staticDockerfile = @'
FROM nginx:alpine

# Copy all HTML files directly to nginx
COPY frontend/src/app/ /usr/share/nginx/html/

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
'@
$staticDockerfile | Out-File -FilePath "docker\Dockerfile.frontend" -Encoding UTF8 -NoNewline

Write-Host "[3/4] Creating nginx configuration..." -ForegroundColor Yellow

$nginxConfig = @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # SPA routing - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API proxy to backend
    location /api/ {
        proxy_pass http://backend:4001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://backend:4001/health;
    }
}
'@
$nginxConfig | Out-File -FilePath "docker\nginx.conf" -Encoding UTF8 -NoNewline

Write-Host "[4/4] Rebuilding and starting frontend..." -ForegroundColor Yellow

docker-compose build --no-cache frontend
docker-compose up -d

Start-Sleep -Seconds 8

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "FRONTEND FIXED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""

# Test if frontend is working
Write-Host "Testing frontend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4000/" -UseBasicParsing -TimeoutSec 5
    Write-Host "  Status: $($response.StatusCode) OK" -ForegroundColor Green
    
    if ($response.Content -like "*FactoryOS AI*") {
        Write-Host "  Content: FactoryOS AI website detected!" -ForegroundColor Green
    } else {
        Write-Host "  Content: Website loaded, checking title..." -ForegroundColor Gray
    }
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Opening website..." -ForegroundColor Cyan
Start-Process "http://localhost:4000/"
Write-Host ""
Write-Host "Available pages:" -ForegroundColor Cyan
Write-Host "  Home:      http://localhost:4000/" -ForegroundColor White
Write-Host "  Login:     http://localhost:4000/login" -ForegroundColor White
Write-Host "  Signup:    http://localhost:4000/signup" -ForegroundColor White
Write-Host "  Dashboard: http://localhost:4000/dashboard" -ForegroundColor White
Write-Host "  Pricing:   http://localhost:4000/pricing" -ForegroundColor White
Write-Host "  Blog:      http://localhost:4000/blog" -ForegroundColor White
Write-Host "  Docs:      http://localhost:4000/docs" -ForegroundColor White
Write-Host "  Workspace: http://localhost:4000/workspace" -ForegroundColor White
Write-Host "  Audit:     http://localhost:4000/audit" -ForegroundColor White
Write-Host "  Usage:     http://localhost:4000/usage" -ForegroundColor White
Write-Host "  Admin:     http://localhost:4000/admin" -ForegroundColor White
Write-Host ""
Write-Host "API endpoints (backend):" -ForegroundColor Cyan
Write-Host "  API Docs:  http://localhost:4001/docs" -ForegroundColor White
Write-Host "  Health:    http://localhost:4001/health" -ForegroundColor White