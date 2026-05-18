# factory/agents/base_agent.py
from abc import ABC, abstractmethod
from typing import Dict, Any
from dataclasses import dataclass
from datetime import datetime

@dataclass
class AgentTask:
    task_id: str
    task_type: str
    input_data: Dict[str, Any]
    context: Dict[str, Any]

@dataclass
class AgentResult:
    task_id: str
    agent_type: str
    output_data: Dict[str, Any]
    confidence_score: float
    success: bool

class BaseAgent(ABC):
    def __init__(self, name: str, agent_type: str):
        self.name = name
        self.agent_type = agent_type
    
    @abstractmethod
    async def process(self, task: AgentTask) -> AgentResult:
        pass
    
    @abstractmethod
    def can_handle(self, task_type: str) -> bool:
        pass
