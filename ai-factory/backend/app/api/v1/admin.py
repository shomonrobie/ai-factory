# backend/app/api/v1/admin.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os

router = APIRouter()

DATA_DIR = "/app/data"
USERS_FILE = os.path.join(DATA_DIR, "users.json")
BATCHES_FILE = os.path.join(DATA_DIR, "batches.json")

# Ensure data directory exists
os.makedirs(DATA_DIR, exist_ok=True)

def load_users():
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, 'r') as f:
            return json.load(f)
    default_users = [
        {"id": 1, "name": "Admin User", "email": "admin@factoryos.ai", "tier": "enterprise", "status": "active"},
        {"id": 2, "name": "Demo User", "email": "demo@factoryos.ai", "tier": "free", "status": "active"}
    ]
    with open(USERS_FILE, 'w') as f:
        json.dump(default_users, f, indent=2)
    return default_users

def load_batches():
    if os.path.exists(BATCHES_FILE):
        with open(BATCHES_FILE, 'r') as f:
            return json.load(f)
    return []

@router.get("/users")
async def get_users():
    return {"users": load_users()}

@router.get("/stats")
async def get_stats():
    users = load_users()
    batches = load_batches()
    return {
        "total_users": len(users),
        "total_batches": len(batches),
        "active_users": len([u for u in users if u.get("status") == "active"])
    }

@router.get("/settings")
async def get_settings():
    return {
        "app_name": "FactoryOS AI",
        "version": "1.5.0",
        "default_tier": "free",
        "max_batches_free": 5
    }
