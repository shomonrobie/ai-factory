"""
Batch 1: Base Factory System Foundation
Generates the core infrastructure, monorepo structure, and base services
"""

import os
import json
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Any

class Batch1Generator:
    def __init__(self):
        self.project_root = Path("/app/ai-factory")
        self.backend_dir = self.project_root / "backend"
        self.frontend_dir = self.project_root / "frontend"
        self.factory_dir = self.project_root / "factory"
        self.database_dir = self.project_root / "database"
        self.docker_dir = self.project_root / "docker"
        self.tests_dir = self.project_root / "tests"
        
    def create_directory_structure(self):
        """Create the complete monorepo structure"""
        directories = [
            self.backend_dir / "app" / "api" / "v1",
            self.backend_dir / "app" / "core",
            self.backend_dir / "app" / "models",
            self.backend_dir / "app" / "schemas",
            self.backend_dir / "app" / "services",
            self.backend_dir / "app" / "repositories",
            self.backend_dir / "app" / "workers",
            self.frontend_dir / "src" / "app",
            self.frontend_dir / "src" / "components",
            self.frontend_dir / "src" / "lib",
            self.frontend_dir / "src" / "types",
            self.factory_dir / "agents",
            self.factory_dir / "engine",
            self.factory_dir / "orchestrator",
            self.factory_dir / "pipeline",
            self.factory_dir / "ci",
            self.factory_dir / "memory",
            self.factory_dir / "registry",
            self.factory_dir / "validator",
            self.factory_dir / "fixer",
            self.database_dir / "migrations",
            self.docker_dir,
            self.tests_dir / "unit",
            self.tests_dir / "integration",
            self.tests_dir / "e2e",
            self.project_root / "scripts",
            self.project_root / "docs"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            (directory / "__init__.py").touch()
            
        print(f"✅ Created directory structure with {len(directories)} directories")
        
    def create_docker_files(self):
        """Create Docker configuration files"""
        
        # Backend Dockerfile
        backend_docker = self.docker_dir / "Dockerfile.backend"
        backend_docker.write_text("""
            FROM python:3.11-slim

            WORKDIR /app

            RUN apt-get update && apt-get install -y \\
                gcc \\
                postgresql-client \\
                libpq-dev \\
                && rm -rf /var/lib/apt/lists/*

            COPY backend/requirements.txt /app/requirements.txt
            RUN pip install --no-cache-dir -r requirements.txt

            COPY backend/ /app/backend/
            COPY factory/ /app/factory/
            COPY database/ /app/database/

            ENV PYTHONPATH=/app

            WORKDIR /app/backend

            CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
            """)
        
        # Frontend Dockerfile
        frontend_docker = self.docker_dir / "Dockerfile.frontend"
        frontend_docker.write_text("""
            FROM node:18-alpine AS builder

            WORKDIR /app

            COPY frontend/package*.json ./
            RUN npm ci

            COPY frontend/ ./
            RUN npm run build

            FROM node:18-alpine

            WORKDIR /app

            COPY --from=builder /app/.next ./.next
            COPY --from=builder /app/public ./public
            COPY --from=builder /app/package*.json ./
            COPY --from=builder /app/node_modules ./node_modules

            EXPOSE 3000

            CMD ["npm", "start"]
            """)
                
        # docker-compose.yml
        compose_file = self.project_root / "docker-compose.yml"
        compose_file.write_text("""
            version: '3.8'

            services:
            postgres:
                image: postgres:15
                environment:
                POSTGRES_USER: aifactory
                POSTGRES_PASSWORD: aifactory123
                POSTGRES_DB: aifactory
                ports:
                - "5432:5432"
                volumes:
                - postgres_data:/var/lib/postgresql/data
                healthcheck:
                test: ["CMD-SHELL", "pg_isready -U aifactory"]
                interval: 10s
                timeout: 5s
                retries: 5

            redis:
                image: redis:7-alpine
                ports:
                - "6379:6379"
                volumes:
                - redis_data:/data
                healthcheck:
                test: ["CMD", "redis-cli", "ping"]
                interval: 10s
                timeout: 5s
                retries: 5

            backend:
                build:
                context: .
                dockerfile: docker/Dockerfile.backend
                ports:
                - "8000:8000"
                environment:
                DATABASE_URL: postgresql://aifactory:aifactory123@postgres:5432/aifactory
                REDIS_URL: redis://redis:6379
                ENVIRONMENT: development
                depends_on:
                postgres:
                    condition: service_healthy
                redis:
                    condition: service_healthy
                volumes:
                - ./backend:/app/backend
                - ./factory:/app/factory
                command: >
                sh -c "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

            frontend:
                build:
                context: .
                dockerfile: docker/Dockerfile.frontend
                ports:
                - "3000:3000"
                environment:
                NEXT_PUBLIC_API_URL: http://localhost:8000
                depends_on:
                - backend

            worker:
                build:
                context: .
                dockerfile: docker/Dockerfile.backend
                command: celery -A app.workers.celery_app worker --loglevel=info
                environment:
                DATABASE_URL: postgresql://aifactory:aifactory123@postgres:5432/aifactory
                REDIS_URL: redis://redis:6379
                depends_on:
                - postgres
                - redis
                volumes:
                - ./backend:/app/backend
                - ./factory:/app/factory

            volumes:
            postgres_data:
            redis_data:
            """)
            
print("✅ Created Docker configuration files")
        
def create_backend_files(self):
    "Create backend FastAPI application files"
    
    # requirements.txt
    requirements = self.backend_dir / "requirements.txt"
    requirements.write_text("""
        fastapi==0.104.1
        uvicorn[standard]==0.24.0
        sqlalchemy==2.0.23
        alembic==1.12.1
        psycopg2-binary==2.9.9
        redis==5.0.1
        celery==5.3.4
        pydantic==2.5.0
        pydantic-settings==2.1.0
        python-dotenv==1.0.0
        python-multipart==0.0.6
        httpx==0.25.1
        python-jose[cryptography]==3.3.0
        passlib[bcrypt]==1.7.4
        pytest==7.4.3
        pytest-asyncio==0.21.1
        pytest-cov==4.1.0
        black==23.11.0
        isort==5.12.0
        mypy==1.7.0
        """)
        
    # main.py
    main_app = self.backend_dir / "app" / "main.py"
    main_app.write_text("""
        from fastapi import FastAPI
        from fastapi.middleware.cors import CORSMiddleware
        from contextlib import asynccontextmanager
        import logging
        from .api.v1 import router as api_v1_router
        from .core.config import settings
        from .core.database import engine, Base

        logging.basicConfig(level=logging.INFO)
        logger = logging.getLogger(__name__)

        @asynccontextmanager
        async def lifespan(app: FastAPI):
            "Handle startup and shutdown events"
            logger.info("Starting up AI Factory...")
            Base.metadata.create_all(bind=engine)
            yield
            logger.info("Shutting down AI Factory...")

        app = FastAPI(
            title="AI Software Factory",
            version="1.0.0",
            description="Enterprise-grade AI-powered software engineering factory",
            lifespan=lifespan
        )

        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.CORS_ORIGINS,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

        app.include_router(api_v1_router, prefix="/api/v1")

        @app.get("/health")
        async def health_check():
            return {"status": "healthy", "version": "1.0.0"}

        @app.get("/")
        async def root():
            return {"message": "AI Software Factory API", "version": "1.0.0"}
        """)
            
    # config.py
    config_file = self.backend_dir / "app" / "core" / "config.py"
    config_file.write_text("""
        from pydantic_settings import BaseSettings
        from typing import List
        import os

        class Settings(BaseSettings):
            APP_NAME: str = "AI Software Factory"
            ENVIRONMENT: str = "development"
            DEBUG: bool = True
            
            DATABASE_URL: str = "postgresql://aifactory:aifactory123@localhost:5432/aifactory"
            REDIS_URL: str = "redis://localhost:6379"
            
            CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8000"]
            
            JWT_SECRET: str = "your-secret-key-change-in-production"
            JWT_ALGORITHM: str = "HS256"
            ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
            
            BATCH_QUEUE_NAME: str = "batch_queue"
            BATCH_RESULT_QUEUE: str = "batch_results"
            
            class Config:
                env_file = ".env"
                case_sensitive = True

        settings = Settings()
        """)
            
    # database.py
    database_file = self.backend_dir / "app" / "core" / "database.py"
    database_file.write_text("""
        from sqlalchemy import create_engine
        from sqlalchemy.ext.declarative import declarative_base
        from sqlalchemy.orm import sessionmaker
        from .config import settings

        engine = create_engine(
            settings.DATABASE_URL,
            pool_pre_ping=True,
            echo=settings.DEBUG
        )

        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

        Base = declarative_base()

        def get_db():
            "Dependency for getting database session"
            db = SessionLocal()
            try:
                yield db
            finally:
                db.close()
        """)
            
    # models.py
    models_file = self.backend_dir / "app" / "models" / "__init__.py"
    models_file.write_text("""
        from sqlalchemy import Column, Integer, String, DateTime, JSON, Text, Boolean, Float
        from sqlalchemy.sql import func
        from ..core.database import Base

        class Batch(Base):
            __tablename__ = "batches"
            
            id = Column(Integer, primary_key=True, index=True)
            batch_number = Column(Integer, unique=True, nullable=False)
            status = Column(String, default="pending")
            prompt = Column(Text, nullable=False)
            result = Column(JSON, nullable=True)
            metadata = Column(JSON, default={})
            created_at = Column(DateTime(timezone=True), server_default=func.now())
            updated_at = Column(DateTime(timezone=True), onupdate=func.now())
            
        class Project(Base):
            __tablename__ = "projects"
            
            id = Column(Integer, primary_key=True, index=True)
            name = Column(String, unique=True, nullable=False)
            description = Column(Text)
            current_batch = Column(Integer, default=0)
            status = Column(String, default="initializing")
            config = Column(JSON, default={})
            created_at = Column(DateTime(timezone=True), server_default=func.now())
            
        class CodeGeneration(Base):
            __tablename__ = "code_generations"
            
            id = Column(Integer, primary_key=True, index=True)
            project_id = Column(Integer, nullable=False)
            batch_id = Column(Integer, nullable=False)
            component = Column(String, nullable=False)
            code = Column(Text, nullable=False)
            score = Column(Float, default=0.0)
            iterations = Column(Integer, default=0)
            created_at = Column(DateTime(timezone=True), server_default=func.now())
            
        class AgentTask(Base):
            __tablename__ = "agent_tasks"
            
            id = Column(Integer, primary_key=True, index=True)
            batch_id = Column(Integer, nullable=False)
            agent_type = Column(String, nullable=False)
            task = Column(JSON, nullable=False)
            result = Column(JSON, nullable=True)
            status = Column(String, default="pending")
            created_at = Column(DateTime(timezone=True), server_default=func.now())
        """)
            
    # API v1 router
    api_init = self.backend_dir / "app" / "api" / "__init__.py"
    api_init.touch()

    api_v1_init = self.backend_dir / "app" / "api" / "v1" / "__init__.py"
    api_v1_init.write_text("""
        from fastapi import APIRouter
        from .batches import router as batches_router
        from .projects import router as projects_router

        router = APIRouter()
        router.include_router(batches_router, prefix="/batches", tags=["batches"])
        router.include_router(projects_router, prefix="/projects", tags=["projects"])
        """)
                
    # batches.py
    batches_file = self.backend_dir / "app" / "api" / "v1" / "batches.py"
    batches_file.write_text("""
        from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
        from sqlalchemy.orm import Session
        from typing import List, Optional
        from ...core.database import get_db
        from ...models import Batch
        from ...schemas import BatchCreate, BatchResponse, BatchStatus
        from ...workers.batch_worker import process_batch

        router = APIRouter()

        @router.post("/", response_model=BatchResponse)
        async def create_batch(
            batch_data: BatchCreate,
            background_tasks: BackgroundTasks,
            db: Session = Depends(get_db)
        ):
            "Create and execute a new batch"
            db_batch = Batch(
                batch_number=batch_data.batch_number,
                prompt=batch_data.prompt,
                status="pending",
                metadata={}
            )
            db.add(db_batch)
            db.commit()
            db.refresh(db_batch)
            
            background_tasks.add_task(process_batch, db_batch.id, batch_data.prompt)
            
            return BatchResponse(
                id=db_batch.id,
                batch_number=db_batch.batch_number,
                status=db_batch.status,
                prompt=db_batch.prompt
            )

        @router.get("/{batch_id}", response_model=BatchResponse)
        async def get_batch(batch_id: int, db: Session = Depends(get_db)):
            "Get batch status and results"
            batch = db.query(Batch).filter(Batch.id == batch_id).first()
            if not batch:
                raise HTTPException(status_code=404, detail="Batch not found")
            
            return BatchResponse(
                id=batch.id,
                batch_number=batch.batch_number,
                status=batch.status,
                prompt=batch.prompt,
                result=batch.result
            )

        @router.get("/", response_model=List[BatchResponse])
        async def list_batches(
            skip: int = 0,
            limit: int = 100,
            db: Session = Depends(get_db)
        ):
            "List all batches"
            batches = db.query(Batch).offset(skip).limit(limit).all()
            return [
                BatchResponse(
                    id=b.id,
                    batch_number=b.batch_number,
                    status=b.status,
                    prompt=b.prompt
                )
                for b in batches
            ]
        """)
            
    # projects.py
    projects_file = self.backend_dir / "app" / "api" / "v1" / "projects.py"
    projects_file.write_text("""
        from fastapi import APIRouter, Depends, HTTPException
        from sqlalchemy.orm import Session
        from typing import List
        from ...core.database import get_db
        from ...models import Project
        from ...schemas import ProjectCreate, ProjectResponse

        router = APIRouter()

        @router.post("/", response_model=ProjectResponse)
        async def create_project(project_data: ProjectCreate, db: Session = Depends(get_db)):
            "Create a new project"
            db_project = Project(
                name=project_data.name,
                description=project_data.description,
                config=project_data.config or {}
            )
            db.add(db_project)
            db.commit()
            db.refresh(db_project)
            
            return ProjectResponse(
                id=db_project.id,
                name=db_project.name,
                description=db_project.description,
                status=db_project.status,
                current_batch=db_project.current_batch
            )

        @router.get("/", response_model=List[ProjectResponse])
        async def list_projects(db: Session = Depends(get_db)):
            "List all projects"
            projects = db.query(Project).all()
            return [
                ProjectResponse(
                    id=p.id,
                    name=p.name,
                    description=p.description,
                    status=p.status,
                    current_batch=p.current_batch
                )
                for p in projects
            ]
        """)
            
    # schemas.py
    schemas_file = self.backend_dir / "app" / "schemas" / "__init__.py"
    schemas_file.write_text("""
        from pydantic import BaseModel
        from typing import Optional, Dict, Any, List
        from datetime import datetime

        class BatchCreate(BaseModel):
            batch_number: int
            prompt: str
            metadata: Optional[Dict[str, Any]] = {}

        class BatchResponse(BaseModel):
            id: int
            batch_number: int
            status: str
            prompt: str
            result: Optional[Dict[str, Any]] = None
            created_at: Optional[datetime] = None
            
            class Config:
                from_attributes = True

        class ProjectCreate(BaseModel):
            name: str
            description: Optional[str] = ""
            config: Optional[Dict[str, Any]] = {}

        class ProjectResponse(BaseModel):
            id: int
            name: str
            description: Optional[str]
            status: str
            current_batch: int
            
            class Config:
                from_attributes = True

        class BatchStatus(BaseModel):
            status: str
            progress: float
            message: str
        """)
                
    # celery_app.py
    celery_file = self.backend_dir / "app" / "workers" / "celery_app.py"
    celery_file.write_text("""
        from celery import Celery
        from ..core.config import settings

        celery_app = Celery(
            "ai_factory",
            broker=settings.REDIS_URL,
            backend=settings.REDIS_URL
        )

        celery_app.conf.update(
            task_serializer="json",
            accept_content=["json"],
            result_serializer="json",
            timezone="UTC",
            enable_utc=True,
            task_track_started=True,
            task_time_limit=30 * 60,
            task_soft_time_limit=25 * 60,
        )

        celery_app.conf.beat_schedule = {
            "cleanup-old-batches": {
                "task": "app.workers.tasks.cleanup_old_batches",
                "schedule": 3600.0,
            },
        }
        """)
            
    # batch_worker.py
    batch_worker_file = self.backend_dir / "app" / "workers" / "batch_worker.py"
    batch_worker_file.write_text("""
        import logging
        from sqlalchemy.orm import Session
        from ..core.database import SessionLocal
        from ..models import Batch
        from .celery_app import celery_app

        logger = logging.getLogger(__name__)

        def process_batch(batch_id: int, prompt: str):
            "Process a batch asynchronously"
            db = SessionLocal()
            try:
                batch = db.query(Batch).filter(Batch.id == batch_id).first()
                if batch:
                    batch.status = "processing"
                    db.commit()
                    
                    # TODO: Implement actual AI processing
                    result = {
                        "generated_code": [],
                        "agents_used": ["architect", "backend", "frontend"],
                        "validation_score": 0.0
                    }
                    
                    batch.status = "completed"
                    batch.result = result
                    db.commit()
                    
                    logger.info(f"Batch {batch_id} completed successfully")
                    
            except Exception as e:
                logger.error(f"Error processing batch {batch_id}: {str(e)}")
                if batch:
                    batch.status = "failed"
                    batch.metadata = {"error": str(e)}
                    db.commit()
            finally:
                db.close()

        @celery_app.task
        def process_batch_task(batch_id: int, prompt: str):
            "Celery task for batch processing"
            process_batch(batch_id, prompt)
        """)
        
print("✅ Created backend application files")
        
def create_frontend_files(self):
    """Create Next.js frontend files"""
    
    # package.json
    package_json = self.frontend_dir / "package.json"
    package_json.write_text("""
        {
        "name": "ai-factory-frontend",
        "version": "1.0.0",
        "private": true,
        "scripts": {
            "dev": "next dev",
            "build": "next build",
            "start": "next start",
            "lint": "next lint",
            "test": "jest"
        },
        "dependencies": {
            "next": "14.0.4",
            "react": "18.2.0",
            "react-dom": "18.2.0",
            "axios": "1.6.2",
            "@tanstack/react-query": "5.12.2",
            "recharts": "2.10.3",
            "react-hook-form": "7.48.2",
            "zod": "3.22.4",
            "clsx": "2.0.0",
            "lucide-react": "0.294.0"
        },
        "devDependencies": {
            "@types/node": "20.10.4",
            "@types/react": "18.2.45",
            "@types/react-dom": "18.2.17",
            "typescript": "5.3.3",
            "tailwindcss": "3.3.6",
            "autoprefixer": "10.4.16",
            "postcss": "8.4.32",
            "@testing-library/react": "14.1.2",
            "jest": "29.7.0"
        }
        }
        """)
        
    # layout.tsx
    layout_file = self.frontend_dir / "src" / "app" / "layout.tsx"
    layout_file.write_text("""
        import type { Metadata } from 'next'
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
        """)
            
    # page.tsx
    page_file = self.frontend_dir / "src" / "app" / "page.tsx"
    page_file.write_text("""
        'use client';

        import { useState } from 'react';
        import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
        import BatchCreator from '@/components/BatchCreator';
        import BatchList from '@/components/BatchList';

        const queryClient = new QueryClient();

        export default function Home() {
        const [refreshKey, setRefreshKey] = useState(0);

        const handleBatchCreated = () => {
            setRefreshKey(prev => prev + 1);
        };

        return (
            <QueryClientProvider client={queryClient}>
            <main className="min-h-screen bg-gray-50">
                <div className="container mx-auto px-4 py-8">
                <h1 className="text-4xl font-bold text-gray-900 mb-8">
                    AI Software Factory
                </h1>
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <BatchCreator onBatchCreated={handleBatchCreated} />
                    <BatchList key={refreshKey} />
                </div>
                </div>
            </main>
            </QueryClientProvider>
        );
        }
        """)
            
    # BatchCreator.tsx
    batch_creator = self.frontend_dir / "src" / "components" / "BatchCreator.tsx"
    batch_creator.write_text("""
        'use client';

        import { useState } from 'react';
        import axios from 'axios';

        interface BatchCreatorProps {
        onBatchCreated: () => void;
        }

        export default function BatchCreator({ onBatchCreated }: BatchCreatorProps) {
        const [prompt, setPrompt] = useState('');
        const [batchNumber, setBatchNumber] = useState(1);
        const [loading, setLoading] = useState(false);

        const handleSubmit = async (e: React.FormEvent) => {
            e.preventDefault();
            setLoading(true);

            try {
            await axios.post('http://localhost:8000/api/v1/batches/', {
                batch_number: batchNumber,
                prompt: prompt,
            });
            setPrompt('');
            setBatchNumber(prev => prev + 1);
            onBatchCreated();
            } catch (error) {
            console.error('Error creating batch:', error);
            alert('Failed to create batch');
            } finally {
            setLoading(false);
            }
        };

        return (
            <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-2xl font-semibold mb-4">Create New Batch</h2>
            <form onSubmit={handleSubmit}>
                <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                    Batch Number
                </label>
                <input
                    type="number"
                    value={batchNumber}
                    onChange={(e) => setBatchNumber(parseInt(e.target.value))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                    min={1}
                />
                </div>
                <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                    Prompt
                </label>
                <textarea
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    rows={6}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                    placeholder="Describe the SaaS application you want to generate..."
                    required
                />
                </div>
                <button
                type="submit"
                disabled={loading}
                className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                {loading ? 'Creating...' : 'Create Batch'}
                </button>
            </form>
            </div>
        );
        }
        """)
            
    # BatchList.tsx
    batch_list = self.frontend_dir / "src" / "components" / "BatchList.tsx"
    batch_list.write_text("""
        'use client';

        import { useQuery } from '@tanstack/react-query';
        import axios from 'axios';

        interface Batch {
        id: number;
        batch_number: number;
        status: string;
        prompt: string;
        }

        export default function BatchList() {
        const { data: batches, isLoading, error } = useQuery({
            queryKey: ['batches'],
            queryFn: async () => {
            const response = await axios.get('http://localhost:8000/api/v1/batches/');
            return response.data;
            },
            refetchInterval: 3000,
        });

        if (isLoading) return <div>Loading batches...</div>;
        if (error) return <div>Error loading batches</div>;

        const getStatusColor = (status: string) => {
            switch (status) {
            case 'completed':
                return 'text-green-600';
            case 'processing':
                return 'text-yellow-600';
            case 'failed':
                return 'text-red-600';
            default:
                return 'text-gray-600';
            }
        };

        return (
            <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-2xl font-semibold mb-4">Batches</h2>
            <div className="space-y-4">
                {batches?.map((batch: Batch) => (
                <div key={batch.id} className="border rounded-lg p-4">
                    <div className="flex justify-between items-start mb-2">
                    <h3 className="font-semibold">Batch #{batch.batch_number}</h3>
                    <span className={`text-sm font-medium ${getStatusColor(batch.status)}`}>
                        {batch.status}
                    </span>
                    </div>
                    <p className="text-gray-600 text-sm">{batch.prompt.substring(0, 100)}...</p>
                </div>
                ))}
                {batches?.length === 0 && (
                <p className="text-gray-500 text-center">No batches created yet</p>
                )}
            </div>
            </div>
        );
        }
        """)
            
    # globals.css
    css_file = self.frontend_dir / "src" / "app" / "globals.css"
    css_file.write_text("""
        @tailwind base;
        @tailwind components;
        @tailwind utilities;

        :root {
        --foreground-rgb: 0, 0, 0;
        --background-rgb: 249, 250, 251;
        }

        body {
        color: rgb(var(--foreground-rgb));
        background: rgb(var(--background-rgb));
        }
        """)
                
    # tailwind.config.js
    tailwind_config = self.frontend_dir / "tailwind.config.js"
    tailwind_config.write_text("""
        /** @type {import('tailwindcss').Config} */
        module.exports = {
        content: [
            './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
            './src/components/**/*.{js,ts,jsx,tsx,mdx}',
            './src/app/**/*.{js,ts,jsx,tsx,mdx}',
        ],
        theme: {
            extend: {},
        },
        plugins: [],
        }
        """)
            
    # tsconfig.json
    tsconfig = self.frontend_dir / "tsconfig.json"
    tsconfig.write_text("""
        {
        "compilerOptions": {
            "target": "es5",
            "lib": ["dom", "dom.iterable", "esnext"],
            "allowJs": true,
            "skipLibCheck": true,
            "strict": true,
            "noEmit": true,
            "esModuleInterop": true,
            "module": "esnext",
            "moduleResolution": "bundler",
            "resolveJsonModule": true,
            "isolatedModules": true,
            "jsx": "preserve",
            "incremental": true,
            "plugins": [
            {
                "name": "next"
            }
            ],
            "paths": {
            "@/*": ["./src/*"]
            }
        },
        "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
        "exclude": ["node_modules"]
        }
        """)
        
print("✅ Created frontend application files")
        
def create_cli_files(self):
    """Create CLI interface"""
        
    cli_file = self.factory_dir / "cli.py"
    cli_file.write_text("""
        #!/usr/bin/env python3
        "
        AI Software Factory CLI
        "

        import sys
        import json
        import argparse
        import requests
        from pathlib import Path
        from typing import Dict, Any

        class AICLI:
            def __init__(self, api_url: str = "http://localhost:8000"):
                self.api_url = api_url
                
            def create_batch(self, batch_number: int, prompt: str) -> Dict[str, Any]:
                "Create a new batch"
                response = requests.post(
                    f"{self.api_url}/api/v1/batches/",
                    json={"batch_number": batch_number, "prompt": prompt}
                )
                response.raise_for_status()
                return response.json()
            
            def get_batch(self, batch_id: int) -> Dict[str, Any]:
                "Get batch status"
                response = requests.get(f"{self.api_url}/api/v1/batches/{batch_id}")
                response.raise_for_status()
                return response.json()
            
            def list_batches(self) -> list:
                "List all batches"
                response = requests.get(f"{self.api_url}/api/v1/batches/")
                response.raise_for_status()
                return response.json()
            
            def create_project(self, name: str, description: str = "") -> Dict[str, Any]:
                "Create a new project"
                response = requests.post(
                    f"{self.api_url}/api/v1/projects/",
                    json={"name": name, "description": description}
                )
                response.raise_for_status()
                return response.json()

        def main():
            parser = argparse.ArgumentParser(description="AI Software Factory CLI")
            subparsers = parser.add_subparsers(dest="command", help="Commands")
            
            # Batch commands
            batch_parser = subparsers.add_parser("batch", help="Batch operations")
            batch_subparsers = batch_parser.add_subparsers(dest="action")
            
            batch_create = batch_subparsers.add_parser("create")
            batch_create.add_argument("--number", type=int, required=True)
            batch_create.add_argument("--prompt", type=str, required=True)
            
            batch_get = batch_subparsers.add_parser("get")
            batch_get.add_argument("--id", type=int, required=True)
            
            batch_list = batch_subparsers.add_parser("list")
            
            # Project commands
            project_parser = subparsers.add_parser("project", help="Project operations")
            project_subparsers = project_parser.add_subparsers(dest="action")
            
            project_create = project_subparsers.add_parser("create")
            project_create.add_argument("--name", type=str, required=True)
            project_create.add_argument("--description", type=str, default="")
            
            args = parser.parse_args()
            cli = AICLI()
            
            if args.command == "batch":
                if args.action == "create":
                    result = cli.create_batch(args.number, args.prompt)
                    print(json.dumps(result, indent=2))
                elif args.action == "get":
                    result = cli.get_batch(args.id)
                    print(json.dumps(result, indent=2))
                elif args.action == "list":
                    result = cli.list_batches()
                    print(json.dumps(result, indent=2))
            elif args.command == "project":
                if args.action == "create":
                    result = cli.create_project(args.name, args.description)
                    print(json.dumps(result, indent=2))
            else:
                parser.print_help()

        if __name__ == "__main__":
            main()
        """)
            
    cli_file.chmod(0o755)
print("✅ Created CLI files")
        
def create_makefile(self):
    "Create Makefile for easy management"
    
    makefile = self.project_root / "Makefile"
    makefile.write_text("""
    .PHONY: help build up down logs clean test

    help:
        @echo "Available commands:"
        @echo "  make build    - Build Docker images"
        @echo "  make up       - Start all services"
        @echo "  make down     - Stop all services"
        @echo "  make logs     - View logs"
        @echo "  make clean    - Clean up containers and volumes"
        @echo "  make test     - Run tests"

    build:
        docker-compose build

    up:
        docker-compose up -d
        @echo "Services started. Access:"
        @echo "  Backend API: http://localhost:8000"
        @echo "  Frontend: http://localhost:3000"
        @echo "  PostgreSQL: localhost:5432"
        @echo "  Redis: localhost:6379"

    down:
        docker-compose down

    logs:
        docker-compose logs -f

    clean:
        docker-compose down -v
        docker system prune -f

    test:
        docker-compose exec backend pytest /app/tests/

    shell-backend:
        docker-compose exec backend /bin/bash

    shell-frontend:
        docker-compose exec frontend /bin/sh
    """)
        
print("✅ Created Makefile")
        
def create_env_example(self):
    "Create .env.example file"

    env_example = self.project_root / ".env.example"
    env_example.write_text("""
    # Database
    DATABASE_URL=postgresql://aifactory:aifactory123@postgres:5432/aifactory
    POSTGRES_USER=aifactory
    POSTGRES_PASSWORD=aifactory123
    POSTGRES_DB=aifactory

    # Redis
    REDIS_URL=redis://redis:6379

    # API Configuration
    CORS_ORIGINS=http://localhost:3000,http://localhost:8000
    ENVIRONMENT=development
    DEBUG=true

    # Security
    JWT_SECRET=your-super-secret-jwt-key-change-in-production
    JWT_ALGORITHM=HS256
    ACCESS_TOKEN_EXPIRE_MINUTES=30

    # AI Configuration
    OPENAI_API_KEY=your-openai-api-key
    ANTHROPIC_API_KEY=your-anthropic-api-key

    # Batch Configuration
    MAX_BATCH_RETRIES=3
    BATCH_TIMEOUT_SECONDS=1800
    """)
        
print("✅ Created .env.example")
        
def create_readme(self):
    "Create README.md"

    readme = self.project_root / "README.md"
    readme.write_text("""
    # AI Software Factory

    Enterprise-grade AI-powered software engineering factory that can generate full SaaS applications from batch prompts.

    ## Architecture

    - **Backend**: FastAPI (Python)
    - **Frontend**: Next.js (React/TypeScript)
    - **Database**: PostgreSQL
    - **Queue**: Redis with Celery
    - **Container**: Docker

    ## Quick Start

    1. Clone the repository:
    git clone <repository-url>
    cd ai-factory

    2. Copy environment variables:
    cp .env.example .env

    3. Build and start services:
    make build
    make up

    4. Access the application:
    - Frontend: http://localhost:3000
    - Backend API: http://localhost:8000
    - API Documentation: http://localhost:8000/docs

    ## Usage

    ### Using the CLI

    # Create a new batch
    python factory/cli.py batch create --number 1 --prompt "Create a todo app"

    # List all batches
    python factory/cli.py batch list

    # Get batch status
    python factory/cli.py batch get --id 1

    # Create a project
    python factory/cli.py project create --name "MyApp" --description "My SaaS app"

    ### Using the API

    # Create batch
    curl -X POST http://localhost:8000/api/v1/batches/ \\
    -H "Content-Type: application/json" \\
    -d '{"batch_number": 1, "prompt": "Create a blog platform"}'

    # Get batch status
    curl http://localhost:8000/api/v1/batches/1

    ## Development

    ### Running Tests

    make test

    ### View Logs

    make logs

    ### Stop Services

    make down

    ### Clean Everything

    make clean

    ## System Evolution

    This system supports 5 evolution stages:

    1. v1 - Base Factory System (Current)
    2. v2 - AI Factory Engine
    3. v3 - Multi-Agent Orchestration
    4. v4 - Self-Improving System
    5. v5 - Autonomous CI System

    ## License

    Proprietary - All Rights Reserved
    """)
    
print("Created README.md")

def run_initial_setup(self):
    "Run initial setup commands"

    print("\n🚀 Starting Batch 1 - Base Factory System Setup")
    print("=" * 60)

    self.create_directory_structure()
    self.create_docker_files()
    self.create_backend_files()
    self.create_frontend_files()
    self.create_cli_files()
    self.create_makefile()
    self.create_env_example()
    self.create_readme()

    print("\n" + "=" * 60)
    print("✅ Batch 1 Complete - Base Factory System Generated")
    print("\nNext steps:")
    print("1. Run 'make build' to build Docker images")
    print("2. Run 'make up' to start the system")
    print("3. Run 'make test' to verify installation")
    print("4. Run Batch 2 to add AI agents")

def main():
    generator = Batch1Generator()
    generator.run_initial_setup()

if __name__ == "main":
    main()