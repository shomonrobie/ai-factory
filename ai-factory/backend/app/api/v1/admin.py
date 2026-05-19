# backend/app/api/v1/admin.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os

router = APIRouter()

DATA_DIR = "/app/data"
USERS_FILE = os.path.join(DATA_DIR, "admin_users.json")

# Ensure data directory exists
os.makedirs(DATA_DIR, exist_ok=True)

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

def load_users():
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, 'r') as f:
            return json.load(f)
    # Default users
    default_users = [
        {"id": 1, "name": "Admin User", "email": "admin@factoryos.ai", "tier": "enterprise", "status": "active", "created_at": datetime.now().isoformat()},
        {"id": 2, "name": "Demo User", "email": "demo@factoryos.ai", "tier": "free", "status": "active", "created_at": datetime.now().isoformat()}
    ]
    save_users(default_users)
    return default_users

def save_users(users):
    with open(USERS_FILE, 'w') as f:
        json.dump(users, f, indent=2)

@router.get("/users")
async def get_users():
    return {"users": load_users()}

@router.post("/users")
async def create_user(user: UserCreate):
    users = load_users()
    
    # Check if email already exists
    for existing_user in users:
        if existing_user.get("email") == user.email:
            raise HTTPException(status_code=400, detail="Email already exists")
    
    # Create new user
    new_id = max([u.get("id", 0) for u in users], default=0) + 1
    new_user = {
        "id": new_id,
        "name": user.name,
        "email": user.email,
        "tier": user.tier,
        "status": user.status,
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat()
    }
    
    users.append(new_user)
    save_users(users)
    return new_user

@router.put("/users/{user_id}")
async def update_user(user_id: int, user_update: UserUpdate):
    users = load_users()
    for i, u in enumerate(users):
        if u.get("id") == user_id:
            update_data = user_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                users[i][key] = value
            users[i]["updated_at"] = datetime.now().isoformat()
            save_users(users)
            return users[i]
    raise HTTPException(status_code=404, detail="User not found")

@router.delete("/users/{user_id}")
async def delete_user(user_id: int):
    users = load_users()
    for i, u in enumerate(users):
        if u.get("id") == user_id:
            deleted_user = users.pop(i)
            save_users(users)
            return {"message": f"User {deleted_user.get('name')} deleted", "id": user_id}
    raise HTTPException(status_code=404, detail="User not found")

@router.get("/stats")
async def get_stats():
    users = load_users()
    # Load batches from batches.json
    batches_file = os.path.join(DATA_DIR, "batches.json")
    batches = []
    if os.path.exists(batches_file):
        with open(batches_file, 'r') as f:
            batches = json.load(f)
    
    return {
        "total_users": len(users),
        "total_batches": len(batches),
        "active_users": len([u for u in users if u.get("status") == "active"]),
        "avg_quality_score": 85
    }

@router.get("/settings")
async def get_settings():
    settings_file = os.path.join(DATA_DIR, "admin_settings.json")
    if os.path.exists(settings_file):
        with open(settings_file, 'r') as f:
            return json.load(f)
    return {"app_name": "FactoryOS AI", "default_tier": "free", "max_batches_free": 5}

@router.post("/settings")
async def update_settings(settings: dict):
    settings_file = os.path.join(DATA_DIR, "admin_settings.json")
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)
    return settings