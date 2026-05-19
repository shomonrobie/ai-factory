# fix_and_rebuild.ps1
Write-Host "Fixing AI Factory build issues..." -ForegroundColor Green

# Stop and remove existing containers
Write-Host "Stopping containers..." -ForegroundColor Yellow
cd D:\aisfs\ai-factory
docker-compose down -v

# Fix backend requirements.txt
Write-Host "Fixing backend requirements.txt..." -ForegroundColor Yellow
cd D:\aisfs\ai-factory\backend

$requirements = @"
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
openai==1.3.5
anthropic==0.7.7
langchain==0.0.340
tiktoken==0.5.1
tenacity==8.2.3
"@

$requirements | Out-File -FilePath requirements.txt -Encoding UTF8 -NoNewline
Write-Host "requirements.txt fixed" -ForegroundColor Green

# Fix frontend package.json and create package-lock.json
Write-Host "Fixing frontend..." -ForegroundColor Yellow
cd D:\aisfs\ai-factory\frontend

# Create proper package.json
$packageJson = @"
{
  "name": "ai-factory-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
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
"@

$packageJson | Out-File -FilePath package.json -Encoding UTF8 -NoNewline

# Generate package-lock.json
Write-Host "Generating package-lock.json..." -ForegroundColor Yellow
npm install --package-lock-only

# Fix Dockerfile.frontend
Write-Host "Fixing Dockerfile.frontend..." -ForegroundColor Yellow
cd D:\aisfs\ai-factory\docker

$dockerfileFrontend = @"
FROM node:18-alpine AS builder

WORKDIR /app

COPY frontend/package*.json ./

RUN npm install

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
"@

$dockerfileFrontend | Out-File -FilePath Dockerfile.frontend -Encoding UTF8 -NoNewline

# Clean Docker cache
Write-Host "Cleaning Docker cache..." -ForegroundColor Yellow
cd D:\aisfs\ai-factory
docker system prune -f

# Rebuild everything
Write-Host "Rebuilding all containers..." -ForegroundColor Yellow
docker-compose build --no-cache

# Start services
Write-Host "Starting services..." -ForegroundColor Yellow
docker-compose up -d

# Show status
Write-Host "`nServices status:" -ForegroundColor Green
docker-compose ps

Write-Host "`nTo view logs, run: docker-compose logs -f" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend API: http://localhost:8000" -ForegroundColor Cyan