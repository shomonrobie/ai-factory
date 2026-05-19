# backend/app/api/v1/test.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/ping")
async def ping():
    return {"message": "pong", "status": "alive"}

@router.get("/health")
async def health():
    return {"status": "healthy", "timestamp": "2026-05-18"}
