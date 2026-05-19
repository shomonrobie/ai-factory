# backend/app/models/workspace.py
from sqlalchemy import Column, Integer, String, JSON, Boolean, ForeignKey, Table
from .base import BaseModel

# Association table for many-to-many relationship
workspace_members = Table(
    "workspace_members",
    BaseModel.metadata,
    Column("workspace_id", Integer, ForeignKey("workspaces.id")),
    Column("user_id", Integer, ForeignKey("users.id")),
    Column("role", String(50), default="member")
)

class Workspace(BaseModel):
    __tablename__ = "workspaces"
    
    name = Column(String(255), nullable=False)
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    settings = Column(JSON, default={})
    is_active = Column(Boolean, default=True)
    slug = Column(String(255), unique=True, nullable=False)
