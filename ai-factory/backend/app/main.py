from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from .api.v1 import router as api_v1_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FactoryOS AI",
    version="1.5.0",
    description="The Autonomous AI Software Engineering Platform"
)

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
    return {"status": "healthy", "version": "1.5.0"}

@app.get("/")
async def root():
    return {
        "message": "FactoryOS AI API",
        "version": "1.5.0",
        "features": [
            "Multi-Agent Orchestration",
            "Self-Improving System",
            "CI/CD Pipeline"
        ]
    }