# backend/app/models/project.py
from sqlalchemy import Column, Integer, String, Text, JSON, ForeignKey
from .base import BaseModel

class Project(BaseModel):
    __tablename__ = "projects"
    
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    status = Column(String(50), default="active")
    config = Column(JSON, default={})
    current_batch = Column(Integer, default=0)
