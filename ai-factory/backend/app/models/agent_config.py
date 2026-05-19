# backend/app/models/agent_config.py
from sqlalchemy import Column, Integer, String, Boolean, Float
from .base import BaseModel

class AgentConfig(BaseModel):
    __tablename__ = "agent_configs"
    
    agent_name = Column(String(100), unique=True, nullable=False)
    enabled = Column(Boolean, default=True)
    confidence_threshold = Column(Float, default=70.0)
    max_retries = Column(Integer, default=3)
    timeout_seconds = Column(Integer, default=30)
    api_key = Column(String(500), nullable=True)
    model_name = Column(String(100), default="gpt-4")
