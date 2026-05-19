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
