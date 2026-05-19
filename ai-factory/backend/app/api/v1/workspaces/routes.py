# backend/app/api/v1/workspaces/routes.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
import uuid
from datetime import datetime

router = APIRouter()

# In-memory storage for workspaces
workspaces = []
workspace_members = []

class CreateWorkspaceRequest(BaseModel):
    name: str
    settings: Optional[Dict] = {}

class AddMemberRequest(BaseModel):
    user_id: str
    role: str = "member"

@router.post("/workspaces")
async def create_workspace(request: CreateWorkspaceRequest, user_id: str = "admin"):
    workspace = {
        "id": str(uuid.uuid4()),
        "name": request.name,
        "owner_id": user_id,
        "settings": request.settings or {},
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat()
    }
    workspaces.append(workspace)
    return workspace

@router.get("/workspaces")
async def get_user_workspaces(user_id: str = "admin"):
    return [w for w in workspaces if w.get("owner_id") == user_id]

@router.get("/workspaces/{workspace_id}")
async def get_workspace(workspace_id: str):
    for w in workspaces:
        if w["id"] == workspace_id:
            return w
    raise HTTPException(status_code=404, detail="Workspace not found")

@router.post("/workspaces/{workspace_id}/members")
async def add_member(workspace_id: str, request: AddMemberRequest):
    member = {
        "id": str(uuid.uuid4()),
        "workspace_id": workspace_id,
        "user_id": request.user_id,
        "role": request.role,
        "joined_at": datetime.now().isoformat()
    }
    workspace_members.append(member)
    return member

@router.get("/workspaces/{workspace_id}/members")
async def get_workspace_members(workspace_id: str):
    return [m for m in workspace_members if m["workspace_id"] == workspace_id]
