# backend/app/api/v1/evolution.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
import sys
from pathlib import Path

factory_path = Path(__file__).parent.parent.parent.parent / "factory"
if str(factory_path) not in sys.path:
    sys.path.insert(0, str(factory_path))

from factory.evolution.evolution_engine import EvolutionEngine
from factory.memory.pattern_memory import PatternMemory
from factory.evolution.feedback_loop import FeedbackLoop

router = APIRouter()

evolution_engine = EvolutionEngine()
pattern_memory = PatternMemory()
feedback_loop = FeedbackLoop()

class EvolutionRequest(BaseModel):
    requirement: str
    initial_code: Optional[str] = None
    max_iterations: int = 10

class ScoreRequest(BaseModel):
    code: str
    current_score: float
    generation: int

@router.post("/evolve")
async def run_evolution(request: EvolutionRequest):
    result = await feedback_loop.execute(
        requirement=request.requirement,
        initial_code=request.initial_code,
        max_iterations=request.max_iterations
    )
    return result

@router.post("/score")
async def evaluate_score(request: ScoreRequest):
    decision = evolution_engine.evaluate_and_evolve(request.current_score, request.generation)
    return decision

@router.get("/patterns")
async def list_patterns():
    patterns = pattern_memory.get_best_patterns(10)
    return {
        "patterns": [
            {
                "name": p.name,
                "effectiveness": p.effectiveness_score,
                "success_count": p.success_count,
                "code": p.code_snippet[:200] + "..."
            }
            for p in patterns
        ],
        "statistics": pattern_memory.get_statistics()
    }

@router.get("/trend")
async def get_evolution_trend():
    return evolution_engine.get_trend()
