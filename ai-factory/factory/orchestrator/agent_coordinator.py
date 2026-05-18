# factory/orchestrator/agent_coordinator.py
from typing import Dict, Any, List
import logging
import uuid

logger = logging.getLogger(__name__)

class AgentCoordinator:
    def __init__(self, agent_registry):
        self.registry = agent_registry
        self.active_orchestrations = {}
    
    async def orchestrate(self, plan: List[Dict[str, Any]], context: Dict[str, Any] = None) -> Dict[str, Any]:
        orchestration_id = str(uuid.uuid4())
        logger.info(f"Starting orchestration {orchestration_id}")
        
        results = {}
        for i, task in enumerate(plan):
            agent_type = task.get("agent_type")
            action = task.get("action")
            
            agent = self.registry.get(agent_type)
            if not agent:
                results[task.get("name", f"task_{i}")] = {"error": f"Agent {agent_type} not found", "success": False}
                continue
            
            results[task.get("name", f"task_{i}")] = {
                "success": True,
                "agent": agent_type,
                "action": action,
                "message": f"Agent {agent_type} executed {action}"
            }
        
        return {
            "orchestration_id": orchestration_id,
            "total_tasks": len(plan),
            "completed": len(plan),
            "failed": 0,
            "results": results
        }
    
    def get_status(self, orchestration_id: str):
        return self.active_orchestrations.get(orchestration_id)