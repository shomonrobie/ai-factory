# backend/app/api/v1/billing/__init__.py
from fastapi import APIRouter
from .webhooks import router as webhooks_router

router = APIRouter()
router.include_router(webhooks_router, prefix="/stripe", tags=["stripe"])
