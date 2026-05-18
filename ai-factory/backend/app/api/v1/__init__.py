from fastapi import APIRouter
from .batches import router as batches_router
from .projects import router as projects_router
from .agents import router as agents_router

router = APIRouter()
router.include_router(batches_router, prefix="/batches", tags=["batches"])
router.include_router(projects_router, prefix="/projects", tags=["projects"])
router.include_router(agents_router, prefix="/agents", tags=["agents"])
