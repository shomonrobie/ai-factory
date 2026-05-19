# final_fixes_v2.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FINAL FIXES V2 - Creating missing directories" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

# Create the missing directory
Write-Host "[1/3] Creating api-docs directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "frontend\src\app\api-docs" | Out-Null

# Create api-docs page
Write-Host "[2/3] Creating API Docs page..." -ForegroundColor Yellow

$apiDocsFixed = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>API Reference - FactoryOS AI</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Inter',sans-serif;background:#F7FAFC;}
.header{background:#1A365D;color:white;padding:16px 0;position:sticky;top:0;}
.header .container{max-width:1280px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;}
.logo{font-size:24px;font-weight:bold;}
.logo a{color:white;text-decoration:none;}
.nav a{color:white;text-decoration:none;margin-left:20px;}
.btn-outline{border:1px solid white;padding:8px 20px;border-radius:8px;}
.btn-solid{background:#319795;padding:8px 20px;border-radius:8px;}
.container{max-width:1000px;margin:0 auto;padding:40px 24px;background:white;border-radius:12px;margin-top:40px;}
pre{background:#EDF2F7;padding:15px;border-radius:8px;overflow-x:auto;margin:20px 0;}
code{font-family:monospace;}
h1{color:#1A365D;}
h2{color:#1A365D;margin:30px 0 15px;}
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
<a href="/login" class="btn-outline">Sign In</a>
<a href="/signup" class="btn-solid">Get Started</a>
</nav>
</div>
</header>
<div class="container">
<h1>API Reference</h1>
<p>Complete REST API documentation for FactoryOS AI.</p>

<h2>Authentication</h2>
<pre><code>curl -X POST https://api.factoryos.ai/api/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"yourpassword"}'</code></pre>

<h2>Batches API</h2>
<h3>Create Batch</h3>
<pre><code>curl -X POST https://api.factoryos.ai/api/v1/batches/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"batch_number": 1, "prompt": "Create a todo app"}'</code></pre>

<h3>List Batches</h3>
<pre><code>curl -X GET https://api.factoryos.ai/api/v1/batches/ \
  -H "Authorization: Bearer YOUR_TOKEN"</code></pre>

<h2>Agents API</h2>
<h3>List Agents</h3>
<pre><code>curl -X GET https://api.factoryos.ai/api/v1/agents/ \
  -H "Authorization: Bearer YOUR_TOKEN"</code></pre>

<h3>Execute Agent</h3>
<pre><code>curl -X POST https://api.factoryos.ai/api/v1/agents/execute \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"agent_type": "code_generator", "task_type": "generate_code", "input_data": {"prompt": "Create a REST API"}}'</code></pre>

<h2>Orchestration API</h2>
<h3>Create Plan</h3>
<pre><code>curl -X POST https://api.factoryos.ai/api/v1/orchestration/plan \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"goal": "Build an e-commerce platform", "context": {}}'</code></pre>

<h2>Interactive Documentation</h2>
<p>For interactive API testing, visit <a href="http://localhost:4001/docs" target="_blank">http://localhost:4001/docs</a></p>
</div>
<footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI. All rights reserved.</p></div></footer>
</body>
</html>
'@
$apiDocsFixed | Out-File -FilePath "frontend\src\app\api-docs\index.html" -Encoding UTF8

Write-Host "[3/3] Restarting frontend and opening site..." -ForegroundColor Yellow

docker-compose restart frontend
Start-Sleep -Seconds 8

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "ALL FIXES APPLIED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now opening the website..." -ForegroundColor Cyan
Start-Process "http://localhost:4000/"

Write-Host ""
Write-Host "Website should now have:" -ForegroundColor White
Write-Host "  - Complete header with navigation on all pages" -ForegroundColor Green
Write-Host "  - Blog page with proper styling" -ForegroundColor Green
Write-Host "  - Documentation page with sidebar" -ForegroundColor Green
Write-Host "  - API Docs page with code examples" -ForegroundColor Green
Write-Host "  - Quick Start guide" -ForegroundColor Green
Write-Host "  - Working login/signup/dashboard pages" -ForegroundColor Green
Write-Host ""
Write-Host "Dashboard API integration (batches, usage) will work once you:" -ForegroundColor Yellow
Write-Host "  1. Create a batch through the dashboard" -ForegroundColor White
Write-Host "  2. Or use the API: curl -X POST http://localhost:4001/api/v1/batches/ ..." -ForegroundColor White