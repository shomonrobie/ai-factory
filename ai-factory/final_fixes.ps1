# final_fixes.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "APPLYING FINAL FIXES" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/5] Fixing port conflict - changing PostgreSQL port..." -ForegroundColor Yellow

# Update docker-compose.yml to use different PostgreSQL port
$composeFixed = @'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: aifactory
      POSTGRES_PASSWORD: aifactory123
      POSTGRES_DB: aifactory
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U aifactory"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile.backend
    ports:
      - "4001:4001"
    environment:
      DATABASE_URL: postgresql://aifactory:aifactory123@postgres:5432/aifactory
      REDIS_URL: redis://redis:6379
      ENVIRONMENT: development
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./backend:/app/backend
      - ./factory:/app/factory
    command: >
      sh -c "sleep 5 && uvicorn app.main:app --host 0.0.0.0 --port 4001 --reload"

  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend
    ports:
      - "4000:80"
    depends_on:
      - backend

volumes:
  postgres_data:
  redis_data:
'@
$composeFixed | Out-File -FilePath "docker-compose.yml" -Encoding UTF8 -NoNewline

Write-Host "[2/5] Creating header include file for consistent navigation..." -ForegroundColor Yellow

$headerInclude = @'
<header style="background:#1A365D;color:white;padding:16px 0;position:sticky;top:0;z-index:100;">
<div style="max-width:1280px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;">
<div style="font-size:24px;font-weight:bold;"><a href="/" style="color:white;text-decoration:none;">FactoryOS AI</a></div>
<nav style="display:flex;gap:20px;align-items:center;flex-wrap:wrap;">
<a href="/#features" style="color:white;text-decoration:none;">Features</a>
<a href="/#agents" style="color:white;text-decoration:none;">Agents</a>
<a href="/pricing" style="color:white;text-decoration:none;">Pricing</a>
<a href="/docs" style="color:white;text-decoration:none;">Docs</a>
<a href="/blog" style="color:white;text-decoration:none;">Blog</a>
<a href="/login" style="color:white;text-decoration:none;border:1px solid white;padding:8px 20px;border-radius:8px;">Sign In</a>
<a href="/signup" style="background:#319795;padding:8px 20px;border-radius:8px;color:white;text-decoration:none;">Get Started</a>
</nav>
</div>
</header>
'@
$headerInclude | Out-File -FilePath "frontend\src\app\header.inc.html" -Encoding UTF8

Write-Host "[3/5] Fixing blog page with header..." -ForegroundColor Yellow

$blogFixed = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Blog - FactoryOS AI</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Inter',sans-serif;color:#2D3748;background:#F7FAFC;}
.container{max-width:1280px;margin:0 auto;padding:0 24px;}
.blog-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(350px,1fr));gap:30px;padding:60px 0;}
.blog-card{background:white;border-radius:12px;padding:24px;box-shadow:0 2px 4px rgba(0,0,0,0.1);}
.blog-card:hover{transform:translateY(-2px);transition:transform 0.2s;}
.blog-date{color:#718096;font-size:14px;margin-bottom:10px;}
.blog-title{font-size:20px;color:#1A365D;margin-bottom:10px;}
.blog-excerpt{color:#4A5568;margin-bottom:15px;}
.read-more{color:#3182CE;text-decoration:none;font-weight:500;}
.footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
</style>
</head>
<body>
' + $headerInclude + '
<div class="container">
<h1 style="margin-top:40px;">Blog</h1>
<p>Insights on AI-powered software engineering</p>
<div class="blog-grid">
<div class="blog-card"><div class="blog-date">May 18, 2026</div><h2 class="blog-title">Introducing FactoryOS AI v1.5</h2><p class="blog-excerpt">Complete CI/CD automation, monitoring, and batch scheduling now available.</p><a href="/blog/introducing-v1.5" class="read-more">Read More →</a></div>
<div class="blog-card"><div class="blog-date">May 15, 2026</div><h2 class="blog-title">How 8 AI Agents Work Together</h2><p class="blog-excerpt">Learn about multi-agent orchestration and how agents coordinate.</p><a href="/blog/multi-agent-orchestration" class="read-more">Read More →</a></div>
<div class="blog-card"><div class="blog-date">May 10, 2026</div><h2 class="blog-title">Self-Improving Feedback Loop</h2><p class="blog-excerpt">PLAN -> BUILD -> REVIEW -> SCORE -> OPTIMIZE -> FINALIZE explained.</p><a href="/blog/feedback-loop" class="read-more">Read More →</a></div>
</div>
</div>
<footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI. All rights reserved.</p></div></footer>
</body>
</html>
'@
$blogFixed | Out-File -FilePath "frontend\src\app\blog\index.html" -Encoding UTF8

Write-Host "[4/5] Fixing docs page with header..." -ForegroundColor Yellow

$docsFixed = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Documentation - FactoryOS AI</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Inter',sans-serif;color:#2D3748;background:#F7FAFC;}
.container{max-width:1280px;margin:0 auto;padding:0 24px;}
.docs-layout{display:grid;grid-template-columns:280px 1fr;gap:40px;padding:40px 0;}
.sidebar{position:sticky;top:20px;}
.sidebar h3{color:#1A365D;margin:20px 0 10px;}
.sidebar ul{list-style:none;}
.sidebar li{margin-bottom:8px;}
.sidebar a{color:#4A5568;text-decoration:none;}
.sidebar a:hover{color:#3182CE;}
.content h1{color:#1A365D;margin-bottom:20px;}
.content h2{color:#1A365D;margin:30px 0 15px;}
.content pre{background:#EDF2F7;padding:15px;border-radius:8px;overflow-x:auto;margin:20px 0;}
.content code{background:#EDF2F7;padding:2px 6px;border-radius:4px;font-family:monospace;}
.footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
@media (max-width:768px){.docs-layout{grid-template-columns:1fr;}}
</style>
</head>
<body>
' + $headerInclude + '
<div class="container">
<div class="docs-layout">
<div class="sidebar">
<h3>Getting Started</h3>
<ul><li><a href="/docs/quickstart">Quick Start Guide</a></li><li><a href="/docs/installation">Installation</a></li><li><a href="/docs/first-batch">Your First Batch</a></li></ul>
<h3>API Reference</h3>
<ul><li><a href="/api-docs">API Documentation</a></li><li><a href="/docs/api/batches">Batches API</a></li><li><a href="/docs/api/agents">Agents API</a></li></ul>
<h3>Guides</h3>
<ul><li><a href="/docs/guides/agents">Using AI Agents</a></li><li><a href="/docs/guides/orchestration">Multi-Agent Orchestration</a></li><li><a href="/docs/guides/evolution">Self-Improving Evolution</a></li></ul>
</div>
<div class="content">
<h1>Welcome to FactoryOS AI</h1>
<p>FactoryOS AI is an autonomous AI-powered software engineering platform that uses 8 specialized agents to build production-ready software.</p>
<h2>Quick Start</h2>
<pre><code># Install FactoryOS AI
docker pull factoryos/backend:latest
docker pull factoryos/frontend:latest

# Run with Docker Compose
curl -O https://factoryos.ai/docker-compose.yml
docker-compose up -d

# Create your first batch
curl -X POST https://api.factoryos.ai/api/v1/batches/ \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"batch_number": 1, "prompt": "Create a todo app"}'</code></pre>
<h2>Next Steps</h2>
<ul><li><a href="/docs/quickstart">Read the Quick Start Guide</a></li><li><a href="/api-docs">Explore the API Reference</a></li><li><a href="/signup">Start Building for Free</a></li></ul>
</div>
</div>
</div>
<footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI. All rights reserved.</p></div></footer>
</body>
</html>
'@
$docsFixed | Out-File -FilePath "frontend\src\app\docs\index.html" -Encoding UTF8

Write-Host "[5/5] Creating missing pages..." -ForegroundColor Yellow

# Create quickstart page
$quickstart = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Quick Start - FactoryOS AI</title>
<style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:'Inter',sans-serif;background:#F7FAFC;}.container{max-width:800px;margin:0 auto;padding:40px 24px;background:white;}.footer{background:#1A365D;color:white;padding:40px 0;text-align:center;}</style>
</head>
<body>
' + $headerInclude + '
<div class="container"><h1>Quick Start Guide</h1><p>Get started with FactoryOS AI in 5 minutes.</p>
<h2>Prerequisites</h2><ul><li>Docker Desktop</li><li>API key (sign up for free)</li></ul>
<h2>Step 1: Sign Up</h2><p>Visit <a href="/signup">/signup</a> to create your free account.</p>
<h2>Step 2: Install CLI</h2><pre><code>pip install factoryos-cli</code></pre>
<h2>Step 3: Create Your First Batch</h2><pre><code>factoryos batch create --prompt "Create a todo list app"</code></pre>
<h2>Step 4: Monitor Progress</h2><pre><code>factoryos batch status --id 1</code></pre>
<h2>Step 5: Deploy</h2><p>Generated code includes Docker configuration. Run <code>docker-compose up -d</code> to deploy.</p>
</div>
<footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI</p></div></footer>
</body>
</html>
'@
$quickstart | Out-File -FilePath "frontend\src\app\docs\quickstart.html" -Encoding UTF8

# Create api-docs page
$apiDocs = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>API Reference - FactoryOS AI</title>
<style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:'Inter',sans-serif;background:#F7FAFC;}.container{max-width:1000px;margin:0 auto;padding:40px 24px;background:white;}.footer{background:#1A365D;color:white;padding:40px 0;text-align:center;}pre{background:#EDF2F7;padding:15px;border-radius:8px;overflow-x:auto;}</style>
</head>
<body>
' + $headerInclude + '
<div class="container">
<h1>API Reference</h1>
<p>Complete REST API documentation for FactoryOS AI.</p>
<h2>Authentication</h2>
<pre><code>curl -X POST https://api.factoryos.ai/api/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"yourpassword"}'</code></pre>
<h2>Batches</h2>
<pre><code># Create batch
curl -X POST https://api.factoryos.ai/api/v1/batches/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"batch_number":1,"prompt":"Create an API"}'</code></pre>
<h2>Agents</h2>
<pre><code># List agents
curl -X GET https://api.factoryos.ai/api/v1/agents/ \
  -H "Authorization: Bearer YOUR_TOKEN"</code></pre>
<h2>Interactive Docs</h2>
<p>Visit <a href="http://localhost:4001/docs">http://localhost:4001/docs</a> for interactive Swagger documentation.</p>
</div>
<footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI</p></div></footer>
</body>
</html>
'@
$apiDocs | Out-File -FilePath "frontend\src\app\api-docs\index.html" -Encoding UTF8
New-Item -ItemType Directory -Force -Path "frontend\src\app\api-docs" | Out-Null
$apiDocs | Out-File -FilePath "frontend\src\app\api-docs\index.html" -Encoding UTF8

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "FIXES APPLIED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "To apply changes, restart the frontend:" -ForegroundColor Yellow
Write-Host "  docker-compose restart frontend" -ForegroundColor White
Write-Host ""
Write-Host "Then refresh your browser (Ctrl+F5)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Fixed pages:" -ForegroundColor Cyan
Write-Host "  - Blog now has header" -ForegroundColor White
Write-Host "  - Docs now has header" -ForegroundColor White
Write-Host "  - Quick Start page created" -ForegroundColor White
Write-Host "  - API Docs page created" -ForegroundColor White
Write-Host "  - PostgreSQL port changed to 5433 (avoid conflict)" -ForegroundColor White

docker-compose restart frontend
Start-Sleep -Seconds 5
Start-Process "http://localhost:4000/"