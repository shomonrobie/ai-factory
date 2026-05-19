# backend/app/models/user.py
from sqlalchemy import Column, Integer, String, DateTime, Boolean, JSON
from sqlalchemy.sql import func
from .base import BaseModel

class User(BaseModel):
    __tablename__ = "users"
    
    email = Column(String(255), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    password_hash = Column(String(255), nullable=True)
    tier = Column(String(50), default="free")
    status = Column(String(50), default="active")
    email_verified = Column(Boolean, default=False)
    last_login = Column(DateTime, nullable=True)
    metadata = Column(JSON, default={})
