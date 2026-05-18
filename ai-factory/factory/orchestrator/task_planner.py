# factory/orchestrator/task_planner.py
from typing import Dict, Any, List
import logging

logger = logging.getLogger(__name__)

class TaskPlanner:
    def __init__(self):
        pass
    
    def create_plan(self, goal: str, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        plan = [
            {"name": "design_architecture", "agent_type": "code_generator", "action": "generate_code", "depends_on": []},
            {"name": "generate_backend", "agent_type": "code_generator", "action": "generate_code", "depends_on": ["design_architecture"]},
            {"name": "create_frontend", "agent_type": "code_generator", "action": "generate_code", "depends_on": ["generate_backend"]}
        ]
        logger.info(f"Created plan with {len(plan)} tasks for: {goal}")
        return plan
    
    def optimize_plan(self, plan: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        return plan