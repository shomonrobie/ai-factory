# one_click_setup.ps1
# AI Software Factory - Complete One-Click Setup
# Frontend: Port 4000 | Backend: Port 4001

param(
    [int]$FrontendPort = 4000,
    [int]$BackendPort = 4001
)

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     AI SOFTWARE FACTORY - COMPLETE SETUP                    ║
║     One-click installation and deployment                   ║
║                                                              ║
║     Frontend: http://localhost:$FrontendPort                ║
║     Backend:  http://localhost:$BackendPort                 ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Create main directory
$MainDir = "D:\aisfs\ai-factory"
if (Test-Path $MainDir) {
    Write-Host "Removing existing directory..." -ForegroundColor Yellow
    Remove-Item -Path $MainDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Creating directory structure..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\api\v1 | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\core | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\models | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\schemas | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\workers | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\agents | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\engine | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\orchestrator | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\pipeline | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\ci | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\memory | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\registry | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\validator | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\factory\fixer | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\docker | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\tests\unit | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\tests\integration | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\scripts | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\frontend | Out-Null

Write-Host "Creating backend files..." -ForegroundColor Green

# requirements.txt
@"
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
redis==5.0.1
celery==5.3.4
pydantic==2.5.0
pydantic-settings==2.1.0
python-dotenv==1.0.0
python-multipart==0.0.6
httpx==0.25.1
pytest==7.4.3
pytest-asyncio==0.21.1
pytest-cov==4.1.0
"@ | Out-File -FilePath $MainDir\backend\requirements.txt -Encoding UTF8 -NoNewline

# main.py
@"
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting up AI Factory...")
    yield
    logger.info("Shutting down AI Factory...")

app = FastAPI(
    title="AI Software Factory",
    version="1.0.0",
    description="Enterprise-grade AI-powered software engineering factory",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:$FrontendPort", "http://localhost:8000", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "1.0.0"}

@app.get("/")
async def root():
    return {"message": "AI Software Factory API", "version": "1.0.0"}

@app.get("/api/v1/batches/")
async def list_batches():
    return []

@app.post("/api/v1/batches/")
async def create_batch(batch_data: dict):
    return {"id": 1, "status": "processing", "message": "Batch created"}
"@ | Out-File -FilePath $MainDir\backend\app\main.py -Encoding UTF8

# __init__.py files
"# API module" | Out-File -FilePath $MainDir\backend\app\__init__.py -Encoding UTF8
"# API v1 module" | Out-File -FilePath $MainDir\backend\app\api\__init__.py -Encoding UTF8
"# API v1 module" | Out-File -FilePath $MainDir\backend\app\api\v1\__init__.py -Encoding UTF8
"# Core module" | Out-File -FilePath $MainDir\backend\app\core\__init__.py -Encoding UTF8
"# Models module" | Out-File -FilePath $MainDir\backend\app\models\__init__.py -Encoding UTF8
"# Schemas module" | Out-File -FilePath $MainDir\backend\app\schemas\__init__.py -Encoding UTF8
"# Workers module" | Out-File -FilePath $MainDir\backend\app\workers\__init__.py -Encoding UTF8

Write-Host "Creating frontend files..." -ForegroundColor Green

# index.html
@"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Software Factory</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        .header {
            background: white;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .subtitle {
            color: #666;
            font-size: 1.1em;
        }
        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        .card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .card h2 {
            color: #333;
            margin-bottom: 20px;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        .status {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: bold;
        }
        .status.healthy {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .status.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        input, textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        textarea {
            resize: vertical;
            font-family: monospace;
        }
        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            transition: transform 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
        }
        button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        .badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .badge.completed { background: #d4edda; color: #155724; }
        .badge.processing { background: #fff3cd; color: #856404; }
        .badge.failed { background: #f8d7da; color: #721c24; }
        .badge.pending { background: #e2e3e5; color: #383d41; }
        .result {
            margin-top: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 5px;
            display: none;
        }
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 AI Software Factory</h1>
            <p class="subtitle">Enterprise-grade AI-powered software engineering factory</p>
        </div>

        <div class="grid">
            <div class="card">
                <h2>📝 Create New Batch</h2>
                <div id="healthStatus" class="status">Checking backend status...</div>
                <div class="form-group">
                    <label>Batch Number:</label>
                    <input type="number" id="batchNumber" value="1" min="1">
                </div>
                <div class="form-group">
                    <label>Prompt / Requirements:</label>
                    <textarea id="prompt" rows="6" placeholder="Describe the SaaS application you want to generate...&#10;&#10;Example:&#10;Create a task management app with user authentication, task creation, and due dates."></textarea>
                </div>
                <button onclick="createBatch()">🚀 Create Batch</button>
                <div id="result" class="result"></div>
            </div>

            <div class="card">
                <h2>📋 Batches History</h2>
                <div id="batchesList">
                    <div class="loading"></div> Loading...
                </div>
            </div>
        </div>

        <div class="card">
            <h2>ℹ️ System Information</h2>
            <p><strong>Backend API:</strong> <span id="apiUrl">http://localhost:$BackendPort</span></p>
            <p><strong>Frontend:</strong> http://localhost:$FrontendPort</p>
            <p><strong>Status:</strong> <span id="systemStatus">Initializing...</span></p>
        </div>
    </div>

    <script>
        const API_URL = 'http://localhost:$BackendPort';
        
        async function checkHealth() {
            try {
                const response = await fetch(`${API_URL}/health`);
                const data = await response.json();
                const statusDiv = document.getElementById('healthStatus');
                statusDiv.innerHTML = `✅ Backend is healthy (${data.status})`;
                statusDiv.className = 'status healthy';
                document.getElementById('systemStatus').innerHTML = '✅ Running';
                document.getElementById('systemStatus').style.color = 'green';
            } catch (error) {
                document.getElementById('healthStatus').innerHTML = `❌ Backend not available: ${error.message}`;
                document.getElementById('healthStatus').className = 'status error';
                document.getElementById('systemStatus').innerHTML = '❌ Backend not connected';
                document.getElementById('systemStatus').style.color = 'red';
            }
        }
        
        async function loadBatches() {
            try {
                const response = await fetch(`${API_URL}/api/v1/batches/`);
                const batches = await response.json();
                if (!batches || batches.length === 0) {
                    document.getElementById('batchesList').innerHTML = '<p style="text-align: center; color: #999;">No batches created yet. Create your first batch!</p>';
                } else {
                    let html = '<table><thead><tr>';
                    html += '<th>Batch #</th><th>Status</th><th>Prompt</th><th>Created</th>';
                    html += '</tr></thead><tbody>';
                    batches.forEach(batch => {
                        let statusClass = 'badge ' + (batch.status || 'pending');
                        html += `<tr>
                            <td><strong>${batch.batch_number || batch.id}</strong></td>
                            <td><span class="${statusClass}">${batch.status || 'pending'}</span></td>
                            <td>${(batch.prompt || '').substring(0, 100)}${(batch.prompt || '').length > 100 ? '...' : ''}</td>
                            <td>${batch.created_at ? new Date(batch.created_at).toLocaleString() : '-'}</td>
                        </tr>`;
                    });
                    html += '</tbody></table>';
                    document.getElementById('batchesList').innerHTML = html;
                }
            } catch (error) {
                document.getElementById('batchesList').innerHTML = `<p style="color: red;">Error loading batches: ${error.message}</p>`;
            }
        }
        
        async function createBatch() {
            const batchNumber = document.getElementById('batchNumber').value;
            const prompt = document.getElementById('prompt').value;
            
            if (!prompt.trim()) {
                alert('Please enter a prompt describing your application');
                return;
            }
            
            const resultDiv = document.getElementById('result');
            const button = event.target;
            
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div class="loading"></div> Creating batch...';
            button.disabled = true;
            
            try {
                const response = await fetch(`${API_URL}/api/v1/batches/`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        batch_number: parseInt(batchNumber),
                        prompt: prompt
                    })
                });
                
                const data = await response.json();
                resultDiv.innerHTML = `✅ Batch created successfully!<br><br><strong>Response:</strong><br><pre style="margin-top: 10px; background: white; padding: 10px; border-radius: 5px;">${JSON.stringify(data, null, 2)}</pre>`;
                resultDiv.style.background = '#d4edda';
                
                document.getElementById('batchNumber').value = parseInt(batchNumber) + 1;
                document.getElementById('prompt').value = '';
                
                setTimeout(() => {
                    resultDiv.style.display = 'none';
                    resultDiv.style.background = '#f8f9fa';
                }, 5000);
                
                loadBatches();
            } catch (error) {
                resultDiv.innerHTML = `❌ Error: ${error.message}`;
                resultDiv.style.background = '#f8d7da';
            } finally {
                button.disabled = false;
            }
        }
        
        // Initial load
        checkHealth();
        loadBatches();
        
        // Refresh every 3 seconds
        setInterval(loadBatches, 3000);
        setInterval(checkHealth, 10000);
    </script>
</body>
</html>
"@ | Out-File -FilePath $MainDir\frontend\index.html -Encoding UTF8

Write-Host "Creating Docker files..." -ForegroundColor Green

# Dockerfile.backend
@"
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ /app/backend/

ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

WORKDIR /app/backend

EXPOSE $BackendPort

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "$BackendPort", "--reload"]
"@ | Out-File -FilePath $MainDir\docker\Dockerfile.backend -Encoding UTF8

# Dockerfile.frontend
@"
FROM nginx:alpine

COPY frontend/index.html /usr/share/nginx/html/
COPY frontend/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
"@ | Out-File -FilePath $MainDir\docker\Dockerfile.frontend -Encoding UTF8

# docker-compose.yml
@"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: aifactory
      POSTGRES_PASSWORD: aifactory123
      POSTGRES_DB: aifactory
    ports:
      - "5432:5432"
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
      - "${BackendPort}:${BackendPort}"
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
    command: >
      sh -c "sleep 5 && uvicorn app.main:app --host 0.0.0.0 --port ${BackendPort} --reload"

  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend
    ports:
      - "${FrontendPort}:80"
    depends_on:
      - backend

volumes:
  postgres_data:
  redis_data:
"@ | Out-File -FilePath $MainDir\docker-compose.yml -Encoding UTF8

# .env file
@"
DATABASE_URL=postgresql://aifactory:aifactory123@postgres:5432/aifactory
REDIS_URL=redis://redis:6379
CORS_ORIGINS=http://localhost:$FrontendPort,http://localhost:$BackendPort
ENVIRONMENT=development
DEBUG=true
FRONTEND_PORT=$FrontendPort
BACKEND_PORT=$BackendPort
"@ | Out-File -FilePath $MainDir\.env -Encoding UTF8

Write-Host "Creating utility scripts..." -ForegroundColor Green

# start.ps1
@"
# start.ps1
Write-Host "Starting AI Software Factory..." -ForegroundColor Green
Set-Location $MainDir
docker-compose up -d
Write-Host "Services started!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:$FrontendPort" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:$BackendPort" -ForegroundColor Cyan
"@ | Out-File -FilePath $MainDir\start.ps1 -Encoding UTF8

# stop.ps1
@"
# stop.ps1
Write-Host "Stopping AI Software Factory..." -ForegroundColor Yellow
Set-Location $MainDir
docker-compose down
Write-Host "Services stopped!" -ForegroundColor Green
"@ | Out-File -FilePath $MainDir\stop.ps1 -Encoding UTF8

# status.ps1
@"
# status.ps1
Write-Host "AI Software Factory Status" -ForegroundColor Cyan
Set-Location $MainDir
docker-compose ps
Write-Host ""
Write-Host "Frontend: http://localhost:$FrontendPort" -ForegroundColor Yellow
Write-Host "Backend: http://localhost:$BackendPort" -ForegroundColor Yellow
"@ | Out-File -FilePath $MainDir\status.ps1 -Encoding UTF8

# logs.ps1
@"
# logs.ps1
Set-Location $MainDir
docker-compose logs -f
"@ | Out-File -FilePath $MainDir\logs.ps1 -Encoding UTF8

Write-Host "Building and starting containers..." -ForegroundColor Green

Set-Location $MainDir

# Stop any existing containers
docker-compose down -v 2>$null

# Build containers
Write-Host "Building Docker images (this may take a few minutes)..." -ForegroundColor Yellow
docker-compose build --no-cache

# Start services
Write-Host "Starting services..." -ForegroundColor Yellow
docker-compose up -d

# Wait for services to initialize
Write-Host "Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "✅ AI SOFTWARE FACTORY IS NOW RUNNING!" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Access your application:" -ForegroundColor White
Write-Host "   🌐 Frontend: http://localhost:$FrontendPort" -ForegroundColor Cyan
Write-Host "   🔧 Backend API: http://localhost:$BackendPort" -ForegroundColor Cyan
Write-Host "   📚 API Docs: http://localhost:$BackendPort/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Useful commands:" -ForegroundColor White
Write-Host "   🚀 Start:   .\start.ps1" -ForegroundColor Yellow
Write-Host "   🛑 Stop:    .\stop.ps1" -ForegroundColor Yellow
Write-Host "   📊 Status:  .\status.ps1" -ForegroundColor Yellow
Write-Host "   📜 Logs:    .\logs.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔍 Checking service status..." -ForegroundColor White

# Check backend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$BackendPort/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Backend API is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Backend API is starting up (wait a few seconds)" -ForegroundColor Yellow
}

# Check frontend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$FrontendPort" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Frontend is accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Frontend is starting up (wait a few seconds)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Setup complete! Opening browser..." -ForegroundColor Green

# Open browser
Start-Process "http://localhost:$FrontendPort"

Write-Host ""
Write-Host "Press any key to show service status..." -ForegroundColor Gray
#$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

docker-compose ps