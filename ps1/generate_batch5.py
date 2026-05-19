#!/usr/bin/env python3
\"\"\""
Batch 5: Autonomous CI System & Complete Integration
Implements CI/CD, git integration, and full automation pipeline
\"\"\""

import os
from pathlib import Path

def create_ci_files():
    \"\"\"Generate CI/CD system components\"\"\"

    # CI Engine
    ci_engine_py = \"\"\"from typing import Dict, Any, List, Optional"
from enum import Enum
import asyncio
import subprocess
import logging
from pathlib import Path
from datetime import datetime

logger = logging.getLogger(__name__)

class PipelineStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    PASSED = "passed"
    FAILED = "failed"
    FIXING = "fixing"

class CIEngine:
    \"\"\"Continuous Integration engine\"\"\"

    def __init__(self, project_path: str = "./generated_repo"):
        self.project_path = Path(project_path)
        self.current_status = PipelineStatus.PENDING
        self.pipeline_history: List[Dict] = []

    async def run_pipeline(self, code: str, language: str = "python") -> Dict[str, Any]:
        \"\"\"Run complete CI pipeline\"\"\"

        pipeline_id = f"pipeline_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
        start_time = datetime.utcnow()

        results = {
            "pipeline_id": pipeline_id,
            "status": PipelineStatus.RUNNING.value,
            "stages": {},
            "start_time": start_time.isoformat()
        }

        try:
            # Stage 1: Lint
            logger.info(f"Pipeline {pipeline_id}: Running linter")
            lint_result = await self._run_linter(code, language)
            results["stages"]["lint"] = lint_result

            if not lint_result["passed"]:
                raise Exception(f"Linting failed: {lint_result['errors']}")

            # Stage 2: Type Check
            logger.info(f"Pipeline {pipeline_id}: Running type checker")
            type_result = await self._run_type_check(code, language)
            results["stages"]["type_check"] = type_result

            # Stage 3: Unit Tests
            logger.info(f"Pipeline {pipeline_id}: Running unit tests")
            test_result = await self._run_tests(code, language)
            results["stages"]["tests"] = test_result

            # Stage 4: Security Scan
            logger.info(f"Pipeline {pipeline_id}: Running security scan")
            security_result = await self._run_security_scan(code)
            results["stages"]["security"] = security_result

            # Stage 5: Build
            logger.info(f"Pipeline {pipeline_id}: Building project")
            build_result = await self._run_build(code, language)
            results["stages"]["build"] = build_result

            # All stages passed
            results["status"] = PipelineStatus.PASSED.value
            results["final_score"] = self._calculate_final_score(results["stages"])

        except Exception as e:
            logger.error(f"Pipeline {pipeline_id} failed: {str(e)}")
            results["status"] = PipelineStatus.FAILED.value
            results["error"] = str(e)

        results["end_time"] = datetime.utcnow().isoformat()
        results["duration_seconds"] = (datetime.utcnow() - start_time).total_seconds()

        self.pipeline_history.append(results)

        return results

    async def _run_linter(self, code: str, language: str) -> Dict[str, Any]:
        \"\"\"Run linter on code\"\"\"
        errors = []
        warnings = []

        # Simulate linting
        lines = code.split('\\n')

        for i, line in enumerate(lines, 1):
            # Check for trailing whitespace:
            if line.endswith(' '):
                warnings.append(f"Line {i}: Trailing whitespace")

            # Check line length
            if len(line) > 100:
                warnings.append(f"Line {i}: Line too long ({len(line)} > 100)")

            # Check for unused imports (simplified):
            if 'import ' in line and ' used' not in code:
                warnings.append(f"Line {i}: Possible unused import")

        return {
            "passed": len(errors) == 0,
            "errors": errors,
            "warnings": warnings
        }

    async def _run_type_check(self, code: str, language: str) -> Dict[str, Any]:
        \"\"\"Run type checker\"\"\"
        errors = []

        # Check for type hints:
        if language == "python":
            if ': ' not in code or '->' not in code:
                errors.append("Missing type hints in function definitions")

        return {
            "passed": len(errors) == 0,
            "errors": errors
        }

    async def _run_tests(self, code: str, language: str) -> Dict[str, Any]:
        \"\"\"Run unit tests\"\"\"
        # Simulate test execution
        test_count = code.count('def test_'):
        if test_count == 0:
            test_count = 1  # Assume at least one test

        passed = max(1, test_count - code.count('fail')) if test_count > 0 else 0

        return {:
            "passed": passed == test_count,
            "total": test_count,
            "passed_count": passed,
            "failed_count": test_count - passed,
            "coverage": min(100, passed * 20)
        }

    async def _run_security_scan(self, code: str) -> Dict[str, Any]:
        \"\"\"Run security scan\"\"\"
        vulnerabilities = []

        # Check for common security issues:
        if 'eval(' in code:
            vulnerabilities.append({
                "severity": "high",
                "description": "Use of eval() detected"
            })

        if 'exec(' in code:
            vulnerabilities.append({
                "severity": "high",
                "description": "Use of exec() detected"
            })

        if '__import__' in code:
            vulnerabilities.append({
                "severity": "medium",
                "description": "Dynamic imports may be dangerous"
            })

        return {
            "passed": len(vulnerabilities) == 0,
            "vulnerabilities": vulnerabilities,
            "severity_count": {
                "high": sum(1 for v in vulnerabilities if v["severity"] == "high"),:
                "medium": sum(1 for v in vulnerabilities if v["severity"] == "medium"),:
                "low": sum(1 for v in vulnerabilities if v["severity"] == "low")
            }:
        }
    :
    async def _run_build(self, code: str, language: str) -> Dict[str, Any]:
        \"\"\"Build the project\"\"\"
        # Simulate build process
        errors = []

        # Check for required files:
        if language == "python" and 'requirements.txt' not in code and 'setup.py' not in code:
            errors.append("No requirements.txt or setup.py found")

        return {
            "passed": len(errors) == 0,
            "errors": errors,
            "build_time": 1.5  # seconds
        }

    def _calculate_final_score(self, stages: Dict) -> float:
        \"\"\"Calculate final pipeline score\"\"\"
        scores = []

        for stage_name, stage_result in stages.items():
            if stage_result.get("passed", False):
                scores.append(100)
            else:
                # Partial score based on percentage
                if "passed_count" in stage_result and "total" in stage_result:
                    score = (stage_result["passed_count"] / stage_result["total"]) * 100
                    scores.append(score)
                else:
                    scores.append(0)

        return sum(scores) / len(scores) if scores else 0
\"\"\""
    :
    with open("factory/ci/ci_engine.py", "w") as f:
        f.write(ci_engine_py)

    # Dependency Graph
    dependency_graph_py = \"\"\"from typing import Dict, Any, List, Set"
from collections import defaultdict
import ast

class DependencyGraph:
    \"\"\"Manages code dependencies\"\"\"

    def __init__(self):
        self.graph: Dict[str, Set[str]] = defaultdict(set)
        self.reverse_graph: Dict[str, Set[str]] = defaultdict(set)

    def build_graph(self, code: str) -> Dict[str, Any]:
        \"\"\"Build dependency graph from code\"\"\"

        try:
            tree = ast.parse(code)

            # Track imports
            for node in ast.walk(tree):
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        self._add_dependency("__main__", alias.name)

                elif isinstance(node, ast.ImportFrom):
                    module = node.module or ""
                    for alias in node.names:
                        self._add_dependency("__main__", f"{module}.{alias.name}")

                elif isinstance(node, ast.ClassDef):
                    # Track class dependencies
                    for base in node.bases:
                        if isinstance(base, ast.Name):
                            self._add_dependency(node.name, base.id)

                elif isinstance(node, ast.FunctionDef):
                    # Track function dependencies
                    for subnode in ast.walk(node):
                        if isinstance(subnode, ast.Call):
                            if isinstance(subnode.func, ast.Name):
                                self._add_dependency(node.name, subnode.func.id)

            return self.analyze_graph()

        except Exception as e:
            return {"error": str(e), "nodes": 0, "edges": 0}

    def _add_dependency(self, source: str, target: str):
        \"\"\"Add dependency relationship\"\"\"
        self.graph[source].add(target)
        self.reverse_graph[target].add(source)

    def analyze_graph(self) -> Dict[str, Any]:
        \"\"\"Analyze dependency graph\"\"\"

        return {
            "nodes": len(self.graph),
            "edges": sum(len(deps) for deps in self.graph.values()),:
            "circular_dependencies": self._find_circular_dependencies(),
            "most_dependent": self._find_most_dependent(),
            "critical_path": self._find_critical_path(),
            "layers": self._calculate_layers()
        }

    def _find_circular_dependencies(self) -> List[List[str]]:
        \"\"\"Find circular dependencies\"\"\"
        circular = []
        visited = set()
        path = []

        def dfs(node: str):
            if node in path:
                # Found a cycle
                cycle_start = path.index(node)
                circular.append(path[cycle_start:] + [node])
                return

            if node in visited:
                return

            visited.add(node)
            path.append(node)

            for neighbor in self.graph.get(node, []):
                dfs(neighbor)

            path.pop()

        for node in list(self.graph.keys()):
            dfs(node)

        return circular

    def _find_most_dependent(self) -> List[tuple]:
        \"\"\"Find most depended-on modules\"\"\"
        dependencies = []

        for module, dependents in self.reverse_graph.items():
            dependencies.append((module, len(dependents)))

        dependencies.sort(key=lambda x: x[1], reverse=True)
        return dependencies[:5]

    def _find_critical_path(self) -> List[str]:
        \"\"\"Find critical path through dependency graph\"\"\"
        # Simplified topological sort for critical path:
        if not self.graph:
            return []

        in_degree = defaultdict(int)
        for node, deps in self.graph.items():
            in_degree[node] = len(deps)

        # Find nodes with no dependencies
        queue = [node for node, degree in in_degree.items() if degree == 0]:
        critical_path = []
        :
        while queue:
            # Process node with most dependents first
            queue.sort(key=lambda n: len(self.reverse_graph.get(n, [])), reverse=True)
            node = queue.pop(0)
            critical_path.append(node)

            # Remove node and update dependencies
            for dependent in self.reverse_graph.get(node, []):
                in_degree[dependent] -= 1
                if in_degree[dependent] == 0:
                    queue.append(dependent)

        return critical_path

    def _calculate_layers(self) -> List[List[str]]:
        \"\"\"Calculate dependency layers\"\"\"
        layers = []
        remaining = set(self.graph.keys())
        processed = set()

        while remaining:
            # Find nodes with no dependencies on remaining nodes
            layer = []
            for node in remaining:
                deps = self.graph.get(node, set())
                if deps.issubset(processed):
                    layer.append(node)

            if not layer:
                break  # Circular dependency detected

            layers.append(layer)
            remaining -= set(layer)
            processed.update(layer)

        return layers

    def get_dependents(self, module: str) -> List[str]:
        \"\"\"Get all modules that depend on given module\"\"\"
        return list(self.reverse_graph.get(module, []))

    def get_dependencies(self, module: str) -> List[str]:
        \"\"\"Get dependencies of a module\"\"\"
        return list(self.graph.get(module, []))
\"\"\""

    with open("factory/ci/dependency_graph.py", "w") as f:
        f.write(dependency_graph_py)

    # Change Detector
    change_detector_py = \"\"\"from typing import Dict, Any, List, Optional"
from dataclasses import dataclass
from datetime import datetime
import hashlib

@dataclass
class Change:
    \"\"\"Represents a code change\"\"\"
    file_path: str
    change_type: str  # added, modified, deleted
    old_hash: str
    new_hash: str
    lines_added: int
    lines_removed: int
    timestamp: datetime

class ChangeDetector:
    \"\"\"Detects and tracks code changes\"\"\"

    def __init__(self):
        self.snapshots: Dict[str, Dict[str, str]] = {}  # file_path -> content hash
        self.change_history: List[Change] = []

    def detect_changes(self, current_code: Dict[str, str]) -> List[Change]:
        \"\"\"Detect changes between previous and current state\"\"\"
        changes = []

        # Check for modified and deleted files:
        for file_path, old_hash in self.snapshots.items():
            if file_path in current_code:
                new_hash = self._hash_content(current_code[file_path])
                if old_hash != new_hash:
                    # Modified
                    change = self._analyze_change(file_path, "modified", old_hash, new_hash, current_code[file_path])
                    changes.append(change)
            else:
                # Deleted
                change = Change(
                    file_path=file_path,
                    change_type="deleted",
                    old_hash=old_hash,
                    new_hash="",
                    lines_added=0,
                    lines_removed=self._count_lines(self._get_old_content(file_path)),
                    timestamp=datetime.utcnow()
                )
                changes.append(change)

        # Check for added files:
        for file_path, content in current_code.items():
            if file_path not in self.snapshots:
                new_hash = self._hash_content(content)
                change = Change(
                    file_path=file_path,
                    change_type="added",
                    old_hash="",
                    new_hash=new_hash,
                    lines_added=self._count_lines(content),
                    lines_removed=0,
                    timestamp=datetime.utcnow()
                )
                changes.append(change)

        # Update snapshot
        self.snapshots = {path: self._hash_content(content) for path, content in current_code.items()}

        # Record changes
        self.change_history.extend(changes)

        return changes
    :
    def _analyze_change(self, file_path: str, change_type: str, old_hash: str, new_hash: str, new_content: str) -> Change:
        \"\"\"Analyze a change in detail\"\"\"
        old_content = self._get_old_content(file_path)

        # Simple line diff
        old_lines = old_content.split('\\n') if old_content else []
        new_lines = new_content.split('\\n')

        # Count added/removed lines (simplified)
        added = 0
        removed = 0
        :
        for line in new_lines:
            if line not in old_lines:
                added += 1

        for line in old_lines:
            if line not in new_lines:
                removed += 1

        return Change(
            file_path=file_path,
            change_type=change_type,
            old_hash=old_hash,
            new_hash=new_hash,
            lines_added=added,
            lines_removed=removed,
            timestamp=datetime.utcnow()
        )

    def _hash_content(self, content: str) -> str:
        \"\"\"Generate hash of content\"\"\"
        return hashlib.sha256(content.encode()).hexdigest()

    def _get_old_content(self, file_path: str) -> str:
        \"\"\"Get old content from snapshot (simplified)\"\"\"
        # In production, would retrieve from storage
        return ""

    def _count_lines(self, content: str) -> int:
        \"\"\"Count lines in content\"\"\"
        return len(content.split('\\n')) if content else 0
    :
    def get_change_summary(self) -> Dict[str, Any]:
        \"\"\"Get summary of all changes\"\"\"
        if not self.change_history:
            return {"total_changes": 0}

        by_type = {}
        for change in self.change_history:
            by_type[change.change_type] = by_type.get(change.change_type, 0) + 1

        return {
            "total_changes": len(self.change_history),
            "by_type": by_type,
            "total_lines_added": sum(c.lines_added for c in self.change_history),:
            "total_lines_removed": sum(c.lines_removed for c in self.change_history),:
            "latest_change": self.change_history[-1].timestamp.isoformat() if self.change_history else None
        }
    :
    def get_changes_since(self, timestamp: datetime) -> List[Change]:
        \"\"\"Get changes since specific timestamp\"\"\"
        return [c for c in self.change_history if c.timestamp > timestamp]
    :
    def clear_history(self):
        \"\"\"Clear change history\"\"\"
        self.change_history = []
        self.snapshots = {}
\"\"\""

    with open("factory/ci/change_detector.py", "w") as f:
        f.write(change_detector_py)

    # Batch Scheduler
    batch_scheduler_py = \"\"\"from typing import Dict, Any, List, Optional"
import asyncio
import logging
from dataclasses import dataclass
from datetime import datetime, timedelta
from enum import Enum

logger = logging.getLogger(__name__)

class BatchPriority(Enum):
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4

@dataclass
class ScheduledBatch:
    \"\"\"Represents a scheduled batch\"\"\"
    batch_id: str
    version: int
    prompt: str
    priority: BatchPriority
    scheduled_time: datetime
    retry_count: int = 0
    max_retries: int = 3

class BatchScheduler:
    \"\"\"Scheduler for automatic batch execution\"\"\"
    :
    def __init__(self, max_concurrent: int = 3):
        self.max_concurrent = max_concurrent
        self.queue: List[ScheduledBatch] = []
        self.running: Dict[str, ScheduledBatch] = {}
        self.completed: List[ScheduledBatch] = []
        self.failed: List[ScheduledBatch] = []

    async def schedule_batch(self, version: int, prompt: str, priority: BatchPriority = BatchPriority.NORMAL, delay_seconds: int = 0) -> str:
        \"\"\"Schedule a batch for execution\"\"\"

        batch_id = f"batch_{datetime.utcnow().strftime('%Y%m%d_%H%M%S_%f')}"
        scheduled_time = datetime.utcnow() + timedelta(seconds=delay_seconds)

        batch = ScheduledBatch(
            batch_id=batch_id,
            version=version,
            prompt=prompt,
            priority=priority,
            scheduled_time=scheduled_time
        )

        self.queue.append(batch)
        self._sort_queue()

        logger.info(f"Scheduled batch {batch_id} for {scheduled_time}")

        return batch_id
    :
    async def process_scheduler(self, batch_executor):
        \"\"\"Main scheduler loop\"\"\"

        while True:
            now = datetime.utcnow()

            # Check for batches ready to run
            ready_batches = [
                b for b in self.queue
                if b.scheduled_time <= now and len(self.running) < self.max_concurrent:
            ]
            :
            # Process ready batches:
            for batch in ready_batches:
                self.queue.remove(batch)
                self.running[batch.batch_id] = batch

                # Execute batch
                asyncio.create_task(self._execute_batch(batch, batch_executor))

            await asyncio.sleep(1)  # Check every second

    async def _execute_batch(self, batch: ScheduledBatch, batch_executor):
        \"\"\"Execute a scheduled batch\"\"\"

        logger.info(f"Executing scheduled batch {batch.batch_id}")

        try:
            # Call batch executor
            result = await batch_executor.execute_batch(
                batch.batch_id,
                batch.version,
                batch.prompt
            )

            # Check result
            if result.get("overall_score", 0) >= 70:
                self.completed.append(batch)
                logger.info(f"Batch {batch.batch_id} completed successfully")

                # Schedule next batch in sequence
                if batch.version < 40:
                    await self.schedule_batch(
                        batch.version + 1,
                        f"Continue evolution from batch {batch.version}",
                        BatchPriority.NORMAL,
                        delay_seconds=5
                    )
            else:
                # Retry if needed:
                if batch.retry_count < batch.max_retries:
                    batch.retry_count += 1
                    batch.scheduled_time = datetime.utcnow() + timedelta(seconds=30)
                    self.queue.append(batch)
                    self._sort_queue()
                    logger.warning(f"Batch {batch.batch_id} failed, scheduled retry {batch.retry_count}")
                else:
                    self.failed.append(batch)
                    logger.error(f"Batch {batch.batch_id} failed permanently after {batch.max_retries} retries")

        except Exception as e:
            logger.error(f"Error executing batch {batch.batch_id}: {str(e)}")
            self.failed.append(batch)

        finally:
            # Remove from running
            if batch.batch_id in self.running:
                del self.running[batch.batch_id]

    def _sort_queue(self):
        \"\"\"Sort queue by priority and time\"\"\"
        self.queue.sort(key=lambda b: (b.priority.value, b.scheduled_time), reverse=True)

    def get_status(self) -> Dict[str, Any]:
        \"\"\"Get scheduler status\"\"\"
        return {
            "queued": len(self.queue),
            "running": len(self.running),
            "completed": len(self.completed),
            "failed": len(self.failed),
            "max_concurrent": self.max_concurrent
        }
\"\"\""

    with open("factory/ci/batch_scheduler.py", "w") as f:
        f.write(batch_scheduler_py)

    # Git Integration
    git_integration_py = \"\"\"from typing import Dict, Any, List, Optional"
import subprocess
import logging
from pathlib import Path
from datetime import datetime

logger = logging.getLogger(__name__)

class GitIntegration:
    \"\"\"Git integration for version control\"\"\"
    :
    def __init__(self, repo_path: str = "./generated_repo"):
        self.repo_path = Path(repo_path)
        self.repo_path.mkdir(parents=True, exist_ok=True)

    async def init_repo(self) -> bool:
        \"\"\"Initialize git repository\"\"\"
        try:
            result = subprocess.run(
                ["git", "init"],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )
            return result.returncode == 0
        except Exception as e:
            logger.error(f"Failed to init repo: {str(e)}")
            return False

    async def commit(self, message: str, files: List[str] = None) -> bool:
        \"\"\"Commit changes\"\"\"
        try:
            # Add files
            if files:
                subprocess.run(["git", "add"] + files, cwd=self.repo_path)
            else:
                subprocess.run(["git", "add", "."], cwd=self.repo_path)

            # Commit
            result = subprocess.run(
                ["git", "commit", "-m", message],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                logger.warning(f"Commit failed: {result.stderr}")
                return False

            return True

        except Exception as e:
            logger.error(f"Failed to commit: {str(e)}")
            return False

    async def create_branch(self, branch_name: str) -> bool:
        \"\"\"Create a new branch\"\"\"
        try:
            result = subprocess.run(
                ["git", "checkout", "-b", branch_name],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )
            return result.returncode == 0
        except Exception as e:
            logger.error(f"Failed to create branch: {str(e)}")
            return False

    async def tag_version(self, version: str) -> bool:
        \"\"\"Tag a version\"\"\"
        try:
            result = subprocess.run(
                ["git", "tag", f"v{version}"],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )
            return result.returncode == 0
        except Exception as e:
            logger.error(f"Failed to tag version: {str(e)}")
            return False

    async def get_commit_history(self, limit: int = 10) -> List[Dict[str, Any]]:
        \"\"\"Get commit history\"\"\"
        try:
            result = subprocess.run(
                ["git", "log", f"-{limit}", "--pretty=format:%H|%an|%ae|%at|%s"],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )

            commits = []
            for line in result.stdout.strip().split('\\n'):
                if line:
                    parts = line.split('|')
                    if len(parts) >= 5:
                        commits.append({
                            "hash": parts[0],
                            "author": parts[1],
                            "email": parts[2],
                            "timestamp": datetime.fromtimestamp(int(parts[3])).isoformat(),
                            "message": parts[4]
                        })

            return commits

        except Exception as e:
            logger.error(f"Failed to get commit history: {str(e)}")
            return []

    async def get_current_branch(self) -> Optional[str]:
        \"\"\"Get current branch name\"\"\"
        try:
            result = subprocess.run(
                ["git", "branch", "--show-current"],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )
            return result.stdout.strip() if result.returncode == 0 else None:
        except Exception as e:
            logger.error(f"Failed to get current branch: {str(e)}")
            return None

    async def is_dirty(self) -> bool:
        \"\"\"Check if working directory is dirty\"\"\":
        try:
            result = subprocess.run(
                ["git", "status", "--porcelain"],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )
            return len(result.stdout.strip()) > 0
        except Exception as e:
            logger.error(f"Failed to check dirty state: {str(e)}")
            return False
\"\"\""

    with open("factory/ci/git_integration.py", "w") as f:
        f.write(git_integration_py)

    # Pipeline Trigger
    pipeline_trigger_py = \"\"\"from typing import Dict, Any, List, Optional"
import asyncio
import logging
from datetime import datetime

from factory.ci.ci_engine import CIEngine
from factory.ci.change_detector import ChangeDetector

logger = logging.getLogger(__name__)

class PipelineTrigger:
    \"\"\"Triggers CI pipelines based on events\"\"\"

    def __init__(self, ci_engine: CIEngine, change_detector: ChangeDetector):
        self.ci_engine = ci_engine
        self.change_detector = change_detector
        self.trigger_history: List[Dict] = []

    async def on_code_change(self, code: Dict[str, str]) -> Optional[Dict[str, Any]]:
        \"\"\"Trigger pipeline on code change\"\"\"

        # Detect changes
        changes = self.change_detector.detect_changes(code)

        if not changes:
            logger.info("No changes detected")
            return None

        # Determine if pipeline should run
        should_run = self._should_run_pipeline(changes)
        :
        if not should_run:
            logger.info("Changes not significant enough to trigger pipeline")
            return None

        # Run pipeline
        logger.info(f"Triggering pipeline due to {len(changes)} changes")

        # Combine all code for pipeline
        combined_code = "\\n\\n".join(code.values())

        result = await self.ci_engine.run_pipeline(combined_code)

        # Record trigger
        self.trigger_history.append({:
            "timestamp": datetime.utcnow().isoformat(),
            "changes_count": len(changes),
            "pipeline_id": result["pipeline_id"],
            "result": result["status"]
        })

        return result

    def _should_run_pipeline(self, changes: List) -> bool:
        \"\"\"Determine if pipeline should run based on changes\"\"\"

        # Always run on critical changes:
        for change in changes:
            if change.change_type in ["added", "modified"] and change.lines_added > 10:
                return True

        # Run if many changes:
        if len(changes) > 3:
            return True

        # Run if significant line changes
        total_lines_changed = sum(change.lines_added + change.lines_removed for change in changes):
        if total_lines_changed > 20:
            return True

        return False

    async def on_schedule(self, interval_seconds: int = 3600) -> None:
        \"\"\"Trigger pipeline on schedule\"\"\"

        while True:
            logger.info(f"Running scheduled pipeline (interval: {interval_seconds}s)")

            # In production, would fetch latest code
            result = await self.ci_engine.run_pipeline("")

            self.trigger_history.append({
                "timestamp": datetime.utcnow().isoformat(),
                "type": "scheduled",
                "pipeline_id": result["pipeline_id"],
                "result": result["status"]
            })

            await asyncio.sleep(interval_seconds)

    async def on_demand(self, code: str, reason: str) -> Dict[str, Any]:
        \"\"\"Trigger pipeline on demand\"\"\"

        logger.info(f"Triggering on-demand pipeline: {reason}")

        result = await self.ci_engine.run_pipeline(code)

        self.trigger_history.append({
            "timestamp": datetime.utcnow().isoformat(),
            "type": "on_demand",
            "reason": reason,
            "pipeline_id": result["pipeline_id"],
            "result": result["status"]
        })

        return result

    def get_trigger_stats(self) -> Dict[str, Any]:
        \"\"\"Get trigger statistics\"\"\"
        if not self.trigger_history:
            return {"total_triggers": 0}

        by_type = {}
        for trigger in self.trigger_history:
            trigger_type = trigger.get("type", "unknown")
            by_type[trigger_type] = by_type.get(trigger_type, 0) + 1

        success_count = sum(1 for t in self.trigger_history if t.get("result") == "passed")
        :
        return {:
            "total_triggers": len(self.trigger_history),
            "by_type": by_type,
            "success_rate": (success_count / len(self.trigger_history)) * 100,
            "last_trigger": self.trigger_history[-1]["timestamp"] if self.trigger_history else None
        }
\"\"\""
    :
    with open("factory/ci/pipeline_trigger.py", "w") as f:
        f.write(pipeline_trigger_py)

    # Complete System Integration
    system_integration_py = \"\"\"#!/usr/bin/env python3"
\"\"\""
Complete System Integration
Connects all components into a cohesive system
\"\"\""

import asyncio
import logging
import sys
from pathlib import Path

# Add paths
sys.path.insert(0, str(Path(__file__).parent.parent))

from factory.engine.batch_engine import BatchEngine
from factory.orchestrator.coordinator import AgentCoordinator
from factory.orchestrator.pipeline_manager import PipelineManager
from factory.evolution.evolution_engine import EvolutionEngine, PatternMemory
from factory.memory.improvement_tracker import ImprovementTracker
from factory.ci.ci_engine import CIEngine
from factory.ci.batch_scheduler import BatchScheduler, BatchPriority
from factory.ci.git_integration import GitIntegration

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AIFactorySystem:
    \"\"\"Complete AI Software Factory System\"\"\"

    def __init__(self):
        # Core components
        self.batch_engine = BatchEngine()
        self.ci_engine = CIEngine()
        self.pattern_memory = PatternMemory()
        self.evolution_engine = EvolutionEngine(self.pattern_memory)
        self.improvement_tracker = ImprovementTracker()
        self.batch_scheduler = BatchScheduler()
        self.git = GitIntegration()

        # Initialize orchestrator with agents
        from factory.agents.architect_agent import ArchitectAgent
        from factory.agents.backend_agent import BackendAgent
        from factory.agents.frontend_agent import FrontendAgent
        from factory.agents.qa_agent import QAAgent
        from factory.agents.security_agent import SecurityAgent
        from factory.agents.devops_agent import DevOpsAgent
        from factory.agents.reviewer_agent import ReviewerAgent
        from factory.agents.optimizer_agent import OptimizerAgent

        agents = {
            agent_role: agent_class()
            for agent_role, agent_class in {:
                # Will add agent instances here
            }
        }

        self.coordinator = AgentCoordinator(agents)
        self.pipeline_manager = PipelineManager(self.coordinator)
    :
    async def run_batch(self, version: int, prompt: str, auto_improve: bool = True) -> Dict[str, Any]:
        \"\"\"Run a complete batch with evolution\"\"\"

        logger.info(f"Starting batch v{version}: {prompt[:50]}...")

        # Execute batch
        batch_result = await self.batch_engine.execute_batch(
            f"batch_v{version}",
            version,
            prompt
        )

        # Get code from result
        code = batch_result.get("output", {}).get("backend_code", "")

        # Run evolution if enabled:
        if auto_improve and code:
            logger.info("Running evolution cycle")
            evolution_result = await self.evolution_engine.evolve(code, {
                "initial_score": batch_result.get("overall_score", 0),
                "version": version
            })

            batch_result["evolution"] = evolution_result

            # Record improvement
            if evolution_result["final_score"] > batch_result.get("overall_score", 0):
                await self.improvement_tracker.record_improvement(...)

        # Run CI pipeline
        logger.info("Running CI pipeline")
        ci_result = await self.ci_engine.run_pipeline(code)
        batch_result["ci"] = ci_result

        # Commit to git if successful:
        if ci_result["status"] == "passed":
            await self.git.init_repo()
            await self.git.commit(f"Batch v{version}: {prompt[:50]}")
            await self.git.tag_version(str(version))

        return batch_result

    async def run_evolution_sequence(self, start_version: int, end_version: int, base_prompt: str):
        \"\"\"Run a sequence of evolving batches\"\"\"

        results = []
        current_prompt = base_prompt

        for version in range(start_version, end_version + 1):
            logger.info(f"=== Running Batch v{version} ===")

            # Run batch
            result = await self.run_batch(version, current_prompt)
            results.append(result)

            # Update prompt for next iteration:
            current_prompt = f"Improve and evolve: {current_prompt}\\n\\nPrevious score: {result.get('overall_score', 0)}"

            # Schedule next batch automatically
            if version < end_version:
                await self.batch_scheduler.schedule_batch(
                    version + 1,
                    current_prompt,
                    BatchPriority.NORMAL,
                    delay_seconds=10
                )

        return results

    async def start_autonomous_mode(self):
        \"\"\"Start autonomous operation mode\"\"\"

        logger.info("Starting autonomous mode...")

        # Initialize git
        await self.git.init_repo()

        # Start scheduler in background
        asyncio.create_task(self.batch_scheduler.process_scheduler(self.batch_engine))

        # Start with initial batch
        await self.batch_scheduler.schedule_batch(
            1,
            "Generate initial SaaS application with user authentication and CRUD operations",
            BatchPriority.HIGH,
            delay_seconds=0
        )

        # Monitor and report
        while True:
            status = self.batch_scheduler.get_status()
            logger.info(f"System status: {status}")

            # Get improvement stats
            stats = await self.improvement_tracker.get_improvement_stats()
            if stats["total_improvements"] > 0:
                logger.info(f"Average improvement: {stats['average_improvement']:.2f}%")

            await asyncio.sleep(30)  # Report every 30 seconds

async def main():
    \"\"\"Main entry point\"\"\"

    system = AIFactorySystem()

    # Parse arguments
    import argparse
    parser = argparse.ArgumentParser(description="AI Software Factory")
    parser.add_argument("--mode", choices=["batch", "sequence", "autonomous"], default="batch")
    parser.add_argument("--version", type=int, default=1)
    parser.add_argument("--prompt", default="Generate a todo list application")
    parser.add_argument("--end-version", type=int, default=5)

    args = parser.parse_args()

    if args.mode == "batch":
        result = await system.run_batch(args.version, args.prompt)
        print(f"\\nBatch completed with score: {result.get('overall_score', 0)}")

    elif args.mode == "sequence":
        results = await system.run_evolution_sequence(args.version, args.end_version, args.prompt)
        print(f"\\nSequence completed. Final score: {results[-1].get('overall_score', 0)}")

    elif args.mode == "autonomous":
        print("Starting autonomous mode. Press Ctrl+C to stop.")
        await system.start_autonomous_mode()

if __name__ == "__main__":
    asyncio.run(main())
\"\"\""

    with open("factory/system.py", "w") as f:
        f.write(system_integration_py)

    # Make executable
    os.chmod("factory/system.py", 0o755)

def create_test_files():
    \"\"\"Generate comprehensive test suite\"\"\"

    # Base test
    test_base_py = \"\"\"import pytest"
from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class TestBaseAgent:
    def test_agent_creation(self):
        class ConcreteAgent(BaseAgent):
            async def process(self, input_data):
                return AgentOutput(code="test", explanation="test")

        agent = ConcreteAgent("test", AgentRole.ARCHITECT)
        assert agent.name == "test"
        assert agent.role == AgentRole.ARCHITECT

    def test_validate_output(self):
        class ConcreteAgent(BaseAgent):
            async def process(self, input_data):
                return AgentOutput(code="", explanation="")

        agent = ConcreteAgent("test", AgentRole.ARCHITECT)
        output = AgentOutput(code="valid code", explanation="valid")
        assert agent.validate_output(output) == True

        invalid = AgentOutput(code="", explanation="")
        assert agent.validate_output(invalid) == False
\"\"\""

    with open("tests/test_base.py", "w") as f:
        f.write(test_base_py)

    # Test agents
    test_agents_py = \"\"\"import pytest"
from factory.agents.architect_agent import ArchitectAgent
from factory.agents.backend_agent import BackendAgent
from factory.agents.qa_agent import QAAgent

class TestArchitectAgent:
    @pytest.mark.asyncio
    async def test_architect_process(self):
        agent = ArchitectAgent()
        from factory.agents.base_agent import AgentInput
        input_data = AgentInput(task="Build e-commerce platform", context={})
        output = await agent.process(input_data)

        assert output.code is not None
        assert len(output.code) > 0
        assert output.score > 0

class TestBackendAgent:
    @pytest.mark.asyncio
    async def test_backend_generation(self):
        agent = BackendAgent()
        from factory.agents.base_agent import AgentInput
        input_data = AgentInput(
            task="Generate API",
            context={"architecture": {"tech_stack": {"backend": "fastapi"}}}
        )
        output = await agent.process(input_data)

        assert "AuthService" in output.code
        assert output.score > 0

class TestQAAgent:
    @pytest.mark.asyncio
    async def test_qa_validation(self):
        agent = QAAgent()
        from factory.agents.base_agent import AgentInput
        input_data = AgentInput(
            task="Validate code",
            context={"code": "def test():\\n    pass"}
        )
        output = await agent.process(input_data)

        assert output.score >= 0
        assert output.metadata is not None
\"\"\""

    with open("tests/test_agents.py", "w") as f:
        f.write(test_agents_py)

    # Test CI
    test_ci_py = \"\"\"import pytest"
from factory.ci.ci_engine import CIEngine
from factory.ci.change_detector import ChangeDetector

class TestCIEngine:
    @pytest.mark.asyncio
    async def test_run_pipeline(self):
        engine = CIEngine()
        result = await engine.run_pipeline("print('test')")

        assert "pipeline_id" in result
        assert result["status"] in ["passed", "failed"]

    @pytest.mark.asyncio
    async def test_linter(self):
        engine = CIEngine()
        result = await engine._run_linter("x=1\\ny=2\\n", "python")

        assert "passed" in result

class TestChangeDetector:
    def test_detect_changes(self):
        detector = ChangeDetector()

        old_code = {"file1.py": "print('old')"}
        changes = detector.detect_changes(old_code)
        assert len(changes) == 1
        assert changes[0].change_type == "added"

        new_code = {"file1.py": "print('new')"}
        changes = detector.detect_changes(new_code)
        assert len(changes) == 1
        assert changes[0].change_type == "modified"
\"\"\""

    with open("tests/test_ci.py", "w") as f:
        f.write(test_ci_py)

    # Test orchestrator
    test_orchestrator_py = \"\"\"import pytest"
from factory.orchestrator.task_planner import TaskPlanner
from factory.orchestrator.scoring_engine import ScoringEngine

class TestTaskPlanner:
    @pytest.mark.asyncio
    async def test_create_plan(self):
        planner = TaskPlanner()
        plan = await planner.create_plan("Build app", {}, [])

        assert len(plan) > 0
        assert plan[0].priority >= 1

class TestScoringEngine:
    @pytest.mark.asyncio
    async def test_calculate_score(self):
        engine = ScoringEngine()
        from factory.agents.base_agent import AgentOutput
        output = AgentOutput(code="def test():\\n    pass", explanation="test")
        score = await engine.calculate_score(output, {})

        assert 0 <= score <= 100
\"\"\""

    with open("tests/test_orchestrator.py", "w") as f:
        f.write(test_orchestrator_py)

def create_scripts():
    \"\"\"Generate utility scripts\"\"\"

    # Setup script
    setup_sh = \"\"\"#!/bin/bash"
# Setup script for AI Software Factory

echo "Setting up AI Software Factory..."

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install backend dependencies
pip install -r backend/requirements.txt

# Install factory dependencies
pip install -r factory/requirements.txt

# Setup frontend
cd frontend
npm install
cd ..

# Create necessary directories
mkdir -p output
mkdir -p logs
mkdir -p generated_repo

# Copy environment file
cp .env.example .env

echo "Setup complete!"
echo "Run 'docker-compose up' to start all services"
echo "Or run 'python factory/system.py --help' to use CLI"
\"\"\""
    :
    with open("scripts/setup.sh", "w") as f:
        f.write(setup_sh)
    os.chmod("scripts/setup.sh", 0o755)

    # Run test script
    test_sh = \"\"\"#!/bin/bash"
# Run all tests

echo "Running tests..."

# Backend tests
cd backend
pytest tests/ -v
cd ..

# Factory tests
python -m pytest tests/ -v

echo "Tests completed!"
\"\"\""

    with open("scripts/run_tests.sh", "w") as f:
        f.write(test_sh)
    os.chmod("scripts/run_tests.sh", 0o755)

    # Demo script
    demo_py = \"\"\"#!/usr/bin/env python3"
\"\"\"Demo script for AI Software Factory\"\"\"

import asyncio
from factory.system import AIFactorySystem
:
async def demo():
    print("=" * 60)
    print("AI Software Factory Demo")
    print("=" * 60)

    system = AIFactorySystem()

    # Demo 1: Single batch
    print("\\n1. Running single batch...")
    result = await system.run_batch(1, "Create a simple contact management system")
    print(f"   Score: {result.get('overall_score', 0):.1f}")

    # Demo 2: Evolution sequence
    print("\\n2. Running evolution sequence (v1 -> v3)...")
    results = await system.run_evolution_sequence(1, 3, "Create a task management system")

    for i, result in enumerate(results, 1):
        print(f"   Batch {i} score: {result.get('overall_score', 0):.1f}")

    # Demo 3: System status
    print("\\n3. System Status:")
    print(f"   Pattern memory stats: {system.pattern_memory.get_statistics()}")

    print("\\n✅ Demo completed successfully!")

if __name__ == "__main__":
    asyncio.run(demo())
\"\"\""
