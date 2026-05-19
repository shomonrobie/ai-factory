# fix_nginx_proxy.ps1
Write-Host "Fixing nginx proxy configuration..." -ForegroundColor Cyan

cd D:\aisfs\ai-factory

$nginxConfigFixed = @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # API proxy - this must come BEFORE the location / block
    location /api/ {
        proxy_pass http://backend:4001/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
        
        # Handle preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization';
            add_header 'Content-Length' 0;
            return 204;
        }
    }

    # SPA routing - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location = /404.html {
        root /usr/share/nginx/html;
        internal;
    }
}
'@

$nginxConfigFixed | Out-File -FilePath "docker\nginx.conf" -Encoding UTF8 -NoNewline

Write-Host "Restarting frontend..." -ForegroundColor Yellow
docker-compose restart frontend

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Testing API through nginx proxy..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/admin/users" -TimeoutSec 5
    Write-Host "  API proxy working! Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Green
} catch {
    Write-Host "  API proxy still failing" -ForegroundColor Red
}

Write-Host ""
Write-Host "Opening admin dashboard..." -ForegroundColor Cyan
Start-Process "http://localhost:4000/admin"