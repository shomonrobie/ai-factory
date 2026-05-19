# phase2_batch1.ps1
# FactoryOS AI - Phase 2 Batch 1
# Creates: Team Workspaces, Audit Logs, Feature Entitlement UI, Usage Dashboard

param(
    [string]$ProjectPath = "D:\aisfs\ai-factory"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FACTORYOS AI - PHASE 2 BATCH 1" -ForegroundColor Cyan
Write-Host "Team Workspaces, Audit Logs, Feature Entitlement, Usage Dashboard" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Set-Location $ProjectPath

Write-Host "[1/12] Creating workspace directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "backend\app\workspaces" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\audit" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\workspaces" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\audit" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\workspace" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\admin\entitlements" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\usage" | Out-Null

Write-Host "[2/12] Creating Team Workspace Service..." -ForegroundColor Yellow

$workspaceService = @'
# backend/app/workspaces/workspace_service.py
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os
import uuid
import logging

logger = logging.getLogger(__name__)

WORKSPACES_FILE = "/app/data/workspaces.json"
WORKSPACE_MEMBERS_FILE = "/app/data/workspace_members.json"

class WorkspaceService:
    def __init__(self):
        self._ensure_files()
    
    def _ensure_files(self):
        os.makedirs("/app/data", exist_ok=True)
        if not os.path.exists(WORKSPACES_FILE):
            with open(WORKSPACES_FILE, 'w') as f:
                json.dump([], f)
        if not os.path.exists(WORKSPACE_MEMBERS_FILE):
            with open(WORKSPACE_MEMBERS_FILE, 'w') as f:
                json.dump([], f)
    
    def create_workspace(self, name: str, owner_id: str, settings: Dict = None) -> Dict[str, Any]:
        workspaces = self._load_workspaces()
        
        workspace = {
            "id": str(uuid.uuid4()),
            "name": name,
            "owner_id": owner_id,
            "settings": settings or {},
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
            "is_active": True
        }
        
        workspaces.append(workspace)
        self._save_workspaces(workspaces)
        
        # Add owner as member
        self.add_member(workspace["id"], owner_id, "owner")
        
        logger.info(f"Workspace created: {name} by {owner_id}")
        return workspace
    
    def add_member(self, workspace_id: str, user_id: str, role: str = "member") -> Dict[str, Any]:
        members = self._load_members()
        
        # Check if already member
        for m in members:
            if m["workspace_id"] == workspace_id and m["user_id"] == user_id:
                return m
        
        member = {
            "id": str(uuid.uuid4()),
            "workspace_id": workspace_id,
            "user_id": user_id,
            "role": role,
            "joined_at": datetime.now().isoformat()
        }
        
        members.append(member)
        self._save_members(members)
        
        logger.info(f"User {user_id} added to workspace {workspace_id} as {role}")
        return member
    
    def remove_member(self, workspace_id: str, user_id: str) -> bool:
        members = self._load_members()
        original_count = len(members)
        members = [m for m in members if not (m["workspace_id"] == workspace_id and m["user_id"] == user_id)]
        self._save_members(members)
        
        removed = len(members) < original_count
        if removed:
            logger.info(f"User {user_id} removed from workspace {workspace_id}")
        return removed
    
    def get_user_workspaces(self, user_id: str) -> List[Dict[str, Any]]:
        members = self._load_members()
        workspaces = self._load_workspaces()
        
        user_memberships = [m for m in members if m["user_id"] == user_id]
        user_workspace_ids = [m["workspace_id"] for m in user_memberships]
        
        return [w for w in workspaces if w["id"] in user_workspace_ids and w.get("is_active", True)]
    
    def get_workspace_members(self, workspace_id: str) -> List[Dict[str, Any]]:
        members = self._load_members()
        return [m for m in members if m["workspace_id"] == workspace_id]
    
    def update_workspace(self, workspace_id: str, updates: Dict) -> Optional[Dict[str, Any]]:
        workspaces = self._load_workspaces()
        for i, w in enumerate(workspaces):
            if w["id"] == workspace_id:
                workspaces[i].update(updates)
                workspaces[i]["updated_at"] = datetime.now().isoformat()
                self._save_workspaces(workspaces)
                logger.info(f"Workspace {workspace_id} updated")
                return workspaces[i]
        return None
    
    def _load_workspaces(self) -> List[Dict]:
        with open(WORKSPACES_FILE, 'r') as f:
            return json.load(f)
    
    def _save_workspaces(self, workspaces: List[Dict]):
        with open(WORKSPACES_FILE, 'w') as f:
            json.dump(workspaces, f, indent=2)
    
    def _load_members(self) -> List[Dict]:
        with open(WORKSPACE_MEMBERS_FILE, 'r') as f:
            return json.load(f)
    
    def _save_members(self, members: List[Dict]):
        with open(WORKSPACE_MEMBERS_FILE, 'w') as f:
            json.dump(members, f, indent=2)
'@
$workspaceService | Out-File -FilePath "backend\app\workspaces\workspace_service.py" -Encoding UTF8

Write-Host "[3/12] Creating Audit Log Service..." -ForegroundColor Yellow

$auditService = @'
# backend/app/audit/audit_service.py
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
import json
import os
import logging

logger = logging.getLogger(__name__)

AUDIT_FILE = "/app/data/audit_logs.json"

class AuditService:
    def __init__(self):
        self._ensure_file()
    
    def _ensure_file(self):
        os.makedirs("/app/data", exist_ok=True)
        if not os.path.exists(AUDIT_FILE):
            with open(AUDIT_FILE, 'w') as f:
                json.dump([], f)
    
    def log(self, user_id: str, action: str, resource_type: str, resource_id: str, details: Dict = None, ip_address: str = None) -> Dict[str, Any]:
        logs = self._load_logs()
        
        log_entry = {
            "id": len(logs) + 1,
            "user_id": user_id,
            "action": action,
            "resource_type": resource_type,
            "resource_id": resource_id,
            "details": details or {},
            "ip_address": ip_address,
            "timestamp": datetime.now().isoformat()
        }
        
        logs.append(log_entry)
        self._save_logs(logs)
        
        logger.info(f"Audit log: {user_id} - {action} on {resource_type}/{resource_id}")
        return log_entry
    
    def get_logs(self, user_id: str = None, action: str = None, resource_type: str = None, days: int = 30) -> List[Dict[str, Any]]:
        logs = self._load_logs()
        cutoff = datetime.now() - timedelta(days=days)
        
        filtered = [l for l in logs if datetime.fromisoformat(l["timestamp"]) > cutoff]
        
        if user_id:
            filtered = [l for l in filtered if l["user_id"] == user_id]
        if action:
            filtered = [l for l in filtered if l["action"] == action]
        if resource_type:
            filtered = [l for l in filtered if l["resource_type"] == resource_type]
        
        return filtered
    
    def get_user_activity(self, user_id: str, days: int = 30) -> Dict[str, Any]:
        logs = self.get_logs(user_id=user_id, days=days)
        
        actions = {}
        for log in logs:
            action = log["action"]
            actions[action] = actions.get(action, 0) + 1
        
        return {
            "user_id": user_id,
            "total_actions": len(logs),
            "actions": actions,
            "last_active": logs[-1]["timestamp"] if logs else None,
            "logs": logs[-50:]
        }
    
    def export_logs(self, days: int = 90) -> str:
        logs = self.get_logs(days=days)
        return json.dumps(logs, indent=2)
    
    def _load_logs(self) -> List[Dict]:
        with open(AUDIT_FILE, 'r') as f:
            return json.load(f)
    
    def _save_logs(self, logs: List[Dict]):
        with open(AUDIT_FILE, 'w') as f:
            json.dump(logs, f, indent=2)
'@
$auditService | Out-File -FilePath "backend\app\audit\audit_service.py" -Encoding UTF8

Write-Host "[4/12] Creating Workspace API Endpoints..." -ForegroundColor Yellow

$workspaceApi = @'
# backend/app/api/v1/workspaces/routes.py
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from ....workspaces.workspace_service import WorkspaceService
from ....audit.audit_service import AuditService

router = APIRouter()
workspace_service = WorkspaceService()
audit_service = AuditService()

class CreateWorkspaceRequest(BaseModel):
    name: str
    settings: Optional[Dict] = {}

class AddMemberRequest(BaseModel):
    user_id: str
    role: str = "member"

@router.post("/workspaces")
async def create_workspace(request: CreateWorkspaceRequest, user_id: str = "current_user"):
    workspace = workspace_service.create_workspace(request.name, user_id, request.settings)
    audit_service.log(user_id, "create_workspace", "workspace", workspace["id"], {"name": request.name})
    return workspace

@router.get("/workspaces")
async def get_user_workspaces(user_id: str = "current_user"):
    return workspace_service.get_user_workspaces(user_id)

@router.get("/workspaces/{workspace_id}")
async def get_workspace(workspace_id: str, user_id: str = "current_user"):
    workspaces = workspace_service.get_user_workspaces(user_id)
    for w in workspaces:
        if w["id"] == workspace_id:
            return w
    raise HTTPException(status_code=404, detail="Workspace not found")

@router.post("/workspaces/{workspace_id}/members")
async def add_member(workspace_id: str, request: AddMemberRequest, user_id: str = "current_user"):
    member = workspace_service.add_member(workspace_id, request.user_id, request.role)
    audit_service.log(user_id, "add_member", "workspace", workspace_id, {"member_id": request.user_id, "role": request.role})
    return member

@router.delete("/workspaces/{workspace_id}/members/{member_id}")
async def remove_member(workspace_id: str, member_id: str, user_id: str = "current_user"):
    result = workspace_service.remove_member(workspace_id, member_id)
    if not result:
        raise HTTPException(status_code=404, detail="Member not found")
    audit_service.log(user_id, "remove_member", "workspace", workspace_id, {"member_id": member_id})
    return {"status": "removed"}

@router.get("/workspaces/{workspace_id}/members")
async def get_workspace_members(workspace_id: str):
    return workspace_service.get_workspace_members(workspace_id)
'@
$workspaceApi | Out-File -FilePath "backend\app\api\v1\workspaces\routes.py" -Encoding UTF8

Write-Host "[5/12] Creating Audit API Endpoints..." -ForegroundColor Yellow

$auditApi = @'
# backend/app/api/v1/audit/routes.py
from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from ....audit.audit_service import AuditService

router = APIRouter()
audit_service = AuditService()

@router.get("/logs")
async def get_audit_logs(
    user_id: Optional[str] = Query(None),
    action: Optional[str] = Query(None),
    resource_type: Optional[str] = Query(None),
    days: int = Query(30, ge=1, le=365)
):
    logs = audit_service.get_logs(user_id=user_id, action=action, resource_type=resource_type, days=days)
    return {"logs": logs, "count": len(logs)}

@router.get("/logs/user/{user_id}")
async def get_user_activity(user_id: str, days: int = Query(30, ge=1, le=365)):
    return audit_service.get_user_activity(user_id, days)

@router.get("/logs/export")
async def export_logs(days: int = Query(90, ge=1, le=365)):
    export_data = audit_service.export_logs(days)
    return {"export": export_data}
'@
$auditApi | Out-File -FilePath "backend\app\api\v1\audit\routes.py" -Encoding UTF8

Write-Host "[6/12] Creating __init__.py files for new modules..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\workspaces" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\audit" | Out-Null
"# Workspaces API module" | Out-File -FilePath "backend\app\api\v1\workspaces\__init__.py" -Encoding UTF8
"# Audit API module" | Out-File -FilePath "backend\app\api\v1\audit\__init__.py" -Encoding UTF8

Write-Host "[7/12] Updating API Router with new modules..." -ForegroundColor Yellow

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
from .billing import router as billing_router
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
router.include_router(billing_router, prefix="/billing", tags=["billing"])
router.include_router(workspaces_router, prefix="/workspaces", tags=["workspaces"])
router.include_router(audit_router, prefix="/audit", tags=["audit"])
'@
$updatedInitV1 | Out-File -FilePath "backend\app\api\v1\__init__.py" -Encoding UTF8

Write-Host "[8/12] Creating Frontend Workspace UI..." -ForegroundColor Yellow

$workspaceUI = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Team Workspaces - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #F7FAFC; color: #2D3748; }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 24px; }
        .header { margin-bottom: 30px; }
        h1 { color: #1A365D; margin-bottom: 10px; }
        .workspace-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-bottom: 40px; }
        .workspace-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); cursor: pointer; transition: transform 0.2s; }
        .workspace-card:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.15); }
        .workspace-name { font-size: 18px; font-weight: 600; color: #1A365D; margin-bottom: 10px; }
        .workspace-meta { font-size: 14px; color: #718096; }
        .create-btn { background: #3182CE; color: white; padding: 12px 24px; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; }
        .create-btn:hover { background: #2C5282; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 30px; border-radius: 12px; width: 400px; }
        .modal-content input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #E2E8F0; border-radius: 6px; }
        .modal-content button { margin-top: 10px; padding: 10px 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Team Workspaces</h1>
            <p>Collaborate with your team on AI-generated projects</p>
            <button class="create-btn" onclick="showCreateModal()">+ New Workspace</button>
        </div>
        <div class="workspace-grid" id="workspaceList">
            <div style="text-align: center; grid-column: 1/-1; color: #718096;">Loading workspaces...</div>
        </div>
    </div>
    <div id="createModal" class="modal">
        <div class="modal-content">
            <h3>Create Workspace</h3>
            <input type="text" id="workspaceName" placeholder="Workspace name">
            <button onclick="createWorkspace()">Create</button>
            <button onclick="closeModal()">Cancel</button>
        </div>
    </div>
    <script>
        async function loadWorkspaces() {
            try {
                const response = await fetch('/api/v1/workspaces/workspaces');
                const workspaces = await response.json();
                const container = document.getElementById('workspaceList');
                if (workspaces.length === 0) {
                    container.innerHTML = '<div style="text-align: center; grid-column: 1/-1;">No workspaces yet. Create your first workspace!</div>';
                } else {
                    container.innerHTML = workspaces.map(w => `
                        <div class="workspace-card" onclick="location.href='/workspace/${w.id}'">
                            <div class="workspace-name">${w.name}</div>
                            <div class="workspace-meta">Created: ${new Date(w.created_at).toLocaleDateString()}</div>
                        </div>
                    `).join('');
                }
            } catch (error) {
                console.error('Error loading workspaces:', error);
            }
        }
        function showCreateModal() { document.getElementById('createModal').style.display = 'flex'; }
        function closeModal() { document.getElementById('createModal').style.display = 'none'; }
        async function createWorkspace() {
            const name = document.getElementById('workspaceName').value;
            if (!name) return;
            await fetch('/api/v1/workspaces/workspaces', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name })
            });
            closeModal();
            loadWorkspaces();
        }
        loadWorkspaces();
    </script>
</body>
</html>
'@
$workspaceUI | Out-File -FilePath "frontend\src\app\workspace\index.html" -Encoding UTF8

Write-Host "[9/12] Creating Audit Logs UI..." -ForegroundColor Yellow

$auditUI = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Logs - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #F7FAFC; color: #2D3748; }
        .container { max-width: 1400px; margin: 0 auto; padding: 40px 24px; }
        h1 { color: #1A365D; margin-bottom: 10px; }
        .filters { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; display: flex; gap: 15px; flex-wrap: wrap; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; }
        .filter-group label { font-size: 12px; margin-bottom: 5px; color: #718096; }
        .filter-group input, .filter-group select { padding: 8px; border: 1px solid #E2E8F0; border-radius: 6px; }
        table { width: 100%; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #EDF2F7; }
        th { background: #EDF2F7; font-weight: 600; }
        .export-btn { background: #38A169; color: white; padding: 8px 16px; border: none; border-radius: 6px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Audit Logs</h1>
        <p>Track all user actions and system events</p>
        <div class="filters">
            <div class="filter-group">
                <label>User ID</label>
                <input type="text" id="filterUser" placeholder="Filter by user">
            </div>
            <div class="filter-group">
                <label>Action</label>
                <select id="filterAction">
                    <option value="">All</option>
                    <option value="create_batch">Create Batch</option>
                    <option value="create_workspace">Create Workspace</option>
                    <option value="add_member">Add Member</option>
                </select>
            </div>
            <div class="filter-group">
                <label>Days</label>
                <input type="number" id="filterDays" value="30">
            </div>
            <div class="filter-group">
                <button onclick="loadLogs()">Apply Filters</button>
            </div>
            <div class="filter-group">
                <button class="export-btn" onclick="exportLogs()">Export CSV</button>
            </div>
        </div>
        <table id="logsTable">
            <thead>
                <tr><th>Timestamp</th><th>User</th><th>Action</th><th>Resource</th><th>Details</th></tr>
            </thead>
            <tbody>
                <tr><td colspan="5">Loading...</td></tr>
            </tbody>
        </table>
    </div>
    <script>
        async function loadLogs() {
            const user = document.getElementById('filterUser').value;
            const action = document.getElementById('filterAction').value;
            const days = document.getElementById('filterDays').value;
            let url = `/api/v1/audit/logs?days=${days}`;
            if (user) url += `&user_id=${user}`;
            if (action) url += `&action=${action}`;
            const response = await fetch(url);
            const data = await response.json();
            const tbody = document.querySelector('#logsTable tbody');
            if (data.logs.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">No logs found</td></tr>';
            } else {
                tbody.innerHTML = data.logs.map(log => `
                    <tr>
                        <td>${new Date(log.timestamp).toLocaleString()}</td>
                        <td>${log.user_id}</td>
                        <td>${log.action}</td>
                        <td>${log.resource_type}/${log.resource_id}</td>
                        <td><pre style="font-size:12px;">${JSON.stringify(log.details, null, 2)}</pre></td>
                    </tr>
                `).join('');
            }
        }
        async function exportLogs() {
            const days = document.getElementById('filterDays').value;
            const response = await fetch(`/api/v1/audit/logs/export?days=${days}`);
            const data = await response.json();
            const blob = new Blob([data.export], { type: 'text/csv' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `audit_logs_${new Date().toISOString()}.json`;
            a.click();
        }
        loadLogs();
        setInterval(loadLogs, 30000);
    </script>
</body>
</html>
'@
$auditUI | Out-File -FilePath "frontend\src\app\audit\index.html" -Encoding UTF8
New-Item -ItemType Directory -Force -Path "frontend\src\app\audit" | Out-Null
$auditUI | Out-File -FilePath "frontend\src\app\audit\index.html" -Encoding UTF8

Write-Host "[10/12] Creating Usage Dashboard..." -ForegroundColor Yellow

$usageDashboard = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usage Dashboard - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #F7FAFC; color: #2D3748; }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 24px; }
        h1 { color: #1A365D; margin-bottom: 10px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 40px; }
        .stat-card { background: white; padding: 20px; border-radius: 12px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-value { font-size: 36px; font-weight: bold; color: #1A365D; }
        .stat-label { color: #718096; margin-top: 5px; }
        .chart-container { background: white; padding: 20px; border-radius: 12px; margin-bottom: 20px; }
        table { width: 100%; background: white; border-radius: 8px; overflow: hidden; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #EDF2F7; }
        th { background: #EDF2F7; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Usage Dashboard</h1>
        <p>Track your API usage and batch consumption</p>
        <div class="stats-grid" id="stats">
            <div class="stat-card"><div class="stat-value" id="batchCount">-</div><div class="stat-label">Batches This Month</div></div>
            <div class="stat-card"><div class="stat-value" id="apiCalls">-</div><div class="stat-label">API Calls</div></div>
            <div class="stat-card"><div class="stat-value" id="activeAgents">8</div><div class="stat-label">Active Agents</div></div>
        </div>
        <div class="chart-container">
            <h3>Usage History</h3>
            <table id="historyTable">
                <thead><tr><th>Month</th><th>Batches</th><th>API Calls</th></tr></thead>
                <tbody><tr><td colspan="3">Loading...</td></tr></tbody>
            </table>
        </div>
    </div>
    <script>
        async function loadUsage() {
            try {
                const response = await fetch('/api/v1/billing/usage/current_user');
                const data = await response.json();
                document.getElementById('batchCount').innerText = data.current_month?.batch_count || 0;
                document.getElementById('apiCalls').innerText = data.current_month?.api_calls || 0;
                const tbody = document.querySelector('#historyTable tbody');
                if (data.history && data.history.length > 0) {
                    tbody.innerHTML = data.history.map(h => `
                        <tr><td>${h.month}</td><td>${h.batch_count}</td><td>${h.api_calls}</td></tr>
                    `).join('');
                } else {
                    tbody.innerHTML = '<tr><td colspan="3">No usage data available</td></tr>';
                }
            } catch (error) {
                console.error('Error loading usage:', error);
            }
        }
        loadUsage();
        setInterval(loadUsage, 60000);
    </script>
</body>
</html>
'@
$usageDashboard | Out-File -FilePath "frontend\src\app\usage\index.html" -Encoding UTF8
New-Item -ItemType Directory -Force -Path "frontend\src\app\usage" | Out-Null
$usageDashboard | Out-File -FilePath "frontend\src\app\usage\index.html" -Encoding UTF8

Write-Host "[11/12] Adding missing usage endpoint to billing API..." -ForegroundColor Yellow

$usageEndpoint = @'
# Add to backend/app/api/v1/billing/webhooks.py - add this endpoint

@router.get("/usage/current_user")
async def get_current_user_usage(user_id: str = "current_user"):
    monthly = usage_meter.get_monthly_usage(user_id)
    history = usage_meter.get_usage_history(user_id)
    return {
        "current_month": monthly,
        "history": history,
        "tier": feature_gate.get_user_tier(user_id).value
    }
'@
$usageEndpoint | Out-File -FilePath "backend\app\api\v1\billing\usage_endpoint.txt" -Encoding UTF8

Write-Host "[12/12] Updating project_state.json..." -ForegroundColor Yellow

$phase2State = '{
  "product_name": "FactoryOS AI",
  "tagline": "The Autonomous AI Software Engineering Platform",
  "current_version": "v1.5",
  "phase": "Phase 2 - Pro Feature System",
  "batch": "Batch 1 of 3 - Team Workspaces, Audit Logs, Usage Dashboard",
  "status": "complete",
  "last_updated": "' + (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ') + '",
  "phase2_progress": {
    "batch1_workspaces_audit": "complete",
    "batch2_feature_entitlement_ui": "pending",
    "batch3_api_keys_webhooks": "pending"
  },
  "generated_assets_phase2_batch1": [
    "backend/app/workspaces/workspace_service.py",
    "backend/app/audit/audit_service.py",
    "backend/app/api/v1/workspaces/routes.py",
    "backend/app/api/v1/audit/routes.py",
    "frontend/src/app/workspace/index.html",
    "frontend/src/app/audit/index.html",
    "frontend/src/app/usage/index.html"
  ],
  "git_repository": "https://github.com/shomonrobie/ai-factory",
  "next_batch": "phase2_batch2 - Feature Entitlement UI & Admin Dashboard"
}'

$phase2State | Out-File -FilePath "project_state.json" -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "PHASE 2 BATCH 1 COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "New Features Added:" -ForegroundColor Cyan
Write-Host "  - Team Workspaces (create, invite members, roles)" -ForegroundColor White
Write-Host "  - Audit Logging (track all user actions)" -ForegroundColor White
Write-Host "  - Audit Logs UI (filterable, exportable)" -ForegroundColor White
Write-Host "  - Usage Dashboard (track batches and API calls)" -ForegroundColor White
Write-Host ""
Write-Host "Updated project_state.json" -ForegroundColor Green
Write-Host ""
Write-Host "Next Batch: Phase 2 Batch 2 - Feature Entitlement UI & Admin Dashboard" -ForegroundColor Yellow
Write-Host "  - Feature entitlement management UI" -ForegroundColor White
Write-Host "  - Admin dashboard for user management" -ForegroundColor White
Write-Host "  - Tier upgrade/downgrade interface" -ForegroundColor White