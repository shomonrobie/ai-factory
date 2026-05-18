# factory/memory/pattern_memory.py
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import json
import os
import hashlib
import logging

logger = logging.getLogger(__name__)

@dataclass
class CodePattern:
    pattern_id: str
    name: str
    code_snippet: str
    success_count: int
    failure_count: int
    effectiveness_score: float
    created_at: datetime

class PatternMemory:
    def __init__(self, storage_path: str = "/app/data/patterns.json"):
        self.storage_path = storage_path
        self.patterns: Dict[str, CodePattern] = {}
        self._load_patterns()
        self._init_default_patterns()
    
    def _load_patterns(self):
        if os.path.exists(self.storage_path):
            with open(self.storage_path, 'r') as f:
                data = json.load(f)
                for pid, p in data.items():
                    self.patterns[pid] = CodePattern(**p)
    
    def _save_patterns(self):
        os.makedirs(os.path.dirname(self.storage_path), exist_ok=True)
        data = {pid: p.__dict__ for pid, p in self.patterns.items()}
        with open(self.storage_path, 'w') as f:
            json.dump(data, f, indent=2, default=str)
    
    def _init_default_patterns(self):
        defaults = [
            CodePattern("ptrn_001", "CRUD Operations", "def create(item):\n    db.append(item)\n    return item", 0, 0, 0, datetime.now()),
            CodePattern("ptrn_002", "Error Handling", "try:\n    result = operation()\nexcept Exception as e:\n    logger.error(f'Error: {e}')\n    raise", 0, 0, 0, datetime.now()),
            CodePattern("ptrn_003", "Input Validation", "if not data:\n    raise ValueError('Input cannot be empty')", 0, 0, 0, datetime.now())
        ]
        for p in defaults:
            if p.pattern_id not in self.patterns:
                self.patterns[p.pattern_id] = p
        self._save_patterns()
    
    def get_best_patterns(self, limit: int = 3) -> List[CodePattern]:
        sorted_patterns = sorted(self.patterns.values(), key=lambda x: x.effectiveness_score, reverse=True)
        return sorted_patterns[:limit]
    
    def record_success(self, pattern_id: str):
        if pattern_id in self.patterns:
            self.patterns[pattern_id].success_count += 1
            self._update_effectiveness(pattern_id)
            self._save_patterns()
    
    def record_failure(self, pattern_id: str):
        if pattern_id in self.patterns:
            self.patterns[pattern_id].failure_count += 1
            self._update_effectiveness(pattern_id)
            self._save_patterns()
    
    def _update_effectiveness(self, pattern_id: str):
        p = self.patterns[pattern_id]
        total = p.success_count + p.failure_count
        if total > 0:
            p.effectiveness_score = (p.success_count / total) * 100
    
    def get_statistics(self) -> Dict[str, Any]:
        if not self.patterns:
            return {"total_patterns": 0, "average_effectiveness": 0}
        return {
            "total_patterns": len(self.patterns),
            "most_effective": max(self.patterns.values(), key=lambda x: x.effectiveness_score).name,
            "average_effectiveness": sum(p.effectiveness_score for p in self.patterns.values()) / len(self.patterns)
        }
