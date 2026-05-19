# backend/app/api/v1/health.py
from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/health", tags=["Health"], summary="Health check endpoint")
async def health_check():
    """Return service health status"""
    return {
        "status": "healthy",
        "service": "ai-factory-backend",
        "version": "1.5.0",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }