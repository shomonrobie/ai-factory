from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from .api.v1 import router as api_v1_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI Software Factory", version="1.3.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_v1_router, prefix="/api/v1")

@app.get("/health")
async def health_check():
    logger.info("Health check called - v1.3")
    return {"status": "healthy", "version": "1.3.0"}

@app.get("/")
async def root():
    return {
        "message": "AI Software Factory API",
        "version": "1.3.0",
        "endpoints": [
            "/health",
            "/api/v1/batches/",
            "/api/v1/projects/",
            "/api/v1/agents/",
            "/api/v1/orchestration/plan",
            "/api/v1/orchestration/orchestrate"
        ]
    }