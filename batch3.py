#!/usr/bin/env python3
"""
Batch 3: Multi-Agent Orchestration System
Generates the coordinator, task planner, agent debate system, scoring engine, and execution pipeline manager
"""

from pathlib import Path

class Batch3Generator:
    def __init__(self):
        self.project_root = Path("ai-factory")
        self.factory_dir = self.project_root / "factory"
        self.orchestrator_dir = self.factory_dir / "orchestrator"
        self.engine_dir = self.factory_dir / "engine"
        self.agents_dir = self.factory_dir / "agents"
        self.registry_dir = self.factory_dir / "registry"
        self.tests_dir = self.project_root / "tests"
        
    def create_agent_coordinator(self):
        coordinator_file = self.orchestrator_dir / "agent_coordinator.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import asyncio
import logging
import uuid
from ..agents.base_agent import AgentTask, AgentResult
from ..registry.agent_registry import AgentRegistry

logger = logging.getLogger(__name__)

@dataclass
class OrchestrationPlan:
    plan_id: str
    tasks: List[Dict[str, Any]]
    dependencies: Dict[str, List[str]]
    created_at: datetime

class AgentCoordinator:
    def __init__(self):
        self.registry = AgentRegistry()
        self.active_orchestrations = {}
        self.task_queue = asyncio.Queue()
        
    async def orchestrate(self, goal: str, context: Dict[str, Any]) -> Dict[str, Any]:
        orchestration_id = str(uuid.uuid4())
        logger.info(f"Starting orchestration {orchestration_id} for goal: {goal}")
        
        self.active_orchestrations[orchestration_id] = {
            "status": "planning",
            "goal": goal,
            "start_time": datetime.now(),
            "results": {}
        }
        
        try:
            plan = await self._create_plan(goal, context)
            self.active_orchestrations[orchestration_id]["status"] = "executing"
            
            results = await self._execute_plan(plan, context)
            self.active_orchestrations[orchestration_id]["results"] = results
            self.active_orchestrations[orchestration_id]["status"] = "completed"
            
            return {
                "orchestration_id": orchestration_id,
                "status": "completed",
                "plan": plan,
                "results": results
            }
            
        except Exception as e:
            logger.error(f"Orchestration {orchestration_id} failed: {str(e)}")
            self.active_orchestrations[orchestration_id]["status"] = "failed"
            self.active_orchestrations[orchestration_id]["error"] = str(e)
            raise
    
    async def _create_plan(self, goal: str, context: Dict[str, Any]) -> OrchestrationPlan:
        tasks = []
        dependencies = {}
        
        if "generate_application" in goal:
            tasks = [
                {"task_id": "task_1", "agent_type": "architect", "task_type": "design_system", "priority": 1},
                {"task_id": "task_2", "agent_type": "database", "task_type": "design_schema", "priority": 2},
                {"task_id": "task_3", "agent_type": "backend", "task_type": "generate_api", "priority": 3},
                {"task_id": "task_4", "agent_type": "frontend", "task_type": "generate_component", "priority": 4},
                {"task_id": "task_5", "agent_type": "qa", "task_type": "generate_tests", "priority": 5},
                {"task_id": "task_6", "agent_type": "security", "task_type": "scan_code", "priority": 6},
                {"task_id": "task_7", "agent_type": "devops", "task_type": "generate_dockerfile", "priority": 7}
            ]
            dependencies = {
                "task_2": ["task_1"],
                "task_3": ["task_2"],
                "task_4": ["task_3"],
                "task_5": ["task_4"],
                "task_6": ["task_5"],
                "task_7": ["task_6"]
            }
        else:
            agents = self.registry.get_agents_for_task(goal.split()[0] if goal else "design")
            if agents:
                tasks = [{"task_id": f"task_{i}", "agent_type": a.agent_type, "task_type": a.get_supported_tasks()[0] if a.get_supported_tasks() else "process", "priority": i} for i, a in enumerate(agents)]
        
        return OrchestrationPlan(
            plan_id=str(uuid.uuid4()),
            tasks=tasks,
            dependencies=dependencies,
            created_at=datetime.now()
        )
    
    async def _execute_plan(self, plan: OrchestrationPlan, context: Dict[str, Any]) -> Dict[str, Any]:
        results = {}
        
        sorted_tasks = sorted(plan.tasks, key=lambda x: x.get("priority", 999))
        
        for task in sorted_tasks:
            task_id = task["task_id"]
            deps = plan.dependencies.get(task_id, [])
            
            deps_met = all(dep in results and results[dep].get("success", False) for dep in deps)
            
            if not deps_met:
                logger.warning(f"Dependencies not met for task {task_id}, skipping")
                continue
            
            agent = self.registry.get_agent(task["agent_type"])
            if not agent:
                results[task_id] = {"success": False, "error": f"Agent {task['agent_type']} not found"}
                continue
            
            agent_task = AgentTask(
                task_id=str(uuid.uuid4()),
                task_type=task["task_type"],
                input_data=context,
                context={"orchestration_id": plan.plan_id},
                created_at=datetime.now()
            )
            
            try:
                result = await agent.process(agent_task)
                results[task_id] = {
                    "success": True,
                    "agent_type": task["agent_type"],
                    "output": result.output_data,
                    "confidence": result.confidence_score
                }
            except Exception as e:
                results[task_id] = {"success": False, "error": str(e)}
        
        return results
    
    def get_status(self, orchestration_id: str) -> Optional[Dict[str, Any]]:
        return self.active_orchestrations.get(orchestration_id)'''
        coordinator_file.write_text(content)
        print("Created agent_coordinator.py")
        
    def create_task_planner(self):
        planner_file = self.orchestrator_dir / "task_planner.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass, field
from datetime import datetime
import json
import logging
import uuid

logger = logging.getLogger(__name__)

@dataclass
class PlannedTask:
    task_id: str
    description: str
    agent_type: str
    required_capabilities: List[str]
    estimated_duration: float
    dependencies: List[str]
    priority: int
    input_schema: Dict[str, Any] = field(default_factory=dict)
    output_schema: Dict[str, Any] = field(default_factory=dict)

@dataclass
class ExecutionPlan:
    plan_id: str
    goal: str
    tasks: List[PlannedTask]
    estimated_total_duration: float
    created_at: datetime
    metadata: Dict[str, Any] = field(default_factory=dict)

class TaskPlanner:
    def __init__(self):
        self.plan_history = []
        self.task_templates = self._load_task_templates()
        
    def _load_task_templates(self) -> Dict[str, Dict[str, Any]]:
        return {
            "generate_saas": {
                "tasks": [
                    {"description": "Design system architecture", "agent": "architect", "capabilities": ["design", "planning"]},
                    {"description": "Create database schema", "agent": "database", "capabilities": ["schema_design"]},
                    {"description": "Generate backend API", "agent": "backend", "capabilities": ["code_generation"]},
                    {"description": "Create frontend components", "agent": "frontend", "capabilities": ["ui_generation"]},
                    {"description": "Write tests", "agent": "qa", "capabilities": ["testing"]},
                    {"description": "Security scan", "agent": "security", "capabilities": ["security"]},
                    {"description": "Create deployment config", "agent": "devops", "capabilities": ["deployment"]}
                ]
            },
            "fix_code": {
                "tasks": [
                    {"description": "Analyze code issues", "agent": "qa", "capabilities": ["analysis"]},
                    {"description": "Fix security issues", "agent": "security", "capabilities": ["security"]},
                    {"description": "Apply fixes", "agent": "backend", "capabilities": ["code_generation"]},
                    {"description": "Validate fixes", "agent": "qa", "capabilities": ["testing"]}
                ]
            }
        }
    
    def create_plan(self, goal: str, context: Dict[str, Any]) -> ExecutionPlan:
        tasks = []
        template = self._find_template(goal)
        
        if template:
            for i, task_template in enumerate(template["tasks"]):
                task = PlannedTask(
                    task_id=f"task_{i+1}",
                    description=task_template["description"],
                    agent_type=task_template["agent"],
                    required_capabilities=task_template.get("capabilities", []),
                    estimated_duration=task_template.get("duration", 30.0),
                    dependencies=[f"task_{d}" for d in task_template.get("depends_on", [])],
                    priority=i + 1,
                    input_schema=task_template.get("input_schema", {}),
                    output_schema=task_template.get("output_schema", {})
                )
                tasks.append(task)
        else:
            task = PlannedTask(
                task_id="task_1",
                description=f"Process goal: {goal}",
                agent_type="architect",
                required_capabilities=["general"],
                estimated_duration=60.0,
                dependencies=[],
                priority=1
            )
            tasks.append(task)
        
        total_duration = sum(t.estimated_duration for t in tasks)
        
        plan = ExecutionPlan(
            plan_id=str(uuid.uuid4()),
            goal=goal,
            tasks=tasks,
            estimated_total_duration=total_duration,
            created_at=datetime.now(),
            metadata={"context": context}
        )
        
        self.plan_history.append(plan)
        logger.info(f"Created plan {plan.plan_id} with {len(tasks)} tasks")
        
        return plan
    
    def _find_template(self, goal: str) -> Optional[Dict[str, Any]]:
        goal_lower = goal.lower()
        
        for key, template in self.task_templates.items():
            if key in goal_lower or any(word in goal_lower for word in key.split("_")):
                return template
        
        return None
    
    def optimize_plan(self, plan: ExecutionPlan, constraints: Dict[str, Any]) -> ExecutionPlan:
        max_parallel = constraints.get("max_parallel_tasks", 3)
        
        independent_tasks = [t for t in plan.tasks if not t.dependencies]
        dependent_tasks = [t for t in plan.tasks if t.dependencies]
        
        optimized_tasks = independent_tasks[:max_parallel] + dependent_tasks
        
        plan.tasks = optimized_tasks
        plan.metadata["optimized"] = True
        plan.metadata["optimization_constraints"] = constraints
        
        return plan
    
    def estimate_resources(self, plan: ExecutionPlan) -> Dict[str, Any]:
        agent_counts = {}
        total_time = 0
        
        for task in plan.tasks:
            agent_counts[task.agent_type] = agent_counts.get(task.agent_type, 0) + 1
            total_time += task.estimated_duration
        
        return {
            "agent_requirements": agent_counts,
            "total_estimated_time_minutes": total_time,
            "parallel_opportunities": len([t for t in plan.tasks if not t.dependencies]),
            "critical_path_length": self._calculate_critical_path(plan)
        }
    
    def _calculate_critical_path(self, plan: ExecutionPlan) -> float:
        task_durations = {t.task_id: t.estimated_duration for t in plan.tasks}
        dep_map = {t.task_id: t.dependencies for t in plan.tasks}
        
        longest_path = 0.0
        for task in plan.tasks:
            path_length = self._dfs_path_length(task.task_id, dep_map, task_durations, {})
            longest_path = max(longest_path, path_length)
        
        return longest_path
    
    def _dfs_path_length(self, task_id: str, dep_map: Dict[str, List[str]], durations: Dict[str, float], memo: Dict[str, float]) -> float:
        if task_id in memo:
            return memo[task_id]
        
        if not dep_map.get(task_id):
            return durations.get(task_id, 0)
        
        max_dep_length = 0
        for dep in dep_map.get(task_id, []):
            max_dep_length = max(max_dep_length, self._dfs_path_length(dep, dep_map, durations, memo))
        
        result = durations.get(task_id, 0) + max_dep_length
        memo[task_id] = result
        return result
    
    def get_plan_history(self) -> List[ExecutionPlan]:
        return self.plan_history'''
        planner_file.write_text(content)
        print("Created task_planner.py")
        
    def create_agent_debate(self):
        debate_file = self.orchestrator_dir / "agent_debate.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import asyncio
import logging
import uuid
from ..agents.base_agent import BaseAgent
from ..registry.agent_registry import AgentRegistry

logger = logging.getLogger(__name__)

@dataclass
class DebateRound:
    round_number: int
    proposals: Dict[str, Any]
    votes: Dict[str, str]
    consensus_reached: bool
    winning_proposal: Optional[str]
    discussion_points: List[str]

@dataclass
class DebateResult:
    debate_id: str
    topic: str
    rounds: List[DebateRound]
    final_decision: Dict[str, Any]
    consensus_score: float
    duration_seconds: float

class AgentDebate:
    def __init__(self):
        self.registry = AgentRegistry()
        self.active_debates = {}
        
    async def conduct_debate(
        self,
        topic: str,
        context: Dict[str, Any],
        agent_types: List[str],
        max_rounds: int = 3
    ) -> DebateResult:
        debate_id = str(uuid.uuid4())
        logger.info(f"Starting debate {debate_id} on topic: {topic}")
        
        start_time = datetime.now()
        rounds = []
        current_proposals = {}
        
        agents = []
        for agent_type in agent_types:
            agent = self.registry.get_agent(agent_type)
            if agent:
                agents.append(agent)
        
        if not agents:
            agents = list(self.registry.get_all_agents().values())[:3]
        
        for round_num in range(1, max_rounds + 1):
            proposals = await self._collect_proposals(agents, topic, context, current_proposals)
            votes = await self._conduct_vote(agents, proposals)
            
            consensus, winner = self._check_consensus(votes)
            
            debate_round = DebateRound(
                round_number=round_num,
                proposals=proposals,
                votes=votes,
                consensus_reached=consensus,
                winning_proposal=winner,
                discussion_points=self._generate_discussion_points(proposals, votes)
            )
            rounds.append(debate_round)
            
            if consensus:
                break
            
            current_proposals = {winner: proposals.get(winner, {})}
        
        final_decision = self._make_final_decision(rounds, proposals)
        consensus_score = self._calculate_consensus_score(rounds)
        
        duration = (datetime.now() - start_time).total_seconds()
        
        result = DebateResult(
            debate_id=debate_id,
            topic=topic,
            rounds=rounds,
            final_decision=final_decision,
            consensus_score=consensus_score,
            duration_seconds=duration
        )
        
        self.active_debates[debate_id] = result
        return result
    
    async def _collect_proposals(
        self,
        agents: List[BaseAgent],
        topic: str,
        context: Dict[str, Any],
        previous_proposals: Dict[str, Any]
    ) -> Dict[str, Any]:
        proposals = {}
        
        for agent in agents:
            try:
                if hasattr(agent, 'generate_proposal'):
                    proposal = await agent.generate_proposal(topic, context, previous_proposals)
                else:
                    proposal = {
                        "agent": agent.agent_type,
                        "suggestion": f"Proposal from {agent.agent_type} for {topic}",
                        "confidence": 0.7
                    }
                proposals[agent.agent_type] = proposal
            except Exception as e:
                logger.error(f"Error collecting proposal from {agent.agent_type}: {str(e)}")
                proposals[agent.agent_type] = {"error": str(e), "suggestion": "No proposal"}
        
        return proposals
    
    async def _conduct_vote(self, agents: List[BaseAgent], proposals: Dict[str, Any]) -> Dict[str, str]:
        votes = {}
        
        for agent in agents:
            best_proposal = None
            best_score = -1
            
            for proposer, proposal in proposals.items():
                score = self._evaluate_proposal(proposal, agent.agent_type)
                if score > best_score:
                    best_score = score
                    best_proposal = proposer
            
            votes[agent.agent_type] = best_proposal if best_proposal else list(proposals.keys())[0]
        
        return votes
    
    def _evaluate_proposal(self, proposal: Dict[str, Any], evaluator_type: str) -> float:
        base_score = proposal.get("confidence", 0.5)
        
        if proposal.get("error"):
            return 0.0
        
        if "suggestion" in proposal:
            base_score += 0.1
        
        return min(1.0, base_score)
    
    def _check_consensus(self, votes: Dict[str, str]) -> tuple:
        if not votes:
            return False, None
        
        vote_counts = {}
        for vote in votes.values():
            vote_counts[vote] = vote_counts.get(vote, 0) + 1
        
        max_count = max(vote_counts.values()) if vote_counts else 0
        threshold = len(votes) * 0.6
        
        if max_count >= threshold:
            winner = max(vote_counts, key=vote_counts.get)
            return True, winner
        
        return False, None
    
    def _generate_discussion_points(self, proposals: Dict[str, Any], votes: Dict[str, str]) -> List[str]:
        points = []
        
        for proposer, proposal in proposals.items():
            vote_count = sum(1 for v in votes.values() if v == proposer)
            points.append(f"{proposer} received {vote_count} votes")
        
        return points
    
    def _make_final_decision(self, rounds: List[DebateRound], proposals: Dict[str, Any]) -> Dict[str, Any]:
        if not rounds:
            return {"decision": "No consensus", "selected": None}
        
        last_round = rounds[-1]
        
        if last_round.consensus_reached and last_round.winning_proposal:
            return {
                "decision": "Consensus reached",
                "selected": last_round.winning_proposal,
                "proposal": proposals.get(last_round.winning_proposal, {})
            }
        
        return {
            "decision": "Default selection",
            "selected": list(proposals.keys())[0] if proposals else None,
            "proposal": proposals.get(list(proposals.keys())[0], {}) if proposals else {}
        }
    
    def _calculate_consensus_score(self, rounds: List[DebateRound]) -> float:
        if not rounds:
            return 0.0
        
        total_score = 0.0
        for i, round_data in enumerate(rounds):
            weight = 1.0 / (i + 1)
            if round_data.consensus_reached:
                total_score += weight * 1.0
            else:
                total_score += weight * 0.3
        
        return min(1.0, total_score / len(rounds))'''
        debate_file.write_text(content)
        print("Created agent_debate.py")
        
    def create_scoring_engine(self):
        scoring_file = self.orchestrator_dir / "scoring_engine.py"
        content = '''from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime
import json
import logging
import re

logger = logging.getLogger(__name__)

@dataclass
class ScoreBreakdown:
    criteria_name: str
    score: float
    max_score: float
    feedback: str
    weight: float

@dataclass
class EvaluationResult:
    evaluation_id: str
    item_id: str
    total_score: float
    max_possible: float
    breakdown: List[ScoreBreakdown]
    passed: bool
    recommendations: List[str]
    evaluated_at: datetime

class ScoringEngine:
    def __init__(self):
        self.criteria_weights = self._load_criteria_weights()
        self.evaluation_history = []
        
    def _load_criteria_weights(self) -> Dict[str, Dict[str, Any]]:
        return {
            "code_quality": {
                "criteria": ["syntax", "style", "documentation", "structure"],
                "weights": [0.3, 0.2, 0.2, 0.3],
                "max_score": 100
            },
            "security": {
                "criteria": ["vulnerabilities", "authentication", "authorization", "data_protection"],
                "weights": [0.4, 0.2, 0.2, 0.2],
                "max_score": 100
            },
            "performance": {
                "criteria": ["efficiency", "scalability", "resource_usage", "response_time"],
                "weights": [0.3, 0.3, 0.2, 0.2],
                "max_score": 100
            },
            "completeness": {
                "criteria": ["feature_coverage", "edge_cases", "error_handling", "documentation"],
                "weights": [0.4, 0.2, 0.2, 0.2],
                "max_score": 100
            }
        }
    
    def evaluate_code(self, code: str, language: str = "python") -> EvaluationResult:
        breakdown = []
        
        syntax_score = self._evaluate_syntax(code, language)
        style_score = self._evaluate_style(code)
        doc_score = self._evaluate_documentation(code)
        structure_score = self._evaluate_structure(code)
        
        breakdown.append(ScoreBreakdown("syntax", syntax_score, 100, "Code syntax evaluation", 0.3))
        breakdown.append(ScoreBreakdown("style", style_score, 100, "Code style evaluation", 0.2))
        breakdown.append(ScoreBreakdown("documentation", doc_score, 100, "Documentation quality", 0.2))
        breakdown.append(ScoreBreakdown("structure", structure_score, 100, "Code structure", 0.3))
        
        total_score = sum(b.score * b.weight for b in breakdown)
        
        recommendations = []
        if syntax_score < 70:
            recommendations.append("Fix syntax errors")
        if style_score < 60:
            recommendations.append("Improve code style consistency")
        if doc_score < 50:
            recommendations.append("Add more documentation")
        
        return EvaluationResult(
            evaluation_id=str(datetime.now().timestamp()),
            item_id="code_evaluation",
            total_score=total_score,
            max_possible=100,
            breakdown=breakdown,
            passed=total_score >= 70,
            recommendations=recommendations,
            evaluated_at=datetime.now()
        )
    
    def _evaluate_syntax(self, code: str, language: str) -> float:
        score = 100.0
        
        try:
            compile(code, '<string>', 'exec')
        except SyntaxError as e:
            score -= 30
            logger.warning(f"Syntax error: {str(e)}")
        
        return max(0, score)
    
    def _evaluate_style(self, code: str) -> float:
        score = 100.0
        lines = code.split('\\n')
        
        for i, line in enumerate(lines):
            if len(line) > 100:
                score -= 2
            if line.endswith(' '):
                score -= 1
            if '\\t' in line:
                score -= 1
        
        return max(0, min(100, score))
    
    def _evaluate_documentation(self, code: str) -> float:
        score = 50.0
        
        if '#' in code or '#' in code:
            score += 30
        if '# TODO' in code:
            score += 10
        if '# FIXME' in code:
            score += 10
        
        return min(100, score)
    
    def _evaluate_structure(self, code: str) -> float:
        score = 70.0
        lines = code.split('\\n')
        
        class_count = len([l for l in lines if l.strip().startswith('class ')])
        func_count = len([l for l in lines if l.strip().startswith('def ')])
        
        if class_count > 0 or func_count > 0:
            score += 20
        
        return min(100, score)
    
    def evaluate_agent_output(self, output: Dict[str, Any], agent_type: str) -> EvaluationResult:
        breakdown = []
        
        completeness_score = self._evaluate_completeness(output)
        accuracy_score = self._evaluate_accuracy(output, agent_type)
        relevance_score = self._evaluate_relevance(output, agent_type)
        
        breakdown.append(ScoreBreakdown("completeness", completeness_score, 100, "Output completeness", 0.4))
        breakdown.append(ScoreBreakdown("accuracy", accuracy_score, 100, "Output accuracy", 0.4))
        breakdown.append(ScoreBreakdown("relevance", relevance_score, 100, "Task relevance", 0.2))
        
        total_score = sum(b.score * b.weight for b in breakdown)
        
        return EvaluationResult(
            evaluation_id=str(datetime.now().timestamp()),
            item_id=f"agent_{agent_type}",
            total_score=total_score,
            max_possible=100,
            breakdown=breakdown,
            passed=total_score >= 60,
            recommendations=[],
            evaluated_at=datetime.now()
        )
    
    def _evaluate_completeness(self, output: Dict[str, Any]) -> float:
        if not output:
            return 0.0
        
        expected_keys = ["code", "output", "result", "data", "message"]
        found_keys = sum(1 for k in expected_keys if k in output or any(k in str(v).lower() for v in output.values()))
        
        return (found_keys / len(expected_keys)) * 100
    
    def _evaluate_accuracy(self, output: Dict[str, Any], agent_type: str) -> float:
        base_score = 70.0
        
        if "error" in output:
            base_score -= 40
        if "success" in output and output["success"] == False:
            base_score -= 30
        
        return max(0, base_score)
    
    def _evaluate_relevance(self, output: Dict[str, Any], agent_type: str) -> float:
        if not output:
            return 0.0
        
        output_str = json.dumps(output).lower()
        
        relevance_indicators = {
            "architect": ["architecture", "design", "system", "component"],
            "backend": ["api", "service", "database", "model"],
            "frontend": ["component", "page", "ui", "react"],
            "database": ["schema", "table", "column", "query"],
            "qa": ["test", "assert", "coverage", "pytest"],
            "security": ["vulnerability", "security", "auth", "encryption"],
            "devops": ["docker", "deploy", "pipeline", "monitoring"]
        }
        
        indicators = relevance_indicators.get(agent_type, ["code", "output"])
        found = sum(1 for ind in indicators if ind in output_str)
        
        return (found / len(indicators)) * 100
    
    def get_threshold(self, criteria: str) -> float:
        thresholds = {
            "pass": 70.0,
            "warning": 50.0,
            "critical": 30.0
        }
        return thresholds.get(criteria, 60.0)'''
        scoring_file.write_text(content)
        print("Created scoring_engine.py")
        
    def create_execution_pipeline_manager(self):
        pipeline_manager_file = self.orchestrator_dir / "execution_pipeline_manager.py"
        content = '''from typing import Dict, Any, List, Optional, Callable
from dataclasses import dataclass
from datetime import datetime
import asyncio
import logging
import uuid
from .agent_coordinator import AgentCoordinator
from .task_planner import TaskPlanner, ExecutionPlan
from .scoring_engine import ScoringEngine, EvaluationResult

logger = logging.getLogger(__name__)

@dataclass
class PipelineExecution:
    execution_id: str
    plan: ExecutionPlan
    status: str
    current_stage: int
    results: Dict[str, Any]
    scores: Dict[str, EvaluationResult]
    started_at: datetime
    completed_at: Optional[datetime]
    errors: List[str]

class ExecutionPipelineManager:
    def __init__(self):
        self.coordinator = AgentCoordinator()
        self.planner = TaskPlanner()
        self.scoring_engine = ScoringEngine()
        self.active_executions = {}
        self.pipeline_hooks = {
            "pre_execution": [],
            "post_task": [],
            "post_execution": []
        }
        
    async def execute_pipeline(
        self,
        goal: str,
        context: Dict[str, Any],
        config: Optional[Dict[str, Any]] = None
    ) -> PipelineExecution:
        execution_id = str(uuid.uuid4())
        logger.info(f"Starting pipeline execution {execution_id} for goal: {goal}")
        
        await self._trigger_hooks("pre_execution", execution_id, {"goal": goal, "context": context})
        
        plan = self.planner.create_plan(goal, context)
        
        if config and config.get("optimize", False):
            plan = self.planner.optimize_plan(plan, config.get("constraints", {}))
        
        execution = PipelineExecution(
            execution_id=execution_id,
            plan=plan,
            status="running",
            current_stage=0,
            results={},
            scores={},
            started_at=datetime.now(),
            completed_at=None,
            errors=[]
        )
        
        self.active_executions[execution_id] = execution
        
        try:
            result = await self.coordinator.orchestrate(goal, context)
            execution.results = result.get("results", {})
            
            for task_id, task_result in execution.results.items():
                if "output" in task_result:
                    score = self.scoring_engine.evaluate_agent_output(
                        task_result["output"],
                        task_result.get("agent_type", "unknown")
                    )
                    execution.scores[task_id] = score
            
            execution.status = "completed"
            execution.completed_at = datetime.now()
            
            await self._trigger_hooks("post_execution", execution_id, execution)
            
        except Exception as e:
            execution.status = "failed"
            execution.errors.append(str(e))
            logger.error(f"Pipeline {execution_id} failed: {str(e)}")
        
        return execution
    
    async def execute_stage(
        self,
        execution_id: str,
        stage_config: Dict[str, Any]
    ) -> Dict[str, Any]:
        execution = self.active_executions.get(execution_id)
        if not execution:
            raise ValueError(f"Execution {execution_id} not found")
        
        agent_type = stage_config.get("agent_type")
        task_type = stage_config.get("task_type")
        input_data = stage_config.get("input", {})
        
        agent = self.coordinator.registry.get_agent(agent_type)
        if not agent:
            raise ValueError(f"Agent {agent_type} not found")
        
        from ..agents.base_agent import AgentTask
        task = AgentTask(
            task_id=str(uuid.uuid4()),
            task_type=task_type,
            input_data=input_data,
            context={"execution_id": execution_id},
            created_at=datetime.now()
        )
        
        result = await agent.process(task)
        
        execution.current_stage += 1
        
        await self._trigger_hooks("post_task", execution_id, {
            "stage": stage_config,
            "result": result
        })
        
        return {
            "task_id": task.task_id,
            "output": result.output_data,
            "confidence": result.confidence_score
        }
    
    def get_execution_status(self, execution_id: str) -> Optional[PipelineExecution]:
        return self.active_executions.get(execution_id)
    
    def get_execution_summary(self, execution_id: str) -> Dict[str, Any]:
        execution = self.active_executions.get(execution_id)
        if not execution:
            return {}
        
        avg_score = 0.0
        if execution.scores:
            avg_score = sum(s.total_score for s in execution.scores.values()) / len(execution.scores)
        
        return {
            "execution_id": execution.execution_id,
            "status": execution.status,
            "duration_seconds": (execution.completed_at - execution.started_at).total_seconds() if execution.completed_at else None,
            "tasks_completed": execution.current_stage,
            "average_score": avg_score,
            "error_count": len(execution.errors)
        }
    
    def register_hook(self, hook_type: str, hook_func: Callable):
        if hook_type in self.pipeline_hooks:
            self.pipeline_hooks[hook_type].append(hook_func)
            logger.info(f"Registered hook for {hook_type}")
    
    async def _trigger_hooks(self, hook_type: str, execution_id: str, data: Any):
        for hook in self.pipeline_hooks.get(hook_type, []):
            try:
                if asyncio.iscoroutinefunction(hook):
                    await hook(execution_id, data)
                else:
                    hook(execution_id, data)
            except Exception as e:
                logger.error(f"Hook {hook_type} failed: {str(e)}")
    
    async def retry_failed_stages(self, execution_id: str) -> bool:
        execution = self.active_executions.get(execution_id)
        if not execution or execution.status != "failed":
            return False
        
        retry_config = {
            "agent_type": "qa",
            "task_type": "analyze_coverage",
            "input": {"previous_results": execution.results}
        }
        
        try:
            result = await self.execute_stage(execution_id, retry_config)
            execution.status = "completed"
            execution.errors = []
            return True
        except Exception as e:
            logger.error(f"Retry failed: {str(e)}")
            return False'''
        pipeline_manager_file.write_text(content)
        print("Created execution_pipeline_manager.py")
        
    def create_structured_output_system(self):
        structured_output_file = self.orchestrator_dir / "structured_output.py"
        content = '''from typing import Dict, Any, List, Optional, Generic, TypeVar
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
import json
import logging
import asyncio

logger = logging.getLogger(__name__)

T = TypeVar('T')

class MessageType(Enum):
    TASK = "task"
    RESULT = "result"
    QUERY = "query"
    RESPONSE = "response"
    ERROR = "error"
    STATUS = "status"

class Priority(Enum):
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    CRITICAL = 4

@dataclass
class StructuredMessage:
    message_id: str
    message_type: MessageType
    source: str
    target: str
    payload: Dict[str, Any]
    priority: Priority = Priority.MEDIUM
    correlation_id: Optional[str] = None
    timestamp: datetime = field(default_factory=datetime.now)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_json(self) -> str:
        return json.dumps({
            "message_id": self.message_id,
            "message_type": self.message_type.value,
            "source": self.source,
            "target": self.target,
            "payload": self.payload,
            "priority": self.priority.value,
            "correlation_id": self.correlation_id,
            "timestamp": self.timestamp.isoformat(),
            "metadata": self.metadata
        })
    
    @classmethod
    def from_json(cls, json_str: str) -> "StructuredMessage":
        data = json.loads(json_str)
        return cls(
            message_id=data["message_id"],
            message_type=MessageType(data["message_type"]),
            source=data["source"],
            target=data["target"],
            payload=data["payload"],
            priority=Priority(data["priority"]),
            correlation_id=data.get("correlation_id"),
            timestamp=datetime.fromisoformat(data["timestamp"]),
            metadata=data.get("metadata", {})
        )

@dataclass
class TaskMessage(StructuredMessage):
    task_type: str = ""
    timeout_seconds: int = 30
    retry_count: int = 0
    
    def __post_init__(self):
        self.message_type = MessageType.TASK
        if "task_type" in self.payload:
            self.task_type = self.payload.get("task_type", "")
        if "timeout" in self.payload:
            self.timeout_seconds = self.payload.get("timeout", 30)

@dataclass
class ResultMessage(StructuredMessage):
    success: bool = True
    error_message: Optional[str] = None
    output_data: Dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        self.message_type = MessageType.RESULT
        if "success" in self.payload:
            self.success = self.payload.get("success", True)
        if "error" in self.payload:
            self.error_message = self.payload.get("error")
        if "output" in self.payload:
            self.output_data = self.payload.get("output", {})

class StructuredOutputValidator:
    def __init__(self):
        self.schemas = self._load_schemas()
    
    def _load_schemas(self) -> Dict[str, Dict[str, Any]]:
        return {
            "code_generation": {
                "required": ["code", "language", "file_path"],
                "optional": ["tests", "dependencies", "description"]
            },
            "architecture_design": {
                "required": ["components", "interactions", "data_flow"],
                "optional": ["deployment", "scaling", "security"]
            },
            "test_results": {
                "required": ["passed", "failed", "total"],
                "optional": ["coverage", "failures", "execution_time"]
            },
            "security_report": {
                "required": ["vulnerabilities", "score", "passed"],
                "optional": ["recommendations", "fixed_issues"]
            },
            "deployment_config": {
                "required": ["dockerfile", "port", "environment"],
                "optional": ["volumes", "networks", "depends_on"]
            }
        }
    
    def validate(self, output: Dict[str, Any], schema_type: str) -> tuple:
        if schema_type not in self.schemas:
            return True, []
        
        schema = self.schemas[schema_type]
        errors = []
        
        for required_field in schema.get("required", []):
            if required_field not in output:
                errors.append(f"Missing required field: {required_field}")
        
        for field in list(output.keys()):
            if field not in schema["required"] and field not in schema.get("optional", []):
                errors.append(f"Unexpected field: {field}")
        
        return len(errors) == 0, errors
    
    def create_structured_output(
        self,
        data: Dict[str, Any],
        schema_type: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        is_valid, errors = self.validate(data, schema_type)
        
        output = {
            "data": data,
            "schema_type": schema_type,
            "valid": is_valid,
            "timestamp": datetime.now().isoformat(),
            "version": "1.0"
        }
        
        if metadata:
            output["metadata"] = metadata
        
        if not is_valid:
            output["validation_errors"] = errors
        
        return output
    
    def extract_data(self, structured_output: Dict[str, Any]) -> Dict[str, Any]:
        return structured_output.get("data", {})
    
    def is_valid_output(self, structured_output: Dict[str, Any]) -> bool:
        return structured_output.get("valid", False)

class AgentCommunicationBus:
    def __init__(self):
        self.message_queue = asyncio.Queue()
        self.subscribers: Dict[str, List[callable]] = {}
        self.validator = StructuredOutputValidator()
        
    async def send_message(self, message: StructuredMessage):
        logger.debug(f"Sending message {message.message_id} from {message.source} to {message.target}")
        await self.message_queue.put(message)
        
        for subscriber in self.subscribers.get(message.target, []):
            try:
                await subscriber(message)
            except Exception as e:
                logger.error(f"Subscriber error: {str(e)}")
    
    async def receive_message(self, timeout: Optional[float] = None) -> Optional[StructuredMessage]:
        try:
            if timeout:
                message = await asyncio.wait_for(self.message_queue.get(), timeout=timeout)
            else:
                message = await self.message_queue.get()
            return message
        except asyncio.TimeoutError:
            return None
    
    def subscribe(self, agent_name: str, callback: callable):
        if agent_name not in self.subscribers:
            self.subscribers[agent_name] = []
        self.subscribers[agent_name].append(callback)
        logger.info(f"Subscribed {callback.__name__} to {agent_name}")
    
    def unsubscribe(self, agent_name: str, callback: callable):
        if agent_name in self.subscribers and callback in self.subscribers[agent_name]:
            self.subscribers[agent_name].remove(callback)
    
    async def broadcast(self, message: StructuredMessage):
        for subscribers in self.subscribers.values():
            for subscriber in subscribers:
                try:
                    await subscriber(message)
                except Exception as e:
                    logger.error(f"Broadcast error: {str(e)}")
    
    def create_task_message(
        self,
        source: str,
        target: str,
        task_type: str,
        input_data: Dict[str, Any],
        priority: Priority = Priority.MEDIUM
    ) -> TaskMessage:
        return TaskMessage(
            message_id=str(datetime.now().timestamp()),
            message_type=MessageType.TASK,
            source=source,
            target=target,
            payload={"task_type": task_type, "input": input_data},
            priority=priority,
            correlation_id=None
        )
    
    def create_result_message(
        self,
        source: str,
        target: str,
        output_data: Dict[str, Any],
        success: bool = True,
        error: Optional[str] = None
    ) -> ResultMessage:
        return ResultMessage(
            message_id=str(datetime.now().timestamp()),
            message_type=MessageType.RESULT,
            source=source,
            target=target,
            payload={"output": output_data, "success": success, "error": error},
            priority=Priority.MEDIUM,
            correlation_id=None
        )'''
        structured_output_file.write_text(content)
        print("Created structured_output.py")
        
    def create_orchestrator_tests(self):
        test_file = self.tests_dir / "unit" / "test_orchestrator.py"
        content = '''import pytest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from factory.orchestrator.agent_coordinator import AgentCoordinator
from factory.orchestrator.task_planner import TaskPlanner
from factory.orchestrator.scoring_engine import ScoringEngine
from factory.registry.agent_registry import AgentRegistry

@pytest.mark.asyncio
async def test_agent_coordinator():
    coordinator = AgentCoordinator()
    result = await coordinator.orchestrate("generate_application", {"feature": "user_auth"})
    assert result["status"] == "completed"
    assert "results" in result

def test_task_planner():
    planner = TaskPlanner()
    plan = planner.create_plan("generate_saas application", {})
    assert plan.goal == "generate_saas application"
    assert len(plan.tasks) > 0
    assert plan.plan_id is not None

def test_scoring_engine_code():
    engine = ScoringEngine()
    test_code = "def hello():\\n    print('world')\\n"
    result = engine.evaluate_code(test_code)
    assert result.total_score >= 0
    assert result.max_possible == 100
    assert result.passed is not None

def test_scoring_engine_agent_output():
    engine = ScoringEngine()
    output = {"code": "print('test')", "success": True}
    result = engine.evaluate_agent_output(output, "backend")
    assert result.total_score >= 0
    assert len(result.breakdown) > 0

def test_execution_pipeline_manager():
    from factory.orchestrator.execution_pipeline_manager import ExecutionPipelineManager
    manager = ExecutionPipelineManager()
    assert manager.pipeline_hooks is not None

def test_structured_output_validator():
    from factory.orchestrator.structured_output import StructuredOutputValidator
    validator = StructuredOutputValidator()
    output = {"code": "test.py", "language": "python", "file_path": "/app/test.py"}
    is_valid, errors = validator.validate(output, "code_generation")
    assert is_valid is True'''
        test_file.write_text(content)
        print("Created orchestrator tests")
        
    def run_setup(self):
        print("\nStarting Batch 3 - Multi-Agent Orchestration System")
        print("=" * 60)
        
        self.create_agent_coordinator()
        self.create_task_planner()
        self.create_agent_debate()
        self.create_scoring_engine()
        self.create_execution_pipeline_manager()
        self.create_structured_output_system()
        self.create_orchestrator_tests()
        
        print("\n" + "=" * 60)
        print("Batch 3 Complete - Multi-Agent Orchestration System Generated")
        print("\nComponents added:")
        print("  Agent Coordinator - Orchestrates multi-agent workflows")
        print("  Task Planner - Breaks down goals into executable tasks")
        print("  Agent Debate System - Enables consensus building between agents")
        print("  Scoring Engine - Evaluates agent outputs")
        print("  Execution Pipeline Manager - Manages complete execution pipelines")
        print("  Structured Output System - Ensures structured agent communication")
        print("\nNext steps:")
        print("1. Run Batch 4 to add self-improving system")

def main():
    generator = Batch3Generator()
    generator.run_setup()

if __name__ == "__main__":
    main()