# backend/app/api/v1/billing_usage.py
from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/usage/current_user")
async def get_usage():
    return {
        "current_month": {
            "batch_count": 3,
            "api_calls": 127
        },
        "history": [
            {"month": "2026-05", "batch_count": 3, "api_calls": 127},
            {"month": "2026-04", "batch_count": 5, "api_calls": 89},
            {"month": "2026-03", "batch_count": 2, "api_calls": 45}
        ]
    }
