# phase1_batch1.ps1
# FactoryOS AI - Phase 1 Batch 1
# Creates: Branding assets, documentation, PRD, executive summary

param(
    [string]$ProjectPath = "D:\aisfs\ai-factory"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FACTORYOS AI - PHASE 1 BATCH 1" -ForegroundColor Cyan
Write-Host "Branding & Documentation Assets" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Set-Location $ProjectPath

Write-Host "[1/8] Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "branding\logo" | Out-Null
New-Item -ItemType Directory -Force -Path "branding\colors" | Out-Null
New-Item -ItemType Directory -Force -Path "branding\typography" | Out-Null
New-Item -ItemType Directory -Force -Path "docs\technical" | Out-Null
New-Item -ItemType Directory -Force -Path "docs\user" | Out-Null
New-Item -ItemType Directory -Force -Path "docs\developer" | Out-Null
New-Item -ItemType Directory -Force -Path "docs\deployment" | Out-Null
New-Item -ItemType Directory -Force -Path "docs\security" | Out-Null
New-Item -ItemType Directory -Force -Path "docs\pricing" | Out-Null
New-Item -ItemType Directory -Force -Path "investor" | Out-Null

Write-Host "[2/8] Creating branding assets..." -ForegroundColor Yellow

$brandGuidelines = @"
# FactoryOS AI - Brand Guidelines

## Brand Identity
FactoryOS AI is the Autonomous AI Software Engineering Platform.

## Color Palette

### Primary Colors
- Deep Blue: #1A365D
- Electric Blue: #3182CE
- Accent Teal: #319795

### Secondary Colors
- Dark Gray: #2D3748
- Medium Gray: #4A5568
- Light Gray: #EDF2F7

## Typography
- Headings: Inter (Sans-serif)
- Body: Inter (Sans-serif)
- Code: JetBrains Mono

## Tone of Voice
Professional yet approachable. Technical but accessible.
"@
$brandGuidelines | Out-File -FilePath "branding\brand_guidelines.md" -Encoding UTF8

$cssVariables = @"
:root {
  --color-primary: #1A365D;
  --color-primary-light: #3182CE;
  --color-accent: #319795;
  --color-success: #38A169;
  --color-warning: #D69E2E;
  --color-error: #E53E3E;
  --color-text-primary: #2D3748;
  --color-text-secondary: #4A5568;
  --color-bg-primary: #FFFFFF;
  --color-bg-secondary: #F7FAFC;
  --font-family-sans: 'Inter', sans-serif;
  --font-family-mono: 'JetBrains Mono', monospace;
  --container-width: 1280px;
  --border-radius-md: 8px;
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}
"@
$cssVariables | Out-File -FilePath "branding\colors\variables.css" -Encoding UTF8

$logoSvg = @"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 50' width='200' height='50'>
  <defs>
    <linearGradient id='grad' x1='0%' y1='0%' x2='100%' y2='100%'>
      <stop offset='0%' style='stop-color:#1A365D'/>
      <stop offset='100%' style='stop-color:#3182CE'/>
    </linearGradient>
  </defs>
  <g transform='translate(5, 25)'>
    <circle cx='0' cy='0' r='12' fill='none' stroke='url(#grad)' stroke-width='3'/>
    <line x1='-16' y1='0' x2='-8' y2='0' stroke='url(#grad)' stroke-width='3' stroke-linecap='round'/>
    <line x1='8' y1='0' x2='16' y2='0' stroke='url(#grad)' stroke-width='3' stroke-linecap='round'/>
    <line x1='0' y1='-16' x2='0' y2='-8' stroke='url(#grad)' stroke-width='3' stroke-linecap='round'/>
    <line x1='0' y1='8' x2='0' y2='16' stroke='url(#grad)' stroke-width='3' stroke-linecap='round'/>
  </g>
  <text x='35' y='35' font-family='Inter, sans-serif' font-size='20' font-weight='700' fill='#1A365D'>FactoryOS</text>
  <text x='118' y='35' font-family='Inter, sans-serif' font-size='14' font-weight='500' fill='#3182CE'>AI</text>
</svg>
"@
$logoSvg | Out-File -FilePath "branding\logo\logo.svg" -Encoding UTF8

$faviconSvg = @"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>
  <defs>
    <linearGradient id='grad' x1='0%' y1='0%' x2='100%' y2='100%'>
      <stop offset='0%' style='stop-color:#1A365D'/>
      <stop offset='100%' style='stop-color:#3182CE'/>
    </linearGradient>
  </defs>
  <rect width='64' height='64' rx='12' fill='url(#grad)'/>
  <g transform='translate(32, 32)'>
    <circle cx='0' cy='0' r='12' fill='none' stroke='#FFFFFF' stroke-width='3'/>
    <line x1='-16' y1='0' x2='-8' y2='0' stroke='#FFFFFF' stroke-width='3' stroke-linecap='round'/>
    <line x1='8' y1='0' x2='16' y2='0' stroke='#FFFFFF' stroke-width='3' stroke-linecap='round'/>
    <line x1='0' y1='-16' x2='0' y2='-8' stroke='#FFFFFF' stroke-width='3' stroke-linecap='round'/>
    <line x1='0' y1='8' x2='0' y2='16' stroke='#FFFFFF' stroke-width='3' stroke-linecap='round'/>
  </g>
</svg>
"@
$faviconSvg | Out-File -FilePath "branding\logo\favicon.svg" -Encoding UTF8

Write-Host "[3/8] Creating Product Requirements Document..." -ForegroundColor Yellow

$prd = @"
# FactoryOS AI - Product Requirements Document (PRD)

## Version: 1.0
## Date: 2026-05-18

## Executive Summary

FactoryOS AI is an autonomous AI-powered software engineering platform that generates, validates, tests, and continuously improves production-grade software.

## Core Features by Tier

### Free Tier
- Limited to 5 batches
- Single user
- Basic templates
- Community support

### Pro Tier ($49/month)
- Unlimited batches
- Multi-agent orchestration
- Self-improving system
- Team workspaces (3 users)
- Priority processing

### Enterprise Tier (Custom pricing)
- White-label deployment
- SSO/SAML
- On-premise installation
- Dedicated support

## Technical Requirements
- Backend: FastAPI (Python)
- Frontend: Next.js (React/TypeScript)
- Database: PostgreSQL
- Container: Docker
"@
$prd | Out-File -FilePath "docs\PRD.md" -Encoding UTF8

Write-Host "[4/8] Creating Executive Summary..." -ForegroundColor Yellow

$execSummary = @"
# FactoryOS AI - Executive Summary

## Problem
Software development is slow, expensive, and error-prone.

## Solution
FactoryOS AI deploys 8 specialized AI agents that work together to plan, build, and improve software automatically.

## Market Opportunity
- Global software development market: $500B+
- AI in software engineering: 40% CAGR

## Business Model
- Free: Limited features
- Pro: $49/month
- Enterprise: Custom pricing

## Competitive Advantage
- True multi-agent system
- Self-improving through feedback loops
- Production-ready code
"@
$execSummary | Out-File -FilePath "docs\executive_summary.md" -Encoding UTF8

Write-Host "[5/8] Creating Technical Architecture Documentation..." -ForegroundColor Yellow

$techArch = @"
# FactoryOS AI - Technical Architecture

## Architecture Layers

1. Client Layer - Web, API, CLI
2. API Gateway - FastAPI with rate limiting
3. Core Services - Batch, Agent, Project
4. Orchestration Layer - Coordinator, Planner, Pipeline
5. AI Agent Layer - 8 specialized agents
6. Evolution Layer - Engine, Memory, Feedback Loop
7. CI/CD Layer - Pipeline, Scheduler, Monitoring
8. Data Layer - PostgreSQL, Redis, File Storage

## Agents
- Architect - System design
- Backend - API generation
- Frontend - UI components
- Database - Schema design
- QA - Test generation
- Security - Vulnerability scanning
- DevOps - Docker, CI/CD
- Code Generator - General code

## API Endpoints
- 28+ production-ready endpoints
- OpenAPI documentation at /docs
- JWT authentication
- Rate limiting per tier
"@
$techArch | Out-File -FilePath "docs\technical\architecture.md" -Encoding UTF8

Write-Host "[6/8] Creating User Guide..." -ForegroundColor Yellow

$userGuide = @"
# FactoryOS AI - User Guide

## Getting Started

### Sign Up
1. Visit https://factoryos.ai
2. Click Sign Up
3. Enter email and password
4. Verify email

### Create a Batch

curl -X POST https://api.factoryos.ai/api/v1/batches/ \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"batch_number": 1, "prompt": "Create a todo list app"}'

### Check Status

curl -X GET https://api.factoryos.ai/api/v1/batches/1 \
  -H "Authorization: Bearer YOUR_API_KEY"

### Use Agents

curl -X POST https://api.factoryos.ai/api/v1/agents/generate \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Create user authentication", "entity_name": "User"}'
"@
$userGuide | Out-File -FilePath "docs\user\user_guide.md" -Encoding UTF8

Write-Host "[7/8] Creating Developer Guide..." -ForegroundColor Yellow

$devGuide = @"
# FactoryOS AI - Developer Guide

## Quick Start

git clone https://github.com/shomonrobie/ai-factory.git
cd ai-factory
docker-compose up -d

## API Integration

headers = {"Authorization": f"Bearer {API_KEY}"}

response = requests.post(
    "https://api.factoryos.ai/api/v1/batches/",
    headers=headers,
    json={"batch_number": 1, "prompt": "Create API"}
)

## Custom Agent

class CustomAgent(BaseAgent):
    async def process(self, task):
        return AgentResult(success=True, output="done")

## Testing

pytest backend/tests/ -v
cd frontend && npm test

## Deployment

docker build -f docker/Dockerfile.backend -t factoryos-backend .
kubectl apply -f k8s/deployment.yaml
"@
$devGuide | Out-File -FilePath "docs\developer\developer_guide.md" -Encoding UTF8

Write-Host "[8/8] Creating Deployment Guide..." -ForegroundColor Yellow

$deployGuide = @"
# FactoryOS AI - Deployment Guide

## Docker Compose (Development)

docker-compose up -d

## Kubernetes (Production)

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

## Environment Variables

DATABASE_URL=postgresql://user:pass@postgres:5432/factoryos
REDIS_URL=redis://redis:6379
JWT_SECRET=your-secret-key
OPENAI_API_KEY=sk-...

## SSL Configuration

certbot --nginx -d factoryos.ai

## Monitoring

Prometheus: http://localhost:9090
Grafana: http://localhost:3000

## Backup

pg_dump factoryos > backup.sql
aws s3 cp backup.sql s3://factoryos-backups/
"@
$deployGuide | Out-File -FilePath "docs\deployment\deployment_guide.md" -Encoding UTF8

Write-Host "Creating Security Whitepaper..." -ForegroundColor Yellow

$securityWhitepaper = @"
# FactoryOS AI - Security Whitepaper

## Data Protection
- TLS 1.3 for all connections
- AES-256 encryption at rest
- Regular key rotation

## Authentication
- JWT-based authentication
- OAuth2 support (Google, GitHub)
- SSO for Enterprise

## Authorization
- Role-based access control (RBAC)
- Tier-based feature gating
- API key management

## Compliance
- SOC2 Type II (in progress)
- GDPR compliant
- Regular security audits

## Vulnerability Management
- Weekly dependency scans
- Monthly penetration testing
- Bug bounty program
"@
$securityWhitepaper | Out-File -FilePath "docs\security\security_whitepaper.md" -Encoding UTF8

Write-Host "Creating Pricing Documentation..." -ForegroundColor Yellow

$pricingDoc = @"
# FactoryOS AI - Pricing

## Free Tier - $0
- 5 batches per month
- Single user
- Basic templates
- Community support
- 7-day history

## Pro Tier - $49/month
- Unlimited batches
- Multi-agent orchestration
- Self-improving system
- Team workspaces (3 users)
- Priority processing
- Email support
- 90-day history

## Enterprise - Custom
- White-label deployment
- SSO/SAML
- Audit logs
- On-premise installation
- Private model integration
- Dedicated support
- Custom SLA
- Unlimited history

## Annual Discount
- 20% off for annual billing

## Free Trial
- 14-day free trial on Pro plan
- No credit card required
"@
$pricingDoc | Out-File -FilePath "docs\pricing\pricing.md" -Encoding UTF8

Write-Host "Creating FAQ..." -ForegroundColor Yellow

$faq = @"
# FactoryOS AI - FAQ

## General

Q: What is FactoryOS AI?
A: FactoryOS AI is an autonomous AI software engineering platform.

Q: How does it work?
A: 8 specialized AI agents work together to plan, build, and improve code.

## Technical

Q: What kind of code does it generate?
A: Production-ready Python, JavaScript, TypeScript, and more.

Q: Can I use my own OpenAI key?
A: Yes, Enterprise plan includes private model integration.

## Billing

Q: Is there a free trial?
A: Yes, 14-day free trial on Pro plan.

Q: Can I cancel anytime?
A: Yes, monthly subscriptions can be cancelled anytime.

## Support

Q: How do I get help?
A: Email support@factoryos.ai or join our Discord.

Q: Is there documentation?
A: Yes, visit https://docs.factoryos.ai
"@
$faq | Out-File -FilePath "docs\FAQ.md" -Encoding UTF8

Write-Host "Creating project_state.json..." -ForegroundColor Yellow

$stateJson = '{
  "product_name": "FactoryOS AI",
  "tagline": "The Autonomous AI Software Engineering Platform",
  "current_version": "v1.5",
  "phase": "Phase 1 - Productization",
  "batch": "Batch 1 of 5 - Branding & Documentation",
  "status": "complete",
  "last_updated": "' + (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ') + '",
  "completed_batches": [
    {"batch": "v1.0", "status": "success"},
    {"batch": "v1.1", "status": "success"},
    {"batch": "v1.2", "status": "success"},
    {"batch": "v1.3", "status": "success"},
    {"batch": "v1.4", "status": "success"},
    {"batch": "v1.5", "status": "success"},
    {"batch": "phase1_batch1", "status": "success", "description": "Branding & Documentation"}
  ],
  "phase1_progress": {
    "batch1_branding_docs": "complete",
    "batch2_landing_cms": "pending",
    "batch3_billing_api": "pending",
    "batch4_multilingual_seed": "pending",
    "batch5_investor_materials": "pending"
  },
  "generated_assets": [
    "branding/brand_guidelines.md",
    "branding/colors/variables.css",
    "branding/logo/logo.svg",
    "branding/logo/favicon.svg",
    "docs/PRD.md",
    "docs/executive_summary.md",
    "docs/technical/architecture.md",
    "docs/user/user_guide.md",
    "docs/developer/developer_guide.md",
    "docs/deployment/deployment_guide.md",
    "docs/security/security_whitepaper.md",
    "docs/pricing/pricing.md",
    "docs/FAQ.md"
  ],
  "git_repository": "https://github.com/shomonrobie/ai-factory",
  "next_batch": "phase1_batch2 - Landing Page & CMS"
}'

$stateJson | Out-File -FilePath "project_state.json" -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "PHASE 1 BATCH 1 COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Generated Assets:" -ForegroundColor Cyan
Write-Host "  - Brand Guidelines" -ForegroundColor White
Write-Host "  - CSS Variables" -ForegroundColor White
Write-Host "  - Logo SVG" -ForegroundColor White
Write-Host "  - Favicon SVG" -ForegroundColor White
Write-Host "  - Product Requirements Document" -ForegroundColor White
Write-Host "  - Executive Summary" -ForegroundColor White
Write-Host "  - Technical Architecture" -ForegroundColor White
Write-Host "  - User Guide" -ForegroundColor White
Write-Host "  - Developer Guide" -ForegroundColor White
Write-Host "  - Deployment Guide" -ForegroundColor White
Write-Host "  - Security Whitepaper" -ForegroundColor White
Write-Host "  - Pricing Documentation" -ForegroundColor White
Write-Host "  - FAQ" -ForegroundColor White
Write-Host ""
Write-Host "Updated project_state.json" -ForegroundColor Green
Write-Host ""
Write-Host "Next Batch: Phase 1 Batch 2 - Landing Page & CMS" -ForegroundColor Yellow