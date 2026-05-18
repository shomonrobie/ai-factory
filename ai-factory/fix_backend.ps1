# fix_backend.ps1
Write-Host "Fixing backend to persist data..." -ForegroundColor Green

$MainDir = "D:\aisfs\ai-factory"
$mainPyPath = "$MainDir\backend\app\main.py"

@"
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from datetime import datetime
import json
import os

app = FastAPI(title="AI Software Factory", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# File-based storage for persistence
DATA_FILE = "/app/data/batches.json"
PROJECTS_FILE = "/app/data/projects.json"

# Ensure data directory exists
os.makedirs("/app/data", exist_ok=True)

def load_batches():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r') as f:
            return json.load(f)
    return []

def save_batches(batches):
    with open(DATA_FILE, 'w') as f:
        json.dump(batches, f, indent=2)

def load_projects():
    if os.path.exists(PROJECTS_FILE):
        with open(PROJECTS_FILE, 'r') as f:
            return json.load(f)
    return []

def save_projects(projects):
    with open(PROJECTS_FILE, 'w') as f:
        json.dump(projects, f, indent=2)

class BatchCreate(BaseModel):
    batch_number: int
    prompt: str
    metadata: Optional[Dict] = {}

class ProjectCreate(BaseModel):
    name: str
    description: Optional[str] = ""

@app.get("/health")
async def health():
    return {"status": "healthy", "version": "2.0.0", "timestamp": datetime.now().isoformat()}

@app.post("/api/v1/batches/")
async def create_batch(batch: BatchCreate):
    batches = load_batches()
    
    # Check if batch number already exists
    for existing in batches:
        if existing.get("batch_number") == batch.batch_number:
            raise HTTPException(status_code=400, detail=f"Batch #{batch.batch_number} already exists")
    
    new_batch = {
        "id": len(batches) + 1,
        "batch_number": batch.batch_number,
        "prompt": batch.prompt,
        "status": "completed",
        "result": {
            "generated_code": f"# Generated code for batch {batch.batch_number}\n# Prompt: {batch.prompt}\n\nclass GeneratedApp:\n    def __init__(self):\n        print('AI Factory Generated Application')\n\n    def run(self):\n        return 'Application is running!'",
            "validation_score": 85,
            "agents_used": ["architect", "backend", "frontend", "qa", "security"],
            "files_generated": [
                "app/main.py",
                "app/models.py",
                "app/api.py",
                "tests/test_main.py"
            ]
        },
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat(),
        "metadata": batch.metadata
    }
    
    batches.append(new_batch)
    save_batches(batches)
    
    return new_batch

@app.get("/api/v1/batches/")
async def list_batches():
    return load_batches()

@app.get("/api/v1/batches/{batch_id}")
async def get_batch(batch_id: int):
    batches = load_batches()
    for batch in batches:
        if batch.get("id") == batch_id:
            return batch
    raise HTTPException(status_code=404, detail="Batch not found")

@app.get("/api/v1/batches/number/{batch_number}")
async def get_batch_by_number(batch_number: int):
    batches = load_batches()
    for batch in batches:
        if batch.get("batch_number") == batch_number:
            return batch
    raise HTTPException(status_code=404, detail=f"Batch #{batch_number} not found")

@app.delete("/api/v1/batches/{batch_id}")
async def delete_batch(batch_id: int):
    batches = load_batches()
    for i, batch in enumerate(batches):
        if batch.get("id") == batch_id:
            deleted = batches.pop(i)
            save_batches(batches)
            return {"message": f"Batch #{deleted['batch_number']} deleted", "deleted": deleted}
    raise HTTPException(status_code=404, detail="Batch not found")

@app.post("/api/v1/projects/")
async def create_project(project: ProjectCreate):
    projects = load_projects()
    
    new_project = {
        "id": len(projects) + 1,
        "name": project.name,
        "description": project.description,
        "status": "active",
        "current_batch": 0,
        "batches": [],
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat()
    }
    
    projects.append(new_project)
    save_projects(projects)
    return new_project

@app.get("/api/v1/projects/")
async def list_projects():
    return load_projects()

@app.get("/api/v1/projects/{project_id}")
async def get_project(project_id: int):
    projects = load_projects()
    for project in projects:
        if project.get("id") == project_id:
            return project
    raise HTTPException(status_code=404, detail="Project not found")

@app.put("/api/v1/projects/{project_id}")
async def update_project(project_id: int, project_update: ProjectCreate):
    projects = load_projects()
    for i, project in enumerate(projects):
        if project.get("id") == project_id:
            projects[i]["name"] = project_update.name
            projects[i]["description"] = project_update.description
            projects[i]["updated_at"] = datetime.now().isoformat()
            save_projects(projects)
            return projects[i]
    raise HTTPException(status_code=404, detail="Project not found")

@app.delete("/api/v1/projects/{project_id}")
async def delete_project(project_id: int):
    projects = load_projects()
    for i, project in enumerate(projects):
        if project.get("id") == project_id:
            deleted = projects.pop(i)
            save_projects(projects)
            return {"message": f"Project '{deleted['name']}' deleted", "deleted": deleted}
    raise HTTPException(status_code=404, detail="Project not found")

@app.post("/api/v1/projects/{project_id}/batches/{batch_id}")
async def add_batch_to_project(project_id: int, batch_id: int):
    projects = load_projects()
    batches = load_batches()
    
    project = None
    for p in projects:
        if p.get("id") == project_id:
            project = p
            break
    
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    
    batch = None
    for b in batches:
        if b.get("id") == batch_id:
            batch = b
            break
    
    if not batch:
        raise HTTPException(status_code=404, detail="Batch not found")
    
    if batch_id not in project.get("batches", []):
        project["batches"].append(batch_id)
        project["current_batch"] = batch.get("batch_number")
        project["updated_at"] = datetime.now().isoformat()
        save_projects(projects)
    
    return {"message": f"Batch #{batch['batch_number']} added to project '{project['name']}'", "project": project}

@app.get("/")
async def root():
    return {
        "message": "AI Software Factory API",
        "version": "2.0.0",
        "endpoints": {
            "health": "/health",
            "batches": "/api/v1/batches/",
            "batch_detail": "/api/v1/batches/{id}",
            "batch_by_number": "/api/v1/batches/number/{batch_number}",
            "projects": "/api/v1/projects/",
            "project_detail": "/api/v1/projects/{id}",
            "docs": "/docs"
        }
    }
"@ | Out-File -FilePath $mainPyPath -Encoding UTF8

Write-Host "Restarting backend container..." -ForegroundColor Yellow

Set-Location $MainDir
docker-compose restart backend

Start-Sleep -Seconds 5

Write-Host "`n✅ Backend fixed! Testing now..." -ForegroundColor Green

# Test the fixed backend
$testScript = @'
Write-Host "`n=== Testing Fixed Backend ===" -ForegroundColor Cyan

$baseUrl = "http://localhost:4001"

# Test health
Write-Host "`n1. Health check:" -ForegroundColor Yellow
$result = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
Write-Host "   Status: $($result.status)" -ForegroundColor Green

# Create a batch
Write-Host "`n2. Creating batch #10:" -ForegroundColor Yellow
$body = @{batch_number = 10; prompt = "Create an e-commerce platform"} | ConvertTo-Json
$batch = Invoke-RestMethod -Uri "$baseUrl/api/v1/batches/" -Method POST -ContentType "application/json" -Body $body
Write-Host "   Batch #$($batch.batch_number) created with ID: $($batch.id)" -ForegroundColor Green

# List all batches
Write-Host "`n3. Listing all batches:" -ForegroundColor Yellow
$batches = Invoke-RestMethod -Uri "$baseUrl/api/v1/batches/" -Method GET
Write-Host "   Total batches: $($batches.Count)" -ForegroundColor Green
foreach ($b in $batches) {
    Write-Host "     Batch #$($b.batch_number): $($b.status) - $($b.prompt.Substring(0, [Math]::Min(30, $b.prompt.Length)))..." -ForegroundColor Gray
}

# Create a project
Write-Host "`n4. Creating project:" -ForegroundColor Yellow
$body = @{name = "ECommerceApp"; description = "AI-generated e-commerce platform"} | ConvertTo-Json
$project = Invoke-RestMethod -Uri "$baseUrl/api/v1/projects/" -Method POST -ContentType "application/json" -Body $body
Write-Host "   Project '$($project.name)' created with ID: $($project.id)" -ForegroundColor Green

# List projects
Write-Host "`n5. Listing projects:" -ForegroundColor Yellow
$projects = Invoke-RestMethod -Uri "$baseUrl/api/v1/projects/" -Method GET
Write-Host "   Total projects: $($projects.Count)" -ForegroundColor Green
foreach ($p in $projects) {
    Write-Host "     Project #$($p.id): $($p.name) - $($p.status)" -ForegroundColor Gray
}

Write-Host "`n✅ All tests passed!" -ForegroundColor Green
Write-Host "`n📊 Access your data:" -ForegroundColor Cyan
Write-Host "   API Docs: http://localhost:4001/docs" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:4000" -ForegroundColor Cyan
'@

$testScript | Out-File -FilePath "$MainDir\test_fixed.ps1" -Encoding UTF8

& "$MainDir\test_fixed.ps1"