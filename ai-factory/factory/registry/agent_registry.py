# factory/registry/agent_registry.py
from typing import Dict, Optional
from ..agents.base_agent import BaseAgent

class AgentRegistry:
    _instance = None
    _agents: Dict[str, BaseAgent] = {}
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def register(self, agent: BaseAgent):
        self._agents[agent.agent_type] = agent
        print(f"Registered agent: {agent.agent_type}")
    
    def get(self, agent_type: str) -> Optional[BaseAgent]:
        return self._agents.get(agent_type)
    
    def list_agents(self) -> list:
        return list(self._agents.keys())
