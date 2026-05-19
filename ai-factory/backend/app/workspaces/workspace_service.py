# backend/app/workspaces/workspace_service.py
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os
import uuid
import logging

logger = logging.getLogger(__name__)

WORKSPACES_FILE = "/app/data/workspaces.json"
WORKSPACE_MEMBERS_FILE = "/app/data/workspace_members.json"

class WorkspaceService:
    def __init__(self):
        self._ensure_files()
    
    def _ensure_files(self):
        os.makedirs("/app/data", exist_ok=True)
        if not os.path.exists(WORKSPACES_FILE):
            with open(WORKSPACES_FILE, 'w') as f:
                json.dump([], f)
        if not os.path.exists(WORKSPACE_MEMBERS_FILE):
            with open(WORKSPACE_MEMBERS_FILE, 'w') as f:
                json.dump([], f)
    
    def create_workspace(self, name: str, owner_id: str, settings: Dict = None) -> Dict[str, Any]:
        workspaces = self._load_workspaces()
        
        workspace = {
            "id": str(uuid.uuid4()),
            "name": name,
            "owner_id": owner_id,
            "settings": settings or {},
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
            "is_active": True
        }
        
        workspaces.append(workspace)
        self._save_workspaces(workspaces)
        
        # Add owner as member
        self.add_member(workspace["id"], owner_id, "owner")
        
        logger.info(f"Workspace created: {name} by {owner_id}")
        return workspace
    
    def add_member(self, workspace_id: str, user_id: str, role: str = "member") -> Dict[str, Any]:
        members = self._load_members()
        
        # Check if already member
        for m in members:
            if m["workspace_id"] == workspace_id and m["user_id"] == user_id:
                return m
        
        member = {
            "id": str(uuid.uuid4()),
            "workspace_id": workspace_id,
            "user_id": user_id,
            "role": role,
            "joined_at": datetime.now().isoformat()
        }
        
        members.append(member)
        self._save_members(members)
        
        logger.info(f"User {user_id} added to workspace {workspace_id} as {role}")
        return member
    
    def remove_member(self, workspace_id: str, user_id: str) -> bool:
        members = self._load_members()
        original_count = len(members)
        members = [m for m in members if not (m["workspace_id"] == workspace_id and m["user_id"] == user_id)]
        self._save_members(members)
        
        removed = len(members) < original_count
        if removed:
            logger.info(f"User {user_id} removed from workspace {workspace_id}")
        return removed
    
    def get_user_workspaces(self, user_id: str) -> List[Dict[str, Any]]:
        members = self._load_members()
        workspaces = self._load_workspaces()
        
        user_memberships = [m for m in members if m["user_id"] == user_id]
        user_workspace_ids = [m["workspace_id"] for m in user_memberships]
        
        return [w for w in workspaces if w["id"] in user_workspace_ids and w.get("is_active", True)]
    
    def get_workspace_members(self, workspace_id: str) -> List[Dict[str, Any]]:
        members = self._load_members()
        return [m for m in members if m["workspace_id"] == workspace_id]
    
    def update_workspace(self, workspace_id: str, updates: Dict) -> Optional[Dict[str, Any]]:
        workspaces = self._load_workspaces()
        for i, w in enumerate(workspaces):
            if w["id"] == workspace_id:
                workspaces[i].update(updates)
                workspaces[i]["updated_at"] = datetime.now().isoformat()
                self._save_workspaces(workspaces)
                logger.info(f"Workspace {workspace_id} updated")
                return workspaces[i]
        return None
    
    def _load_workspaces(self) -> List[Dict]:
        with open(WORKSPACES_FILE, 'r') as f:
            return json.load(f)
    
    def _save_workspaces(self, workspaces: List[Dict]):
        with open(WORKSPACES_FILE, 'w') as f:
            json.dump(workspaces, f, indent=2)
    
    def _load_members(self) -> List[Dict]:
        with open(WORKSPACE_MEMBERS_FILE, 'r') as f:
            return json.load(f)
    
    def _save_members(self, members: List[Dict]):
        with open(WORKSPACE_MEMBERS_FILE, 'w') as f:
            json.dump(members, f, indent=2)
