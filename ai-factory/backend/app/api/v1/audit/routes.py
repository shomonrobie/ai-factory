# backend/app/api/v1/audit/routes.py
from fastapi import APIRouter, Query
from typing import Optional
from datetime import datetime, timedelta
import json
import os

router = APIRouter()

AUDIT_FILE = "/app/data/audit_logs.json"

def load_audit_logs():
    if os.path.exists(AUDIT_FILE):
        with open(AUDIT_FILE, 'r') as f:
            return json.load(f)
    return []

@router.get("/logs")
async def get_audit_logs(
    user_id: Optional[str] = Query(None),
    action: Optional[str] = Query(None),
    resource_type: Optional[str] = Query(None),
    days: int = Query(30, ge=1, le=365)
):
    logs = load_audit_logs()
    cutoff = datetime.now() - timedelta(days=days)
    
    filtered = [l for l in logs if datetime.fromisoformat(l["timestamp"]) > cutoff]
    
    if user_id:
        filtered = [l for l in filtered if l.get("user_id") == user_id]
    if action:
        filtered = [l for l in filtered if l.get("action") == action]
    if resource_type:
        filtered = [l for l in filtered if l.get("resource_type") == resource_type]
    
    return {"logs": filtered, "count": len(filtered)}

@router.get("/logs/user/{user_id}")
async def get_user_activity(user_id: str, days: int = 30):
    logs = load_audit_logs()
    cutoff = datetime.now() - timedelta(days=days)
    user_logs = [l for l in logs if l.get("user_id") == user_id and datetime.fromisoformat(l["timestamp"]) > cutoff]
    
    actions = {}
    for log in user_logs:
        action = log.get("action", "unknown")
        actions[action] = actions.get(action, 0) + 1
    
    return {
        "user_id": user_id,
        "total_actions": len(user_logs),
        "actions": actions,
        "last_active": user_logs[-1]["timestamp"] if user_logs else None,
        "logs": user_logs[-50:]
    }

@router.get("/logs/export")
async def export_logs(days: int = 90):
    logs = load_audit_logs()
    cutoff = datetime.now() - timedelta(days=days)
    filtered = [l for l in logs if datetime.fromisoformat(l["timestamp"]) > cutoff]
    return {"export": json.dumps(filtered, indent=2)}
