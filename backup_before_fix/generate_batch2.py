#!/usr/bin/env python3
\"\"\""
Batch 2: AI Factory Engine & Multi-Agent System
Implements core AI agents and code generation pipeline
\"\"\""

import os
import json
from pathlib import Path
from typing import Dict, Any, List
from datetime import datetime

def create_agent_files():
    """Generate all AI agent implementations"""

    # Base Agent
    base_agent_py = \"\"\"from abc import ABC, abstractmethod"
from typing import Dict, Any, Optional
from dataclasses import dataclass, field
from enum import Enum
import json
import logging

logger = logging.getLogger(__name__)

class AgentRole(Enum):
    ARCHITECT = "architect"
    BACKEND = "backend"
    FRONTEND = "frontend"
    DATABASE = "database"
    QA = "qa"
    SECURITY = "security"
    DEVOPS = "devops"
    REVIEWER = "reviewer"
    OPTIMIZER = "optimizer"

@dataclass
class AgentInput:
    """Structured input for agents""":
    task: str
    context: Dict[str, Any] = field(default_factory=dict)
    constraints: List[str] = field(default_factory=list)
    previous_output: Optional[Dict[str, Any]] = None

@dataclass
class AgentOutput:
    """Structured output from agents"""
    code: str
    explanation: str
    score: float = 0.0
    metadata: Dict[str, Any] = field(default_factory=dict)
    errors: List[str] = field(default_factory=list)
    suggestions: List[str] = field(default_factory=list)

class BaseAgent(ABC):
    """Base class for all AI agents"""
    :
    def __init__(self, name: str, role: AgentRole, model: str = "gpt-4"):
        self.name = name
        self.role = role
        self.model = model
        self.context = {}
        self.memory = []

    @abstractmethod
    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Process input and return structured output"""
        pass

    def validate_output(self, output: AgentOutput) -> bool:
        """Validate agent output meets quality standards"""
        if not output.code or len(output.code) < 10:
            return False
        if not output.explanation:
            return False
        return True

    def update_context(self, key: str, value: Any):
        """Update agent context"""
        self.context[key] = value

    def store_memory(self, item: Dict[str, Any]):
        """Store memory for future use"""
        self.memory.append(item):
        if len(self.memory) > 100:
            self.memory = self.memory[-100:]
\"\"\""

    with open("factory/agents/base_agent.py", "w") as f:
        f.write(base_agent_py)

    # Architect Agent
    architect_agent_py = \"\"\"from typing import Dict, Any"
import json

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class ArchitectAgent(BaseAgent):
    """Architect Agent - Designs system architecture and components"""

    def __init__(self, name: str = "ArchitectAgent"):
        super().__init__(name, AgentRole.ARCHITECT)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Generate system architecture based on requirements"""

        # Parse requirements
        requirements = self._parse_requirements(input_data.task, input_data.context)

        # Design architecture
        architecture = self._design_architecture(requirements)

        # Generate component specifications
        components = self._generate_components(architecture)

        # Create data models
        data_models = self._design_data_models(requirements)

        # Generate output
        output_code = self._format_architecture_output(architecture, components, data_models)

        return AgentOutput(
            code=output_code,
            explanation=f"Designed {len(components)} components for {requirements['app_name']}",
            score=85.0,
            metadata={:
                "architecture": architecture,
                "components": components,
                "data_models": data_models,
                "requirements": requirements
            }
        )

    def _parse_requirements(self, task: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Parse and structure requirements"""
        # In production, this would use LLM
        return {
            "app_name": context.get("app_name", "GeneratedApp"),
            "features": ["authentication", "data_management", "api"],
            "tech_stack": {
                "backend": "fastapi",
                "frontend": "react",
                "database": "postgresql"
            },
            "scaling": "horizontal",
            "security_level": "standard"
        }

    def _design_architecture(self, requirements: Dict[str, Any]) -> Dict[str, Any]:
        """Design system architecture"""
        return {
            "layers": ["presentation", "application", "domain", "infrastructure"],
            "patterns": ["repository", "service", "factory"],
            "communication": "async_messages",
            "deployment": "docker_kubernetes"
        }

    def _generate_components(self, architecture: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Generate component specifications"""
        components = [
            {"name": "AuthService", "type": "service", "dependencies": []},
            {"name": "UserRepository", "type": "repository", "dependencies": ["Database"]},
            {"name": "APIGateway", "type": "gateway", "dependencies": ["AuthService"]}
        ]
        return components

    def _design_data_models(self, requirements: Dict[str, Any]) -> Dict[str, Any]:
        """Design data models"""
        return {
            "User": {
                "fields": ["id", "email", "hashed_password", "created_at"],
                "relations": ["has_many:Project"]
            },
            "Project": {
                "fields": ["id", "name", "user_id", "created_at"],
                "relations": ["belongs_to:User"]
            }
        }

    def _format_architecture_output(self, architecture: Dict, components: List, models: Dict) -> str:
        """Format architecture as output code"""
        output = f\"\"\"# System Architecture Design"

## Overview
Layers: {', '.join(architecture['layers'])}
Patterns: {', '.join(architecture['patterns'])}

## Components
\"\"\""
        for comp in components:
            output += f"\n### {comp['name']}\nType: {comp['type']}\nDependencies: {', '.join(comp['dependencies'])}\n"

        output += "\n## Data Models\n"
        for model, details in models.items():
            output += f"\n### {model}\nFields: {', '.join(details['fields'])}\nRelations: {', '.join(details['relations'])}\n"

        return output
\"\"\""

    with open("factory/agents/architect_agent.py", "w") as f:
        f.write(architect_agent_py)

    # Backend Agent
    backend_agent_py = \"\"\"from typing import Dict, Any"
import json

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class BackendAgent(BaseAgent):
    """Backend Agent - Generates backend API code"""

    def __init__(self, name: str = "BackendAgent"):
        super().__init__(name, AgentRole.BACKEND)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Generate backend API code based on architecture"""

        architecture = input_data.context.get("architecture", {})
        components = input_data.context.get("components", [])

        # Generate API endpoints
        api_endpoints = self._generate_endpoints(components)

        # Generate service code
        service_code = self._generate_services(components)

        # Generate repository code
        repository_code = self._generate_repositories(architecture)

        # Generate models
        model_code = self._generate_models(input_data.context.get("data_models", {}))

        combined_code = f\"\"\"# Backend Code Generation"
{service_code}

{repository_code}

{model_code}

{self._format_endpoints(api_endpoints)}
\"\"\""

        return AgentOutput(
            code=combined_code,
            explanation=f"Generated backend code with {len(api_endpoints)} endpoints",
            score=82.0,
            metadata={
                "endpoints": api_endpoints,
                "services": [c["name"] for c in components if c["type"] == "service"]
            }:
        )
    :
    def _generate_endpoints(self, components: List[Dict]) -> List[Dict]:
        """Generate API endpoints"""
        return [
            {"path": "/api/v1/auth/login", "method": "POST", "handler": "login_handler"},
            {"path": "/api/v1/users", "method": "GET", "handler": "get_users"},
            {"path": "/api/v1/users/{id}", "method": "GET", "handler": "get_user"},
            {"path": "/api/v1/projects", "method": "POST", "handler": "create_project"}
        ]

    def _generate_services(self, components: List[Dict]) -> str:
        """Generate service layer code"""
        code = \'\'\''
class AuthService:
    """Authentication service"""

    async def login(self, email: str, password: str):
        # In production, this would validate credentials
        return {"token": "jwt_token", "user": {"email": email}}

    async def verify_token(self, token: str):
        # Verify JWT token
        return {"valid": True, "user_id": "user123"}

class UserService:
    """User management service"""

    async def get_user(self, user_id: str):
        # Fetch user from repository
        return {"id": user_id, "email": f"user{user_id}@example.com"}

    async def create_user(self, user_data: dict):
        # Create new user
        return {"id": "new_id", **user_data}
\'\'\''
        return code

    def _generate_repositories(self, architecture: Dict) -> str:
        """Generate repository layer code"""
        code = \'\'\''
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

class UserRepository:
    """User data repository"""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def find_by_id(self, user_id: str):
        query = select(User).where(User.id == user_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def save(self, user):
        self.session.add(user)
        await self.session.commit()
        return user
\'\'\''
        return code

    def _generate_models(self, data_models: Dict) -> str:
        """Generate database models"""
        code = \'\'\''
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    projects = relationship("Project", back_populates="user")

class Project(Base):
    __tablename__ = "projects"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    user_id = Column(String, ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="projects")
\'\'\''
        return code

    def _format_endpoints(self, endpoints: List[Dict]) -> str:
        """Format endpoints as FastAPI code"""
        output = "\n# API Endpoints\n\n"
        for ep in endpoints:
            output += f"@app.{ep['method'].lower()}('{ep['path']}')\n"
            output += f"async def {ep['handler']}():\n"
            output += "    return {'message': 'Endpoint implemented'}\n\n"
        return output
\"\"\""

    with open("factory/agents/backend_agent.py", "w") as f:
        f.write(backend_agent_py)

    # Frontend Agent
    frontend_agent_py = \"\"\"from typing import Dict, Any"
import json

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class FrontendAgent(BaseAgent):
    """Frontend Agent - Generates React/Next.js frontend code"""

    def __init__(self, name: str = "FrontendAgent"):
        super().__init__(name, AgentRole.FRONTEND)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Generate frontend code based on API specifications"""

        api_specs = input_data.context.get("api_specs", {})

        # Generate components
        components = self._generate_components(api_specs)

        # Generate API client
        api_client = self._generate_api_client(api_specs)

        # Generate pages
        pages = self._generate_pages(api_specs)

        combined_code = f\"\"\"// Frontend Code Generation"

{api_client}

{self._format_components(components)}

{self._format_pages(pages)}
\"\"\""

        return AgentOutput(
            code=combined_code,
            explanation=f"Generated frontend code with {len(components)} components",
            score=80.0,
            metadata={
                "components": components,
                "pages": pages
            }
        )

    def _generate_components(self, api_specs: Dict) -> List[Dict]:
        """Generate React components"""
        return [
            {"name": "LoginForm", "type": "form", "api_calls": ["/auth/login"]},
            {"name": "UserProfile", "type": "display", "api_calls": ["/users/{id}"]},
            {"name": "ProjectList", "type": "list", "api_calls": ["/projects"]}
        ]

    def _generate_api_client(self, api_specs: Dict) -> str:
        """Generate TypeScript API client"""
        code = \'\'\''
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {:
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const authAPI = {:
  login: (email: string, password: string) =>
    api.post('/api/v1/auth/login', { email, password }),
  logout: () => api.post('/api/v1/auth/logout'),
};

export const userAPI = {
  getProfile: () => api.get('/api/v1/users/profile'),
  updateProfile: (data: any) => api.put('/api/v1/users/profile', data),
};

export const projectAPI = {
  list: () => api.get('/api/v1/projects'),
  create: (data: any) => api.post('/api/v1/projects', data),
  get: (id: string) => api.get(`/api/v1/projects/${id}`),
};
\'\'\''
        return code

    def _format_components(self, components: List[Dict]) -> str:
        """Format components as TypeScript React code"""
        output = "\n// React Components\n\n"

        for comp in components:
            output += f\"\"\""
export const {comp['name']} = () => {{
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (data: any) => {{
    setLoading(true);
    try {{
      // API call would go here
      console.log('Submitting:', data);
    }} catch (err) {{
      setError(err.message);
    }} finally {{
      setLoading(false);
    }}
  }};

  return (
    <div className="{comp['name'].lower()}">
      <h2>{comp['name']}</h2>
      {{loading && <p>Loading...</p>}}
      {{error && <p className="error">{{error}}</p>}}
      <!-- Form implementation -->
    </div>
  );
}};
\"\"\""
        return output

    def _generate_pages(self, api_specs: Dict) -> List[str]:
        """Generate Next.js pages"""
        return [
            "pages/index.tsx - Dashboard",
            "pages/login.tsx - Authentication",
            "pages/dashboard.tsx - User dashboard",
            "pages/projects/[id].tsx - Project details"
        ]

    def _format_pages(self, pages: List[str]) -> str:
        """Format pages as code"""
        output = "\n// Next.js Pages\n\n"
        for page in pages:
            output += f"// {page}\n"
        return output
\"\"\""

    with open("factory/agents/frontend_agent.py", "w") as f:
        f.write(frontend_agent_py)

    # QA Agent
    qa_agent_py = \"\"\"from typing import Dict, Any, List"
import re

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class QAAgent(BaseAgent):
    """QA Agent - Validates code quality and runs tests"""

    def __init__(self, name: str = "QAAgent"):
        super().__init__(name, AgentRole.QA)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Validate and test generated code"""

        code = input_data.context.get("code", "")

        # Run validation checks
        syntax_errors = self._check_syntax(code)
        style_errors = self._check_style(code)
        test_results = self._run_mental_tests(code)

        # Calculate score
        score = self._calculate_score(syntax_errors, style_errors, test_results)

        # Generate fixed code if needed:
        if score < 70:
            code = self._auto_fix(code, syntax_errors, style_errors)

        return AgentOutput(
            code=code,
            explanation=f"QA validation completed. Score: {score}",
            score=score,
            metadata={
                "syntax_errors": syntax_errors,
                "style_errors": style_errors,
                "test_results": test_results
            },
            errors=[str(e) for e in syntax_errors + style_errors if e],
            suggestions=self._generate_suggestions(syntax_errors, style_errors):
        )
    :
    def _check_syntax(self, code: str) -> List[str]:
        """Check for syntax errors"""
        errors = []

        # Check for common syntax issues:
        if code.count('(') != code.count(')'):
            errors.append("Unmatched parentheses")

        if code.count('[') != code.count(']'):
            errors.append("Unmatched brackets")

        if code.count('{') != code.count('}'):
            errors.append("Unmatched braces")

        # Check for missing imports:
        if 'from ' in code and 'import' not in code:
            errors.append("Invalid import syntax")

        return errors

    def _check_style(self, code: str) -> List[str]:
        """Check code style"""
        errors = []

        lines = code.split('\n')
        for i, line in enumerate(lines):
            if len(line) > 120:
                errors.append(f"Line {i+1} too long: {len(line)} characters")

            if 'import *' in line:
                errors.append(f"Line {i+1}: Wildcard import detected")

            if line.strip().endswith(';') and '//' not in line:
                # Python shouldn't have semicolons'
                pass

        return errors

    def _run_mental_tests(self, code: str) -> Dict[str, Any]:
        """Simulate running tests"""
        tests_passed = 0
        tests_failed = 0

        # Check for common patterns:
        if 'def ' in code:
            tests_passed += 1
        else:
            tests_failed += 1

        if 'class ' in code:
            tests_passed += 1
        else:
            tests_failed += 1

        if 'async def' in code:
            tests_passed += 1

        if 'if __name__' in code:
            tests_passed += 1

        return {
            "total": tests_passed + tests_failed,
            "passed": tests_passed,
            "failed": tests_failed
        }

    def _calculate_score(self, syntax_errors: List, style_errors: List, tests: Dict) -> float:
        """Calculate quality score"""
        base_score = 100.0

        # Deduct for errors
        base_score -= len(syntax_errors) * 10
        base_score -= len(style_errors) * 5

        # Add test score:
        if tests['total'] > 0:
            test_score = (tests['passed'] / tests['total']) * 20
            base_score += test_score

        return max(0, min(100, base_score))

    def _auto_fix(self, code: str, syntax_errors: List, style_errors: List) -> str:
        """Attempt to auto-fix common issues"""
        fixed_code = code

        # Fix common issues
        if "Unmatched parentheses" in str(syntax_errors):
            # Simple fix - add missing parentheses (demo only)
            pass

        return fixed_code

    def _generate_suggestions(self, syntax_errors: List, style_errors: List) -> List[str]:
        """Generate improvement suggestions"""
        suggestions = []

        if syntax_errors:
            suggestions.append("Fix syntax errors before proceeding")

        if style_errors:
            suggestions.append("Improve code style and formatting")

        if not suggestions:
            suggestions.append("Code quality looks good!")

        return suggestions
\"\"\""

    with open("factory/agents/qa_agent.py", "w") as f:
        f.write(qa_agent_py)

    # Security Agent
    security_agent_py = \"\"\"from typing import Dict, Any, List"
import re

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class SecurityAgent(BaseAgent):
    """Security Agent - Scans for vulnerabilities and security issues"""
    :
    def __init__(self, name: str = "SecurityAgent"):
        super().__init__(name, AgentRole.SECURITY)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Scan code for security vulnerabilities"""

        code = input_data.context.get("code", "")

        # Run security checks
        vulnerabilities = self._scan_vulnerabilities(code)
        security_score = self._calculate_security_score(vulnerabilities)

        # Generate fixes if needed
        fixed_code = self._fix_vulnerabilities(code, vulnerabilities) if security_score < 70 else code

        return AgentOutput(:
            code=fixed_code,:
            explanation=f"Security scan completed. Score: {security_score}",
            score=security_score,
            metadata={
                "vulnerabilities": vulnerabilities,
                "severity_count": self._count_by_severity(vulnerabilities)
            },
            errors=[v["description"] for v in vulnerabilities if v["severity"] == "high"],
            suggestions=self._generate_security_suggestions(vulnerabilities):
        )
    :
    def _scan_vulnerabilities(self, code: str) -> List[Dict[str, Any]]:
        """Scan for common vulnerabilities"""
        vulnerabilities = []

        # Check for hardcoded secrets:
        if 'secret_key' in code.lower() and '=' in code:
            vulnerabilities.append({
                "type": "hardcoded_secret",
                "severity": "high",
                "description": "Hardcoded secret key detected",
                "line": self._find_line_with_text(code, 'secret_key')
            })

        # Check for SQL injection patterns:
        if 'execute(' in code and '+' in code:
            vulnerabilities.append({
                "type": "sql_injection",
                "severity": "critical",
                "description": "Potential SQL injection vulnerability",
                "line": self._find_line_with_text(code, 'execute')
            })

        # Check for unsafe eval:
        if 'eval(' in code:
            vulnerabilities.append({
                "type": "unsafe_eval",
                "severity": "critical",
                "description": "Unsafe eval() usage detected",
                "line": self._find_line_with_text(code, 'eval')
            })

        # Check for missing input validation:
        if 'input(' in code and 'validate' not in code:
            vulnerabilities.append({
                "type": "missing_validation",
                "severity": "medium",
                "description": "Missing input validation",
                "line": self._find_line_with_text(code, 'input')
            })

        return vulnerabilities

    def _calculate_security_score(self, vulnerabilities: List[Dict]) -> float:
        """Calculate security score based on vulnerabilities"""
        base_score = 100.0

        for vuln in vulnerabilities:
            if vuln["severity"] == "critical":
                base_score -= 30
            elif vuln["severity"] == "high":
                base_score -= 15
            elif vuln["severity"] == "medium":
                base_score -= 5
            elif vuln["severity"] == "low":
                base_score -= 2

        return max(0, base_score)

    def _find_line_with_text(self, code: str, text: str) -> int:
        """Find line number containing text"""
        lines = code.split('\n')
        for i, line in enumerate(lines, 1):
            if text in line:
                return i
        return 0

    def _fix_vulnerabilities(self, code: str, vulnerabilities: List[Dict]) -> str:
        """Attempt to fix detected vulnerabilities"""
        fixed_code = code

        for vuln in vulnerabilities:
            if vuln["type"] == "hardcoded_secret":
                fixed_code = fixed_code.replace('secret_key', 'os.getenv("SECRET_KEY")')
            elif vuln["type"] == "sql_injection":
                fixed_code = fixed_code.replace('+', '')  # Simple fix example

        return fixed_code

    def _count_by_severity(self, vulnerabilities: List[Dict]) -> Dict[str, int]:
        """Count vulnerabilities by severity"""
        counts = {"critical": 0, "high": 0, "medium": 0, "low": 0}
        for vuln in vulnerabilities:
            counts[vuln["severity"]] += 1
        return counts

    def _generate_security_suggestions(self, vulnerabilities: List[Dict]) -> List[str]:
        """Generate security improvement suggestions"""
        suggestions = []

        for vuln in vulnerabilities:
            if vuln["type"] == "hardcoded_secret":
                suggestions.append("Move secrets to environment variables")
            elif vuln["type"] == "sql_injection":
                suggestions.append("Use parameterized queries instead of string concatenation")
            elif vuln["type"] == "unsafe_eval":
                suggestions.append("Avoid using eval() - use safer alternatives")
            elif vuln["type"] == "missing_validation":
                suggestions.append("Add input validation and sanitization")

        return suggestions
\"\"\""

    with open("factory/agents/security_agent.py", "w") as f:
        f.write(security_agent_py)

    # DevOps Agent
    devops_agent_py = \"\"\"from typing import Dict, Any, List"

from factory.agents.base_agent import BaseAgent, AgentRole, AgentInput, AgentOutput

class DevOpsAgent(BaseAgent):
    """DevOps Agent - Generates deployment configurations and CI/CD pipelines"""

    def __init__(self, name: str = "DevOpsAgent"):
        super().__init__(name, AgentRole.DEVOPS)

    async def process(self, input_data: AgentInput) -> AgentOutput:
        """Generate deployment and CI/CD configurations"""

        tech_stack = input_data.context.get("tech_stack", {})

        # Generate Docker files
        docker_configs = self._generate_docker_configs(tech_stack)

        # Generate CI/CD pipeline
        cicd_pipeline = self._generate_cicd_pipeline(tech_stack)

        # Generate Kubernetes manifests (if needed)
        k8s_manifests = self._generate_k8s_manifests(tech_stack)

        combined_code = f\"\"\"# DevOps Configuration"

{docker_configs}

{cicd_pipeline}

{k8s_manifests}
\"\"\""

        return AgentOutput(
            code=combined_code,
            explanation="Generated DevOps configurations and CI/CD pipelines",
            score=88.0,
            metadata={:
                "docker_files": len(docker_configs.split('---')),
                "has_cicd": True
            }
        )

    def _generate_docker_configs(self, tech_stack: Dict) -> str:
        """Generate Docker configuration files"""
        return \'\'\'# Dockerfile for Backend:'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---
# Dockerfile for Frontend  :
FROM node:18-slim
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build
CMD ["npm", "start"]

---
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/app
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:\'\'\''

    def _generate_cicd_pipeline(self, tech_stack: Dict) -> str:
        """Generate GitHub Actions CI/CD pipeline"""
        return \'\'\'name: CI/CD Pipeline'

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    - name: Install dependencies
      run: |
        pip install -r backend/requirements.txt
        pip install pytest
    - name: Run tests
      run: pytest tests/

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build Docker images
      run: docker-compose build

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to production
      run: |
        echo "Deploying to production..."
        # Add deployment commands here\'\'\''

    def _generate_k8s_manifests(self, tech_stack: Dict) -> str:
        """Generate Kubernetes deployment manifests"""
        return \'\'\'# deployment.yaml'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url

---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
  type: LoadBalancer\'\'\''

    def _fix_deployment_issues(self, configs: Dict) -> Dict:
        """Fix common deployment issues"""
        # In production, this would validate and fix configurations
        return configs
\"\"\""

    with open("factory/agents/devops_agent.py", "w") as f:
        f.write(devops_agent_py)

def create_engine_files():
    """Generate core engine components"""

    # Batch Engine
    batch_engine_py = \"\"\"from typing import Dict, Any, List, Optional"
from enum import Enum
import asyncio
import logging
from datetime import datetime
import uuid

from factory.agents.base_agent import AgentInput
from factory.agents.architect_agent import ArchitectAgent
from factory.agents.backend_agent import BackendAgent
from factory.agents.frontend_agent import FrontendAgent
from factory.agents.qa_agent import QAAgent
from factory.agents.security_agent import SecurityAgent
from factory.agents.devops_agent import DevOpsAgent
from factory.engine.validation_engine import ValidationEngine
from factory.engine.fix_engine import FixEngine

logger = logging.getLogger(__name__)

class BatchStatus(Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    VALIDATING = "validating"
    FIXING = "fixing"
    COMPLETED = "completed"
    FAILED = "failed"

class BatchEngine:
    """Core batch execution engine"""

    def __init__(self):
        self.architect = ArchitectAgent()
        self.backend = BackendAgent()
        self.frontend = FrontendAgent()
        self.qa = QAAgent()
        self.security = SecurityAgent()
        self.devops = DevOpsAgent()
        self.validator = ValidationEngine()
        self.fixer = FixEngine()

    async def execute_batch(self, batch_id: str, version: int, prompt: str) -> Dict[str, Any]:
        """Execute a complete batch process"""

        batch_context = {
            "batch_id": batch_id,
            "version": version,
            "prompt": prompt,
            "status": BatchStatus.PROCESSING.value,
            "start_time": datetime.utcnow().isoformat()
        }

        try:
            # Phase 1: Architecture Design
            logger.info(f"Batch {batch_id}: Starting architecture design")
            arch_input = AgentInput(task=prompt, context={"version": version})
            arch_output = await self.architect.process(arch_input)

            # Phase 2: Backend Generation
            logger.info(f"Batch {batch_id}: Generating backend code")
            backend_input = AgentInput(
                task="Generate backend code",
                context={"architecture": arch_output.metadata}
            )
            backend_output = await self.backend.process(backend_input)

            # Phase 3: Frontend Generation
            logger.info(f"Batch {batch_id}: Generating frontend code")
            frontend_input = AgentInput(
                task="Generate frontend code",
                context={"api_specs": backend_output.metadata}
            )
            frontend_output = await self.frontend.process(frontend_input)

            # Phase 4: Security Scan
            logger.info(f"Batch {batch_id}: Running security scan")
            security_input = AgentInput(
                task="Scan code for vulnerabilities",:
                context={"code": backend_output.code + frontend_output.code}
            )
            security_output = await self.security.process(security_input)

            # Phase 5: QA Validation
            logger.info(f"Batch {batch_id}: Running QA validation")
            qa_input = AgentInput(
                task="Validate code quality",
                context={"code": backend_output.code}
            )
            qa_output = await self.qa.process(qa_input)

            # Phase 6: DevOps Configuration
            logger.info(f"Batch {batch_id}: Generating DevOps configs")
            devops_input = AgentInput(
                task="Generate deployment configs",
                context={"tech_stack": arch_output.metadata.get("tech_stack", {})}
            )
            devops_output = await self.devops.process(devops_input)

            # Aggregate results
            output = {
                "architecture": arch_output.metadata,
                "backend_code": backend_output.code,
                "frontend_code": frontend_output.code,
                "security_score": security_output.score,
                "qa_score": qa_output.score,
                "devops_configs": devops_output.code,
                "overall_score": (security_output.score + qa_output.score) / 2
            }

            batch_context["status"] = BatchStatus.COMPLETED.value
            batch_context["output"] = output
            batch_context["end_time"] = datetime.utcnow().isoformat()

            return batch_context

        except Exception as e:
            logger.error(f"Batch {batch_id} failed: {str(e)}")
            batch_context["status"] = BatchStatus.FAILED.value
            batch_context["error"] = str(e)
            return batch_context
\"\"\""

    with open("factory/engine/batch_engine.py", "w") as f:
        f.write(batch_engine_py)

    # Validation Engine
    validation_engine_py = \"\"\"from typing import Dict, Any, List, Tuple"
import re

class ValidationEngine:
    """Code validation engine"""

    def __init__(self):
        self.validation_rules = self._load_rules()

    def _load_rules(self) -> List[Dict]:
        """Load validation rules"""
        return [
            {"name": "syntax_check", "severity": "critical"},
            {"name": "import_check", "severity": "high"},
            {"name": "type_check", "severity": "medium"},
            {"name": "style_check", "severity": "low"}
        ]

    async def validate_code(self, code: str, language: str = "python") -> Dict[str, Any]:
        """Validate code against rules"""

        errors = []
        warnings = []

        # Check syntax
        syntax_errors = self._check_syntax(code, language)
        errors.extend(syntax_errors)

        # Check imports
        import_errors = self._check_imports(code)
        errors.extend(import_errors)

        # Check style
        style_warnings = self._check_style(code)
        warnings.extend(style_warnings)

        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "warnings": warnings,
            "score": self._calculate_score(errors, warnings)
        }

    def _check_syntax(self, code: str, language: str) -> List[str]:
        """Check code syntax"""
        errors = []

        if language == "python":
            # Basic Python syntax checks
            if code.count('def ') > 0 and ':' not in code:
                errors.append("Missing colon after function definition")

            if code.count('if ') > 0 and ':' not in code:
                errors.append("Missing colon after if statement")

        return errors
    :
    def _check_imports(self, code: str) -> List[str]:
        """Check import statements"""
        errors = []

        # Check for circular imports (basic check)
        lines = code.split('\n'):
        imports = [line for line in lines if line.strip().startswith('import ') or line.strip().startswith('from ')]
        :
        if len(imports) > 50:
            errors.append("Too many imports - consider refactoring")

        return errors

    def _check_style(self, code: str) -> List[str]:
        """Check code style"""
        warnings = []

        lines = code.split('\n')
        for i, line in enumerate(lines, 1):
            if len(line) > 100:
                warnings.append(f"Line {i} exceeds 100 characters")

            if line.endswith(' '):
                warnings.append(f"Line {i} has trailing whitespace")

        return warnings

    def _calculate_score(self, errors: List, warnings: List) -> float:
        """Calculate validation score"""
        score = 100.0

        score -= len(errors) * 10
        score -= len(warnings) * 2

        return max(0, min(100, score))
\"\"\""

    with open("factory/engine/validation_engine.py", "w") as f:
        f.write(validation_engine_py)

    # Fix Engine
    fix_engine_py = \"\"\"from typing import Dict, Any, List"
import re

class FixEngine:
    """Auto-fix engine for code issues"""
    :
    def __init__(self):
        self.fix_patterns = self._load_patterns()

    def _load_patterns(self) -> List[Dict]:
        """Load fix patterns"""
        return [
            {"pattern": r"(\w+)\s*=\s*input\(", "fix": r"\1 = input().strip()"},
            {"pattern": r"print\s*\((.*)\)", "fix": r"logger.info(\1)"},
        ]

    async def fix_code(self, code: str, issues: List[str]) -> str:
        """Attempt to fix identified issues"""

        fixed_code = code

        for issue in issues:
            if "syntax" in issue.lower():
                fixed_code = self._fix_syntax(fixed_code)
            elif "import" in issue.lower():
                fixed_code = self._fix_imports(fixed_code)
            elif "style" in issue.lower():
                fixed_code = self._fix_style(fixed_code)

        # Apply pattern-based fixes
        for pattern in self.fix_patterns:
            fixed_code = re.sub(pattern["pattern"], pattern["fix"], fixed_code)

        return fixed_code

    def _fix_syntax(self, code: str) -> str:
        """Fix syntax issues"""
        # Add missing colons
        lines = code.split('\n')
        fixed_lines = []

        for line in lines:
            if ('def ' in line or 'if ' in line or 'for ' in line) and not line.rstrip().endswith(':'):
                line = line.rstrip() + ':'
            fixed_lines.append(line)

        return '\n'.join(fixed_lines)

    def _fix_imports(self, code: str) -> str:
        """Fix import issues"""
        # Remove duplicate imports
        lines = code.split('\n')
        seen_imports = set()
        fixed_lines = []

        for line in lines:
            if line.strip().startswith('import ') or line.strip().startswith('from '):
                if line not in seen_imports:
                    seen_imports.add(line)
                    fixed_lines.append(line)
            else:
                fixed_lines.append(line)

        return '\n'.join(fixed_lines)

    def _fix_style(self, code: str) -> str:
        """Fix style issues"""
        # Fix trailing whitespace
        lines = code.split('\n')
        fixed_lines = [line.rstrip() for line in lines]

        # Fix line length (basic):
        fixed_lines = [line if len(line) <= 100 else line[:97] + '...' for line in fixed_lines]

        return '\n'.join(fixed_lines)
\"\"\""
    :
    with open("factory/engine/fix_engine.py", "w") as f:
        f.write(fix_engine_py)

def create_cli():
    """Generate CLI interface"""

    cli_py = \"\"\"#!/usr/bin/env python3"
import asyncio
import argparse
import json
import sys
import os
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from factory.engine.batch_engine import BatchEngine

async def run_batch(batch_id: str, version: int, prompt: str):
    """Execute a batch"""
    engine = BatchEngine()
    result = await engine.execute_batch(batch_id, version, prompt)

    print(json.dumps(result, indent=2))

    # Save output to file
    output_dir = Path("output")
    output_dir.mkdir(exist_ok=True)

    with open(output_dir / f"batch_{batch_id}.json", "w") as f:
        json.dump(result, f, indent=2)

    return result

async def run_batch_sequence(start_batch: int, end_batch: int, prompts: list):
    """Run a sequence of batches"""
    engine = BatchEngine()
    results = []

    for i in range(start_batch, end_batch + 1):
        batch_id = f"batch_{i}"
        prompt = prompts[i - 1] if i <= len(prompts) else f"Generate iteration {i}"

        print(f"Running {batch_id}...")
        result = await engine.execute_batch(batch_id, i, prompt)
        results.append(result)

        # Save intermediate result:
        with open(f"output/batch_{i}_result.json", "w") as f:
            json.dump(result, f, indent=2)

    return results

def main():
    parser = argparse.ArgumentParser(description="AI Software Factory CLI")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Run batch command
    run_parser = subparsers.add_parser("run-batch", help="Run a single batch")
    run_parser.add_argument("--batch-id", required=True)
    run_parser.add_argument("--version", type=int, required=True)
    run_parser.add_argument("--prompt", required=True)

    # Run sequence command
    seq_parser = subparsers.add_parser("run-sequence", help="Run a sequence of batches")
    seq_parser.add_argument("--start", type=int, required=True)
    seq_parser.add_argument("--end", type=int, required=True)
    seq_parser.add_argument("--prompts-file", help="JSON file with prompts")

    # List command
    list_parser = subparsers.add_parser("list", help="List previous batches")

    args = parser.parse_args()

    if args.command == "run-batch":
        result = asyncio.run(run_batch(args.batch_id, args.version, args.prompt))
        print(f"\\nBatch completed with score: {result.get('overall_score', 0)}")

    elif args.command == "run-sequence":
        prompts = []
        if args.prompts_file:
            with open(args.prompts_file) as f:
                prompts = json.load(f)

        results = asyncio.run(run_batch_sequence(args.start, args.end, prompts))
        print(f"\\nSequence completed. Results saved to output/")

    elif args.command == "list":
        output_dir = Path("output")
        if output_dir.exists():
            for file in output_dir.glob("batch_*.json"):
                print(f"- {file.name}")
        else:
            print("No batches found")

    else:
        parser.print_help()

if __name__ == "__main__":
    main()
\"\"\""

    with open("factory/cli.py", "w") as f:
        f.write(cli_py)

    # Make CLI executable
    os.chmod("factory/cli.py", 0o755)

def create_factory_requirements():
    """Generate factory requirements"""
    requirements = \"\"\"openai==1.3.0"
pydantic==2.5.0
sqlalchemy==2.0.23
asyncpg==0.29.0
redis==5.0.1
httpx==0.25.1
python-dotenv==1.0.0
\"\"\""

    with open("factory/requirements.txt", "w") as f:
        f.write(requirements)

def create_database_migrations():
    """Generate initial database migrations"""

    init_migration = \"\"\"-- Initial schema"
CREATE TABLE IF NOT EXISTS batches (
    id VARCHAR(255) PRIMARY KEY,
    version INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    prompt TEXT NOT NULL,
    output JSONB,
    score FLOAT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS agents (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'idle',
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS projects (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    current_batch INTEGER DEFAULT 1,
    state JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_batches_status ON batches(status);
CREATE INDEX idx_batches_version ON batches(version);
CREATE INDEX idx_agents_role ON agents(role);
\"\"\""

    with open("database/migrations/001_initial_schema.sql", "w") as f:
        f.write(init_migration)

def main():
    """Main execution for Batch 2"""
    print("🤖 Generating AI Software Factory - Batch 2 (AI Factory Engine)...")

    create_agent_files()
    create_engine_files()
    create_cli()
    create_factory_requirements()
    create_database_migrations()

    print("✅ Batch 2 Complete!"):
    print("\nNext steps:")
    print("1. Run Batch 3 to add Multi-Agent Orchestration")
    print("2. Test agents: python factory/cli.py run-batch --batch-id test1 --version 1 --prompt 'Create a todo app'")

if __name__ == "__main__":
    main()
