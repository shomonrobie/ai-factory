# fix_encoding_final.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FIXING CHARACTER ENCODING & CREATING 404 HANDLER" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/8] Creating 404 page..." -ForegroundColor Yellow

$error404Page = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - FactoryOS AI</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:Inter,sans-serif;background:#F7FAFC;}
        .header{background:#1A365D;color:white;padding:16px 0;position:sticky;top:0;}
        .header .container{max-width:1280px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;}
        .logo{font-size:24px;font-weight:bold;}
        .logo a{color:white;text-decoration:none;}
        .nav a{color:white;text-decoration:none;margin-left:20px;}
        .btn-outline{border:1px solid white;padding:8px 20px;border-radius:8px;}
        .btn-solid{background:#319795;padding:8px 20px;border-radius:8px;}
        .container{max-width:800px;margin:80px auto;padding:60px;background:white;border-radius:12px;text-align:center;}
        h1{font-size:80px;color:#1A365D;margin-bottom:20px;}
        .btn-home{background:#3182CE;color:white;padding:12px 30px;border:none;border-radius:8px;cursor:pointer;display:inline-block;margin-top:20px;text-decoration:none;}
        .footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
    </style>
</head>
<body>
    <header class="header">
        <div class="container">
            <div class="logo"><a href="/">FactoryOS AI</a></div>
            <nav class="nav">
                <a href="/#features">Features</a>
                <a href="/#agents">Agents</a>
                <a href="/pricing">Pricing</a>
                <a href="/docs">Docs</a>
                <a href="/blog">Blog</a>
                <a href="/admin">Admin</a>
                <a href="/login" class="btn-outline">Sign In</a>
                <a href="/signup" class="btn-solid">Get Started</a>
            </nav>
        </div>
    </header>
    <div class="container">
        <h1>404</h1>
        <h2>Page Under Construction</h2>
        <p>This page is currently being built. Our team is working on it!</p>
        <a href="/" class="btn-home">Return to Home</a>
    </div>
    <footer class="footer">
        <div class="container"><p>Copyright 2026 FactoryOS AI. All rights reserved.</p></div>
    </footer>
</body>
</html>
'@
$error404Page | Out-File -FilePath "frontend\src\app\404.html" -Encoding UTF8

Write-Host "[2/8] Creating nginx config..." -ForegroundColor Yellow

$nginxConfig404 = @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    error_page 404 /404.html;
    location = /404.html {
        root /usr/share/nginx/html;
        internal;
    }
    location / {
        try_files $uri $uri/ /index.html;
    }
    location /api/ {
        proxy_pass http://backend:4001;
        proxy_set_header Host $host;
    }
}
'@
$nginxConfig404 | Out-File -FilePath "docker\nginx.conf" -Encoding UTF8

Write-Host "[3/8] Creating nginx Dockerfile..." -ForegroundColor Yellow

$nginxDockerfile = @'
FROM nginx:alpine
COPY frontend/src/app/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
'@
$nginxDockerfile | Out-File -FilePath "docker\Dockerfile.frontend" -Encoding UTF8

Write-Host "[4/8] Creating blog placeholder pages..." -ForegroundColor Yellow

$blogPostTemplate = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Blog Post - FactoryOS AI</title></head>
<body><h1>Blog Post</h1><p>Coming soon!</p><a href="/blog">Back to Blog</a></body>
</html>
'@

$blogPosts = @("introducing-v1.5", "multi-agent-orchestration", "feedback-loop")
foreach ($post in $blogPosts) {
    $blogPostTemplate | Out-File -FilePath "frontend\src\app\blog\$post.html" -Encoding UTF8
}

Write-Host "[5/8] Creating doc placeholder pages..." -ForegroundColor Yellow

$docTemplate = @'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Documentation</title></head>
<body><h1>Documentation</h1><p>Coming soon!</p><a href="/docs">Back to Docs</a></body>
</html>
'@

$docPages = @("quickstart", "installation", "first-batch", "api/batches", "api/agents", "guides/agents", "guides/orchestration")
foreach ($page in $docPages) {
    $pagePath = "frontend\src\app\docs\$page.html"
    $pageDir = Split-Path $pagePath -Parent
    New-Item -ItemType Directory -Force -Path $pageDir | Out-Null
    $docTemplate | Out-File -FilePath $pagePath -Encoding UTF8
}

Write-Host "[6/8] Creating admin API..." -ForegroundColor Yellow

$adminApi = @'
from fastapi import APIRouter
router = APIRouter()
@router.get("/users")
async def get_users():
    return [{"id":1,"name":"Admin","email":"admin@factoryos.ai","tier":"enterprise"}]
@router.get("/stats")
async def get_stats():
    return {"total_users":1,"total_batches":0}
'@
$adminApi | Out-File -FilePath "backend\app\api\v1\admin_full.py" -Encoding UTF8

Write-Host "[7/8] Restarting containers..." -ForegroundColor Yellow
docker-compose down
docker-compose build --no-cache frontend
docker-compose up -d

Start-Sleep -Seconds 10

Write-Host "[8/8] Done!" -ForegroundColor Green
Write-Host ""
Write-Host "Website: http://localhost:4000/" -ForegroundColor Cyan
Write-Host "Admin: http://localhost:4000/admin" -ForegroundColor Cyan
Start-Process "http://localhost:4000/"
'@

# Save and run the new script
$cleanScript | Out-File -FilePath "fix_encoding_final.ps1" -Encoding UTF8 -NoNewline

Write-Host "Created fix_encoding_final.ps1 - Run it now:" -ForegroundColor Green
Write-Host ".\fix_encoding_final.ps1" -ForegroundColor Yellow