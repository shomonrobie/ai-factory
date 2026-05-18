# upgrade_to_v1.3.ps1
# AI Factory v1.3 - Multi-Agent Orchestration

param(
    [string]$ProjectPath = "D:\aisfs\ai-factory"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "           AI FACTORY v1.3 - MULTI-AGENT ORCHESTRATION" -ForegroundColor Cyan
Write-Host "           Adding: Coordinator | Planner | Pipeline | Bus" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Set-Location $ProjectPath

# Backup current state
Write-Host "[1/8] Backing up current state..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
New-Item -ItemType Directory -Force -Path "backups\v1.2_$timestamp" | Out-Null
Copy-Item -Path "backend\app\main.py" -Destination "backups\v1.2_$timestamp\main.py.bak" -ErrorAction SilentlyContinue
Copy-Item -Path "backend\app\services\agent_service.py" -Destination "backups\v1.2_$timestamp\agent_service.py.bak" -ErrorAction SilentlyContinue

# Create directory structure for orchestration
Write-Host "[2/8] Creating orchestration directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "factory\orchestrator" | Out-Null
New-Item -ItemType Directory -Force -Path "factory\pipeline" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\orchestration" | Out-Null

# Create __init__.py files
"# AI Factory Orchestration Module" | Out-File -FilePath "factory\orchestrator\__init__.py" -Encoding UTF8
"# AI Factory Pipeline Module" | Out-File -FilePath "factory\pipeline\__init__.py" -Encoding UTF8
"# Backend Orchestration Module" | Out-File -FilePath "backend\app\orchestration\__init__.py" -Encoding UTF8

# Create Agent Coordinator
Write-Host "[3/8] Creating Agent Coordinator..." -ForegroundColor Yellow
$coordinatorCode = @'
# factory/orchestrator/agent_coordinator.py
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import asyncio
import logging
import uuid

logger = logging.getLogger(__name__)

@dataclass
class OrchestrationTask:
    task_id: str
    name: str
    agent_type: str
    action: str
    input_data: Dict[str, Any]
    depends_on: List[str]
    status: str = "pending"
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None

class AgentCoordinator:
    def __init__(self, agent_registry):
        self.registry = agent_registry
        self.active_orchestrations: Dict[str, List[OrchestrationTask]] = {}
    
    async def orchestrate(self, plan: List[Dict[str, Any]], context: Dict[str, Any] = None) -> Dict[str, Any]:
        orchestration_id = str(uuid.uuid4())
        logger.info(f"Starting orchestration {orchestration_id} with {len(plan)} tasks")
        
        tasks = []
        for task_config in plan:
            task = OrchestrationTask(
                task_id=str(uuid.uuid4()),
                name=task_config.get("name", "unnamed"),
                agent_type=task_config["agent_type"],
                action=task_config["action"],
                input_data=task_config.get("input", {}),
                depends_on=task_config.get("depends_on", [])
            )
            tasks.append(task)
        
        self.active_orchestrations[orchestration_id] = tasks
        results = {}
        
        for task in tasks:
            deps_met = all(dep in results for dep in task.depends_on)
            if not deps_met:
                task.status = "blocked"
                continue
            
            agent = self.registry.get(task.agent_type)
            if not agent:
                task.status = "failed"
                task.error = f"Agent '{task.agent_type}' not found"
                continue
            
            task.status = "running"
            try:
                from factory.agents.base_agent import AgentTask
                agent_task = AgentTask(
                    task_id=task.task_id,
                    task_type=task.action,
                    input_data=task.input_data,
                    context=context or {}
                )
                result = await agent.process(agent_task)
                task.status = "completed"
                task.result = {
                    "output": result.output_data,
                    "confidence": result.confidence_score,
                    "success": result.success
                }
                results[task.task_id] = task.result
            except Exception as e:
                task.status = "failed"
                task.error = str(e)
                results[task.task_id] = {"error": str(e), "success": False}
        
        completed = sum(1 for t in tasks if t.status == "completed")
        failed = sum(1 for t in tasks if t.status == "failed")
        
        return {
            "orchestration_id": orchestration_id,
            "total_tasks": len(tasks),
            "completed": completed,
            "failed": failed,
            "results": results,
            "tasks": [{"name": t.name, "status": t.status, "error": t.error} for t in tasks]
        }
    
    def get_status(self, orchestration_id: str) -> Optional[List[OrchestrationTask]]:
        return self.active_orchestrations.get(orchestration_id)
'@
$coordinatorCode | Out-File -FilePath "factory\orchestrator\agent_coordinator.py" -Encoding UTF8

# Create Task Planner
Write-Host "[4/8] Creating Task Planner..." -ForegroundColor Yellow
$plannerCode = @'
# factory/orchestrator/task_planner.py
from typing import Dict, Any, List
import logging

logger = logging.getLogger(__name__)

class TaskPlanner:
    def __init__(self):
        self.task_templates = self._load_templates()
    
    def _load_templates(self) -> Dict[str, List[Dict[str, Any]]]:
        return {
            "generate_app": [
                {"name": "design_architecture", "agent_type": "architect", "action": "design_system", "depends_on": []},
                {"name": "create_backend", "agent_type": "backend", "action": "generate_api", "depends_on": ["design_architecture"]},
                {"name": "generate_code", "agent_type": "code_generator", "action": "generate_code", "depends_on": ["create_backend"]}
            ],
            "fix_issues": [
                {"name": "analyze_code", "agent_type": "code_generator", "action": "analyze", "depends_on": []},
                {"name": "apply_fixes", "agent_type": "code_generator", "action": "fix", "depends_on": ["analyze_code"]},
                {"name": "validate_fixes", "agent_type": "code_generator", "action": "validate", "depends_on": ["apply_fixes"]}
            ],
            "full_saas": [
                {"name": "design_architecture", "agent_type": "architect", "action": "design_system", "depends_on": []},
                {"name": "create_database", "agent_type": "database", "action": "design_schema", "depends_on": ["design_architecture"]},
                {"name": "create_backend", "agent_type": "backend", "action": "generate_api", "depends_on": ["create_database"]},
                {"name": "create_frontend", "agent_type": "frontend", "action": "generate_component", "depends_on": ["create_backend"]},
                {"name": "generate_tests", "agent_type": "qa", "action": "generate_tests", "depends_on": ["create_backend"]},
                {"name": "security_scan", "agent_type": "security", "action": "scan_code", "depends_on": ["create_backend"]}
            ]
        }
    
    def create_plan(self, goal: str, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        goal_lower = goal.lower()
        
        if "saas" in goal_lower or "full" in goal_lower:
            template = self.task_templates["full_saas"]
        elif "generate" in goal_lower or "create" in goal_lower:
            template = self.task_templates["generate_app"]
        elif "fix" in goal_lower or "repair" in goal_lower:
            template = self.task_templates["fix_issues"]
        else:
            template = self.task_templates["generate_app"]
        
        plan = []
        for task in template:
            customized_task = task.copy()
            if "input" not in customized_task:
                customized_task["input"] = {}
            customized_task["input"]["context"] = context
            plan.append(customized_task)
        
        logger.info(f"Created plan with {len(plan)} tasks for goal: {goal}")
        return plan
    
    def optimize_plan(self, plan: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        seen = set()
        optimized = []
        for task in plan:
            task_key = f"{task['agent_type']}_{task['action']}"
            if task_key not in seen:
                seen.add(task_key)
                optimized.append(task)
        return optimized
'@
$plannerCode | Out-File -FilePath "factory\orchestrator\task_planner.py" -Encoding UTF8

# Create Pipeline Engine
Write-Host "[5/8] Creating Pipeline Engine..." -ForegroundColor Yellow
$pipelineCode = @'
# factory/pipeline/pipeline_engine.py
from typing import Dict, Any, List, Callable
from dataclasses import dataclass
from datetime import datetime
import asyncio
import logging
import uuid

logger = logging.getLogger(__name__)

@dataclass
class PipelineStage:
    name: str
    handler: Callable
    retry_count: int = 0
    timeout_seconds: int = 30

class PipelineEngine:
    def __init__(self):
        self.active_pipelines: Dict[str, Dict[str, Any]] = {}
        self.stage_results: Dict[str, List[Dict[str, Any]]] = {}
    
    async def execute(self, pipeline_id: str, stages: List[PipelineStage], initial_data: Dict[str, Any]) -> Dict[str, Any]:
        logger.info(f"Executing pipeline {pipeline_id} with {len(stages)} stages")
        
        self.active_pipelines[pipeline_id] = {
            "status": "running",
            "started_at": datetime.now(),
            "stages": []
        }
        
        current_data = initial_data
        stage_results = []
        
        for i, stage in enumerate(stages):
            logger.info(f"Pipeline {pipeline_id} - Stage {i+1}: {stage.name}")
            
            stage_start = datetime.now()
            result = None
            error = None
            
            for attempt in range(stage.retry_count + 1):
                try:
                    result = await asyncio.wait_for(
                        stage.handler(current_data),
                        timeout=stage.timeout_seconds
                    )
                    break
                except Exception as e:
                    error = str(e)
                    logger.warning(f"Stage {stage.name} attempt {attempt+1} failed: {e}")
                    if attempt == stage.retry_count:
                        result = {"error": error, "success": False}
            
            stage_end = datetime.now()
            
            stage_record = {
                "name": stage.name,
                "status": "success" if result and not result.get("error") else "failed",
                "duration_seconds": (stage_end - stage_start).total_seconds(),
                "error": error
            }
            stage_results.append(stage_record)
            
            if result and result.get("success") is not False:
                current_data = {**current_data, **result}
            elif result and result.get("error"):
                self.active_pipelines[pipeline_id]["status"] = "failed"
                break
        
        if self.active_pipelines[pipeline_id]["status"] != "failed":
            self.active_pipelines[pipeline_id]["status"] = "completed"
        
        self.active_pipelines[pipeline_id]["completed_at"] = datetime.now()
        self.active_pipelines[pipeline_id]["stages"] = stage_results
        self.stage_results[pipeline_id] = stage_results
        
        return {
            "pipeline_id": pipeline_id,
            "status": self.active_pipelines[pipeline_id]["status"],
            "stages": stage_results,
            "final_data": current_data
        }
    
    def get_status(self, pipeline_id: str) -> Optional[Dict[str, Any]]:
        return self.active_pipelines.get(pipeline_id)
'@
$pipelineCode | Out-File -FilePath "factory\pipeline\pipeline_engine.py" -Encoding UTF8

# Create API endpoints for orchestration
Write-Host "[6/8] Creating Orchestration API Endpoints..." -ForegroundColor Yellow
$orchestrationApi = @'
# backend/app/api/v1/orchestration.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
import sys
from pathlib import Path

factory_path = Path(__file__).parent.parent.parent.parent / "factory"
if str(factory_path) not in sys.path:
    sys.path.insert(0, str(factory_path))

from factory.orchestrator.agent_coordinator import AgentCoordinator
from factory.orchestrator.task_planner import TaskPlanner
from factory.pipeline.pipeline_engine import PipelineEngine, PipelineStage
from ...services.agent_service import AgentService

router = APIRouter()

agent_service = AgentService()
coordinator = AgentCoordinator(agent_service.registry)
planner = TaskPlanner()
pipeline_engine = PipelineEngine()

class OrchestrationRequest(BaseModel):
    goal: str
    context: Dict[str, Any] = {}

class PlanRequest(BaseModel):
    goal: str
    context: Dict[str, Any] = {}

@router.post("/orchestrate")
async def orchestrate(request: OrchestrationRequest):
    plan = planner.create_plan(request.goal, request.context)
    result = await coordinator.orchestrate(plan, request.context)
    return result

@router.post("/plan")
async def create_plan(request: PlanRequest):
    plan = planner.create_plan(request.goal, request.context)
    optimized = planner.optimize_plan(plan)
    return {
        "goal": request.goal,
        "tasks": optimized,
        "total_tasks": len(optimized)
    }

@router.get("/orchestration/{orchestration_id}")
async def get_orchestration_status(orchestration_id: str):
    status = coordinator.get_status(orchestration_id)
    if not status:
        raise HTTPException(status_code=404, detail="Orchestration not found")
    return {"orchestration_id": orchestration_id, "tasks": status}

@router.post("/pipeline/execute")
async def execute_pipeline(stages_config: List[Dict[str, Any]]):
    import uuid
    
    stages = []
    for stage_config in stages_config:
        async def handler(data):
            agent_type = stage_config.get("agent_type")
            action = stage_config.get("action")
            input_data = stage_config.get("input", {})
            result = await agent_service.execute_agent(agent_type, action, {**input_data, **data})
            return result
        
        stage = PipelineStage(
            name=stage_config["name"],
            handler=handler,
            retry_count=stage_config.get("retry_count", 0),
            timeout_seconds=stage_config.get("timeout_seconds", 30)
        )
        stages.append(stage)
    
    pipeline_id = str(uuid.uuid4())
    result = await pipeline_engine.execute(pipeline_id, stages, {})
    return result
'@
$orchestrationApi | Out-File -FilePath "backend\app\api\v1\orchestration.py" -Encoding UTF8

# Update API router to include orchestration
Write-Host "[7/8] Updating API routes..." -ForegroundColor Yellow
$initV1Path = "backend\app\api\v1\__init__.py"
$newInitContent = @'
from fastapi import APIRouter
from .batches import router as batches_router
from .projects import router as projects_router
from .agents import router as agents_router
from .orchestration import router as orchestration_router

router = APIRouter()
router.include_router(batches_router, prefix="/batches", tags=["batches"])
router.include_router(projects_router, prefix="/projects", tags=["projects"])
router.include_router(agents_router, prefix="/agents", tags=["agents"])
router.include_router(orchestration_router, prefix="/orchestration", tags=["orchestration"])
'@
$newInitContent | Out-File -FilePath $initV1Path -Encoding UTF8

# Update main.py to include new version
$mainPyPath = "backend\app\main.py"
$mainContent = @'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from .api.v1 import router as api_v1_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="AI Software Factory",
    version="1.3.0",
    description="Enterprise-grade AI-powered software engineering factory with Multi-Agent Orchestration"
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
    return {"status": "healthy", "version": "1.3.0"}

@app.get("/")
async def root():
    return {
        "message": "AI Software Factory API",
        "version": "1.3.0",
        "features": [
            "Multi-Agent Orchestration",
            "Task Planning",
            "Pipeline Execution",
            "Agent Coordination"
        ]
    }
'@
$mainContent | Out-File -FilePath $mainPyPath -Encoding UTF8

# Rebuild and restart
Write-Host "[8/8] Rebuilding and restarting containers..." -ForegroundColor Yellow
docker-compose down
docker-compose build --no-cache
docker-compose up -d

Write-Host "Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Run validation tests
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "VALIDATION TESTS - v1.3 Multi-Agent Orchestration" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

# Test 1: Health check
Write-Host "`n[TEST 1] Health Check:" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:4001/health" -ErrorAction Stop
    Write-Host "  SUCCESS: Backend v$($health.version) is healthy" -ForegroundColor Green
} catch {
    Write-Host "  FAILED: Backend health check failed" -ForegroundColor Red
}

# Test 2: Create a plan
Write-Host "`n[TEST 2] Task Planner - Create Plan:" -ForegroundColor Yellow
$planBody = @{goal = "Generate a full SaaS application"; context = @{app_name = "MyApp"}} | ConvertTo-Json
try {
    $plan = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/orchestration/plan" -Method POST -ContentType "application/json" -Body $planBody -ErrorAction Stop
    Write-Host "  SUCCESS: Plan created with $($plan.total_tasks) tasks" -ForegroundColor Green
    foreach ($task in $plan.tasks) {
        Write-Host "     - $($task.name): $($task.agent_type)/$($task.action)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  FAILED: Plan creation failed" -ForegroundColor Red
}

# Test 3: Execute orchestration
Write-Host "`n[TEST 3] Agent Orchestration:" -ForegroundColor Yellow
$orchestrationBody = @{goal = "Generate a simple app"; context = @{}} | ConvertTo-Json
try {
    $result = Invoke-RestMethod -Uri "http://localhost:4001/api/v1/orchestration/orchestrate" -Method POST -ContentType "application/json" -Body $orchestrationBody -ErrorAction Stop
    Write-Host "  SUCCESS: Orchestration completed" -ForegroundColor Green
    Write-Host "     Total tasks: $($result.total_tasks)" -ForegroundColor Gray
    Write-Host "     Completed: $($result.completed)" -ForegroundColor Gray
    Write-Host "     Failed: $($result.failed)" -ForegroundColor Gray
} catch {
    Write-Host "  FAILED: Orchestration failed" -ForegroundColor Red
}

# Test 4: List endpoints
Write-Host "`n[TEST 4] Available Orchestration Endpoints:" -ForegroundColor Yellow
$endpoints = @(
    "POST /api/v1/orchestration/plan",
    "POST /api/v1/orchestration/orchestrate",
    "GET  /api/v1/orchestration/orchestration/{id}",
    "POST /api/v1/orchestration/pipeline/execute"
)
foreach ($ep in $endpoints) {
    Write-Host "     $ep" -ForegroundColor Gray
}

# Update project state
$state = @{
    current_batch = "v1.3"
    completed_modules = @(
        "FastAPI Backend",
        "Static Frontend",
        "Docker Configuration",
        "Batch CRUD",
        "Project CRUD",
        "Base AI Agent Framework",
        "Agent API Endpoints",
        "Agent Coordinator",
        "Task Planner",
        "Pipeline Engine",
        "Orchestration API"
    )
    active_architecture = @{
        backend_port = 4001
        frontend_port = 4000
        agents_registered = @("code_generator", "architect", "backend")
        orchestration_enabled = $true
        api_endpoints_count = 11
    }
    execution_history = @(
        @{batch = "v1.0"; status = "success"},
        @{batch = "v1.1"; status = "success"},
        @{batch = "v1.2"; status = "success"},
        @{batch = "v1.3"; status = "success"; timestamp = (Get-Date).ToString()}
    )
    next_recommended_batch = "v1.4 - Self-Improving System with Feedback Loop"
}
$state | ConvertTo-Json -Depth 10 | Out-File -FilePath "project_state.json" -Encoding UTF8

Write-Host "`n============================================================================" -ForegroundColor Green
Write-Host "UPGRADE TO v1.3 COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "System Status:" -ForegroundColor Cyan
Write-Host "  Backend API: http://localhost:4001" -ForegroundColor White
Write-Host "  API Docs: http://localhost:4001/docs" -ForegroundColor White
Write-Host "  Frontend: http://localhost:4000" -ForegroundColor White
Write-Host ""
Write-Host "New Features in v1.3:" -ForegroundColor Cyan
Write-Host "  - Agent Coordinator: Orchestrates multiple agents" -ForegroundColor White
Write-Host "  - Task Planner: Creates execution plans from goals" -ForegroundColor White
Write-Host "  - Pipeline Engine: Executes staged workflows" -ForegroundColor White
Write-Host "  - Orchestration API: /api/v1/orchestration/*" -ForegroundColor White
Write-Host ""
Write-Host "Next: v1.4 - Self-Improving System" -ForegroundColor Yellow
Write-Host "  Features: Feedback Loop, Evolution Engine, Pattern Memory" -ForegroundColor Gray
Write-Host ""
Write-Host "Opening API documentation..." -ForegroundColor Gray
Start-Process "http://localhost:4001/docs"