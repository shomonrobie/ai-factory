# phase1_batch4.ps1
# FactoryOS AI - Phase 1 Batch 4
# Creates: Multilingual i18n infrastructure, Demo seed data, Testimonials, Case studies

param(
    [string]$ProjectPath = "D:\aisfs\ai-factory"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FACTORYOS AI - PHASE 1 BATCH 4" -ForegroundColor Cyan
Write-Host "Multilingual Support & Demo Seed Data" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Set-Location $ProjectPath

Write-Host "[1/15] Creating i18n directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "frontend\src\i18n\locales\en" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\i18n\locales\es" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\i18n\locales\de" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\i18n\locales\fr" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\i18n\locales\ja" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\i18n\locales\zh" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\i18n" | Out-Null
New-Item -ItemType Directory -Force -Path "scripts\seed" | Out-Null
New-Item -ItemType Directory -Force -Path "data\seed" | Out-Null

Write-Host "[2/15] Creating English translations (en)..." -ForegroundColor Yellow

$enTranslations = @'
{
  "common": {
    "app_name": "FactoryOS AI",
    "tagline": "The Autonomous AI Software Engineering Platform",
    "learn_more": "Learn More",
    "get_started": "Get Started",
    "contact_us": "Contact Us",
    "sign_in": "Sign In",
    "sign_up": "Sign Up",
    "dashboard": "Dashboard",
    "docs": "Documentation",
    "blog": "Blog",
    "pricing": "Pricing",
    "demo": "Book a Demo"
  },
  "home": {
    "hero_title": "Build Production Software with AI Agents",
    "hero_subtitle": "8 specialized AI agents work together to plan, build, test, and deploy your applications automatically.",
    "feature_1_title": "10x Faster Development",
    "feature_1_desc": "Generate complete applications in minutes, not months.",
    "feature_2_title": "8 Specialized Agents",
    "feature_2_desc": "Architect, Backend, Frontend, Database, QA, Security, DevOps, Code Generator.",
    "feature_3_title": "Self-Improving System",
    "feature_3_desc": "Code reviews itself and improves through feedback loops.",
    "feature_4_title": "Production-Ready Code",
    "feature_4_desc": "Includes tests, documentation, and CI/CD pipelines.",
    "feature_5_title": "CI/CD Automation",
    "feature_5_desc": "Automated build, test, security, and deploy stages.",
    "feature_6_title": "Enterprise Security",
    "feature_6_desc": "SOC2 compliant, encrypted data, SSO support."
  },
  "pricing": {
    "title": "Simple, Transparent Pricing",
    "subtitle": "Choose the plan that fits your needs",
    "free_name": "Free",
    "free_price": "$0",
    "free_period": "/month",
    "free_features": ["5 batches per month", "Single user", "Basic templates", "Community support", "7-day history"],
    "pro_name": "Pro",
    "pro_price": "$49",
    "pro_period": "/month",
    "pro_features": ["Unlimited batches", "Multi-agent orchestration", "Self-improving system", "Team workspaces (3 users)", "Priority processing", "Advanced templates", "Documentation generation", "Email support", "90-day history"],
    "enterprise_name": "Enterprise",
    "enterprise_price": "Custom",
    "enterprise_features": ["White-label deployment", "SSO/SAML", "Audit logs", "On-premise installation", "Private model integration", "Dedicated support", "Custom SLA", "Unlimited history"],
    "popular": "MOST POPULAR",
    "free_trial": "14-day free trial",
    "annual_discount": "20% off annual billing"
  },
  "agents": {
    "title": "Meet Your AI Engineering Team",
    "subtitle": "8 specialized agents work in orchestration to build your software",
    "architect": "Architect",
    "architect_desc": "System design",
    "backend": "Backend",
    "backend_desc": "API generation",
    "frontend": "Frontend",
    "frontend_desc": "UI components",
    "database": "Database",
    "database_desc": "Schema design",
    "qa": "QA",
    "qa_desc": "Test generation",
    "security": "Security",
    "security_desc": "Vulnerability scan",
    "devops": "DevOps",
    "devops_desc": "CI/CD pipeline",
    "code": "Code Generator",
    "code_desc": "Code generation"
  },
  "footer": {
    "rights": "All rights reserved.",
    "privacy": "Privacy Policy",
    "terms": "Terms of Service",
    "security": "Security"
  }
}
'@
$enTranslations | Out-File -FilePath "frontend\src\i18n\locales\en\common.json" -Encoding UTF8

Write-Host "[3/15] Creating Spanish translations (es)..." -ForegroundColor Yellow

$esTranslations = @'
{
  "common": {
    "app_name": "FactoryOS AI",
    "tagline": "La Plataforma Autónoma de Ingeniería de Software con IA",
    "learn_more": "Más Información",
    "get_started": "Comenzar",
    "contact_us": "Contáctenos",
    "sign_in": "Iniciar Sesión",
    "sign_up": "Registrarse",
    "dashboard": "Panel",
    "docs": "Documentación",
    "blog": "Blog",
    "pricing": "Precios",
    "demo": "Agendar Demo"
  },
  "home": {
    "hero_title": "Construye Software de Producción con Agentes IA",
    "hero_subtitle": "8 agentes IA especializados trabajan juntos para planificar, construir, probar y desplegar tus aplicaciones automáticamente.",
    "feature_1_title": "Desarrollo 10x Más Rápido",
    "feature_1_desc": "Genera aplicaciones completas en minutos, no meses.",
    "feature_2_title": "8 Agentes Especializados",
    "feature_2_desc": "Arquitecto, Backend, Frontend, Base de Datos, QA, Seguridad, DevOps, Generador de Código.",
    "feature_3_title": "Sistema Auto-mejorable",
    "feature_3_desc": "El código se revisa a sí mismo y mejora mediante bucles de retroalimentación.",
    "feature_4_title": "Código Listo para Producción",
    "feature_4_desc": "Incluye pruebas, documentación y pipelines CI/CD.",
    "feature_5_title": "Automatización CI/CD",
    "feature_5_desc": "Etapas automatizadas de construcción, prueba, seguridad y despliegue.",
    "feature_6_title": "Seguridad Empresarial",
    "feature_6_desc": "Cumple con SOC2, datos encriptados, soporte SSO."
  },
  "pricing": {
    "title": "Precios Simples y Transparentes",
    "subtitle": "Elige el plan que se adapte a tus necesidades",
    "free_name": "Gratis",
    "free_price": "$0",
    "free_period": "/mes",
    "pro_name": "Pro",
    "pro_price": "$49",
    "pro_period": "/mes",
    "enterprise_name": "Empresa",
    "enterprise_price": "Personalizado",
    "popular": "MÁS POPULAR",
    "free_trial": "Prueba gratuita de 14 días",
    "annual_discount": "20% de descuento en facturación anual"
  },
  "agents": {
    "title": "Conoce a tu Equipo de Ingeniería IA",
    "subtitle": "8 agentes especializados trabajan en orquestación para construir tu software",
    "architect": "Arquitecto",
    "backend": "Backend",
    "frontend": "Frontend",
    "database": "Base de Datos",
    "qa": "QA",
    "security": "Seguridad",
    "devops": "DevOps",
    "code": "Generador de Código"
  }
}
'@
$esTranslations | Out-File -FilePath "frontend\src\i18n\locales\es\common.json" -Encoding UTF8

Write-Host "[4/15] Creating German translations (de)..." -ForegroundColor Yellow

$deTranslations = @'
{
  "common": {
    "app_name": "FactoryOS AI",
    "tagline": "Die Autonome KI-Softwareentwicklungsplattform",
    "learn_more": "Mehr Erfahren",
    "get_started": "Loslegen",
    "contact_us": "Kontakt",
    "sign_in": "Anmelden",
    "sign_up": "Registrieren",
    "dashboard": "Dashboard",
    "docs": "Dokumentation",
    "blog": "Blog",
    "pricing": "Preise",
    "demo": "Demo Buchen"
  },
  "home": {
    "hero_title": "Produktionssoftware mit KI-Agenten erstellen",
    "hero_subtitle": "8 spezialisierte KI-Agenten arbeiten zusammen, um Ihre Anwendungen automatisch zu planen, zu erstellen, zu testen und bereitzustellen.",
    "feature_1_title": "10x Schnellere Entwicklung",
    "feature_2_title": "8 Spezialisierte Agenten",
    "feature_3_title": "Selbstverbesserndes System",
    "feature_4_title": "Produktionsreifer Code",
    "feature_5_title": "CI/CD Automatisierung",
    "feature_6_title": "Unternehmenssicherheit"
  },
  "pricing": {
    "title": "Einfache, Transparente Preise",
    "free_name": "Kostenlos",
    "pro_name": "Pro",
    "pro_price": "49€",
    "enterprise_name": "Unternehmen",
    "popular": "AM BELIEBTESTEN",
    "free_trial": "14 Tage kostenlose Testversion"
  }
}
'@
$deTranslations | Out-File -FilePath "frontend\src\i18n\locales\de\common.json" -Encoding UTF8

Write-Host "[5/15] Creating French translations (fr)..." -ForegroundColor Yellow

$frTranslations = @'
{
  "common": {
    "app_name": "FactoryOS AI",
    "tagline": "La Plateforme Autonome d'Ingénierie Logicielle par IA",
    "learn_more": "En Savoir Plus",
    "get_started": "Commencer",
    "contact_us": "Nous Contacter",
    "sign_in": "Se Connecter",
    "sign_up": "S'inscrire",
    "dashboard": "Tableau de Bord",
    "docs": "Documentation",
    "blog": "Blog",
    "pricing": "Tarifs",
    "demo": "Réserver une Démo"
  },
  "home": {
    "hero_title": "Créez des Logiciels de Production avec des Agents IA",
    "hero_subtitle": "8 agents IA spécialisés travaillent ensemble pour planifier, construire, tester et déployer vos applications automatiquement.",
    "feature_1_title": "Développement 10x Plus Rapide",
    "feature_2_title": "8 Agents Spécialisés",
    "feature_3_title": "Système Auto-améliorant",
    "feature_4_title": "Code Prêt pour la Production",
    "feature_5_title": "Automatisation CI/CD",
    "feature_6_title": "Sécurité Entreprise"
  },
  "pricing": {
    "title": "Tarifs Simples et Transparents",
    "free_name": "Gratuit",
    "pro_name": "Pro",
    "pro_price": "49€",
    "enterprise_name": "Entreprise",
    "popular": "LE PLUS POPULAIRE",
    "free_trial": "Essai gratuit de 14 jours"
  }
}
'@
$frTranslations | Out-File -FilePath "frontend\src\i18n\locales\fr\common.json" -Encoding UTF8

Write-Host "[6/15] Creating Japanese translations (ja)..." -ForegroundColor Yellow

$jaTranslations = @'
{
  "common": {
    "app_name": "FactoryOS AI",
    "tagline": "自律型AIソフトウェアエンジニアリングプラットフォーム",
    "learn_more": "詳細を見る",
    "get_started": "始める",
    "contact_us": "お問い合わせ",
    "sign_in": "ログイン",
    "sign_up": "登録",
    "dashboard": "ダッシュボード",
    "docs": "ドキュメント",
    "blog": "ブログ",
    "pricing": "価格",
    "demo": "デモを予約"
  },
  "home": {
    "hero_title": "AIエージェントでプロダクションソフトウェアを構築",
    "hero_subtitle": "8つの専門AIエージェントが連携して、アプリケーションを自動的に計画、構築、テスト、デプロイします。",
    "feature_1_title": "10倍高速な開発",
    "feature_2_title": "8つの専門エージェント",
    "feature_3_title": "自己改善システム",
    "feature_4_title": "本番環境対応コード",
    "feature_5_title": "CI/CD自動化",
    "feature_6_title": "エンタープライズセキュリティ"
  },
  "pricing": {
    "title": "シンプルで透明な価格設定",
    "free_name": "無料",
    "pro_name": "プロ",
    "pro_price": "¥7,900",
    "enterprise_name": "エンタープライズ",
    "popular": "最も人気",
    "free_trial": "14日間無料トライアル"
  }
}
'@
$jaTranslations | Out-File -FilePath "frontend\src\i18n\locales\ja\common.json" -Encoding UTF8

Write-Host "[7/15] Creating Chinese translations (zh)..." -ForegroundColor Yellow

$zhTranslations = @'
{
  "common": {
    "app_name": "FactoryOS AI",
    "tagline": "自主AI软件工程平台",
    "learn_more": "了解更多",
    "get_started": "开始使用",
    "contact_us": "联系我们",
    "sign_in": "登录",
    "sign_up": "注册",
    "dashboard": "仪表板",
    "docs": "文档",
    "blog": "博客",
    "pricing": "价格",
    "demo": "预约演示"
  },
  "home": {
    "hero_title": "使用AI代理构建生产级软件",
    "hero_subtitle": "8个专业AI代理协同工作，自动规划、构建、测试和部署您的应用程序。",
    "feature_1_title": "10倍快速开发",
    "feature_2_title": "8个专业代理",
    "feature_3_title": "自我改进系统",
    "feature_4_title": "生产就绪代码",
    "feature_5_title": "CI/CD自动化",
    "feature_6_title": "企业级安全"
  },
  "pricing": {
    "title": "简单透明的定价",
    "free_name": "免费",
    "pro_name": "专业版",
    "pro_price": "¥349",
    "enterprise_name": "企业版",
    "popular": "最受欢迎",
    "free_trial": "14天免费试用"
  }
}
'@
$zhTranslations | Out-File -FilePath "frontend\src\i18n\locales\zh\common.json" -Encoding UTF8

Write-Host "[8/15] Creating i18n configuration and language switcher..." -ForegroundColor Yellow

$i18nConfig = @'
// frontend/src/i18n/config.js
const locales = {
  en: { name: "English", flag: "🇺🇸", dir: "ltr" },
  es: { name: "Español", flag: "🇪🇸", dir: "ltr" },
  de: { name: "Deutsch", flag: "🇩🇪", dir: "ltr" },
  fr: { name: "Français", flag: "🇫🇷", dir: "ltr" },
  ja: { name: "日本語", flag: "🇯🇵", dir: "ltr" },
  zh: { name: "中文", flag: "🇨🇳", dir: "ltr" }
};

const defaultLocale = "en";

function getLocale() {
  return localStorage.getItem("locale") || defaultLocale;
}

function setLocale(locale) {
  if (locales[locale]) {
    localStorage.setItem("locale", locale);
    window.location.reload();
  }
}

async function loadTranslations(locale) {
  try {
    const response = await fetch(`/i18n/locales/${locale}/common.json`);
    return await response.json();
  } catch (error) {
    console.error("Failed to load translations:", error);
    return {};
  }
}

export { locales, defaultLocale, getLocale, setLocale, loadTranslations };
'@
$i18nConfig | Out-File -FilePath "frontend\src\i18n\config.js" -Encoding UTF8

Write-Host "[9/15] Creating demo seed users..." -ForegroundColor Yellow

$seedUsers = @'
# scripts/seed/demo_users.json
[
  {
    "id": "user_demo_1",
    "email": "demo@factoryos.ai",
    "name": "Demo User",
    "tier": "pro",
    "created_at": "2026-01-01T00:00:00Z",
    "metadata": {
      "company": "Demo Corp",
      "role": "CTO"
    }
  },
  {
    "id": "user_demo_2",
    "email": "startup@factoryos.ai",
    "name": "Startup Founder",
    "tier": "free",
    "created_at": "2026-02-15T00:00:00Z",
    "metadata": {
      "company": "Startup Inc",
      "role": "Founder"
    }
  },
  {
    "id": "user_demo_3",
    "email": "enterprise@factoryos.ai",
    "name": "Enterprise Admin",
    "tier": "enterprise",
    "created_at": "2026-03-10T00:00:00Z",
    "metadata": {
      "company": "Enterprise Corp",
      "role": "IT Director"
    }
  }
]
'@
$seedUsers | Out-File -FilePath "scripts\seed\demo_users.json" -Encoding UTF8

Write-Host "[10/15] Creating demo projects and batches..." -ForegroundColor Yellow

$seedProjects = @'
# scripts/seed/demo_projects.json
[
  {
    "id": 1,
    "name": "E-Commerce Platform",
    "description": "Full-featured e-commerce platform with product catalog, shopping cart, and payment processing",
    "status": "completed",
    "batches": [1, 2, 3],
    "created_at": "2026-05-01T00:00:00Z"
  },
  {
    "id": 2,
    "name": "Task Management App",
    "description": "Team task management with boards, lists, cards, and real-time updates",
    "status": "completed",
    "batches": [4, 5],
    "created_at": "2026-05-10T00:00:00Z"
  },
  {
    "id": 3,
    "name": "Blog Platform",
    "description": "Multi-author blog platform with comments, categories, and SEO optimization",
    "status": "in_progress",
    "batches": [6],
    "created_at": "2026-05-15T00:00:00Z"
  }
]
'@
$seedProjects | Out-File -FilePath "scripts\seed\demo_projects.json" -Encoding UTF8

Write-Host "[11/15] Creating example batch prompts and results..." -ForegroundColor Yellow

$seedBatches = @'
# scripts/seed/demo_batches.json
[
  {
    "batch_number": 1,
    "project_id": 1,
    "prompt": "Create a product catalog API with CRUD operations, search, and filtering",
    "status": "completed",
    "result": {
      "generated_code": [
        "app/models/product.py",
        "app/api/products.py",
        "app/services/product_service.py",
        "tests/test_products.py"
      ],
      "validation_score": 92,
      "deployment_url": "https://demo.factoryos.ai/projects/1"
    },
    "created_at": "2026-05-01T10:00:00Z"
  },
  {
    "batch_number": 2,
    "project_id": 1,
    "prompt": "Add shopping cart functionality with session management and checkout flow",
    "status": "completed",
    "result": {
      "generated_code": [
        "app/models/cart.py",
        "app/api/cart.py",
        "app/services/cart_service.py"
      ],
      "validation_score": 88,
      "deployment_url": "https://demo.factoryos.ai/projects/1"
    },
    "created_at": "2026-05-03T14:30:00Z"
  },
  {
    "batch_number": 3,
    "project_id": 1,
    "prompt": "Integrate Stripe payment processing with webhooks for payment confirmation",
    "status": "completed",
    "result": {
      "generated_code": [
        "app/payment/stripe_integration.py",
        "app/api/webhooks.py"
      ],
      "validation_score": 85,
      "deployment_url": "https://demo.factoryos.ai/projects/1"
    },
    "created_at": "2026-05-05T09:15:00Z"
  },
  {
    "batch_number": 4,
    "project_id": 2,
    "prompt": "Create a task board with drag-and-drop columns for To Do, In Progress, and Done",
    "status": "completed",
    "result": {
      "generated_code": [
        "frontend/components/Board.jsx",
        "frontend/components/Card.jsx",
        "backend/api/tasks.py"
      ],
      "validation_score": 90,
      "deployment_url": "https://demo.factoryos.ai/projects/2"
    },
    "created_at": "2026-05-11T11:00:00Z"
  }
]
'@
$seedBatches | Out-File -FilePath "scripts\seed\demo_batches.json" -Encoding UTF8

Write-Host "[12/15] Creating testimonials data..." -ForegroundColor Yellow

$testimonials = @'
# data/seed/testimonials.json
[
  {
    "id": 1,
    "author": "Sarah Chen",
    "title": "CTO at TechStart",
    "content": "FactoryOS AI reduced our MVP development time from 3 months to 1 week. The multi-agent system is incredibly smart and the generated code is production-ready.",
    "rating": 5,
    "avatar": "https://randomuser.me/api/portraits/women/1.jpg",
    "date": "2026-04-15"
  },
  {
    "id": 2,
    "author": "Michael Rodriguez",
    "title": "Lead Developer at DevShop",
    "content": "The self-improving feedback loop is a game-changer. Our code quality improved by 40% after using FactoryOS AI for just one month.",
    "rating": 5,
    "avatar": "https://randomuser.me/api/portraits/men/2.jpg",
    "date": "2026-04-20"
  },
  {
    "id": 3,
    "author": "Emily Watson",
    "title": "Founder at SaaSify",
    "content": "We built our entire platform using FactoryOS AI. The CI/CD pipeline automation saved us hundreds of engineering hours.",
    "rating": 5,
    "avatar": "https://randomuser.me/api/portraits/women/3.jpg",
    "date": "2026-05-01"
  },
  {
    "id": 4,
    "author": "David Kim",
    "title": "Engineering Manager at EnterpriseCo",
    "content": "Enterprise features like SSO and on-premise deployment made adoption seamless. The audit logs are comprehensive.",
    "rating": 5,
    "avatar": "https://randomuser.me/api/portraits/men/4.jpg",
    "date": "2026-05-10"
  }
]
'@
$testimonials | Out-File -FilePath "data\seed\testimonials.json" -Encoding UTF8

Write-Host "[13/15] Creating case studies..." -ForegroundColor Yellow

$caseStudies = @'
# data/seed/case_studies.json
[
  {
    "id": 1,
    "title": "How TechStart Built Their MVP in 7 Days",
    "company": "TechStart Inc",
    "industry": "SaaS",
    "challenge": "Needed to launch quickly with limited engineering resources",
    "solution": "Used FactoryOS AI Pro to generate full-stack application",
    "results": {
      "development_time": "3 months → 1 week",
      "cost_savings": "$150,000",
      "code_quality": "92% validation score"
    },
    "testimonial_id": 1,
    "published_date": "2026-04-15"
  },
  {
    "id": 2,
    "title": "40% Code Quality Improvement at DevShop",
    "company": "DevShop",
    "industry": "Agency",
    "challenge": "Inconsistent code quality across projects",
    "solution": "Implemented FactoryOS AI self-improving feedback loop",
    "results": {
      "quality_improvement": "40%",
      "review_time": "Reduced by 60%",
      "client_satisfaction": "4.9/5"
    },
    "testimonial_id": 2,
    "published_date": "2026-04-20"
  }
]
'@
$caseStudies | Out-File -FilePath "data\seed\case_studies.json" -Encoding UTF8

Write-Host "[14/15] Creating seed data loader script..." -ForegroundColor Yellow

$seedLoader = @'
# scripts/seed/load_seed_data.py
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

def load_json_file(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)

def load_demo_users():
    users = load_json_file("scripts/seed/demo_users.json")
    print(f"Loaded {len(users)} demo users")
    return users

def load_demo_projects():
    projects = load_json_file("scripts/seed/demo_projects.json")
    print(f"Loaded {len(projects)} demo projects")
    return projects

def load_demo_batches():
    batches = load_json_file("scripts/seed/demo_batches.json")
    print(f"Loaded {len(batches)} demo batches")
    return batches

def load_testimonials():
    testimonials = load_json_file("data/seed/testimonials.json")
    print(f"Loaded {len(testimonials)} testimonials")
    return testimonials

def load_case_studies():
    case_studies = load_json_file("data/seed/case_studies.json")
    print(f"Loaded {len(case_studies)} case studies")
    return case_studies

if __name__ == "__main__":
    print("Loading seed data...")
    load_demo_users()
    load_demo_projects()
    load_demo_batches()
    load_testimonials()
    load_case_studies()
    print("Seed data loaded successfully!")
'@
$seedLoader | Out-File -FilePath "scripts\seed\load_seed_data.py" -Encoding UTF8

Write-Host "[15/15] Updating project_state.json..." -ForegroundColor Yellow

$stateJson = '{
  "product_name": "FactoryOS AI",
  "tagline": "The Autonomous AI Software Engineering Platform",
  "current_version": "v1.5",
  "phase": "Phase 1 - Productization",
  "batch": "Batch 4 of 5 - Multilingual Support & Demo Seed Data",
  "status": "complete",
  "last_updated": "' + (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ') + '",
  "phase1_progress": {
    "batch1_branding_docs": "complete",
    "batch2_landing_cms": "complete",
    "batch3_billing_api": "complete",
    "batch4_multilingual_seed": "complete",
    "batch5_investor_materials": "pending"
  },
  "languages_supported": ["en", "es", "de", "fr", "ja", "zh"],
  "generated_assets_batch4": [
    "frontend/src/i18n/locales/en/common.json",
    "frontend/src/i18n/locales/es/common.json",
    "frontend/src/i18n/locales/de/common.json",
    "frontend/src/i18n/locales/fr/common.json",
    "frontend/src/i18n/locales/ja/common.json",
    "frontend/src/i18n/locales/zh/common.json",
    "frontend/src/i18n/config.js",
    "scripts/seed/demo_users.json",
    "scripts/seed/demo_projects.json",
    "scripts/seed/demo_batches.json",
    "data/seed/testimonials.json",
    "data/seed/case_studies.json",
    "scripts/seed/load_seed_data.py"
  ],
  "demo_data": {
    "users": 3,
    "projects": 3,
    "batches": 4,
    "testimonials": 4,
    "case_studies": 2
  },
  "git_repository": "https://github.com/shomonrobie/ai-factory",
  "next_batch": "phase1_batch5 - Investor Materials (Pitch Deck, Financial Projections, Competitive Analysis)"
}'

$stateJson | Out-File -FilePath "project_state.json" -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "PHASE 1 BATCH 4 COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Generated Assets:" -ForegroundColor Cyan
Write-Host "  - i18n Infrastructure (6 languages: English, Spanish, German, French, Japanese, Chinese)" -ForegroundColor White
Write-Host "  - Translation files for all UI components" -ForegroundColor White
Write-Host "  - Language switcher configuration" -ForegroundColor White
Write-Host "  - Demo seed users (3 users with different tiers)" -ForegroundColor White
Write-Host "  - Demo projects (3 sample projects)" -ForegroundColor White
Write-Host "  - Demo batches (4 example batches with results)" -ForegroundColor White
Write-Host "  - Testimonials (4 customer testimonials)" -ForegroundColor White
Write-Host "  - Case studies (2 detailed success stories)" -ForegroundColor White
Write-Host "  - Seed data loader script" -ForegroundColor White
Write-Host ""
Write-Host "Updated project_state.json" -ForegroundColor Green
Write-Host ""
Write-Host "Next Batch: Phase 1 Batch 5 - Investor Materials" -ForegroundColor Yellow
Write-Host "  - Pitch deck content (10-15 slides)" -ForegroundColor White
Write-Host "  - Financial projections (3-year forecast)" -ForegroundColor White
Write-Host "  - Competitive analysis matrix" -ForegroundColor White
Write-Host "  - Market size and TAM/SAM/SOM analysis" -ForegroundColor White
Write-Host "  - Investor one-pager" -ForegroundColor White
Write-Host "  - Due diligence checklist" -ForegroundColor White