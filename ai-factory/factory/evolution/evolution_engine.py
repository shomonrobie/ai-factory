# factory/evolution/evolution_engine.py
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import json
import os
import logging

logger = logging.getLogger(__name__)

@dataclass
class EvolutionRecord:
    generation: int
    score: float
    improvements: List[str]
    timestamp: datetime

class EvolutionEngine:
    def __init__(self, storage_path: str = "/app/data/evolution.json"):
        self.storage_path = storage_path
        self.history: List[EvolutionRecord] = []
        self.score_thresholds = {
            "excellent": 90,
            "good": 75,
            "acceptable": 60,
            "poor": 40,
            "critical": 25
        }
        self._load_history()
    
    def _load_history(self):
        if os.path.exists(self.storage_path):
            with open(self.storage_path, 'r') as f:
                data = json.load(f)
                self.history = [EvolutionRecord(**r) for r in data]
    
    def _save_history(self):
        os.makedirs(os.path.dirname(self.storage_path), exist_ok=True)
        with open(self.storage_path, 'w') as f:
            json.dump([r.__dict__ for r in self.history], f, indent=2, default=str)
    
    def evaluate_and_evolve(self, current_score: float, generation: int) -> Dict[str, Any]:
        if current_score >= self.score_thresholds["excellent"]:
            return {"action": "finalize", "confidence": 0.95, "reason": f"Score {current_score} meets excellent threshold", "target_score": current_score}
        elif current_score >= self.score_thresholds["good"]:
            return {"action": "optimize", "confidence": 0.8, "reason": f"Score {current_score} can be improved", "target_score": min(100, current_score + 15)}
        elif current_score >= self.score_thresholds["acceptable"]:
            return {"action": "refactor", "confidence": 0.85, "reason": f"Score {current_score} needs refactoring", "target_score": min(100, current_score + 25)}
        else:
            return {"action": "regenerate", "confidence": 0.9, "reason": f"Score {current_score} requires regeneration", "target_score": 70}
    
    def record_evolution(self, generation: int, score: float, improvements: List[str]):
        record = EvolutionRecord(generation=generation, score=score, improvements=improvements, timestamp=datetime.now())
        self.history.append(record)
        self._save_history()
        logger.info(f"Recorded evolution generation {generation} with score {score}")
    
    def get_trend(self) -> Dict[str, Any]:
        if len(self.history) < 2:
            return {"trend": "stable", "improvement_rate": 0}
        scores = [r.score for r in self.history[-5:]]
        improvement = scores[-1] - scores[0]
        return {"trend": "improving" if improvement > 0 else "declining", "improvement_rate": improvement / len(scores) if scores else 0}
    
    def should_stop(self, current_score: float, generation: int, max_generations: int = 10) -> bool:
        if generation >= max_generations:
            return True
        if current_score >= self.score_thresholds["excellent"]:
            return True
        trend = self.get_trend()
        if trend["trend"] == "declining" and trend["improvement_rate"] < -2:
            return True
        return False
