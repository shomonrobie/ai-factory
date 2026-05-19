# backend/app/audit/audit_service.py
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
import json
import os
import logging

logger = logging.getLogger(__name__)

AUDIT_FILE = "/app/data/audit_logs.json"

class AuditService:
    def __init__(self):
        self._ensure_file()
    
    def _ensure_file(self):
        os.makedirs("/app/data", exist_ok=True)
        if not os.path.exists(AUDIT_FILE):
            with open(AUDIT_FILE, 'w') as f:
                json.dump([], f)
    
    def log(self, user_id: str, action: str, resource_type: str, resource_id: str, details: Dict = None, ip_address: str = None) -> Dict[str, Any]:
        logs = self._load_logs()
        
        log_entry = {
            "id": len(logs) + 1,
            "user_id": user_id,
            "action": action,
            "resource_type": resource_type,
            "resource_id": resource_id,
            "details": details or {},
            "ip_address": ip_address,
            "timestamp": datetime.now().isoformat()
        }
        
        logs.append(log_entry)
        self._save_logs(logs)
        
        logger.info(f"Audit log: {user_id} - {action} on {resource_type}/{resource_id}")
        return log_entry
    
    def get_logs(self, user_id: str = None, action: str = None, resource_type: str = None, days: int = 30) -> List[Dict[str, Any]]:
        logs = self._load_logs()
        cutoff = datetime.now() - timedelta(days=days)
        
        filtered = [l for l in logs if datetime.fromisoformat(l["timestamp"]) > cutoff]
        
        if user_id:
            filtered = [l for l in filtered if l["user_id"] == user_id]
        if action:
            filtered = [l for l in filtered if l["action"] == action]
        if resource_type:
            filtered = [l for l in filtered if l["resource_type"] == resource_type]
        
        return filtered
    
    def get_user_activity(self, user_id: str, days: int = 30) -> Dict[str, Any]:
        logs = self.get_logs(user_id=user_id, days=days)
        
        actions = {}
        for log in logs:
            action = log["action"]
            actions[action] = actions.get(action, 0) + 1
        
        return {
            "user_id": user_id,
            "total_actions": len(logs),
            "actions": actions,
            "last_active": logs[-1]["timestamp"] if logs else None,
            "logs": logs[-50:]
        }
    
    def export_logs(self, days: int = 90) -> str:
        logs = self.get_logs(days=days)
        return json.dumps(logs, indent=2)
    
    def _load_logs(self) -> List[Dict]:
        with open(AUDIT_FILE, 'r') as f:
            return json.load(f)
    
    def _save_logs(self, logs: List[Dict]):
        with open(AUDIT_FILE, 'w') as f:
            json.dump(logs, f, indent=2)
