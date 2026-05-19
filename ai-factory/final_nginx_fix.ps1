# final_nginx_fix.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FINAL NGINX FIX" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/4] Creating correct nginx configuration..." -ForegroundColor Yellow

$correctNginxConfig = @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # API proxy - must be first
    location ~ ^/api/ {
        proxy_pass http://backend:4001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Remove /api prefix when proxying
        rewrite ^/api/(.*) /$1 break;
        
        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
        
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization';
            add_header 'Content-Length' 0;
            return 204;
        }
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Error pages
    error_page 404 /404.html;
    location = /404.html {
        root /usr/share/nginx/html;
        internal;
    }
}
'@

$correctNginxConfig | Out-File -FilePath "docker\nginx.conf" -Encoding UTF8 -NoNewline

Write-Host "[2/4] Rebuilding frontend container with new nginx config..." -ForegroundColor Yellow

docker-compose stop frontend
docker-compose rm -f frontend
docker rmi ai-factory-frontend -f 2>$null
docker-compose build --no-cache frontend
docker-compose up -d frontend

Start-Sleep -Seconds 10

Write-Host "[3/4] Testing API through nginx..." -ForegroundColor Yellow

$testEndpoints = @(
    "/api/v1/health",
    "/api/v1/agents/",
    "/api/v1/admin/users"
)

foreach ($endpoint in $testEndpoints) {
    try {
        $url = "http://localhost:4000$endpoint"
        Write-Host "  Testing: $url" -ForegroundColor Gray
        $response = Invoke-RestMethod -Uri $url -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  $endpoint - SUCCESS" -ForegroundColor Green
    } catch {
        Write-Host "  $endpoint - FAILED: $_" -ForegroundColor Red
    }
}

Write-Host "[4/4] Final check..." -ForegroundColor Yellow

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "FIX APPLIED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now test these URLs in your browser:" -ForegroundColor Cyan
Write-Host "  http://localhost:4000/api/v1/health" -ForegroundColor White
Write-Host "  http://localhost:4000/api/v1/agents/" -ForegroundColor White
Write-Host "  http://localhost:4000/api/v1/admin/users" -ForegroundColor White
Write-Host ""
Write-Host "If these work, then refresh the admin dashboard:" -ForegroundColor Yellow
Write-Host "  http://localhost:4000/admin" -ForegroundColor White
Write-Host ""
Write-Host "Then do a hard refresh (Ctrl+Shift+R)" -ForegroundColor Yellow

Start-Process "http://localhost:4000/api/v1/health"