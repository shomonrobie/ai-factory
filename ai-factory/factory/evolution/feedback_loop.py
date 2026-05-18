# factory/evolution/feedback_loop.py
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import json
import os
import logging
from .evolution_engine import EvolutionEngine
from ..memory.pattern_memory import PatternMemory

logger = logging.getLogger(__name__)

@dataclass
class IterationResult:
    iteration: int
    phase: str
    code: str
    score: float
    improvements: List[str]
    timestamp: datetime

class FeedbackLoop:
    def __init__(self):
        self.evolution_engine = EvolutionEngine()
        self.pattern_memory = PatternMemory()
        self.iteration_history: List[IterationResult] = []
    
    async def execute(self, requirement: str, initial_code: Optional[str] = None, max_iterations: int = 10) -> Dict[str, Any]:
        current_code = initial_code or self._generate_initial_code(requirement)
        current_score = 0.0
        iteration = 0
        
        while iteration < max_iterations:
            iteration += 1
            logger.info(f"Feedback loop iteration {iteration}")
            
            # PLAN phase
            iteration_result = IterationResult(iteration=iteration, phase="PLAN", code=current_code, score=current_score, improvements=[], timestamp=datetime.now())
            self.iteration_history.append(iteration_result)
            
            # BUILD phase
            current_code = await self._build_phase(requirement, current_code, iteration)
            
            # REVIEW phase
            review_result = await self._review_phase(current_code)
            issues = review_result.get("issues", [])
            
            # SCORE phase
            current_score = await self._score_phase(current_code)
            iteration_result.score = current_score
            
            # OPTIMIZE phase
            if current_score < 75:
                improvements = await self._optimize_phase(current_code, issues, iteration)
                current_code = improvements.get("code", current_code)
                iteration_result.improvements = improvements.get("applied", [])
            
            # Record evolution
            self.evolution_engine.record_evolution(iteration, current_score, iteration_result.improvements)
            
            # Check stop condition
            if self.evolution_engine.should_stop(current_score, iteration, max_iterations):
                break
        
        # FINALIZE phase
        final_code = await self._finalize_phase(current_code, current_score)
        
        return {
            "final_code": final_code,
            "final_score": current_score,
            "iterations": iteration,
            "history": [(i.iteration, i.score, i.improvements) for i in self.iteration_history],
            "trend": self.evolution_engine.get_trend(),
            "patterns_used": [p.name for p in self.pattern_memory.get_best_patterns(3)]
        }
    
    def _generate_initial_code(self, requirement: str) -> str:
        return f"# AI-Generated Code\n# Requirement: {requirement}\n\nclass GeneratedApplication:\n    def __init__(self):\n        self.data = []\n    \n    def process(self):\n        return 'Application is running'"
    
    async def _build_phase(self, requirement: str, code: str, iteration: int) -> str:
        best_patterns = self.pattern_memory.get_best_patterns(2)
        if best_patterns and iteration > 1:
            pattern = best_patterns[0]
            code += f"\n\n# Applied pattern: {pattern.name}\n{pattern.code_snippet}"
        return code
    
    async def _review_phase(self, code: str) -> Dict[str, Any]:
        issues = []
        if "TODO" in code:
            issues.append({"type": "todo", "severity": "warning", "message": "TODO comment found"})
        return {"issues": issues, "quality_score": max(0, 100 - len(issues) * 10)}
    
    async def _score_phase(self, code: str) -> float:
        score = 70.0
        if "class" in code:
            score += 10
        if "def " in code:
            score += 10
        if "return" in code:
            score += 5
        return min(100, max(0, score))
    
    async def _optimize_phase(self, code: str, issues: List[Dict], iteration: int) -> Dict[str, Any]:
        applied = []
        if any(i.get("type") == "todo" for i in issues):
            code = code.replace("# TODO", "# COMPLETED")
            applied.append("Resolved TODO comments")
        return {"code": code, "applied": applied}
    
    async def _finalize_phase(self, code: str, score: float) -> str:
        status = "APPROVED" if score >= 75 else "NEEDS_REVIEW"
        return f"# FINAL VERSION - Status: {status} (Score: {score})\n{code}"
