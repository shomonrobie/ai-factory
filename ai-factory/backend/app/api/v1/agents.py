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
