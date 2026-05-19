#!/usr/bin/env python3
"""
Batch 4: Self-Improving System
Generates reviewer agent, optimizer agent, evolution engine, feedback loop, and pattern memory storage
"""

from pathlib import Path

class Batch4Generator:
    def __init__(self):
        self.project_root = Path("ai-factory")
        self.factory_dir = self.project_root / "factory"
        self.orchestrator_dir = self.factory_dir / "orchestrator"
        self.agents_dir = self.factory_dir / "agents"
        self.memory_dir = self.factory_dir / "memory"
        self.engine_dir = self.factory_dir / "engine"
        self.tests_dir = self.project_root / "tests"
        
    def create_reviewer_agent(self):
        """Create reviewer agent for code criticism and feedback"""
        
        reviewer_file = self.agents_dir / "reviewer_agent.py"
        content = '''from typing import Dict, Any, List
import json
import logging
from .base_agent import BaseAgent, AgentTask, AgentResult

logger = logging.getLogger(__name__)

class ReviewerAgent(BaseAgent):
    def __init__(self):
        super().__init__("ReviewerAgent", "reviewer")
        self.supported_task_types = ["review_code", "analyze_quality", "suggest_improvements"]
        
    def can_handle(self, task_type: str) -> bool:
        return task_type in self.supported_task_types
    
    def validate_input(self, task: AgentTask) -> bool:
        required_fields = {
            "review_code": ["code", "language"],
            "analyze_quality": ["code", "metrics"],
            "suggest_improvements": ["code", "issues"]
        }
        
        task_type = task.task_type
        if task_type in required_fields:
            for field in required_fields[task_type]:
                if field not in task.input_data:
                    logger.error(f"Missing required field: {field}")
                    return False
        return True
    
    async def process(self, task: AgentTask) -> AgentResult:
        import time
        start_time = time.time()
        
        try:
            if not self.validate_input(task):
                return AgentResult(
                    task_id=task.task_id,
                    agent_type=self.agent_type,
                    output_data={},
                    confidence_score=0.0,
                    execution_time=0,
                    errors=["Invalid input validation failed"],
                    metadata={}
                )
            
            if task.task_type == "review_code":
                output = self._review_code(task.input_data)
            elif task.task_type == "analyze_quality":
                output = self._analyze_quality(task.input_data)
            elif task.task_type == "suggest_improvements":
                output = self._suggest_improvements(task.input_data)
            else:
                output = {"error": f"Unknown task type: {task.task_type}"}
            
            execution_time = time.time() - start_time
            
            return AgentResult(
                task_id=task.task_id,
                agent_type=self.agent_type,
                output_data=output,
                confidence_score=0.88,
                execution_time=execution_time,
                errors=[],
                metadata={"reviewer_version": "1.0"}
            )
            
        except Exception as e:
            logger.error(f"Error in ReviewerAgent: {str(e)}")
            return AgentResult(
                task_id=task.task_id,
                agent_type=self.agent_type,
                output_data={},
                confidence_score=0.0,
                execution_time=time.time() - start_time,
                errors=[str(e)],
                metadata={}
            )
    
    def _review_code(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        code = input_data.get("code", "")
        language = input_data.get("language", "python")
        
        issues = []
        suggestions = []
        
        lines = code.split('\\n')
        
        for i, line in enumerate(lines, 1):
            if 'TODO' in line:
                issues.append({
                    "line": i,
                    "type": "todo",
                    "severity": "info",
                    "message": "TODO comment found"
                })
            
            if 'print(' in line and language == "python":
                issues.append({
                    "line": i,
                    "type": "debug_statement",
                    "severity": "warning",
                    "message": "Print statement in production code"
                })
            
            if len(line) > 100:
                issues.append({
                    "line": i,
                    "type": "line_length",
                    "severity": "warning",
                    "message": f"Line exceeds 100 characters ({len(line)})"
                })
            
            if 'except:' in line and 'Exception' not in line:
                issues.append({
                    "line": i,
                    "type": "bare_except",
                    "severity": "error",
                    "message": "Bare except clause"
                })
        
        if not issues:
            suggestions.append("Code looks clean. Consider adding more tests.")
        
        quality_score = max(0, 100 - (len([i for i in issues if i["severity"] == "error"]) * 20) - (len([i for i in issues if i["severity"] == "warning"]) * 5))
        
        return {
            "issues": issues,
            "suggestions": suggestions,
            "quality_score": quality_score,
            "total_issues": len(issues),
            "errors": len([i for i in issues if i["severity"] == "error"]),
            "warnings": len([i for i in issues if i["severity"] == "warning"]),
            "approved": quality_score >= 70
        }
    
    def _analyze_quality(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        code = input_data.get("code", "")
        metrics = input_data.get("metrics", [])
        
        analysis = {
            "complexity": self._calculate_complexity(code),
            "maintainability": self._calculate_maintainability(code),
            "testability": self._calculate_testability(code),
            "reusability": self._calculate_reusability(code)
        }
        
        overall_score = sum(analysis.values()) / len(analysis)
        
        return {
            "metrics": analysis,
            "overall_score": overall_score,
            "grade": self._get_grade(overall_score),
            "recommendations": self._generate_recommendations(analysis)
        }
    
    def _calculate_complexity(self, code: str) -> float:
        lines = code.split('\\n')
        complexity = 1.0
        
        for line in lines:
            if 'if' in line or 'else' in line or 'elif' in line:
                complexity += 0.5
            if 'for' in line or 'while' in line:
                complexity += 0.8
            if 'try' in line:
                complexity += 0.3
        
        score = max(0, 100 - (complexity * 5))
        return min(100, score)
    
    def _calculate_maintainability(self, code: str) -> float:
        lines = code.split('\\n')
        
        comment_lines = sum(1 for line in lines if line.strip().startswith('#') or '\"\"\"' in line)
        blank_lines = sum(1 for line in lines if not line.strip())
        
        total_lines = len(lines)
        
        if total_lines == 0:
            return 50.0
        
        comment_ratio = comment_lines / total_lines
        blank_ratio = blank_lines / total_lines
        
        score = 50 + (comment_ratio * 30) + (blank_ratio * 20)
        
        return min(100, score)
    
    def _calculate_testability(self, code: str) -> float:
        functions = [line for line in code.split('\\n') if line.strip().startswith('def ')]
        
        if not functions:
            return 50.0
        
        testable_functions = 0
        for func in functions:
            if len(func) < 80 and 'self' not in func:
                testable_functions += 1
        
        return (testable_functions / len(functions)) * 100
    
    def _calculate_reusability(self, code: str) -> float:
        score = 50.0
        
        if 'def ' in code:
            score += 20
        if 'class ' in code:
            score += 20
        if 'return' in code:
            score += 10
        
        return min(100, score)
    
    def _get_grade(self, score: float) -> str:
        if score >= 90:
            return "A"
        elif score >= 80:
            return "B"
        elif score >= 70:
            return "C"
        elif score >= 60:
            return "D"
        else:
            return "F"
    
    def _generate_recommendations(self, analysis: Dict[str, float]) -> List[str]:
        recommendations = []
        
        if analysis.get("complexity", 100) < 60:
            recommendations.append("Reduce code complexity by breaking down functions")
        if analysis.get("maintainability", 100) < 60:
            recommendations.append("Add more comments and documentation")
        if analysis.get("testability", 100) < 60:
            recommendations.append("Refactor to improve testability")
        if analysis.get("reusability", 100) < 60:
            recommendations.append("Extract reusable components")
        
        return recommendations
    
    def _suggest_improvements(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        code = input_data.get("code", "")
        issues = input_data.get("issues", [])
        
        improvements = []
        
        for issue in issues:
            if issue.get("type") == "line_length":
                improvements.append({
                    "type": "formatting",
                    "description": "Break long lines into multiple lines",
                    "original": issue.get("code", ""),
                    "suggested": "Break this line into multiple lines"
                })
            elif issue.get("type") == "debug_statement":
                improvements.append({
                    "type": "cleanup",
                    "description": "Remove debug print statements",
                    "original": "print(...)",
                    "suggested": "Use proper logging instead"
                })
            elif issue.get("type") == "bare_except":
                improvements.append({
                    "type": "error_handling",
                    "description": "Specify exception type",
                    "original": "except:",
                    "suggested": "except Exception as e:"
                })
        
        return {
            "improvements": improvements,
            "total_suggestions": len(improvements),
            "auto_fixable": len([i for i in improvements if i["type"] in ["formatting", "cleanup"]])
        }
    
    def get_supported_tasks(self) -> list:
        return self.supported_task_types'''
        reviewer_file.write_text(content)
        print("Created reviewer_agent.py")
        
    def create_optimizer_agent(self):
        """Create optimizer agent for performance improvement"""
        
        optimizer_file = self.agents_dir / "optimizer_agent.py"
        content = '''from typing import Dict, Any, List
import json
import logging
import re
from .base_agent import BaseAgent, AgentTask, AgentResult

logger = logging.getLogger(__name__)

class OptimizerAgent(BaseAgent):
    def __init__(self):
        super().__init__("OptimizerAgent", "optimizer")
        self.supported_task_types = ["optimize_performance", "refactor_code", "improve_efficiency"]
        
    def can_handle(self, task_type: str) -> bool:
        return task_type in self.supported_task_types
    
    def validate_input(self, task: AgentTask) -> bool:
        required_fields = {
            "optimize_performance": ["code", "metrics"],
            "refactor_code": ["code", "target_pattern"],
            "improve_efficiency": ["code", "bottlenecks"]
        }
        
        task_type = task.task_type
        if task_type in required_fields:
            for field in required_fields[task_type]:
                if field not in task.input_data:
                    logger.error(f"Missing required field: {field}")
                    return False
        return True
    
    async def process(self, task: AgentTask) -> AgentResult:
        import time
        start_time = time.time()
        
        try:
            if not self.validate_input(task):
                return AgentResult(
                    task_id=task.task_id,
                    agent_type=self.agent_type,
                    output_data={},
                    confidence_score=0.0,
                    execution_time=0,
                    errors=["Invalid input validation failed"],
                    metadata={}
                )
            
            if task.task_type == "optimize_performance":
                output = self._optimize_performance(task.input_data)
            elif task.task_type == "refactor_code":
                output = self._refactor_code(task.input_data)
            elif task.task_type == "improve_efficiency":
                output = self._improve_efficiency(task.input_data)
            else:
                output = {"error": f"Unknown task type: {task.task_type}"}
            
            execution_time = time.time() - start_time
            
            return AgentResult(
                task_id=task.task_id,
                agent_type=self.agent_type,
                output_data=output,
                confidence_score=0.86,
                execution_time=execution_time,
                errors=[],
                metadata={"optimizer_version": "1.0"}
            )
            
        except Exception as e:
            logger.error(f"Error in OptimizerAgent: {str(e)}")
            return AgentResult(
                task_id=task.task_id,
                agent_type=self.agent_type,
                output_data={},
                confidence_score=0.0,
                execution_time=time.time() - start_time,
                errors=[str(e)],
                metadata={}
            )
    
    def _optimize_performance(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        code = input_data.get("code", "")
        metrics = input_data.get("metrics", {})
        
        optimizations = []
        optimized_code = code
        
        if "for" in code and "range" in code:
            optimized_code = self._optimize_loops(optimized_code)
            optimizations.append("Optimized loop structures")
        
        if ".append" in code:
            optimized_code = self._optimize_list_operations(optimized_code)
            optimizations.append("Optimized list operations")
        
        if "if" in code and "else" in code:
            optimized_code = self._optimize_conditionals(optimized_code)
            optimizations.append("Simplified conditional logic")
        
        performance_gain = len(optimizations) * 5
        
        return {
            "original_code": code,
            "optimized_code": optimized_code,
            "optimizations_applied": optimizations,
            "estimated_performance_gain": f"{performance_gain}%",
            "lines_changed": self._count_changes(code, optimized_code)
        }
    
    def _optimize_loops(self, code: str) -> str:
        lines = code.split('\\n')
        optimized = []
        
        for line in lines:
            if 'for i in range(len(' in line:
                match = re.search(r'for i in range\(len\((\w+)\)\)', line)
                if match:
                    var_name = match.group(1)
                    new_line = line.replace(f'for i in range(len({var_name}))', f'for item in {var_name}')
                    optimized.append(new_line)
                    continue
            optimized.append(line)
        
        return '\\n'.join(optimized)
    
    def _optimize_list_operations(self, code: str) -> str:
        lines = code.split('\\n')
        optimized = []
        
        for line in lines:
            if '.append' in line:
                line = line.replace('.append(', '.extend([')
            optimized.append(line)
        
        return '\\n'.join(optimized)
    
    def _optimize_conditionals(self, code: str) -> str:
        lines = code.split('\\n')
        optimized = []
        
        for line in lines:
            if 'if' in line and 'else' in line and len(line) < 60:
                match = re.search(r'if (.+):.*else:', line)
                if match:
                    condition = match.group(1)
                    new_line = f"result = {condition} and value1 or value2"
                    optimized.append(new_line)
                    continue
            optimized.append(line)
        
        return '\\n'.join(optimized)
    
    def _refactor_code(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        code = input_data.get("code", "")
        target_pattern = input_data.get("target_pattern", "extract_function")
        
        refactored_code = code
        refactoring_notes = []
        
        if target_pattern == "extract_function":
            lines = code.split('\\n')
            large_blocks = []
            current_block = []
            
            for line in lines:
                if line.strip() and not line.strip().startswith('def ') and not line.strip().startswith('class '):
                    current_block.append(line)
                elif current_block:
                    if len(current_block) > 10:
                        large_blocks.append(current_block)
                    current_block = []
            
            for block in large_blocks:
                block_text = '\\n'.join(block)
                refactoring_notes.append(f"Consider extracting {len(block)} lines into a separate function")
        
        elif target_pattern == "extract_class":
            functions = [line for line in code.split('\\n') if line.strip().startswith('def ')]
            if len(functions) > 3:
                refactoring_notes.append("Consider grouping related functions into a class")
        
        return {
            "refactored_code": refactored_code,
            "refactoring_notes": refactoring_notes,
            "pattern_applied": target_pattern,
            "complexity_reduction": len(refactoring_notes) * 5
        }
    
    def _improve_efficiency(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        code = input_data.get("code", "")
        bottlenecks = input_data.get("bottlenecks", [])
        
        improvements = []
        improved_code = code
        
        for bottleneck in bottlenecks:
            if "database" in bottleneck.lower() or "query" in bottleneck.lower():
                improved_code = self._add_caching(improved_code)
                improvements.append("Added caching for database queries")
            
            if "loop" in bottleneck.lower() or "iteration" in bottleneck.lower():
                improved_code = self._vectorize_operations(improved_code)
                improvements.append("Vectorized loop operations")
            
            if "recursion" in bottleneck.lower():
                improved_code = self._convert_to_iterative(improved_code)
                improvements.append("Converted recursion to iteration")
        
        return {
            "improved_code": improved_code,
            "improvements": improvements,
            "efficiency_gain": len(improvements) * 10,
            "bottlenecks_addressed": len(bottlenecks)
        }
    
    def _add_caching(self, code: str) -> str:
        lines = code.split('\\n')
        result = []
        
        for line in lines:
            if 'def ' in line and 'get' in line or 'fetch' in line:
                result.append('    @lru_cache(maxsize=128)')
            result.append(line)
        
        return '\\n'.join(result)
    
    def _vectorize_operations(self, code: str) -> str:
        if 'for' in code and 'in range' in code:
            code = code.replace('for', '# Optimized: use vectorized operations\\n# Original: for')
        
        return code
    
    def _convert_to_iterative(self, code: str) -> str:
        lines = code.split('\\n')
        result = []
        
        for line in lines:
            if 'return' in line and line.count('(') > 2:
                comment = "# Consider converting to iterative approach"
                result.append(comment)
            result.append(line)
        
        return '\\n'.join(result)
    
    def _count_changes(self, original: str, optimized: str) -> int:
        original_lines = original.split('\\n')
        optimized_lines = optimized.split('\\n')
        
        changes = 0
        for i in range(min(len(original_lines), len(optimized_lines))):
            if original_lines[i] != optimized_lines[i]:
                changes += 1
        
        return changes
    
    def get_supported_tasks(self) -> list:
        return self.supported_task_types'''
        optimizer_file.write_text(content)
        print("Created optimizer_agent.py")
        
    def create_evolution_engine(self):
        """Create evolution engine for score-based decision making"""
        
        evolution_file = self.engine_dir / "evolution_engine.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass, field
from datetime import datetime
import json
import logging
import statistics

logger = logging.getLogger(__name__)

@dataclass
class EvolutionRecord:
    generation: int
    code_version: str
    score: float
    improvements: List[str]
    timestamp: datetime
    metadata: Dict[str, Any] = field(default_factory=dict)

@dataclass
class EvolutionDecision:
    action: str
    confidence: float
    reason: str
    target_score: float

class EvolutionEngine:
    def __init__(self):
        self.evolution_history: List[EvolutionRecord] = []
        self.improvement_patterns: Dict[str, int] = {}
        self.score_thresholds = {
            "excellent": 90,
            "good": 75,
            "acceptable": 60,
            "poor": 40,
            "critical": 25
        }
        
    def evaluate_and_evolve(
        self,
        code: str,
        current_score: float,
        generation: int,
        context: Dict[str, Any]
    ) -> EvolutionDecision:
        logger.info(f"Evaluating generation {generation} with score {current_score}")
        
        if current_score >= self.score_thresholds["excellent"]:
            return EvolutionDecision(
                action="finalize",
                confidence=0.95,
                reason=f"Score {current_score} meets excellent threshold",
                target_score=current_score
            )
        
        elif current_score >= self.score_thresholds["good"]:
            improvement_potential = self._calculate_improvement_potential(code)
            if improvement_potential > 20:
                return EvolutionDecision(
                    action="optimize",
                    confidence=0.7,
                    reason=f"Score {current_score} can be improved further. Potential: {improvement_potential}%",
                    target_score=min(100, current_score + improvement_potential)
                )
            else:
                return EvolutionDecision(
                    action="finalize",
                    confidence=0.8,
                    reason="Limited improvement potential",
                    target_score=current_score
                )
        
        elif current_score >= self.score_thresholds["acceptable"]:
            return EvolutionDecision(
                action="optimize",
                confidence=0.85,
                reason=f"Score {current_score} needs optimization",
                target_score=min(100, current_score + 20)
            )
        
        elif current_score >= self.score_thresholds["poor"]:
            return EvolutionDecision(
                action="refactor",
                confidence=0.9,
                reason=f"Score {current_score} is poor. Major refactoring needed",
                target_score=min(100, current_score + 35)
            )
        
        else:
            return EvolutionDecision(
                action="regenerate",
                confidence=0.95,
                reason=f"Score {current_score} is critical. Complete regeneration needed",
                target_score=70
            )
    
    def _calculate_improvement_potential(self, code: str) -> float:
        potential = 0.0
        
        if 'TODO' in code:
            potential += 5
        if 'print(' in code:
            potential += 5
        if 'except:' in code:
            potential += 10
        if '# FIXME' in code:
            potential += 15
        if len(code.split('\\n')) > 100:
            potential += 5
        
        return min(50, potential)
    
    def record_evolution(self, record: EvolutionRecord):
        self.evolution_history.append(record)
        logger.info(f"Recorded evolution generation {record.generation} with score {record.score}")
        
        for improvement in record.improvements:
            self.improvement_patterns[improvement] = self.improvement_patterns.get(improvement, 0) + 1
    
    def get_best_patterns(self, limit: int = 5) -> List[tuple]:
        sorted_patterns = sorted(self.improvement_patterns.items(), key=lambda x: x[1], reverse=True)
        return sorted_patterns[:limit]
    
    def calculate_trend(self, last_n: int = 5) -> Dict[str, Any]:
        if not self.evolution_history:
            return {"trend": "stable", "average_score": 0, "improvement_rate": 0}
        
        recent_records = self.evolution_history[-last_n:]
        scores = [r.score for r in recent_records]
        
        if len(scores) < 2:
            return {"trend": "stable", "average_score": scores[0] if scores else 0, "improvement_rate": 0}
        
        improvement_rate = (scores[-1] - scores[0]) / len(scores)
        
        if improvement_rate > 5:
            trend = "improving"
        elif improvement_rate < -5:
            trend = "declining"
        else:
            trend = "stable"
        
        return {
            "trend": trend,
            "average_score": statistics.mean(scores),
            "improvement_rate": improvement_rate,
            "best_score": max(scores),
            "worst_score": min(scores)
        }
    
    def should_stop_evolution(self, current_score: float, max_generations: int, current_generation: int) -> bool:
        if current_generation >= max_generations:
            logger.info(f"Reached max generations {max_generations}")
            return True
        
        if current_score >= self.score_thresholds["excellent"]:
            logger.info(f"Score {current_score} meets excellent threshold")
            return True
        
        trend_data = self.calculate_trend(3)
        if trend_data["trend"] == "declining" and trend_data["improvement_rate"] < -2:
            logger.info("Declining trend detected")
            return True
        
        return False
    
    def get_next_target_score(self, current_score: float) -> float:
        if current_score < 40:
            return 70
        elif current_score < 60:
            return 80
        elif current_score < 75:
            return 85
        elif current_score < 90:
            return 95
        else:
            return 100
    
    def generate_evolution_summary(self) -> Dict[str, Any]:
        if not self.evolution_history:
            return {"message": "No evolution records"}
        
        first = self.evolution_history[0]
        last = self.evolution_history[-1]
        
        return {
            "total_generations": len(self.evolution_history),
            "initial_score": first.score,
            "final_score": last.score,
            "total_improvement": last.score - first.score,
            "best_score": max(r.score for r in self.evolution_history),
            "best_patterns": self.get_best_patterns(3),
            "trend": self.calculate_trend(),
            "total_improvements": sum(len(r.improvements) for r in self.evolution_history)
        }'''
        evolution_file.write_text(content)
        print("Created evolution_engine.py")
        
    def create_feedback_loop(self):
        """Create feedback loop system PLAN -> BUILD -> REVIEW -> SCORE -> OPTIMIZE -> FINALIZE"""
        
        feedback_loop_file = self.engine_dir / "feedback_loop.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import asyncio
import logging
import uuid
from ..agents.backend_agent import BackendAgent
from ..agents.reviewer_agent import ReviewerAgent
from ..agents.optimizer_agent import OptimizerAgent
from ..orchestrator.scoring_engine import ScoringEngine
from .evolution_engine import EvolutionEngine, EvolutionRecord

logger = logging.getLogger(__name__)

@dataclass
class LoopIteration:
    iteration: int
    phase: str
    code: str
    score: float
    issues: List[Dict[str, Any]]
    improvements: List[str]
    timestamp: datetime

class FeedbackLoop:
    def __init__(self):
        self.backend_agent = BackendAgent()
        self.reviewer_agent = ReviewerAgent()
        self.optimizer_agent = OptimizerAgent()
        self.scoring_engine = ScoringEngine()
        self.evolution_engine = EvolutionEngine()
        self.iteration_history: List[LoopIteration] = []
        
    async def execute(
        self,
        requirement: str,
        initial_code: Optional[str] = None,
        max_iterations: int = 10
    ) -> Dict[str, Any]:
        loop_id = str(uuid.uuid4())
        logger.info(f"Starting feedback loop {loop_id} for requirement: {requirement}")
        
        current_code = initial_code or ""
        current_score = 0.0
        iteration = 0
        
        while iteration < max_iterations:
            iteration += 1
            logger.info(f"Loop iteration {iteration}")
            
            # PLAN phase
            phase = "PLAN"
            plan_result = await self._plan_phase(requirement, current_code, iteration)
            logger.info(f"PLAN phase complete")
            
            # BUILD phase
            phase = "BUILD"
            build_result = await self._build_phase(requirement, plan_result, iteration)
            current_code = build_result.get("code", current_code)
            logger.info(f"BUILD phase complete")
            
            # REVIEW phase
            phase = "REVIEW"
            review_result = await self._review_phase(current_code)
            issues = review_result.get("issues", [])
            logger.info(f"REVIEW phase found {len(issues)} issues")
            
            # SCORE phase
            phase = "SCORE"
            score_result = self._score_phase(current_code)
            current_score = score_result.get("total_score", 0)
            logger.info(f"SCORE phase: {current_score}")
            
            # Record iteration
            loop_iteration = LoopIteration(
                iteration=iteration,
                phase=phase,
                code=current_code,
                score=current_score,
                issues=issues,
                improvements=[],
                timestamp=datetime.now()
            )
            self.iteration_history.append(loop_iteration)
            
            # Check if should stop
            if current_score >= 90:
                logger.info(f"Score {current_score} meets threshold, finalizing")
                break
            
            # OPTIMIZE phase
            phase = "OPTIMIZE"
            if current_score < 75:
                optimize_result = await self._optimize_phase(current_code, issues)
                if optimize_result.get("optimized_code"):
                    current_code = optimize_result["optimized_code"]
                    loop_iteration.improvements = optimize_result.get("improvements", [])
                    logger.info(f"OPTIMIZE phase applied {len(loop_iteration.improvements)} improvements")
            
            # Record evolution
            evolution_record = EvolutionRecord(
                generation=iteration,
                code_version=f"v{iteration}",
                score=current_score,
                improvements=loop_iteration.improvements,
                timestamp=datetime.now(),
                metadata={"requirement": requirement}
            )
            self.evolution_engine.record_evolution(evolution_record)
            
            # Check stop condition
            if self.evolution_engine.should_stop_evolution(current_score, max_iterations, iteration):
                logger.info(f"Stop condition met at iteration {iteration}")
                break
        
        # FINALIZE phase
        final_code = await self._finalize_phase(current_code, current_score)
        
        return {
            "loop_id": loop_id,
            "final_code": final_code,
            "final_score": current_score,
            "iterations": iteration,
            "history": self._summarize_history(),
            "evolution_summary": self.evolution_engine.generate_evolution_summary()
        }
    
    async def _plan_phase(self, requirement: str, existing_code: str, iteration: int) -> Dict[str, Any]:
        plan = {
            "requirement": requirement,
            "existing_code": existing_code,
            "iteration": iteration,
            "strategy": "incremental_improvement" if existing_code else "from_scratch"
        }
        
        if iteration == 1:
            plan["focus"] = "core_functionality"
        elif iteration <= 3:
            plan["focus"] = "error_handling"
        elif iteration <= 6:
            plan["focus"] = "optimization"
        else:
            plan["focus"] = "polish"
        
        return plan
    
    async def _build_phase(self, requirement: str, plan: Dict[str, Any], iteration: int) -> Dict[str, Any]:
        from ..agents.base_agent import AgentTask
        
        task = AgentTask(
            task_id=str(uuid.uuid4()),
            task_type="generate_api",
            input_data={
                "entity_name": "item",
                "fields": {"name": "string", "description": "string"}
            },
            context={"requirement": requirement, "plan": plan},
            created_at=datetime.now()
        )
        
        result = await self.backend_agent.process(task)
        
        return {
            "code": result.output_data.get("code", "# Code generation result"),
            "metadata": result.metadata
        }
    
    async def _review_phase(self, code: str) -> Dict[str, Any]:
        from ..agents.base_agent import AgentTask
        
        task = AgentTask(
            task_id=str(uuid.uuid4()),
            task_type="review_code",
            input_data={"code": code, "language": "python"},
            context={},
            created_at=datetime.now()
        )
        
        result = await self.reviewer_agent.process(task)
        
        return result.output_data
    
    def _score_phase(self, code: str) -> Dict[str, Any]:
        evaluation = self.scoring_engine.evaluate_code(code)
        
        return {
            "total_score": evaluation.total_score,
            "breakdown": [(b.criteria_name, b.score) for b in evaluation.breakdown],
            "passed": evaluation.passed,
            "recommendations": evaluation.recommendations
        }
    
    async def _optimize_phase(self, code: str, issues: List[Dict[str, Any]]) -> Dict[str, Any]:
        from ..agents.base_agent import AgentTask
        
        task = AgentTask(
            task_id=str(uuid.uuid4()),
            task_type="refactor_code",
            input_data={"code": code, "target_pattern": "extract_function"},
            context={"issues": issues},
            created_at=datetime.now()
        )
        
        result = await self.optimizer_agent.process(task)
        
        return {
            "optimized_code": result.output_data.get("refactored_code"),
            "improvements": result.output_data.get("refactoring_notes", [])
        }
    
    async def _finalize_phase(self, code: str, score: float) -> str:
        final_code = code
        
        if score < 60:
            final_code = "# WARNING: Score below threshold\\n" + code + "\\n# TODO: Further improvements needed"
        
        final_code = "# AUTO-GENERATED BY AI FACTORY\\n# Final version\\n" + final_code
        
        return final_code
    
    def _summarize_history(self) -> List[Dict[str, Any]]:
        return [
            {
                "iteration": i.iteration,
                "score": i.score,
                "issues_count": len(i.issues),
                "improvements_count": len(i.improvements)
            }
            for i in self.iteration_history
        ]
    
    def get_best_iteration(self) -> Optional[LoopIteration]:
        if not self.iteration_history:
            return None
        
        return max(self.iteration_history, key=lambda x: x.score)'''
        feedback_loop_file.write_text(content)
        print("Created feedback_loop.py")
        
    def create_pattern_memory(self):
        """Create pattern memory storage for learning from past improvements"""
        
        pattern_memory_file = self.memory_dir / "pattern_memory.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass, field
from datetime import datetime
import json
import logging
import hashlib

logger = logging.getLogger(__name__)

@dataclass
class CodePattern:
    pattern_id: str
    pattern_type: str
    description: str
    code_snippet: str
    context: Dict[str, Any]
    success_count: int
    failure_count: int
    effectiveness_score: float
    created_at: datetime
    last_used: Optional[datetime]

@dataclass
class ImprovementRecord:
    record_id: str
    original_code_hash: str
    improved_code_hash: str
    pattern_used: str
    score_before: float
    score_after: float
    improvement_delta: float
    timestamp: datetime

class PatternMemory:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not hasattr(self, 'initialized'):
            self.initialized = True
            self.patterns: Dict[str, CodePattern] = {}
            self.improvements: List[ImprovementRecord] = []
            self._load_default_patterns()
    
    def _load_default_patterns(self):
        default_patterns = [
            CodePattern(
                pattern_id="ptrn_001",
                pattern_type="error_handling",
                description="Add proper exception handling",
                code_snippet="try:\\n    # operation\\nexcept Exception as e:\\n    logger.error(f'Error: {e}')\\n    raise",
                context={},
                success_count=0,
                failure_count=0,
                effectiveness_score=0.0,
                created_at=datetime.now(),
                last_used=None
            ),
            CodePattern(
                pattern_id="ptrn_002",
                pattern_type="logging",
                description="Add structured logging",
                code_snippet="import logging\\nlogger = logging.getLogger(__name__)",
                context={},
                success_count=0,
                failure_count=0,
                effectiveness_score=0.0,
                created_at=datetime.now(),
                last_used=None
            ),
            CodePattern(
                pattern_id="ptrn_003",
                pattern_type="validation",
                description="Add input validation",
                code_snippet="if not input_data:\\n    raise ValueError('Input cannot be empty')",
                context={},
                success_count=0,
                failure_count=0,
                effectiveness_score=0.0,
                created_at=datetime.now(),
                last_used=None
            ),
            CodePattern(
                pattern_id="ptrn_004",
                pattern_type="caching",
                description="Add caching decorator",
                code_snippet="from functools import lru_cache\\n\\n@lru_cache(maxsize=128)",
                context={},
                success_count=0,
                failure_count=0,
                effectiveness_score=0.0,
                created_at=datetime.now(),
                last_used=None
            ),
            CodePattern(
                pattern_id="ptrn_005",
                pattern_type="type_hints",
                description="Add type hints",
                code_snippet="def function_name(param: str) -> dict:",
                context={},
                success_count=0,
                failure_count=0,
                effectiveness_score=0.0,
                created_at=datetime.now(),
                last_used=None
            )
        ]
        
        for pattern in default_patterns:
            self.patterns[pattern.pattern_id] = pattern
    
    def add_pattern(self, pattern: CodePattern):
        self.patterns[pattern.pattern_id] = pattern
        logger.info(f"Added pattern {pattern.pattern_id}: {pattern.description}")
    
    def get_pattern(self, pattern_id: str) -> Optional[CodePattern]:
        pattern = self.patterns.get(pattern_id)
        if pattern:
            pattern.last_used = datetime.now()
        return pattern
    
    def get_patterns_by_type(self, pattern_type: str) -> List[CodePattern]:
        return [p for p in self.patterns.values() if p.pattern_type == pattern_type]
    
    def get_best_patterns(self, limit: int = 5) -> List[CodePattern]:
        sorted_patterns = sorted(
            self.patterns.values(),
            key=lambda x: x.effectiveness_score,
            reverse=True
        )
        return sorted_patterns[:limit]
    
    def record_success(self, pattern_id: str, score_improvement: float):
        pattern = self.patterns.get(pattern_id)
        if pattern:
            pattern.success_count += 1
            pattern.effectiveness_score = self._calculate_effectiveness(pattern)
            logger.info(f"Recorded success for pattern {pattern_id}")
    
    def record_failure(self, pattern_id: str):
        pattern = self.patterns.get(pattern_id)
        if pattern:
            pattern.failure_count += 1
            pattern.effectiveness_score = self._calculate_effectiveness(pattern)
            logger.info(f"Recorded failure for pattern {pattern_id}")
    
    def _calculate_effectiveness(self, pattern: CodePattern) -> float:
        total = pattern.success_count + pattern.failure_count
        if total == 0:
            return 0.0
        
        base_score = (pattern.success_count / total) * 100
        
        if pattern.success_count > 5:
            base_score += 5
        if pattern.failure_count > pattern.success_count:
            base_score -= 20
        
        return max(0, min(100, base_score))
    
    def add_improvement_record(
        self,
        original_code: str,
        improved_code: str,
        pattern_used: str,
        score_before: float,
        score_after: float
    ):
        record = ImprovementRecord(
            record_id=self._generate_id(),
            original_code_hash=self._hash_code(original_code),
            improved_code_hash=self._hash_code(improved_code),
            pattern_used=pattern_used,
            score_before=score_before,
            score_after=score_after,
            improvement_delta=score_after - score_before,
            timestamp=datetime.now()
        )
        self.improvements.append(record)
        
        if record.improvement_delta > 0:
            self.record_success(pattern_used, record.improvement_delta)
        else:
            self.record_failure(pattern_used)
        
        logger.info(f"Added improvement record with delta {record.improvement_delta}")
    
    def _hash_code(self, code: str) -> str:
        return hashlib.md5(code.encode()).hexdigest()
    
    def _generate_id(self) -> str:
        return f"rec_{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}"
    
    def find_similar_improvements(self, code: str) -> List[ImprovementRecord]:
        code_hash = self._hash_code(code)
        similar = []
        
        for record in self.improvements:
            if record.original_code_hash == code_hash:
                similar.append(record)
        
        return similar
    
    def get_statistics(self) -> Dict[str, Any]:
        total_patterns = len(self.patterns)
        total_improvements = len(self.improvements)
        
        if total_improvements > 0:
            avg_improvement = sum(r.improvement_delta for r in self.improvements) / total_improvements
        else:
            avg_improvement = 0.0
        
        return {
            "total_patterns": total_patterns,
            "total_improvements": total_improvements,
            "avg_improvement_delta": avg_improvement,
            "most_effective_pattern": self.get_best_patterns(1)[0] if self.get_best_patterns(1) else None,
            "patterns_by_type": {t: len(self.get_patterns_by_type(t)) for t in set(p.pattern_type for p in self.patterns.values())}
        }
    
    def export_memory(self) -> Dict[str, Any]:
        return {
            "patterns": [
                {
                    "pattern_id": p.pattern_id,
                    "pattern_type": p.pattern_type,
                    "description": p.description,
                    "code_snippet": p.code_snippet,
                    "success_count": p.success_count,
                    "failure_count": p.failure_count,
                    "effectiveness_score": p.effectiveness_score
                }
                for p in self.patterns.values()
            ],
            "improvements": [
                {
                    "record_id": r.record_id,
                    "pattern_used": r.pattern_used,
                    "score_before": r.score_before,
                    "score_after": r.score_after,
                    "improvement_delta": r.improvement_delta,
                    "timestamp": r.timestamp.isoformat()
                }
                for r in self.improvements
            ],
            "statistics": self.get_statistics()
        }'''
        pattern_memory_file.write_text(content)
        print("Created pattern_memory.py")
        
    def create_improvement_tracker(self):
        """Create improvement tracking system"""
        
        tracker_file = self.memory_dir / "improvement_tracker.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta
import json
import logging

logger = logging.getLogger(__name__)

@dataclass
class ImprovementMetric:
    metric_name: str
    value_before: float
    value_after: float
    improvement: float
    timestamp: datetime

class ImprovementTracker:
    def __init__(self):
        self.metrics: List[ImprovementMetric] = []
        self.scores: List[float] = []
        
    def track_improvement(
        self,
        metric_name: str,
        before: float,
        after: float
    ):
        metric = ImprovementMetric(
            metric_name=metric_name,
            value_before=before,
            value_after=after,
            improvement=after - before,
            timestamp=datetime.now()
        )
        self.metrics.append(metric)
        logger.info(f"Tracked improvement for {metric_name}: {before} -> {after}")
    
    def track_score(self, score: float):
        self.scores.append(score)
        logger.debug(f"Tracked score: {score}")
    
    def get_average_improvement(self, metric_name: Optional[str] = None) -> float:
        relevant_metrics = self.metrics
        if metric_name:
            relevant_metrics = [m for m in self.metrics if m.metric_name == metric_name]
        
        if not relevant_metrics:
            return 0.0
        
        total_improvement = sum(m.improvement for m in relevant_metrics)
        return total_improvement / len(relevant_metrics)
    
    def get_total_improvement(self) -> float:
        if not self.scores or len(self.scores) < 2:
            return 0.0
        
        return self.scores[-1] - self.scores[0]
    
    def get_improvement_rate(self, window_days: int = 7) -> float:
        cutoff = datetime.now() - timedelta(days=window_days)
        recent_metrics = [m for m in self.metrics if m.timestamp >= cutoff]
        
        if not recent_metrics:
            return 0.0
        
        total = sum(m.improvement for m in recent_metrics)
        return total / len(recent_metrics)
    
    def get_best_improvement(self) -> Optional[ImprovementMetric]:
        if not self.metrics:
            return None
        
        return max(self.metrics, key=lambda x: x.improvement)
    
    def get_worst_improvement(self) -> Optional[ImprovementMetric]:
        if not self.metrics:
            return None
        
        return min(self.metrics, key=lambda x: x.improvement)
    
    def generate_report(self) -> Dict[str, Any]:
        if not self.metrics and not self.scores:
            return {"message": "No improvement data tracked"}
        
        report = {
            "total_improvements_tracked": len(self.metrics),
            "total_scores_tracked": len(self.scores),
            "average_improvement": self.get_average_improvement(),
            "total_improvement": self.get_total_improvement(),
            "improvement_rate": self.get_improvement_rate(),
            "best_improvement": None,
            "worst_improvement": None,
            "improvements_by_metric": {}
        }
        
        best = self.get_best_improvement()
        if best:
            report["best_improvement"] = {
                "metric": best.metric_name,
                "improvement": best.improvement,
                "from": best.value_before,
                "to": best.value_after
            }
        
        worst = self.get_worst_improvement()
        if worst:
            report["worst_improvement"] = {
                "metric": worst.metric_name,
                "improvement": worst.improvement,
                "from": worst.value_before,
                "to": worst.value_after
            }
        
        metric_names = set(m.metric_name for m in self.metrics)
        for metric_name in metric_names:
            report["improvements_by_metric"][metric_name] = self.get_average_improvement(metric_name)
        
        if self.scores:
            report["score_progression"] = {
                "initial": self.scores[0] if self.scores else None,
                "final": self.scores[-1] if self.scores else None,
                "best": max(self.scores) if self.scores else None,
                "worst": min(self.scores) if self.scores else None
            }
        
        return report
    
    def reset(self):
        self.metrics = []
        self.scores = []
        logger.info("Improvement tracker reset")'''
        tracker_file.write_text(content)
        print("Created improvement_tracker.py")
        
    def create_self_improving_tests(self):
        """Create tests for self-improving system"""
        
        test_file = self.tests_dir / "unit" / "test_self_improving.py"
        content = '''import pytest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from factory.agents.reviewer_agent import ReviewerAgent
from factory.agents.optimizer_agent import OptimizerAgent
from factory.engine.evolution_engine import EvolutionEngine
from factory.engine.feedback_loop import FeedbackLoop
from factory.memory.pattern_memory import PatternMemory
from factory.memory.improvement_tracker import ImprovementTracker

@pytest.mark.asyncio
async def test_reviewer_agent():
    agent = ReviewerAgent()
    from factory.agents.base_agent import AgentTask
    from datetime import datetime
    
    task = AgentTask(
        task_id="test_review",
        task_type="review_code",
        input_data={"code": "def test():\\n    print('hello')\\n", "language": "python"},
        context={},
        created_at=datetime.now()
    )
    
    result = await agent.process(task)
    assert result.agent_type == "reviewer"
    assert "quality_score" in result.output_data

@pytest.mark.asyncio
async def test_optimizer_agent():
    agent = OptimizerAgent()
    from factory.agents.base_agent import AgentTask
    from datetime import datetime
    
    task = AgentTask(
        task_id="test_optimize",
        task_type="optimize_performance",
        input_data={"code": "for i in range(len(items)):\\n    print(items[i])\\n", "metrics": {}},
        context={},
        created_at=datetime.now()
    )
    
    result = await agent.process(task)
    assert result.agent_type == "optimizer"
    assert "optimized_code" in result.output_data

def test_evolution_engine():
    engine = EvolutionEngine()
    decision = engine.evaluate_and_evolve("# code", 65, 1, {})
    assert decision.action in ["finalize", "optimize", "refactor", "regenerate"]

@pytest.mark.asyncio
async def test_feedback_loop():
    loop = FeedbackLoop()
    result = await loop.execute("Create a simple API", max_iterations=2)
    assert "final_code" in result
    assert "final_score" in result

def test_pattern_memory():
    memory = PatternMemory()
    patterns = memory.get_best_patterns()
    assert len(patterns) > 0
    stats = memory.get_statistics()
    assert "total_patterns" in stats

def test_improvement_tracker():
    tracker = ImprovementTracker()
    tracker.track_improvement("code_quality", 50, 75)
    tracker.track_score(75)
    report = tracker.generate_report()
    assert report["total_improvements_tracked"] == 1
    assert report["total_improvement"] == 25'''
        test_file.write_text(content)
        print("Created self_improving tests")
        
    def run_setup(self):
        """Run the batch 4 setup"""
        
        print("\\nStarting Batch 4 - Self-Improving System")
        print("=" * 60)
        
        self.create_reviewer_agent()
        self.create_optimizer_agent()
        self.create_evolution_engine()
        self.create_feedback_loop()
        self.create_pattern_memory()
        self.create_improvement_tracker()
        self.create_self_improving_tests()
        
        print("\\n" + "=" * 60)
        print("Batch 4 Complete - Self-Improving System Generated")
        print("\\nComponents added:")
        print("  Reviewer Agent - Code criticism and feedback")
        print("  Optimizer Agent - Performance improvement")
        print("  Evolution Engine - Score-based decision making")
        print("  Feedback Loop - PLAN -> BUILD -> REVIEW -> SCORE -> OPTIMIZE -> FINALIZE")
        print("  Pattern Memory - Learning from past improvements")
        print("  Improvement Tracker - Track improvement metrics")

def main():
    generator = Batch4Generator()
    generator.run_setup()

if __name__ == "__main__":
    main()