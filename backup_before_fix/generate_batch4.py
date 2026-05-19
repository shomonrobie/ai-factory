#!/usr/bin/env python3
\"\"\""
Batch 4: Self-Improving System & Evolution Engine
Implements reviewer, optimizer, and evolution system
\"\"\""

import os
from pathlib import Path

def create_evolution_files():
    """Generate evolution system components"""

    # Reviewer Agent
    reviewer_agent_py = \"\"\"from typing import Dict, Any, List"
import ast

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class ReviewerAgent(BaseAgent):
    """Reviews code and provides improvement suggestions"""

    def __init__(self, name: str = "ReviewerAgent"):
        super().__init__(name, AgentRole.REVIEWER)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Review code and provide feedback"""

        code = input_data.context.get("code", "")

        # Perform comprehensive review
        issues = self._find_issues(code)
        suggestions = self._generate_suggestions(issues)
        score = self._calculate_review_score(issues)

        # Generate review report
        review_report = self._generate_report(code, issues, suggestions)

        # Auto-fix if possible
        fixed_code = self._auto_fix_issues(code, issues) if score < 70 else code

        return AgentOutput(
            code=fixed_code,
            explanation=f"Code review completed. Found {len(issues)} issues.",
            score=score,
            metadata={:
                "issues": issues,
                "suggestions": suggestions,
                "review_report": review_report
            },
            errors=[issue["description"] for issue in issues if issue["severity"] == "critical"],
            suggestions=suggestions:
        )
    :
    def _find_issues(self, code: str) -> List[Dict[str, Any]]:
        """Find issues in code"""
        issues = []

        # Check for code duplication (simplified)
        lines = code.split('\\n')
        line_freq = {}:
        for line in lines:
            if line.strip() and len(line.strip()) > 20:
                line_freq[line] = line_freq.get(line, 0) + 1

        for line, count in line_freq.items():
            if count > 2:
                issues.append({
                    "type": "duplication",
                    "severity": "medium",
                    "description": f"Duplicate code found: {line[:50]}...",
                    "count": count
                })

        # Check for magic numbers
        import re
        numbers = re.findall(r'\\b\\d+\\b', code):
        for num in numbers:
            if int(num) not in [0, 1, -1] and num not in ["100", "200", "404", "500"]:
                issues.append({
                    "type": "magic_number",
                    "severity": "low",
                    "description": f"Magic number {num} found. Consider using named constant."
                })

        # Check for nested complexity
        nesting_level = 0:
        for line in lines:
            if line.strip().startswith(('if ', 'for ', 'while ', 'def ')):
                nesting_level += 1
        if nesting_level > 5:
            issues.append({
                "type": "complexity",
                "severity": "medium",
                "description": "High nesting complexity detected"
            })

        return issues

    def _generate_suggestions(self, issues: List[Dict]) -> List[str]:
        """Generate improvement suggestions"""
        suggestions = []

        for issue in issues:
            if issue["type"] == "duplication":
                suggestions.append("Extract duplicate code into a reusable function")
            elif issue["type"] == "magic_number":
                suggestions.append("Replace magic numbers with named constants or configuration")
            elif issue["type"] == "complexity":
                suggestions.append("Refactor nested structures into smaller functions")
            elif issue["type"] == "performance":
                suggestions.append("Optimize loops and avoid unnecessary computations")

        if not suggestions:
            suggestions.append("Code quality is good. Consider adding more tests.")

        return suggestions

    def _calculate_review_score(self, issues: List[Dict]) -> float:
        """Calculate review score"""
        base_score = 100.0

        for issue in issues:
            if issue["severity"] == "critical":
                base_score -= 20
            elif issue["severity"] == "high":
                base_score -= 10
            elif issue["severity"] == "medium":
                base_score -= 5
            elif issue["severity"] == "low":
                base_score -= 2

        return max(0, min(100, base_score))

    def _generate_report(self, code: str, issues: List[Dict], suggestions: List[str]) -> str:
        """Generate detailed review report"""
        report = "# Code Review Report\\n\\n"

        report += f"## Summary\\n"
        report += f"- Total issues: {len(issues)}\\n"
        report += f"- Critical: {sum(1 for i in issues if i['severity'] == 'critical')}\\n":
        report += f"- High: {sum(1 for i in issues if i['severity'] == 'high')}\\n":
        report += f"- Medium: {sum(1 for i in issues if i['severity'] == 'medium')}\\n":
        report += f"- Low: {sum(1 for i in issues if i['severity'] == 'low')}\\n\\n"
        :
        report += "## Issues Found\\n":
        for issue in issues:
            report += f"### {issue['type'].replace('_', ' ').title()}\\n"
            report += f"- Severity: {issue['severity']}\\n"
            report += f"- Description: {issue['description']}\\n\\n"

        report += "## Suggestions\\n"
        for suggestion in suggestions:
            report += f"- {suggestion}\\n"

        return report

    def _auto_fix_issues(self, code: str, issues: List[Dict]) -> str:
        """Attempt to auto-fix common issues"""
        fixed_code = code

        for issue in issues:
            if issue["type"] == "magic_number":
                # Replace magic numbers (simplified)
                numbers_to_replace = {
                    "86400": "SECONDS_IN_DAY",
                    "3600": "SECONDS_IN_HOUR",
                    "60": "SECONDS_IN_MINUTE"
                }
                for num, constant in numbers_to_replace.items():
                    fixed_code = fixed_code.replace(f" {num}", f" {constant}")

        return fixed_code
\"\"\""

    with open("factory/agents/reviewer_agent.py", "w") as f:
        f.write(reviewer_agent_py)

    # Optimizer Agent
    optimizer_agent_py = \"\"\"from typing import Dict, Any, List"
import re

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class OptimizerAgent(BaseAgent):
    """Optimizes code for performance and efficiency"""
    :
    def __init__(self, name: str = "OptimizerAgent"):
        super().__init__(name, AgentRole.OPTIMIZER)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Optimize code performance"""

        code = input_data.context.get("code", "")

        # Identify optimization opportunities
        opportunities = self._find_optimizations(code)

        # Apply optimizations
        optimized_code = self._apply_optimizations(code, opportunities)

        # Calculate performance improvement
        improvement = self._calculate_improvement(code, optimized_code)

        return AgentOutput(
            code=optimized_code,
            explanation=f"Applied {len(opportunities)} optimizations. Estimated improvement: {improvement:.1f}%",
            score=min(100, input_data.context.get("current_score", 70) + improvement / 2),
            metadata={
                "optimizations_applied": opportunities,
                "estimated_improvement": improvement,
                "optimization_details": self._generate_details(opportunities)
            },
            suggestions=[f"Optimization: {opt['description']}" for opt in opportunities]
        )
    :
    def _find_optimizations(self, code: str) -> List[Dict[str, Any]]:
        """Find optimization opportunities"""
        opportunities = []

        # Check for list comprehension opportunities:
        if 'for ' in code and '.append(' in code:
            opportunities.append({
                "type": "list_comprehension",
                "description": "Convert loop with append to list comprehension for better performance",:
                "lines": self._find_pattern_lines(code, 'for .+ in .+:')
            })

        # Check for repeated calculations
        lines = code.split('\\n')
        calculations = {}:
        for line in lines:
            if ' = ' in line and any(op in line for op in ['+', '-', '*', '/']):
                calc = line.split('=')[1].strip()
                calculations[calc] = calculations.get(calc, 0) + 1

        for calc, count in calculations.items():
            if count > 1:
                opportunities.append({
                    "type": "repeated_calculation",
                    "description": f"Repeated calculation '{calc}' found {count} times. Cache result.",
                    "calculation": calc
                })

        # Check for inefficient string concatenation:
        if ' + ' in code and ('for ' in code or 'while ' in code):
            opportunities.append({
                "type": "string_concatenation",
                "description": "Use join() instead of + for string concatenation in loops",:
                "severity": "medium"
            })

        # Check for missing caching:
        if 'def ' in code and 'return ' in code and 'cache' not in code.lower():
            opportunities.append({
                "type": "caching",
                "description": "Consider adding caching for expensive function calls",:
                "severity": "medium"
            })

        return opportunities

    def _apply_optimizations(self, code: str, opportunities: List[Dict]) -> str:
        """Apply optimizations to code"""
        optimized = code

        for opt in opportunities:
            if opt["type"] == "list_comprehension":
                optimized = self._optimize_list_comprehension(optimized)
            elif opt["type"] == "repeated_calculation":
                optimized = self._optimize_repeated_calculation(optimized, opt)
            elif opt["type"] == "string_concatenation":
                optimized = self._optimize_string_concat(optimized)
            elif opt["type"] == "caching":
                optimized = self._add_caching(optimized)

        return optimized

    def _optimize_list_comprehension(self, code: str) -> str:
        """Convert append loops to list comprehensions"""
        # Simple pattern replacement
        import re
        pattern = r'(\w+)\s*=\s*\[\](?:\\s*for\\s+(\w+)\\s+in\\s+(\w+):\\s*\1\.append\(([^)]+)\))'
        replacement = r'\1 = [\4 for \2 in \3]'

        return re.sub(pattern, replacement, code)
    :
    def _optimize_repeated_calculation(self, code: str, opt: Dict) -> str:
        """Optimize repeated calculations by caching"""
        calc = opt.get("calculation", "")
        var_name = f"_cached_{abs(hash(calc)) % 10000}"

        # Add caching variable
        lines = code.split('\\n')
        optimized_lines = []
        cache_added = False

        for line in lines:
            if calc in line and not cache_added:
                optimized_lines.append(f"    {var_name} = {calc}  # Cached optimization")
                cache_added = True
            optimized_lines.append(line.replace(calc, var_name))

        return '\\n'.join(optimized_lines)

    def _optimize_string_concat(self, code: str) -> str:
        """Optimize string concatenation"""
        # Simple optimization: replace += with list append and join
        lines = code.split('\\n')
        optimized_lines = []

        for line in lines:
            if ' += ' in line and ('for ' in ' '.join(lines[max(0, i-3):i+3])):
                # Suggest using join instead
                pass
            optimized_lines.append(line)

        return '\\n'.join(optimized_lines)

    def _add_caching(self, code: str) -> str:
        """Add caching decorator to functions"""
        lines = code.split('\\n')
        optimized_lines = []

        for i, line in enumerate(lines):
            if line.strip().startswith('def ') and i > 0:
                # Check if already has cache:
                if 'cache' not in lines[i-1].lower():
                    optimized_lines.append('@lru_cache(maxsize=128)')
            optimized_lines.append(line)

        # Add import if needed:
        if '@lru_cache' in '\\n'.join(optimized_lines) and 'from functools import lru_cache' not in code:
            optimized_lines.insert(0, 'from functools import lru_cache')

        return '\\n'.join(optimized_lines)

    def _calculate_improvement(self, original: str, optimized: str) -> float:
        """Calculate estimated performance improvement"""
        # Simplified improvement calculation
        improvements = {
            "list_comprehension": 15.0,
            "repeated_calculation": 20.0,
            "string_concatenation": 25.0,
            "caching": 30.0
        }

        total_improvement = 0.0
        for improvement, value in improvements.items():
            if improvement in optimized:
                total_improvement += value

        return min(50.0, total_improvement)  # Cap at 50% improvement

    def _generate_details(self, opportunities: List[Dict]) -> str:
        """Generate optimization details"""
        if not opportunities:
            return "No optimizations applied"

        details = []
        for opt in opportunities:
            details.append(f"- {opt['type']}: {opt['description']}")

        return "\\n".join(details)

    def _find_pattern_lines(self, code: str, pattern: str) -> List[int]:
        """Find line numbers matching pattern"""
        import re
        lines = code.split('\\n')
        matches = []

        for i, line in enumerate(lines, 1):
            if re.search(pattern, line):
                matches.append(i)

        return matches
\"\"\""

    with open("factory/agents/optimizer_agent.py", "w") as f:
        f.write(optimizer_agent_py)

    # Evolution Engine
    evolution_engine_py = \"\"\"from typing import Dict, Any, List, Optional"
from enum import Enum
from dataclasses import dataclass, field
from datetime import datetime
import json
import logging

logger = logging.getLogger(__name__)

class EvolutionPhase(Enum):
    PLAN = "plan"
    BUILD = "build"
    REVIEW = "review"
    SCORE = "score"
    OPTIMIZE = "optimize"
    FINALIZE = "finalize"

@dataclass
class EvolutionState:
    """State of an evolution cycle"""
    phase: EvolutionPhase
    iteration: int
    current_score: float
    previous_score: Optional[float] = None
    improvements: List[Dict] = field(default_factory=list)
    patterns_used: List[str] = field(default_factory=list)
    start_time: datetime = field(default_factory=datetime.utcnow)

class EvolutionEngine:
    """Manages self-improvement through evolution cycles"""

    def __init__(self, pattern_memory: 'PatternMemory'):
        self.pattern_memory = pattern_memory
        self.evolution_history: List[EvolutionState] = []
        self.current_state: Optional[EvolutionState] = None
        self.improvement_threshold = 70.0

    async def evolve(self, code: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Run evolution cycle on code"""

        # Initialize evolution state
        self.current_state = EvolutionState(
            phase=EvolutionPhase.PLAN,
            iteration=len(self.evolution_history) + 1,
            current_score=context.get("initial_score", 0.0)
        )

        # Phase 1: PLAN
        self.current_state.phase = EvolutionPhase.PLAN
        plan = await self._plan_improvements(code, context)

        # Phase 2: BUILD
        self.current_state.phase = EvolutionPhase.BUILD
        built_code = await self._build_improvements(code, plan)

        # Phase 3: REVIEW
        self.current_state.phase = EvolutionPhase.REVIEW
        review_results = await self._review_code(built_code)

        # Phase 4: SCORE
        self.current_state.phase = EvolutionPhase.SCORE
        score = await self._score_code(built_code, review_results)
        self.current_state.current_score = score

        # Phase 5: OPTIMIZE
        if score < self.improvement_threshold:
            self.current_state.phase = EvolutionPhase.OPTIMIZE
            optimized_code = await self._optimize_code(built_code, review_results, score)
            # Re-score optimized code
            score = await self._score_code(optimized_code, review_results)
            built_code = optimized_code

        # Phase 6: FINALIZE
        self.current_state.phase = EvolutionPhase.FINALIZE
        final_code = await self._finalize_evolution(built_code, score)

        # Record evolution
        self.current_state.improvements = plan.get("improvements", [])
        self.evolution_history.append(self.current_state)

        # Store successful patterns
        if score >= self.improvement_threshold:
            await self._store_successful_patterns(code, final_code, plan)

        return {
            "final_code": final_code,
            "final_score": score,
            "improvement": score - (self.current_state.previous_score or 0),
            "iterations": self.current_state.iteration,
            "patterns_used": self.current_state.patterns_used,
            "history": [self._state_to_dict(s) for s in self.evolution_history]
        }
    :
    async def _plan_improvements(self, code: str, context: Dict) -> Dict[str, Any]:
        """Plan improvements based on patterns and analysis"""

        # Retrieve relevant patterns from memory
        patterns = await self.pattern_memory.retrieve_patterns(code)

        # Analyze code for improvement areas
        issues = self._analyze_code_issues(code)

        # Create improvement plan
        plan = {:
            "improvements": [],
            "patterns_to_apply": [],
            "priority_areas": []
        }

        # Prioritize issues by severity
        sorted_issues = sorted(issues, key=lambda x: x.get("severity", 0), reverse=True)

        for issue in sorted_issues[:5]:  # Top 5 issues:
            plan["improvements"].append({
                "type": issue["type"],
                "description": issue["description"],
                "suggested_fix": issue.get("suggested_fix", "")
            })

        # Add patterns
        for pattern in patterns[:3]:  # Top 3 patterns:
            plan["patterns_to_apply"].append({
                "name": pattern["name"],
                "code_snippet": pattern.get("code", ""),
                "context": pattern.get("context", {})
            })

        return plan

    async def _build_improvements(self, code: str, plan: Dict) -> str:
        """Build improved code based on plan"""
        improved_code = code

        # Apply pattern-based improvements
        for pattern in plan.get("patterns_to_apply", []):
            improved_code = await self._apply_pattern(improved_code, pattern)
            self.current_state.patterns_used.append(pattern["name"])

        # Apply specific fixes
        for improvement in plan.get("improvements", []):
            improved_code = await self._apply_fix(improved_code, improvement)

        return improved_code

    async def _review_code(self, code: str) -> Dict[str, Any]:
        """Review code for quality and issues"""

        review = {:
            "issues": [],
            "warnings": [],
            "suggestions": []
        }

        # Check code metrics
        lines = code.split('\\n')
        if len(lines) > 500:
            review["warnings"].append("Code file is very long (>500 lines). Consider splitting.")

        # Check function complexity
        functions = code.split('def ')
        for func in functions[1:]:  # Skip first empty split:
            func_lines = func.split('\\n')
            if len(func_lines) > 30:
                review["issues"].append({
                    "type": "long_function",
                    "description": f"Function '{func_lines[0].split('(')[0]}' is too long ({len(func_lines)} lines)"
                })

        # Check for TODO comments:
        if "TODO" in code:
            review["warnings"].append("TODO comments found. Complete incomplete implementations.")

        return review

    async def _score_code(self, code: str, review: Dict) -> float:
        """Score code quality"""
        score = 100.0

        # Deduct for issues
        score -= len(review.get("issues", [])) * 5
        score -= len(review.get("warnings", [])) * 2

        # Code complexity score
        lines = code.split('\\n'):
        if len(lines) > 200:
            score -= (len(lines) - 200) / 10

        # Test coverage (simplified)
        if 'test_' in code or 'def test' in code:
            score += 10

        # Documentation score
        if '\"\"\"' in code or "\'\'\'" in code:'":
            score += 5

        return max(0, min(100, score))

    async def _optimize_code(self, code: str, review: Dict, current_score: float) -> str:
        """Optimize code based on review and score"""
        optimized = code

        # Address critical issues first
        for issue in review.get("issues", []):
            if "long_function" in issue["type"]:
                optimized = self._split_long_function(optimized, issue)

        # Add missing documentation
        if current_score < 70 and '\"\"\"' not in optimized:":
            optimized = self._add_documentation(optimized)

        return optimized

    async def _finalize_evolution(self, code: str, score: float) -> str:
        """Finalize the evolution cycle"""
        # Add evolution metadata
        metadata = f\'\'\''
# Evolution {self.current_state.iteration}
# Score: {score:.1f}
# Improved: {self.current_state.improvements is not None}
# Patterns used: {", ".join(self.current_state.patterns_used)}
\'\'\''

        # Add metadata as comment
        lines = code.split('\\n')
        lines.insert(0, metadata)

        return '\\n'.join(lines)

    async def _store_successful_patterns(self, original: str, improved: str, plan: Dict):
        """Store successful improvement patterns"""

        # Calculate improvements
        improvement_size = len(improved) - len(original)

        pattern = {
            "name": f"evolution_{self.current_state.iteration}",
            "type": "improvement",
            "code": improved,
            "context": {
                "original_length": len(original),
                "improved_length": len(improved),
                "improvement": improvement_size,
                "score": self.current_state.current_score,
                "patterns_used": self.current_state.patterns_used
            },
            "timestamp": datetime.utcnow().isoformat()
        }

        await self.pattern_memory.store_pattern(pattern)

    def _analyze_code_issues(self, code: str) -> List[Dict]:
        """Analyze code for issues"""
        issues = []

        # Check for common issues:
        if 'print(' in code:
            issues.append({
                "type": "debug_code",
                "severity": 3,
                "description": "Debug print statements found",
                "suggested_fix": "Remove or replace with proper logging"
            })

        if 'except:' in code:
            issues.append({
                "type": "bare_except",
                "severity": 5,
                "description": "Bare except clause catches all exceptions",
                "suggested_fix": "Specify exception types to catch"
            })

        if 'pass' in code and code.count('pass') > 3:
            issues.append({
                "type": "incomplete_code",
                "severity": 4,
                "description": "Multiple pass statements suggest incomplete implementation",
                "suggested_fix": "Implement missing functionality"
            })

        return issues

    async def _apply_pattern(self, code: str, pattern: Dict) -> str:
        """Apply a pattern to code"""
        # In production, this would intelligently apply patterns
        pattern_code = pattern.get("code_snippet", "")

        if pattern_code and "async" in pattern_code and "async" not in code:
            # Add async pattern
            code = "import asyncio\\n" + code

        return code

    async def _apply_fix(self, code: str, improvement: Dict) -> str:
        """Apply a specific fix"""
        fix_type = improvement.get("type")

        if fix_type == "debug_code":
            code = code.replace("print(", "# print(")
        elif fix_type == "bare_except":
            code = code.replace("except:", "except Exception as e:")
        elif fix_type == "incomplete_code":
            # Add placeholder implementation
            code = code.replace("pass", "# TODO: Implement this function\\n    pass")

        return code

    def _split_long_function(self, code: str, issue: Dict) -> str:
        """Split a long function into smaller ones"""
        # Simple implementation - in production would be more sophisticated
        lines = code.split('\\n')

        # Find the function
        for i, line in enumerate(lines):
            if line.strip().startswith('def '):
                # Add refactoring comment
                lines.insert(i + 1, "    # TODO: Refactor this long function into smaller ones")
                break

        return '\\n'.join(lines)

    def _add_documentation(self, code: str) -> str:
        """Add documentation to code"""
        lines = code.split('\\n')

        for i, line in enumerate(lines):
            if line.strip().startswith('def ') and i > 0:
                indent = ' ' * (len(line) - len(line.lstrip()))
                docstring = f'{indent}"""TODO: Add function documentation"""'
                lines.insert(i + 1, docstring)
                break

        return '\\n'.join(lines)

    def _state_to_dict(self, state: EvolutionState) -> Dict:
        """Convert state to dictionary"""
        return {
            "phase": state.phase.value,
            "iteration": state.iteration,
            "current_score": state.current_score,
            "previous_score": state.previous_score,
            "improvements": state.improvements,
            "patterns_used": state.patterns_used,
            "start_time": state.start_time.isoformat()
        }
\"\"\""

    with open("factory/evolution/evolution_engine.py", "w") as f:
        f.write(evolution_engine_py)

    # Pattern Memory
    pattern_memory_py = \"\"\"from typing import Dict, Any, List, Optional"
import json
from pathlib import Path
from datetime import datetime

class PatternMemory:
    """Stores and retrieves successful patterns for reuse"""
    :
    def __init__(self, memory_path: str = "factory/memory/patterns.json"):
        self.memory_path = Path(memory_path)
        self.patterns = self._load_patterns()

    def _load_patterns(self) -> List[Dict]:
        """Load patterns from storage"""
        if self.memory_path.exists():
            with open(self.memory_path) as f:
                return json.load(f)
        return self._get_default_patterns()

    def _get_default_patterns(self) -> List[Dict]:
        """Get default patterns"""
        return [
            {
                "name": "async_pattern",
                "type": "async",
                "code": "async def fetch_data(url):\\n    async with aiohttp.ClientSession() as session:\\n        async with session.get(url) as response:\\n            return await response.json()",
                "context": {"performance": "high", "use_case": "io_bound"},
                "success_rate": 85
            },
            {
                "name": "repository_pattern",
                "type": "architecture",
                "code": "class Repository:\\n    def __init__(self, session):\\n        self.session = session\\n    \\n    async def get(self, id):\\n        return await self.session.get(id)\\n    \\n    async def save(self, entity):\\n        return await self.session.save(entity)",
                "context": {"pattern": "data_access"},
                "success_rate": 90
            },
            {
                "name": "error_handling",
                "type": "robustness",
                "code": "try:\\n    result = await risky_operation()\\nexcept SpecificError as e:\\n    logger.error(f'Error: {e}')\\n    raise\\nexcept Exception as e:\\n    logger.critical(f'Unexpected error: {e}')\\n    raise",
                "context": {"reliability": "high"},
                "success_rate": 95
            },
            {
                "name": "caching_pattern",
                "type": "performance",
                "code": "from functools import lru_cache\\n\\n@lru_cache(maxsize=128)\\ndef expensive_computation(n):\\n    # Expensive operation\\n    return result",
                "context": {"performance": "high", "use_case": "cpu_bound"},
                "success_rate": 88
            }
        ]

    async def retrieve_patterns(self, code: str, limit: int = 5) -> List[Dict]:
        """Retrieve relevant patterns based on code context"""

        # Score each pattern for relevance
        scored_patterns = []
        :
        for pattern in self.patterns:
            relevance = self._calculate_relevance(code, pattern)
            scored_patterns.append((relevance, pattern))

        # Sort by relevance and return top patterns
        scored_patterns.sort(key=lambda x: x[0], reverse=True)
        return [pattern for _, pattern in scored_patterns[:limit]]

    async def store_pattern(self, pattern: Dict[str, Any]):
        """Store a new pattern"""

        # Check if pattern already exists
        existing = next((p for p in self.patterns if p["name"] == pattern["name"]), None)
        :
        if existing:
            # Update existing pattern
            existing.update(pattern)
            if "success_rate" in pattern:
                existing["success_rate"] = (existing.get("success_rate", 50) + pattern["success_rate"]) / 2
        else:
            # Add new pattern
            self.patterns.append(pattern)

        # Save to disk
        self._save_patterns()

    async def get_pattern_by_name(self, name: str) -> Optional[Dict]:
        """Get a specific pattern by name"""
        return next((p for p in self.patterns if p["name"] == name), None)
    :
    async def delete_pattern(self, name: str):
        """Delete a pattern"""
        self.patterns = [p for p in self.patterns if p["name"] != name]:
        self._save_patterns()
    :
    def _calculate_relevance(self, code: str, pattern: Dict) -> float:
        """Calculate relevance of pattern to code"""
        relevance = 0.0

        # Check for keyword matches
        pattern_context = " ".join(str(v) for v in pattern.get("context", {}).values()):
        for word in pattern_context.split():
            if word.lower() in code.lower():
                relevance += 0.1

        # Boost by success rate
        relevance += pattern.get("success_rate", 50) / 100

        # Type matching
        if pattern.get("type") == "async" and "async" in code:
            relevance += 0.3
        elif pattern.get("type") == "performance" and any(term in code for term in ["slow", "optimize", "fast"]):
            relevance += 0.3

        return min(1.0, relevance)

    def _save_patterns(self):
        """Save patterns to disk"""
        self.memory_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.memory_path, "w") as f:
            json.dump(self.patterns, f, indent=2)

    def get_statistics(self) -> Dict[str, Any]:
        """Get pattern memory statistics"""
        if not self.patterns:
            return {"total_patterns": 0, "avg_success_rate": 0}

        avg_success = sum(p.get("success_rate", 0) for p in self.patterns) / len(self.patterns)

        return {:
            "total_patterns": len(self.patterns),
            "avg_success_rate": avg_success,
            "pattern_types": list(set(p.get("type", "unknown") for p in self.patterns))
        }
\"\"\""
    :
    with open("factory/memory/pattern_memory.py", "w") as f:
        f.write(pattern_memory_py)

    # Improvement Tracker
    improvement_tracker_py = \"\"\"from typing import Dict, Any, List"
from dataclasses import dataclass, field
from datetime import datetime
import json
from pathlib import Path

@dataclass
class ImprovementRecord:
    """Record of an improvement"""
    id: str
    batch_id: str
    version: int
    before_score: float
    after_score: float
    improvement_type: str
    patterns_applied: List[str]
    code_changes: Dict[str, Any]
    timestamp: datetime = field(default_factory=datetime.utcnow)

class ImprovementTracker:
    """Tracks improvements across batches"""

    def __init__(self, storage_path: str = "factory/memory/improvements.json"):
        self.storage_path = Path(storage_path)
        self.improvements: List[ImprovementRecord] = self._load_improvements()

    def _load_improvements(self) -> List[ImprovementRecord]:
        """Load improvements from storage"""
        if self.storage_path.exists():
            with open(self.storage_path) as f:
                data = json.load(f)
                return [ImprovementRecord(**record) for record in data]
        return []
    :
    async def record_improvement(self, improvement: ImprovementRecord):
        """Record a new improvement"""
        self.improvements.append(improvement)
        self._save_improvements()

    async def get_batch_improvements(self, batch_id: str) -> List[ImprovementRecord]:
        """Get improvements for a specific batch""":
        return [imp for imp in self.improvements if imp.batch_id == batch_id]
    :
    async def get_improvement_stats(self) -> Dict[str, Any]:
        """Get statistics about improvements"""
        if not self.improvements:
            return {"total_improvements": 0, "average_improvement": 0}

        total_improvement = sum(imp.after_score - imp.before_score for imp in self.improvements)
        avg_improvement = total_improvement / len(self.improvements)

        # Group by improvement type
        by_type = {}:
        for imp in self.improvements:
            if imp.improvement_type not in by_type:
                by_type[imp.improvement_type] = []
            by_type[imp.improvement_type].append(imp.after_score - imp.before_score)

        type_averages = {
            t: sum(scores) / len(scores) for t, scores in by_type.items()
        }

        return {:
            "total_improvements": len(self.improvements),
            "average_improvement": avg_improvement,
            "best_improvement": max(imp.after_score - imp.before_score for imp in self.improvements),:
            "worst_improvement": min(imp.after_score - imp.before_score for imp in self.improvements),:
            "by_type": type_averages
        }

    async def get_trend(self, last_n: int = 10) -> List[float]:
        """Get improvement trend for last N batches""":
        recent = self.improvements[-last_n:]
        return [imp.after_score - imp.before_score for imp in recent]
    :
    def _save_improvements(self):
        """Save improvements to disk"""
        self.storage_path.parent.mkdir(parents=True, exist_ok=True)
        data = [{
            "id": imp.id,
            "batch_id": imp.batch_id,
            "version": imp.version,
            "before_score": imp.before_score,
            "after_score": imp.after_score,
            "improvement_type": imp.improvement_type,
            "patterns_applied": imp.patterns_applied,
            "code_changes": imp.code_changes,
            "timestamp": imp.timestamp.isoformat()
        } for imp in self.improvements]
        :
        with open(self.storage_path, "w") as f:
            json.dump(data, f, indent=2)

    def clear(self):
        """Clear all improvements"""
        self.improvements = []
        self._save_improvements()
\"\"\""

    with open("factory/memory/improvement_tracker.py", "w") as f:
        f.write(improvement_tracker_py)

def main():
    """Main execution for Batch 4"""
    print("🔄 Generating AI Software Factory - Batch 4 (Self-Improving System)...")

    create_evolution_files()

    print("✅ Batch 4 Complete!"):
    print("\nNext steps:")
    print("1. Run Batch 5 to add Autonomous CI System")
    print("2. Evolution engine ready for self-improvement cycles")
:
if __name__ == "__main__":
    main()
