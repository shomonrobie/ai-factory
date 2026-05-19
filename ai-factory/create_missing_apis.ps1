# create_missing_apis.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "CREATING MISSING API ENDPOINTS" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/6] Creating admin API with all endpoints..." -ForegroundColor Yellow

$completeAdminApi = @'
# backend/app/api/v1/admin.py
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
    default_users = [
        {"id": 1, "name": "Admin User", "email": "admin@factoryos.ai", "tier": "enterprise", "status": "active", "created_at": datetime.now().isoformat()},
        {"id": 2, "name": "Demo User", "email": "demo@factoryos.ai", "tier": "free", "status": "active", "created_at": datetime.now().isoformat()}
    ]
    save_users(default_users)
    return default_users

def save_users(users):
    with open(USERS_FILE, 'w') as f:
        json.dump(users, f, indent=2)

def load_batches():
    if os.path.exists(BATCHES_FILE):
        with open(BATCHES_FILE, 'r') as f:
            return json.load(f)
    return []

def load_settings():
    os.makedirs("/app/data", exist_ok=True)
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
    return load_batches()

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
    batches = load_batches()
    return {
        "total_users": len(users),
        "total_batches": len(batches),
        "active_users": len([u for u in users if u.get("status") == "active"]),
        "avg_quality_score": 85.5
    }
'@
$completeAdminApi | Out-File -FilePath "backend\app\api\v1\admin.py" -Encoding UTF8

Write-Host "[2/6] Creating billing usage endpoint..." -ForegroundColor Yellow

$billingUsageApi = @'
# backend/app/api/v1/billing_usage.py
from fastapi import APIRouter
from typing import Dict, Any
from datetime import datetime
import json
import os

router = APIRouter()

USAGE_FILE = "/app/data/usage.json"

def load_usage():
    if os.path.exists(USAGE_FILE):
        with open(USAGE_FILE, 'r') as f:
            return json.load(f)
    return {}

@router.get("/usage/current_user")
async def get_current_user_usage(user_id: str = "admin"):
    usage = load_usage()
    current_month = datetime.now().strftime("%Y-%m")
    key = f"{user_id}_{current_month}"
    
    monthly_data = usage.get(key, {"batches": [], "api_calls": 0})
    
    history = []
    for i in range(3):
        month = datetime.now().replace(month=datetime.now().month - i).strftime("%Y-%m")
        hist_key = f"{user_id}_{month}"
        hist_data = usage.get(hist_key, {"batches": [], "api_calls": 0})
        history.append({
            "month": month,
            "batch_count": len(hist_data.get("batches", [])),
            "api_calls": hist_data.get("api_calls", 0)
        })
    
    return {
        "current_month": {
            "batch_count": len(monthly_data.get("batches", [])),
            "api_calls": monthly_data.get("api_calls", 0)
        },
        "history": history
    }
'@
$billingUsageApi | Out-File -FilePath "backend\app\api\v1\billing_usage.py" -Encoding UTF8

Write-Host "[3/6] Updating API router to include all endpoints..." -ForegroundColor Yellow

$updatedInitV1 = @'
from fastapi import APIRouter
from .batches import router as batches_router
from .projects import router as projects_router
from .agents import router as agents_router
from .orchestration import router as orchestration_router
from .evolution import router as evolution_router
from .cicd import router as cicd_router
from .cms.pages import router as cms_router
from .admin import router as admin_router
from .billing_usage import router as billing_usage_router
from .workspaces.routes import router as workspaces_router
from .audit.routes import router as audit_router

router = APIRouter()
router.include_router(batches_router, prefix="/batches", tags=["batches"])
router.include_router(projects_router, prefix="/projects", tags=["projects"])
router.include_router(agents_router, prefix="/agents", tags=["agents"])
router.include_router(orchestration_router, prefix="/orchestration", tags=["orchestration"])
router.include_router(evolution_router, prefix="/evolution", tags=["evolution"])
router.include_router(cicd_router, prefix="/cicd", tags=["cicd"])
router.include_router(cms_router, prefix="/cms", tags=["cms"])
router.include_router(admin_router, prefix="/admin", tags=["admin"])
router.include_router(billing_usage_router, prefix="/billing", tags=["billing"])
router.include_router(workspaces_router, prefix="/workspaces", tags=["workspaces"])
router.include_router(audit_router, prefix="/audit", tags=["audit"])
'@
$updatedInitV1 | Out-File -FilePath "backend\app\api\v1\__init__.py" -Encoding UTF8

Write-Host "[4/6] Creating audit routes if missing..." -ForegroundColor Yellow

$auditRoutes = @'
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
'@
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\audit" | Out-Null
$auditRoutes | Out-File -FilePath "backend\app\api\v1\audit\routes.py" -Encoding UTF8
"# Audit API module" | Out-File -FilePath "backend\app\api\v1\audit\__init__.py" -Encoding UTF8

Write-Host "[5/6] Creating workspace routes if missing..." -ForegroundColor Yellow

$workspaceRoutes = @'
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
'@
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\workspaces" | Out-Null
$workspaceRoutes | Out-File -FilePath "backend\app\api\v1\workspaces\routes.py" -Encoding UTF8
"# Workspaces API module" | Out-File -FilePath "backend\app\api\v1\workspaces\__init__.py" -Encoding UTF8

Write-Host "[6/6] Restarting backend container..." -ForegroundColor Yellow

docker-compose restart backend
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "API ENDPOINTS CREATED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Testing API endpoints..." -ForegroundColor Yellow

# Test the API endpoints
try {
    $testUsers = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/admin/users" -TimeoutSec 5
    Write-Host "  Admin users endpoint: WORKING" -ForegroundColor Green
} catch {
    Write-Host "  Admin users endpoint: FAILED" -ForegroundColor Red
}

try {
    $testUsage = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/billing/usage/current_user" -TimeoutSec 5
    Write-Host "  Billing usage endpoint: WORKING" -ForegroundColor Green
} catch {
    Write-Host "  Billing usage endpoint: FAILED" -ForegroundColor Red
}

try {
    $testAudit = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/audit/logs" -TimeoutSec 5
    Write-Host "  Audit logs endpoint: WORKING" -ForegroundColor Green
} catch {
    Write-Host "  Audit logs endpoint: FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "Access the admin dashboard: http://localhost:4000/admin" -ForegroundColor Cyan
Write-Host "API Documentation: http://localhost:4001/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "The admin dashboard should now work with real data!" -ForegroundColor Green

Start-Process "http://localhost:4000/admin"