# backend/app/api/v1/projects.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os

router = APIRouter()

PROJECTS_FILE = "/app/data/projects.json"
os.makedirs("/app/data", exist_ok=True)

def load_projects():
    if os.path.exists(PROJECTS_FILE):
        with open(PROJECTS_FILE, 'r') as f:
            return json.load(f)
    return []

def save_projects(projects):
    with open(PROJECTS_FILE, 'w') as f:
        json.dump(projects, f, indent=2)

class ProjectCreate(BaseModel):
    name: str
    description: Optional[str] = ""

@router.post("/")
async def create_project(project: ProjectCreate):
    projects = load_projects()
    
    new_project = {
        "id": len(projects) + 1,
        "name": project.name,
        "description": project.description,
        "status": "active",
        "created_at": datetime.now().isoformat()
    }
    
    projects.append(new_project)
    save_projects(projects)
    return new_project

@router.get("/")
async def list_projects():
    return load_projects()

@router.get("/{project_id}")
async def get_project(project_id: int):
    projects = load_projects()
    for project in projects:
        if project.get("id") == project_id:
            return project
    raise HTTPException(status_code=404, detail="Project not found")