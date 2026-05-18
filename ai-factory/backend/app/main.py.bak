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

DATA_FILE = "/app/data/batches.json"
PROJECTS_FILE = "/app/data/projects.json"

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
    return {"status": "healthy", "version": "2.0.0"}

@app.post("/api/v1/batches/")
async def create_batch(batch: BatchCreate):
    batches = load_batches()
    
    for existing in batches:
        if existing.get("batch_number") == batch.batch_number:
            raise HTTPException(status_code=400, detail=f"Batch #{batch.batch_number} already exists")
    
    new_batch = {
        "id": len(batches) + 1,
        "batch_number": batch.batch_number,
        "prompt": batch.prompt,
        "status": "completed",
        "result": {
            "generated_code": f"# Generated code for batch {batch.batch_number}",
            "validation_score": 85,
            "agents_used": ["architect", "backend", "frontend"]
        },
        "created_at": datetime.now().isoformat(),
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

@app.post("/api/v1/projects/")
async def create_project(project: ProjectCreate):
    projects = load_projects()
    
    new_project = {
        "id": len(projects) + 1,
        "name": project.name,
        "description": project.description,
        "status": "active",
        "current_batch": 0,
        "created_at": datetime.now().isoformat()
    }
    
    projects.append(new_project)
    save_projects(projects)
    return new_project

@app.get("/api/v1/projects/")
async def list_projects():
    return load_projects()

@app.get("/")
async def root():
    return {"message": "AI Software Factory API", "version": "2.0.0"}