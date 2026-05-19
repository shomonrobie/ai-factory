# backend/app/api/v1/admin_full.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os

router = APIRouter()

# Data files
USERS_FILE = "/app/data/admin_users.json"
BATCHES_FILE = "/app/data/batches.json"
SETTINGS_FILE = "/app/data/admin_settings.json"

class UserCreate(BaseModel):
    name: str
    email: str
    tier: str = "free"
    status: str = "active"

class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    tier: Optional[str] = None
    status: Optional[str] = None

class SystemSettings(BaseModel):
    app_name: str = "FactoryOS AI"
    default_tier: str = "free"
    max_batches_free: int = 5
    maintenance_mode: bool = False

def load_users():
    os.makedirs("/app/data", exist_ok=True)
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, 'r') as f:
            return json.load(f)
    # Default admin user
    default_users = [
        {"id": 1, "name": "Admin User", "email": "admin@factoryos.ai", "tier": "enterprise", "status": "active", "created_at": datetime.now().isoformat()},
        {"id": 2, "name": "Demo User", "email": "demo@factoryos.ai", "tier": "free", "status": "active", "created_at": datetime.now().isoformat()}
    ]
    save_users(default_users)
    return default_users

def save_users(users):
    with open(USERS_FILE, 'w') as f:
        json.dump(users, f, indent=2)

def load_settings():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, 'r') as f:
            return json.load(f)
    return {"app_name": "FactoryOS AI", "default_tier": "free", "max_batches_free": 5, "maintenance_mode": False}

def save_settings(settings):
    with open(SETTINGS_FILE, 'w') as f:
        json.dump(settings, f, indent=2)

@router.get("/users")
async def get_users():
    return load_users()

@router.post("/users")
async def create_user(user: UserCreate):
    users = load_users()
    new_id = max([u["id"] for u in users], default=0) + 1
    new_user = user.dict()
    new_user["id"] = new_id
    new_user["created_at"] = datetime.now().isoformat()
    users.append(new_user)
    save_users(users)
    return new_user

@router.put("/users/{user_id}")
async def update_user(user_id: int, user_update: UserUpdate):
    users = load_users()
    for i, u in enumerate(users):
        if u["id"] == user_id:
            for key, value in user_update.dict(exclude_unset=True).items():
                users[i][key] = value
            save_users(users)
            return users[i]
    raise HTTPException(status_code=404, detail="User not found")

@router.delete("/users/{user_id}")
async def delete_user(user_id: int):
    users = load_users()
    for i, u in enumerate(users):
        if u["id"] == user_id:
            deleted = users.pop(i)
            save_users(users)
            return {"message": f"User {deleted['name']} deleted"}
    raise HTTPException(status_code=404, detail="User not found")

@router.get("/batches")
async def get_all_batches():
    if os.path.exists(BATCHES_FILE):
        with open(BATCHES_FILE, 'r') as f:
            return json.load(f)
    return []

@router.get("/settings")
async def get_settings():
    return load_settings()

@router.post("/settings")
async def update_settings(settings: SystemSettings):
    save_settings(settings.dict())
    return settings

@router.get("/stats")
async def get_admin_stats():
    users = load_users()
    batches = await get_all_batches()
    return {
        "total_users": len(users),
        "total_batches": len(batches),
        "active_users": len([u for u in users if u.get("status") == "active"]),
        "avg_quality_score": 85.5
    }
