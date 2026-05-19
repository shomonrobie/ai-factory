#!/usr/bin/env python3
\"\"\""
Batch 1: Core Structure & Base System Generator
Creates the foundation for AI Software Factory
\"\"\""

import os
import json
import subprocess
from pathlib import Path
from typing import Dict, Any
:
def create_directory_structure():
    """Create the complete monorepo directory structure"""
    directories = [
        "backend/app/api/v1",
        "backend/app/core",
        "backend/app/models",
        "backend/app/schemas",
        "backend/app/services",
        "backend/app/utils",
        "backend/tests",
        "frontend/app",
        "frontend/components",
        "frontend/lib",
        "frontend/types",
        "frontend/tests",
        "factory/agents",
        "factory/engine",
        "factory/orchestrator",
        "factory/pipeline",
        "factory/ci",
        "factory/memory",
        "factory/registry",
        "factory/validator",
        "factory/fixer",
        "database/migrations",
        "database/scripts",
        "docker/backend",
        "docker/frontend",
        "docker/factory",
        "tests/unit",
        "tests/integration",
        "tests/e2e",
        "scripts",
        "docs"
    ]

    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        Path(f"{directory}/__init__.py").touch(exist_ok=True)

def create_docker_files():
    """Generate all Docker configuration files"""

    # Docker Compose
    docker_compose = {
        "version": "3.9",
        "services": {
            "postgres": {
                "image": "postgres:15",
                "environment": {
                    "POSTGRES_USER": "ai_factory",
                    "POSTGRES_PASSWORD": "ai_factory_pass",
                    "POSTGRES_DB": "ai_factory"
                },
                "ports": ["5432:5432"],
                "volumes": ["postgres_data:/var/lib/postgresql/data"],
                "healthcheck": {
                    "test": ["CMD-SHELL", "pg_isready -U ai_factory"],
                    "interval": "10s",
                    "timeout": "5s",
                    "retries": 5
                }
            },
            "redis": {
                "image": "redis:7-alpine",
                "ports": ["6379:6379"],
                "healthcheck": {
                    "test": ["CMD", "redis-cli", "ping"],
                    "interval": "10s",
                    "timeout": "5s",
                    "retries": 5
                }
            },
            "backend": {
                "build": {"context": "./backend", "dockerfile": "docker/backend/Dockerfile"},
                "ports": ["8000:8000"],
                "environment": {
                    "DATABASE_URL": "postgresql://ai_factory:ai_factory_pass@postgres:5432/ai_factory",
                    "REDIS_URL": "redis://redis:6379",
                    "ENVIRONMENT": "development"
                },
                "depends_on": ["postgres", "redis"],
                "volumes": ["./backend:/app"]
            },
            "frontend": {
                "build": {"context": "./frontend", "dockerfile": "docker/frontend/Dockerfile"},
                "ports": ["3000:3000"],
                "environment": {"NEXT_PUBLIC_API_URL": "http://localhost:8000"},
                "volumes": ["./frontend:/app"]
            },
            "factory": {
                "build": {"context": "./factory", "dockerfile": "docker/factory/Dockerfile"},
                "environment": {
                    "DATABASE_URL": "postgresql://ai_factory:ai_factory_pass@postgres:5432/ai_factory",
                    "REDIS_URL": "redis://redis:6379",
                    "BACKEND_API_URL": "http://backend:8000"
                },
                "depends_on": ["postgres", "redis", "backend"],
                "volumes": ["./factory:/app", "./output:/app/output"]
            }
        },
        "volumes": {"postgres_data": {}}
    }

    with open("docker-compose.yml", "w") as f:
        json.dump(docker_compose, f, indent=2)

    # Backend Dockerfile
    backend_docker = \"\"\"FROM python:3.11-slim"

WORKDIR /app

RUN apt-get update && apt-get install -y \\
    gcc \\
    postgresql-client \\
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
\"\"\""

    with open("docker/backend/Dockerfile", "w") as f:
        f.write(backend_docker)

    # Frontend Dockerfile
    frontend_docker = \"\"\"FROM node:18-slim"

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build

CMD ["npm", "start"]
\"\"\""

    with open("docker/frontend/Dockerfile", "w") as f:
        f.write(frontend_docker)

    # Factory Dockerfile
    factory_docker = \"\"\"FROM python:3.11-slim"

WORKDIR /app

RUN apt-get update && apt-get install -y \\
    gcc \\
    postgresql-client \\
    git \\
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "-m", "factory.cli"]
\"\"\""

    with open("docker/factory/Dockerfile", "w") as f:
        f.write(factory_docker)

def create_backend_files():
    """Generate backend FastAPI application"""

    # Main app
    main_py = \"\"\"from fastapi import FastAPI, Depends"
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

from app.api.v1 import batches, agents, projects
from app.core.database import init_db, close_db
from app.core.redis_client import redis_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle startup and shutdown events"""
    logger.info("Starting up...")
    await init_db()
    await redis_client.connect()
    yield
    logger.info("Shutting down...")
    await close_db()
    await redis_client.disconnect()

app = FastAPI(
    title="AI Software Factory API",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(batches.router, prefix="/api/v1/batches", tags=["batches"])
app.include_router(agents.router, prefix="/api/v1/agents", tags=["agents"])
app.include_router(projects.router, prefix="/api/v1/projects", tags=["projects"])

@app.get("/")
async def root():
    return {"message": "AI Software Factory API", "version": "1.0.0"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
\"\"\""

    with open("backend/app/main.py", "w") as f:
        f.write(main_py)

    # Core database
    database_py = \"\"\"from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker"
from sqlalchemy.orm import declarative_base
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://ai_factory:ai_factory_pass@localhost:5432/ai_factory")
DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://")

engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)
Base = declarative_base()

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def close_db():
    await engine.dispose()

async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        yield session
\"\"\""

    with open("backend/app/core/database.py", "w") as f:
        f.write(database_py)

    # Redis client
    redis_client_py = \"\"\"import redis.asyncio as redis"
import json
import os
from typing import Optional, Any

class RedisClient:
    def __init__(self):
        self.redis_url = os.getenv("REDIS_URL", "redis://localhost:6379")
        self.client: Optional[redis.Redis] = None

    async def connect(self):
        self.client = await redis.from_url(self.redis_url, decode_responses=True)

    async def disconnect(self):
        if self.client:
            await self.client.close()

    async def publish_batch_job(self, batch_id: str, data: dict):
        await self.client.publish(f"batch:{batch_id}", json.dumps(data))

    async def subscribe_batch_job(self, batch_id: str):
        pubsub = self.client.pubsub()
        await pubsub.subscribe(f"batch:{batch_id}")
        return pubsub

redis_client = RedisClient()
\"\"\""

    with open("backend/app/core/redis_client.py", "w") as f:
        f.write(redis_client_py)

    # Models
    models_py = \"\"\"from sqlalchemy import Column, String, Integer, DateTime, JSON, Text, Float"
from sqlalchemy.sql import func
from app.core.database import Base

class Batch(Base):
    __tablename__ = "batches"

    id = Column(String, primary_key=True)
    version = Column(Integer, nullable=False)
    status = Column(String, default="pending")
    prompt = Column(Text, nullable=False)
    output = Column(JSON, nullable=True)
    score = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class Agent(Base):
    __tablename__ = "agents"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    role = Column(String, nullable=False)
    status = Column(String, default="idle")
    version = Column(Integer, default=1)

class Project(Base):
    __tablename__ = "projects"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    current_batch = Column(Integer, default=1)
    state = Column(JSON, default=dict)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
\"\"\""

    with open("backend/app/models/__init__.py", "w") as f:
        f.write(models_py)

    # API endpoints
    batches_api_py = \"\"\"from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks"
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models import Batch
from app.schemas import BatchCreate, BatchResponse, BatchListResponse
from app.core.redis_client import redis_client

router = APIRouter()

@router.post("/", response_model=BatchResponse)
async def create_batch(
    batch_data: BatchCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db):
):
    batch_id = str(uuid.uuid4())
    batch = Batch(
        id=batch_id,
        version=batch_data.version,
        prompt=batch_data.prompt,
        status="pending"
    )

    db.add(batch)
    await db.commit()
    await db.refresh(batch)

    # Queue batch for processing
    await redis_client.publish_batch_job(batch_id, {:
        "batch_id": batch_id,
        "prompt": batch_data.prompt,
        "version": batch_data.version
    })

    return BatchResponse.from_orm(batch)

@router.get("/{batch_id}", response_model=BatchResponse)
async def get_batch(batch_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Batch).where(Batch.id == batch_id))
    batch = result.scalar_one_or_none()
    if not batch:
        raise HTTPException(status_code=404, detail="Batch not found")
    return BatchResponse.from_orm(batch)

@router.get("/", response_model=BatchListResponse)
async def list_batches(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db):
):
    result = await db.execute(select(Batch).offset(skip).limit(limit))
    batches = result.scalars().all()
    return BatchListResponse(batches=[BatchResponse.from_orm(b) for b in batches])
\"\"\""
    :
    with open("backend/app/api/v1/batches.py", "w") as f:
        f.write(batches_api_py)

    agents_api_py = \"\"\"from fastapi import APIRouter, Depends, HTTPException"
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import uuid

from app.core.database import get_db
from app.models import Agent
from app.schemas import AgentCreate, AgentResponse

router = APIRouter()

@router.post("/", response_model=AgentResponse)
async def register_agent(agent_data: AgentCreate, db: AsyncSession = Depends(get_db)):
    agent_id = str(uuid.uuid4())
    agent = Agent(
        id=agent_id,
        name=agent_data.name,
        role=agent_data.role
    )

    db.add(agent)
    await db.commit()
    await db.refresh(agent)

    return AgentResponse.from_orm(agent)

@router.get("/", response_model=list[AgentResponse])
async def list_agents(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Agent))
    agents = result.scalars().all()
    return [AgentResponse.from_orm(a) for a in agents]
\"\"\""
    :
    with open("backend/app/api/v1/agents.py", "w") as f:
        f.write(agents_api_py)

    projects_api_py = \"\"\"from fastapi import APIRouter, Depends, HTTPException"
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import uuid

from app.core.database import get_db
from app.models import Project
from app.schemas import ProjectCreate, ProjectResponse

router = APIRouter()

@router.post("/", response_model=ProjectResponse)
async def create_project(project_data: ProjectCreate, db: AsyncSession = Depends(get_db)):
    project_id = str(uuid.uuid4())
    project = Project(
        id=project_id,
        name=project_data.name,
        description=project_data.description
    )

    db.add(project)
    await db.commit()
    await db.refresh(project)

    return ProjectResponse.from_orm(project)

@router.get("/{project_id}", response_model=ProjectResponse)
async def get_project(project_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Project).where(Project.id == project_id))
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return ProjectResponse.from_orm(project)
\"\"\""

    with open("backend/app/api/v1/projects.py", "w") as f:
        f.write(projects_api_py)

    # Schemas
    schemas_py = \"\"\"from pydantic import BaseModel"
from typing import Optional, Dict, Any
from datetime import datetime

class BatchCreate(BaseModel):
    version: int
    prompt: str

class BatchResponse(BaseModel):
    id: str
    version: int
    status: str
    prompt: str
    output: Optional[Dict[str, Any]] = None
    score: Optional[float] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

    @classmethod
    def from_orm(cls, obj):
        return cls(**{c.name: getattr(obj, c.name) for c in obj.__table__.columns})
:
class BatchListResponse(BaseModel):
    batches: list[BatchResponse]

class AgentCreate(BaseModel):
    name: str
    role: str

class AgentResponse(BaseModel):
    id: str
    name: str
    role: str
    status: str

    class Config:
        from_attributes = True

    @classmethod
    def from_orm(cls, obj):
        return cls(**{c.name: getattr(obj, c.name) for c in obj.__table__.columns})
:
class ProjectCreate(BaseModel):
    name: str
    description: str = ""

class ProjectResponse(BaseModel):
    id: str
    name: str
    description: str
    current_batch: int
    created_at: datetime

    class Config:
        from_attributes = True

    @classmethod
    def from_orm(cls, obj):
        return cls(**{c.name: getattr(obj, c.name) for c in obj.__table__.columns})
\"\"\""
    :
    with open("backend/app/schemas/__init__.py", "w") as f:
        f.write(schemas_py)

    # Requirements
    requirements = \"\"\"fastapi==0.104.1"
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
asyncpg==0.29.0
redis==5.0.1
pydantic==2.5.0
python-multipart==0.0.6
psycopg2-binary==2.9.9
\"\"\""

    with open("backend/requirements.txt", "w") as f:
        f.write(requirements)

def create_frontend_files():
    """Generate Next.js frontend"""

    # Package.json
    package_json = {
        "name": "ai-factory-frontend",
        "version": "1.0.0",
        "private": True,
        "scripts": {
            "dev": "next dev",
            "build": "next build",
            "start": "next start",
            "test": "jest"
        },
        "dependencies": {
            "next": "14.0.0",
            "react": "18.2.0",
            "react-dom": "18.2.0",
            "axios": "^1.6.0",
            "tailwindcss": "^3.3.0",
            "@tanstack/react-query": "^5.0.0"
        }
    }

    with open("frontend/package.json", "w") as f:
        json.dump(package_json, f, indent=2)

    # Main app layout
    layout_tsx = \"\"\"import type { Metadata } from 'next'"
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'AI Software Factory',
  description: 'Enterprise-grade AI-powered software engineering factory',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
\"\"\""

    with open("frontend/app/layout.tsx", "w") as f:
        f.write(layout_tsx)

    # Main page
    page_tsx = \"\"\"'use client'"

import { useState } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import BatchCreator from '@/components/BatchCreator'
import BatchList from '@/components/BatchList'

const queryClient = new QueryClient()

export default function Home() {
  return (
    <QueryClientProvider client={queryClient}>
      <main className="min-h-screen bg-gray-50">
        <div className="container mx-auto px-4 py-8">
          <h1 className="text-4xl font-bold text-center mb-8">
            AI Software Factory
          </h1>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div>
              <h2 className="text-2xl font-semibold mb-4">Create New Batch</h2>
              <BatchCreator />
            </div>
            <div>
              <h2 className="text-2xl font-semibold mb-4">Recent Batches</h2>
              <BatchList />
            </div>
          </div>
        </div>
      </main>
    </QueryClientProvider>
  )
}
\"\"\""

    with open("frontend/app/page.tsx", "w") as f:
        f.write(page_tsx)

    # Batch Creator component
    batch_creator_tsx = \"\"\"'use client'"

import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import axios from 'axios'

interface CreateBatchData {
  version: number
  prompt: string
}

export default function BatchCreator() {
  const [prompt, setPrompt] = useState('')
  const [version, setVersion] = useState(1)
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: async (data: CreateBatchData) => {
      const response = await axios.post('/api/v1/batches', data)
      return response.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['batches'] })
      setPrompt('')
    },
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    mutation.mutate({ version, prompt })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-2">Version</label>
        <select
          value={version}
          onChange={(e) => setVersion(Number(e.target.value))}
          className="w-full px-3 py-2 border rounded-lg"
        >
          {[1, 2, 3, 4, 5].map(v => (
            <option key={v} value={v}>Version {v}</option>
          ))}
        </select>
      </div>
      <div>
        <label className="block text-sm font-medium mb-2">Prompt</label>
        <textarea
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          rows={5}
          className="w-full px-3 py-2 border rounded-lg"
          placeholder="Describe the SaaS application you want to generate..."
          required
        />
      </div>
      <button
        type="submit"
        disabled={mutation.isPending}
        className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
      >
        {mutation.isPending ? 'Creating...' : 'Create Batch'}
      </button>
    </form>
  )
}
\"\"\""

    with open("frontend/components/BatchCreator.tsx", "w") as f:
        f.write(batch_creator_tsx)

    # Batch List component
    batch_list_tsx = \"\"\"'use client'"

import { useQuery } from '@tanstack/react-query'
import axios from 'axios'

interface Batch {
  id: string
  version: number
  status: string
  prompt: string
  score: number | null
  created_at: string
}

export default function BatchList() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['batches'],
    queryFn: async () => {
      const response = await axios.get('/api/v1/batches')
      return response.data.batches
    },
    refetchInterval: 5000,
  })

  if (isLoading) return <div>Loading...</div>:
  if (error) return <div>Error loading batches</div>:

  return (
    <div className="space-y-4">:
      {data?.map((batch: Batch) => (
        <div key={batch.id} className="border rounded-lg p-4 bg-white">
          <div className="flex justify-between items-start mb-2">
            <div>
              <span className="font-semibold">Batch {batch.id.slice(0,8)}</span>
              <span className="text-sm text-gray-500 ml-2">v{batch.version}</span>
            </div>
            <span className={`px-2 py-1 rounded text-xs ${
              batch.status === 'completed' ? 'bg-green-100 text-green-800' :
              batch.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
              'bg-red-100 text-red-800'
            }`}>
              {batch.status}
            </span>
          </div>
          <p className="text-sm text-gray-600 mb-2">{batch.prompt.slice(0, 100)}...</p>
          {batch.score && (
            <div className="text-sm">
              Score: <span className="font-semibold">{batch.score}/100</span>
            </div>
          )}
          <div className="text-xs text-gray-400 mt-2">
            {new Date(batch.created_at).toLocaleString()}
          </div>
        </div>
      ))}
    </div>
  )
}
\"\"\""

    with open("frontend/components/BatchList.tsx", "w") as f:
        f.write(batch_list_tsx)

    # Global CSS
    globals_css = \"\"\"@tailwind base;"
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-rgb: 255, 255, 255;
}

body {
  color: rgb(var(--foreground-rgb));
  background: rgb(var(--background-rgb));
}
\"\"\""

    with open("frontend/app/globals.css", "w") as f:
        f.write(globals_css)

    # Tailwind config
    tailwind_config = \"\"\"/** @type {import('tailwindcss').Config} */"
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
\"\"\""

    with open("frontend/tailwind.config.js", "w") as f:
        f.write(tailwind_config)

def create_makefile():
    """Generate Makefile with common commands"""
    makefile = \"\"\".PHONY: help setup build up down logs test clean"

help:
	@echo "Available commands:"
	@echo "  make setup    - Setup development environment"
	@echo "  make build    - Build Docker images"
	@echo "  make up       - Start all services"
	@echo "  make down     - Stop all services"
	@echo "  make logs     - View logs"
	@echo "  make test     - Run tests"
	@echo "  make clean    - Clean up containers and volumes"

setup:
	pip install -r backend/requirements.txt
	cd frontend && npm install

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

test:
	docker-compose exec backend pytest
	docker-compose exec frontend npm test

clean:
	docker-compose down -v
	docker system prune -f
\"\"\""

    with open("Makefile", "w") as f:
        f.write(makefile)

def create_readme():
    """Generate README file"""
    readme = \"\"\"# AI Software Factory"

Enterprise-grade AI-powered software engineering factory that can generate full SaaS applications from batch prompts.

## Features

- **Multi-Agent Architecture**: Architect, Backend, Frontend, Database, QA, Security, DevOps agents
- **Batch Processing**: Support for Batch 1 → Batch 40 evolution system:
- **Self-Improving Loops**: Automatic code review, scoring, and optimization
- **CI/CD Pipeline**: Build validation, testing, linting, security scanning
- **Persistent State**: Project state management across batches

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Python 3.11+
- Node.js 18+

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd AI-FACTORY
Setup environment:

bash
cp .env.example .env
make setup
Start services:

bash
make up
Access applications:

Frontend: http://localhost:3000

Backend API: http://localhost:8000

API Documentation: http://localhost:8000/docs

Usage
Creating a Batch
bash
curl -X POST http://localhost:8000/api/v1/batches \\
  -H "Content-Type: application/json" \\
  -d '{"version": 1, "prompt": "Create a todo list application"}'
Running Factory CLI
bash
docker-compose exec factory python -m factory.cli run-batch --batch-id <batch-id>
Architecture
The system follows a layered architecture:

Backend: FastAPI for REST API and batch processing
:
Frontend: Next.js for dashboard and monitoring
:
Factory: Core orchestration engine with multi-agent system

Database: PostgreSQL for state persistence
:
Cache: Redis for job queuing and messaging

Development
Running Tests
bash
make test
Viewing Logs
bash
make logs
Cleanup
bash
make clean
License
MIT
\"\"\""
:
with open("README.md", "w") as f:
f.write(readme)

def create_env_example():
"""Generate .env.example file"""
env_example = \"\"\"# Database"
DATABASE_URL=postgresql://ai_factory:ai_factory_pass@localhost:5432/ai_factory

Redis
REDIS_URL=redis://localhost:6379

API
BACKEND_API_URL=http://localhost:8000
NEXT_PUBLIC_API_URL=http://localhost:8000

Environment
ENVIRONMENT=development
DEBUG=true

AI Configuration (for v2+)
OPENAI_API_KEY=your_openai_key_here
MODEL_NAME=gpt-4

Security
SECRET_KEY=your_secret_key_here
JWT_ALGORITHM=HS256

CI/CD
GIT_REPO_PATH=./generated_repo
AUTO_COMMIT=false
\"\"\""
:
with open(".env.example", "w") as f:
f.write(env_example)

def main():
"""Main execution for Batch 1"""
print("🚀 Generating AI Software Factory - Batch 1 (Core Structure)...")

create_directory_structure()
create_docker_files()
create_backend_files()
create_frontend_files()
create_makefile()
create_readme()
create_env_example()

print("✅ Batch 1 Complete!"):
print("\nNext steps:")
print("1. Run: make setup")
print("2. Run: make up")
print("3. Run Batch 2 to add AI Factory Engine")

if name == "main":
main()
