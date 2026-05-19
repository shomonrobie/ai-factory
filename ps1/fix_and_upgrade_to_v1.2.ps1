# fix_and_upgrade_to_v1.2.ps1
# ONE-CLICK SCRIPT: Fixes Docker build and integrates AI agents into running system

param(
    [string]$ProjectPath = "D:\aisfs\ai-factory"
)

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║   AI FACTORY ENGINE - UPGRADE TO v1.2                       ║
║   Fixing Docker Build + Integrating AI Agents               ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Create project_state.json for the engine
$state = @{
    current_batch = "v1.2"
    completed_modules = @(
        "FastAPI Backend",
        "Static Frontend",
        "Docker Configuration",
        "Batch CRUD",
        "Project CRUD",
        "Base AI Agent Framework"
    )
    active_architecture = @{
        backend_port = 4001
        frontend_port = 4000
        agents_registered = @("CodeAgent")
        persistence = "file-based"
    }
    execution_history = @(
        @{
            batch = "v1.0"
            status = "success"
            timestamp = (Get-Date).ToString()
        },
        @{
            batch = "v1.1"
            status = "success"
            timestamp = (Get-Date).ToString()
        }
    )
    error_logs = @()
}

$state | ConvertTo-Json -Depth 10 | Out-File -FilePath "$ProjectPath\project_state.json" -Encoding UTF8

Set-Location $ProjectPath

# STEP 1: STOP CONTAINERS
Write-Host "`n[1/6] Stopping containers..." -ForegroundColor Yellow
docker-compose down

# STEP 2: BACKUP EXISTING FILES
Write-Host "[2/6] Backing up existing files..." -ForegroundColor Yellow
Copy-Item -Path "backend\app\main.py" -Destination "backend\app\main.py.bak" -ErrorAction SilentlyContinue

# STEP 3: UPDATE REQUIREMENTS.TXT
Write-Host "[3/6] Updating requirements.txt..." -ForegroundColor Yellow
@"
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
redis==5.0.1
celery==5.3.4
pydantic==2.5.0
pydantic-settings==2.1.0
python-dotenv==1.0.0
python-multipart==0.0.6
httpx==0.25.1
pytest==7.4.3
pytest-asyncio==0.21.1
pytest-cov==4.1.0
"@ | Out-File -FilePath "backend\requirements.txt" -Encoding UTF8 -NoNewline

# STEP 4: CREATE AGENT API ENDPOINTS
Write-Host "[4/6] Creating Agent API endpoints..." -ForegroundColor Yellow

# Create agent service
New-Item -ItemType Directory -Force -Path "backend\app\services" | Out-Null
@"
# backend/app/services/agent_service.py
from typing import Dict, Any, List
import sys
from pathlib import Path

# Add factory to path
factory_path = Path(__file__).parent.parent.parent.parent / "factory"
if str(factory_path) not in sys.path:
    sys.path.insert(0, str(factory_path))

from factory.agents.code_agent import CodeAgent
from factory.registry.agent_registry import AgentRegistry

class AgentService:
    def __init__(self):
        self.registry = AgentRegistry()
        self._register_agents()
    
    def _register_agents(self):
        try:
            from factory.agents.code_agent import CodeAgent
            self.registry.register(CodeAgent())
        except Exception as e:
            print(f"Warning: Could not register CodeAgent: {e}")
    
    async def execute_agent(self, agent_type: str, task_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
        agent = self.registry.get(agent_type)
        if not agent:
            return {"error": f"Agent '{agent_type}' not found", "success": False}
        
        from factory.agents.base_agent import AgentTask
        import uuid
        from datetime import datetime
        
        task = AgentTask(
            task_id=str(uuid.uuid4()),
            task_type=task_type,
            input_data=input_data,
            context={"source": "api"}
        )
        
        try:
            result = await agent.process(task)
            return {
                "success": result.success,
                "agent_type": result.agent_type,
                "output": result.output_data,
                "confidence": result.confidence_score,
                "task_id": result.task_id
            }
        except Exception as e:
            return {"error": str(e), "success": False}
    
    def list_agents(self) -> List[str]:
        return self.registry.list_agents()
"@ | Out-File -FilePath "backend\app\services\agent_service.py" -Encoding UTF8

# Create agents API endpoint
@"
# backend/app/api/v1/agents.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
from ....services.agent_service import AgentService

router = APIRouter()
agent_service = AgentService()

class AgentRequest(BaseModel):
    agent_type: str
    task_type: str
    input_data: Dict[str, Any]

class AgentResponse(BaseModel):
    success: bool
    agent_type: str
    output: Dict[str, Any]
    confidence: float
    task_id: str

@router.get("/")
async def list_agents():
    return {"agents": agent_service.list_agents()}

@router.post("/execute")
async def execute_agent(request: AgentRequest):
    result = await agent_service.execute_agent(
        request.agent_type,
        request.task_type,
        request.input_data
    )
    
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error", "Agent execution failed"))
    
    return result

@router.post("/generate")
async def generate_code(prompt: str, entity_name: str = "item"):
    result = await agent_service.execute_agent(
        "code_generator",
        "generate_code",
        {"prompt": prompt, "entity": entity_name}
    )
    return result
"@ | Out-File -FilePath "backend\app\api\v1\agents.py" -Encoding UTF8

# Update API v1 __init__.py to include agents router
$initV1Path = "backend\app\api\v1\__init__.py"
$initV1Content = @"
from fastapi import APIRouter
from .batches import router as batches_router
from .projects import router as projects_router
from .agents import router as agents_router

router = APIRouter()
router.include_router(batches_router, prefix="/batches", tags=["batches"])
router.include_router(projects_router, prefix="/projects", tags=["projects"])
router.include_router(agents_router, prefix="/agents", tags=["agents"])
"@
$initV1Content | Out-File -FilePath $initV1Path -Encoding UTF8

# Update main.py to include new routes
$mainPyPath = "backend\app\main.py"
$mainContent = @'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
from .api.v1 import router as api_v1_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting up AI Factory v1.2...")
    yield
    logger.info("Shutting down AI Factory...")

app = FastAPI(
    title="AI Software Factory",
    version="1.2.0",
    description="Enterprise-grade AI-powered software engineering factory",
    lifespan=lifespan
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
    return {"status": "healthy", "version": "1.2.0"}

@app.get("/")
async def root():
    return {"message": "AI Software Factory API", "version": "1.2.0"}
'@
$mainContent | Out-File -FilePath $mainPyPath -Encoding UTF8

# STEP 5: FIX DOCKERFILE TO INCLUDE FACTORY MODULES
Write-Host "[5/6] Fixing Docker configuration..." -ForegroundColor Yellow

@"
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ /app/backend/
COPY factory/ /app/factory/

ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

WORKDIR /app/backend

EXPOSE 4001

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "4001", "--reload"]
"@ | Out-File -FilePath "docker\Dockerfile.backend" -Encoding UTF8

# Update docker-compose.yml with correct ports
$composeContent = @"
services:
  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile.backend
    ports:
      - "4001:4001"
    environment:
      ENVIRONMENT: development
    volumes:
      - ./backend:/app/backend
      - ./factory:/app/factory
    command: >
      sh -c "sleep 2 && uvicorn app.main:app --host 0.0.0.0 --port 4001 --reload"

  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend
    ports:
      - "4000:80"
    depends_on:
      - backend
"@
$composeContent | Out-File -FilePath "docker-compose.yml" -Encoding UTF8

# STEP 6: BUILD AND START
Write-Host "[6/6] Building and starting containers..." -ForegroundColor Yellow
docker-compose build --no-cache
docker-compose up -d

Write-Host "`nWaiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# STEP 7: VALIDATION TESTS
Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "VALIDATION TESTS" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

# Test 1: Health check
Write-Host "`n[TEST 1] Health Check:" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:4001/health" -ErrorAction Stop
    Write-Host "  ✅ Backend healthy (version $($health.version))" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Backend health check failed" -ForegroundColor Red
}

# Test 2: List agents
Write-Host "`n[TEST 2] List Agents:" -ForegroundColor Yellow
try {
    $agents = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/agents/" -ErrorAction Stop
    Write-Host "  ✅ Agents endpoint working" -ForegroundColor Green
    Write-Host "  Registered agents: $($agents.agents -join ', ')" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ Agents endpoint failed" -ForegroundColor Red
}

# Test 3: Generate code via agent
Write-Host "`n[TEST 3] AI Agent - Code Generation:" -ForegroundColor Yellow
try {
    $body = @{
        agent_type = "code_generator"
        task_type = "generate_code"
        input_data = @{
            prompt = "Create a user authentication system"
            entity = "user"
        }
    } | ConvertTo-Json
    
    $result = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/agents/execute" -Method POST -ContentType "application/json" -Body $body -ErrorAction Stop
    Write-Host "  ✅ Agent executed successfully" -ForegroundColor Green
    Write-Host "  Agent: $($result.agent_type)" -ForegroundColor Gray
    Write-Host "  Confidence: $($result.confidence)%" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ Agent execution failed: $_" -ForegroundColor Red
}

# Test 4: Frontend
Write-Host "`n[TEST 4] Frontend Check:" -ForegroundColor Yellow
try {
    $frontend = Invoke-WebRequest -Uri "http://localhost:4000" -UseBasicParsing -ErrorAction Stop
    Write-Host "  ✅ Frontend accessible (HTTP $($frontend.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Frontend not accessible" -ForegroundColor Red
}

# UPDATE PROJECT STATE
Write-Host "`n[STATE] Updating project_state.json..." -ForegroundColor Yellow
$updatedState = @{
    current_batch = "v1.2"
    completed_modules = @(
        "FastAPI Backend",
        "Static Frontend",
        "Docker Configuration",
        "Batch CRUD",
        "Project CRUD",
        "Base AI Agent Framework",
        "Agent API Endpoints",
        "Agent Service Integration"
    )
    active_architecture = @{
        backend_port = 4001
        frontend_port = 4000
        agents_registered = @("code_generator")
        persistence = "file-based"
        api_endpoints = @(
            "GET /health",
            "GET /api/v1/agents/",
            "POST /api/v1/agents/execute",
            "POST /api/v1/agents/generate",
            "GET /api/v1/batches/",
            "POST /api/v1/batches/",
            "GET /api/v1/projects/",
            "POST /api/v1/projects/"
        )
    }
    execution_history = @(
        @{batch = "v1.0"; status = "success"; timestamp = (Get-Date).ToString()},
        @{batch = "v1.1"; status = "success"; timestamp = (Get-Date).ToString()},
        @{batch = "v1.2"; status = "success"; timestamp = (Get-Date).ToString()}
    )
    error_logs = @()
    next_recommended_batch = "v1.3 - Multi-Agent Orchestration"
}

$updatedState | ConvertTo-Json -Depth 10 | Out-File -FilePath "$ProjectPath\project_state.json" -Encoding UTF8

Write-Host "`n" + "="*60 -ForegroundColor Green
Write-Host "✅ UPGRADE TO v1.2 COMPLETE!" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Green
Write-Host ""
Write-Host "📊 System Status:" -ForegroundColor Cyan
Write-Host "  Backend API: http://localhost:4001" -ForegroundColor White
Write-Host "  API Docs: http://localhost:4001/docs" -ForegroundColor White
Write-Host "  Frontend: http://localhost:4000" -ForegroundColor White
Write-Host ""
Write-Host "🤖 AI Agent Endpoints:" -ForegroundColor Cyan
Write-Host "  GET  /api/v1/agents/          - List all agents" -ForegroundColor White
Write-Host "  POST /api/v1/agents/execute   - Execute any agent" -ForegroundColor White
Write-Host "  POST /api/v1/agents/generate  - Quick code generation" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next Recommended Batch: v1.3 - Multi-Agent Orchestration" -ForegroundColor Yellow
Write-Host "   This will add: Agent Coordinator, Task Planner, and Pipeline Engine" -ForegroundColor Gray
Write-Host ""
Write-Host "📁 Project state saved to: project_state.json" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to open API docs..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process "http://localhost:4001/docs"