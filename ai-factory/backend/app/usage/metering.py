# backend/app/usage/metering.py
from typing import Dict, Any, List
from datetime import datetime, timedelta
import json
import os
import logging

logger = logging.getLogger(__name__)

USAGE_FILE = "/app/data/usage.json"

class UsageMeter:
    def __init__(self):
        self._load_usage()
    
    def _load_usage(self):
        if os.path.exists(USAGE_FILE):
            with open(USAGE_FILE, 'r') as f:
                self.usage_data = json.load(f)
        else:
            self.usage_data = {}
    
    def _save_usage(self):
        with open(USAGE_FILE, 'w') as f:
            json.dump(self.usage_data, f, indent=2)
    
    def record_batch(self, user_id: str, batch_id: int):
        current_month = datetime.now().strftime("%Y-%m")
        key = f"{user_id}_{current_month}"
        
        if key not in self.usage_data:
            self.usage_data[key] = {"batches": [], "api_calls": 0}
        
        self.usage_data[key]["batches"].append({
            "batch_id": batch_id,
            "timestamp": datetime.now().isoformat()
        })
        self._save_usage()
        logger.info(f"Recorded batch for user {user_id}")
    
    def record_api_call(self, user_id: str, endpoint: str):
        current_month = datetime.now().strftime("%Y-%m")
        key = f"{user_id}_{current_month}"
        
        if key not in self.usage_data:
            self.usage_data[key] = {"batches": [], "api_calls": 0}
        
        self.usage_data[key]["api_calls"] += 1
        self._save_usage()
    
    def get_monthly_usage(self, user_id: str) -> Dict[str, Any]:
        current_month = datetime.now().strftime("%Y-%m")
        key = f"{user_id}_{current_month}"
        
        if key not in self.usage_data:
            return {"batches": [], "api_calls": 0, "batch_count": 0}
        
        return {
            "batches": self.usage_data[key]["batches"],
            "api_calls": self.usage_data[key]["api_calls"],
            "batch_count": len(self.usage_data[key]["batches"])
        }
    
    def get_usage_history(self, user_id: str, months: int = 6) -> List[Dict[str, Any]]:
        history = []
        for i in range(months):
            date = datetime.now() - timedelta(days=30 * i)
            month_key = date.strftime("%Y-%m")
            key = f"{user_id}_{month_key}"
            
            history.append({
                "month": month_key,
                "batch_count": len(self.usage_data.get(key, {}).get("batches", [])),
                "api_calls": self.usage_data.get(key, {}).get("api_calls", 0)
            })
        return history
