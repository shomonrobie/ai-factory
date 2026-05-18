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
