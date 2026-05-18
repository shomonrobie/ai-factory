from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI Software Factory", version="1.2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    logger.info("Health check called")
    return {"status": "healthy", "version": "1.2.0"}

@app.get("/")
async def root():
    return {"message": "AI Software Factory API", "version": "1.2.0"}

@app.get("/api/v1/agents/")
async def list_agents():
    return {"agents": ["code_generator", "architect", "backend"]}

@app.post("/api/v1/agents/execute")
async def execute_agent(request: dict):
    return {
        "success": True,
        "agent_type": request.get("agent_type", "unknown"),
        "output": {"message": "Agent executed successfully", "code": "# Generated code here"},
        "confidence": 85,
        "task_id": "test-123"
    }

@app.post("/api/v1/agents/generate")
async def generate_code(prompt: str = "", entity_name: str = "item"):
    return {
        "success": True,
        "agent_type": "code_generator",
        "output": {
            "code": f"# Generated code for: {prompt}\nclass {entity_name.capitalize()}:\n    pass",
            "language": "python"
        },
        "confidence": 85,
        "task_id": "gen-456"
    }

# Batch endpoints
@app.get("/api/v1/batches/")
async def list_batches():
    return []

@app.post("/api/v1/batches/")
async def create_batch(batch_data: dict):
    return {"id": 1, "status": "created", "batch_number": batch_data.get("batch_number")}

@app.get("/api/v1/projects/")
async def list_projects():
    return []

@app.post("/api/v1/projects/")
async def create_project(project_data: dict):
    return {"id": 1, "name": project_data.get("name"), "status": "active"}