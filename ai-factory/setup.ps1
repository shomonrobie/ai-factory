# setup.ps1 - Simplified working version
param(
    [int]$FrontendPort = 4000,
    [int]$BackendPort = 4001
)

Write-Host "AI Software Factory Setup - Ports: Frontend=$FrontendPort, Backend=$BackendPort" -ForegroundColor Green

$MainDir = "D:\aisfs\ai-factory"

# Clean and create directories
if (Test-Path $MainDir) { Remove-Item -Path $MainDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\api\v1 | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\core | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\models | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\schemas | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\backend\app\workers | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\docker | Out-Null
New-Item -ItemType Directory -Force -Path $MainDir\frontend | Out-Null

# Create backend requirements.txt
@"
fastapi==0.104.1
uvicorn[standard]==0.24.0
"@ | Out-File -FilePath $MainDir\backend\requirements.txt -Encoding UTF8

# Create main.py
@"
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="AI Software Factory")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/api/v1/batches/")
async def list_batches():
    return []

@app.post("/api/v1/batches/")
async def create_batch(data: dict):
    return {"id": 1, "status": "created", "batch_number": data.get("batch_number")}
"@ | Out-File -FilePath $MainDir\backend\app\main.py -Encoding UTF8

# Create __init__.py files
"# init" | Out-File -FilePath $MainDir\backend\app\__init__.py -Encoding UTF8
"# init" | Out-File -FilePath $MainDir\backend\app\api\__init__.py -Encoding UTF8
"# init" | Out-File -FilePath $MainDir\backend\app\api\v1\__init__.py -Encoding UTF8
"# init" | Out-File -FilePath $MainDir\backend\app\core\__init__.py -Encoding UTF8
"# init" | Out-File -FilePath $MainDir\backend\app\models\__init__.py -Encoding UTF8
"# init" | Out-File -FilePath $MainDir\backend\app\schemas\__init__.py -Encoding UTF8
"# init" | Out-File -FilePath $MainDir\backend\app\workers\__init__.py -Encoding UTF8

# Create frontend index.html
@"
<!DOCTYPE html>
<html>
<head>
    <title>AI Software Factory</title>
    <style>
        body { font-family: Arial; margin: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .container { max-width: 1200px; margin: auto; background: white; border-radius: 10px; padding: 20px; }
        h1 { color: #667eea; }
        button { background: #667eea; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }
        textarea { width: 100%; padding: 10px; margin: 10px 0; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .healthy { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 AI Software Factory</h1>
        <div id="status" class="status">Checking backend...</div>
        <h2>Create Batch</h2>
        <input type="number" id="batchNum" value="1">
        <textarea id="prompt" rows="4" placeholder="Describe your app..."></textarea>
        <button onclick="createBatch()">Create Batch</button>
        <h2>Batches</h2>
        <div id="batches"></div>
    </div>
    <script>
        const API_URL = 'http://localhost:$BackendPort';
        async function checkHealth() {
            try {
                const res = await fetch(API_URL + '/health');
                if (res.ok) {
                    document.getElementById('status').innerHTML = '✅ Backend connected';
                    document.getElementById('status').className = 'status healthy';
                }
            } catch(e) {
                document.getElementById('status').innerHTML = '❌ Backend not available';
                document.getElementById('status').className = 'status error';
            }
        }
        async function loadBatches() {
            try {
                const res = await fetch(API_URL + '/api/v1/batches/');
                const data = await res.json();
                document.getElementById('batches').innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
            } catch(e) {
                document.getElementById('batches').innerHTML = 'Error loading batches';
            }
        }
        async function createBatch() {
            const batchNum = document.getElementById('batchNum').value;
            const prompt = document.getElementById('prompt').value;
            const res = await fetch(API_URL + '/api/v1/batches/', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({batch_number: parseInt(batchNum), prompt: prompt})
            });
            const data = await res.json();
            alert('Batch created: ' + JSON.stringify(data));
            loadBatches();
        }
        checkHealth();
        loadBatches();
        setInterval(loadBatches, 5000);
    </script>
</body>
</html>
"@ | Out-File -FilePath $MainDir\frontend\index.html -Encoding UTF8

# Create Dockerfile.backend
@"
FROM python:3.11-slim
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ /app/backend/
ENV PYTHONPATH=/app
WORKDIR /app/backend
EXPOSE ${BackendPort}
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "${BackendPort}"]
"@ | Out-File -FilePath $MainDir\docker\Dockerfile.backend -Encoding UTF8

# Create Dockerfile.frontend
@"
FROM nginx:alpine
COPY frontend/ /usr/share/nginx/html/
EXPOSE 80
"@ | Out-File -FilePath $MainDir\docker\Dockerfile.frontend -Encoding UTF8

# Create docker-compose.yml
@"
services:
  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile.backend
    ports:
      - "${BackendPort}:${BackendPort}"
  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend
    ports:
      - "${FrontendPort}:80"
    depends_on:
      - backend
"@ | Out-File -FilePath $MainDir\docker-compose.yml -Encoding UTF8

# Build and run
Set-Location $MainDir
Write-Host "Building containers..." -ForegroundColor Yellow
docker-compose build

Write-Host "Starting services..." -ForegroundColor Yellow
docker-compose up -d

Start-Sleep -Seconds 10

Write-Host "`n✅ Setup Complete!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:$FrontendPort" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:$BackendPort" -ForegroundColor Cyan
Write-Host "API Docs: http://localhost:$BackendPort/docs" -ForegroundColor Cyan

Start-Process "http://localhost:$FrontendPort"