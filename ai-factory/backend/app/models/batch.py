# backend/app/models/batch.py
from sqlalchemy import Column, Integer, String, Text, Float, JSON, ForeignKey
from .base import BaseModel

class Batch(BaseModel):
    __tablename__ = "batches"
    
    batch_number = Column(Integer, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=True)
    prompt = Column(Text, nullable=False)
    status = Column(String(50), default="pending")
    result = Column(JSON, nullable=True)
    score = Column(Float, default=0.0)
    metadata = Column(JSON, default={})
