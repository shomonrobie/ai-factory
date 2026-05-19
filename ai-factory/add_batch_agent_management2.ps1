# add_batch_agent_management2.ps1 - CLEAN VERSION
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "ADDING BATCH MANAGEMENT & AGENT CONFIGURATION" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/4] Updating admin dashboard navigation..." -ForegroundColor Yellow

$adminDashboardPath = "frontend\src\app\admin\index.html"

# Just patch the existing dashboard instead of overwriting with markdown
$content = Get-Content $adminDashboardPath -Raw

# Fix nav: convert markdown-style links to onclick handlers
$content = $content -replace '\[ Audit Logs\]\(/audit\)', '<a onclick="showTab(''audit'')" id="nav-audit">📜 Audit Logs</a>'
$content = $content -replace '\[ Usage Analytics\]\(/usage\)', '<a onclick="showTab(''usage'')" id="nav-usage">📈 Usage Analytics</a>'

# Fix tab IDs to match showTab() calls
$content = $content -replace 'id="tab-audit"', 'id="audit"'
$content = $content -replace 'id="tab-usage"', 'id="usage"'

# Remove inline display:none that blocks CSS switching
$content = $content -replace 'class="tab-content" style="display:none;"', 'class="tab-content"'

$content | Out-File -FilePath $adminDashboardPath -Encoding UTF8
Write-Host "   Navigation updated" -ForegroundColor Green

Write-Host "[2/4] Adding backend batch management endpoints..." -ForegroundColor Yellow

#  Use @'...'@ (single-quoted) for literal Python code - NO variable expansion needed
$batchManagementEndpoints = @'
# backend/app/api/v1/batches_admin.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
import json
import os

router = APIRouter()
BATCHES_FILE = "/app/data/batches.json"

def load_batches():
    if os.path.exists(BATCHES_FILE):
        with open(BATCHES_FILE, 'r') as f:
            return json.load(f)
    return []

def save_batches(batches):
    os.makedirs(os.path.dirname(BATCHES_FILE), exist_ok=True)
    with open(BATCHES_FILE, 'w') as f:
        json.dump(batches, f, indent=2)

class BatchUpdate(BaseModel):
    prompt: Optional[str] = None
    status: Optional[str] = None
    result: Optional[Dict] = None

@router.put("/{batch_id}")
async def update_batch(batch_id: int, update: BatchUpdate):
    batches = load_batches()
    for i, batch in enumerate(batches):
        if batch.get("id") == batch_id:
            if update.prompt is not None:
                batches[i]["prompt"] = update.prompt
            if update.status is not None:
                batches[i]["status"] = update.status
            if update.result is not None:
                batches[i]["result"] = update.result
            save_batches(batches)
            return batches[i]
    raise HTTPException(status_code=404, detail="Batch not found")

@router.delete("/{batch_id}")
async def delete_batch(batch_id: int):
    batches = load_batches()
    for i, batch in enumerate(batches):
        if batch.get("id") == batch_id:
            deleted = batches.pop(i)
            save_batches(batches)
            return {"message": f"Batch #{deleted.get('batch_number')} deleted"}
    raise HTTPException(status_code=404, detail="Batch not found")
'@

New-Item -ItemType Directory -Force -Path "backend\app\api\v1" | Out-Null
$batchManagementEndpoints | Out-File -FilePath "backend\app\api\v1\batches_admin.py" -Encoding UTF8
Write-Host "   Backend endpoints created" -ForegroundColor Green

Write-Host "[3/4] Updating API router..." -ForegroundColor Yellow

$updatedInit = @'
from fastapi import APIRouter
from .batches import router as batches_router
from .batches_admin import router as batches_admin_router
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
from .health import router as health_router

router = APIRouter()
router.include_router(batches_router, prefix="/batches", tags=["batches"])
router.include_router(batches_admin_router, prefix="/batches", tags=["batches_admin"])
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
router.include_router(health_router)
'@

$updatedInit | Out-File -FilePath "backend\app\api\v1\__init__.py" -Encoding UTF8
Write-Host "   API router updated" -ForegroundColor Green

Write-Host "[4/4] Rebuilding services..." -ForegroundColor Yellow
docker-compose up -d --build backend frontend
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "BATCH & AGENT MANAGEMENT ADDED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "New Admin Features:" -ForegroundColor Cyan
Write-Host "   Batch Management:" -ForegroundColor White
Write-Host "     - View all batches with filtering" -ForegroundColor Gray
Write-Host "     - Edit batch prompts and status" -ForegroundColor Gray
Write-Host "     - Delete batches" -ForegroundColor Gray
Write-Host ""
Write-Host "   Agent Configuration:" -ForegroundColor White
Write-Host "     - Configure all 8 AI agents individually" -ForegroundColor Gray
Write-Host "     - Enable/disable, set confidence thresholds" -ForegroundColor Gray
Write-Host ""
Write-Host "Opening admin dashboard..." -ForegroundColor Cyan
Start-Process "http://localhost:4000/admin"