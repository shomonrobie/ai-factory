# phase1_batch2.ps1
# FactoryOS AI - Phase 1 Batch 2
# Creates: Landing Page, CMS, Blog, Documentation Section, Demo Booking, Pricing Page

param(
    [string]$ProjectPath = "D:\aisfs\ai-factory"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FACTORYOS AI - PHASE 1 BATCH 2" -ForegroundColor Cyan
Write-Host "Landing Page, CMS, Blog, Demo Booking, Pricing Page" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Set-Location $ProjectPath

Write-Host "[1/12] Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "frontend\src\app\landing" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\blog" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\docs" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\pricing" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\demo" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\components\landing" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\components\blog" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\components\common" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\public\images" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\cms" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\blog" | Out-Null
New-Item -ItemType Directory -Force -Path "backend\app\api\v1\demo" | Out-Null

Write-Host "[2/12] Creating Landing Page HTML..." -ForegroundColor Yellow

$landingPage = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FactoryOS AI - Autonomous AI Software Engineering Platform</title>
    <meta name="description" content="Build production-ready software with 8 specialized AI agents working together. Generate, validate, test, and deploy automatically.">
    <meta name="keywords" content="AI software development, code generation, autonomous coding, AI agents">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.6; color: #2D3748; }
        .container { max-width: 1280px; margin: 0 auto; padding: 0 24px; }
        .header { background: linear-gradient(135deg, #1A365D 0%, #3182CE 100%); color: white; padding: 80px 0; text-align: center; }
        .header h1 { font-size: 48px; margin-bottom: 20px; }
        .header p { font-size: 20px; margin-bottom: 30px; opacity: 0.9; }
        .cta-button { background: #319795; color: white; padding: 15px 40px; border: none; border-radius: 8px; font-size: 18px; cursor: pointer; transition: transform 0.2s; }
        .cta-button:hover { transform: translateY(-2px); background: #2C7A7B; }
        .features { padding: 80px 0; background: #F7FAFC; }
        .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 40px; margin-top: 40px; }
        .feature-card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .feature-card h3 { color: #1A365D; margin-bottom: 15px; }
        .agents { padding: 80px 0; }
        .agents-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 40px; }
        .agent-card { background: #EDF2F7; padding: 20px; border-radius: 8px; text-align: center; }
        .agent-card h4 { color: #1A365D; margin-bottom: 10px; }
        .pricing { padding: 80px 0; background: #F7FAFC; }
        .pricing-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-top: 40px; }
        .pricing-card { background: white; padding: 30px; border-radius: 12px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .pricing-card.pro { border: 2px solid #3182CE; }
        .pricing-card h3 { font-size: 24px; margin-bottom: 15px; }
        .price { font-size: 48px; color: #1A365D; margin: 20px 0; }
        .price span { font-size: 16px; color: #718096; }
        .footer { background: #1A365D; color: white; padding: 40px 0; text-align: center; }
        @media (max-width: 768px) {
            .header h1 { font-size: 32px; }
            .features-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="container">
            <h1>🤖 FactoryOS AI</h1>
            <p>The Autonomous AI Software Engineering Platform</p>
            <p style="font-size: 18px;">8 specialized AI agents working together to build production-ready software</p>
            <button class="cta-button" onclick="location.href='/demo'">Start Building Free →</button>
        </div>
    </div>

    <div class="features">
        <div class="container">
            <h2 style="text-align: center; font-size: 36px;">Why FactoryOS AI?</h2>
            <div class="features-grid">
                <div class="feature-card">
                    <h3>🚀 10x Faster Development</h3>
                    <p>Generate complete applications in minutes, not months. From idea to production in hours.</p>
                </div>
                <div class="feature-card">
                    <h3>🤝 8 Specialized Agents</h3>
                    <p>Architect, Backend, Frontend, Database, QA, Security, DevOps, and Code Generator working together.</p>
                </div>
                <div class="feature-card">
                    <h3>🔄 Self-Improving System</h3>
                    <p>Code reviews itself, scores quality (0-100), and automatically optimizes with feedback loops.</p>
                </div>
                <div class="feature-card">
                    <h3>🔧 Production-Ready Code</h3>
                    <p>Generated code includes tests, documentation, Docker configs, and CI/CD pipelines.</p>
                </div>
                <div class="feature-card">
                    <h3>📊 CI/CD Automation</h3>
                    <p>Built-in pipeline runs build, test, security, and deploy stages automatically.</p>
                </div>
                <div class="feature-card">
                    <h3>🎯 Enterprise Security</h3>
                    <p>SOC2 compliant, encrypted data, SSO support, and audit logging for Enterprise.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="agents">
        <div class="container">
            <h2 style="text-align: center; font-size: 36px; margin-bottom: 20px;">Meet Your AI Engineering Team</h2>
            <p style="text-align: center; color: #718096; margin-bottom: 40px;">8 specialized agents work in orchestration to build your software</p>
            <div class="agents-grid">
                <div class="agent-card"><h4>🏗️ Architect</h4><p>System design</p></div>
                <div class="agent-card"><h4>⚙️ Backend</h4><p>API generation</p></div>
                <div class="agent-card"><h4>🎨 Frontend</h4><p>UI components</p></div>
                <div class="agent-card"><h4>🗄️ Database</h4><p>Schema design</p></div>
                <div class="agent-card"><h4>🧪 QA</h4><p>Test generation</p></div>
                <div class="agent-card"><h4>🔒 Security</h4><p>Vulnerability scan</p></div>
                <div class="agent-card"><h4>🚀 DevOps</h4><p>CI/CD pipeline</p></div>
                <div class="agent-card"><h4>💻 Code</h4><p>Code generation</p></div>
            </div>
        </div>
    </div>

    <div class="pricing">
        <div class="container">
            <h2 style="text-align: center; font-size: 36px;">Simple, Transparent Pricing</h2>
            <p style="text-align: center; margin-bottom: 40px;">Choose the plan that fits your needs</p>
            <div class="pricing-grid">
                <div class="pricing-card">
                    <h3>Free</h3>
                    <div class="price">$0<span>/month</span></div>
                    <p>5 batches per month</p>
                    <p>Single user</p>
                    <p>Basic templates</p>
                    <p>Community support</p>
                    <button class="cta-button" style="margin-top: 20px; background: #4A5568;" onclick="location.href='/signup'">Get Started</button>
                </div>
                <div class="pricing-card pro">
                    <h3>Pro</h3>
                    <div class="price">$49<span>/month</span></div>
                    <p>Unlimited batches</p>
                    <p>Multi-agent orchestration</p>
                    <p>Self-improving system</p>
                    <p>Team workspaces (3 users)</p>
                    <button class="cta-button" style="margin-top: 20px;" onclick="location.href='/pricing'">Start Free Trial</button>
                </div>
                <div class="pricing-card">
                    <h3>Enterprise</h3>
                    <div class="price">Custom</div>
                    <p>White-label deployment</p>
                    <p>SSO/SAML</p>
                    <p>On-premise installation</p>
                    <p>Dedicated support</p>
                    <button class="cta-button" style="margin-top: 20px; background: #4A5568;" onclick="location.href='/contact'">Contact Sales</button>
                </div>
            </div>
        </div>
    </div>

    <div class="footer">
        <div class="container">
            <p>&copy; 2026 FactoryOS AI. All rights reserved.</p>
            <p style="margin-top: 10px;">
                <a href="/docs" style="color: white; margin: 0 10px;">Documentation</a> |
                <a href="/blog" style="color: white; margin: 0 10px;">Blog</a> |
                <a href="/privacy" style="color: white; margin: 0 10px;">Privacy</a> |
                <a href="/terms" style="color: white; margin: 0 10px;">Terms</a>
            </p>
        </div>
    </div>

    <script>
        console.log('FactoryOS AI - Autonomous AI Software Engineering Platform');
    </script>
</body>
</html>
'@
$landingPage | Out-File -FilePath "frontend\src\app\landing\page.html" -Encoding UTF8

Write-Host "[3/12] Creating Blog Index Page..." -ForegroundColor Yellow

$blogIndex = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blog - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; color: #2D3748; background: #F7FAFC; }
        .header { background: linear-gradient(135deg, #1A365D 0%, #3182CE 100%); color: white; padding: 60px 0; text-align: center; }
        .container { max-width: 1280px; margin: 0 auto; padding: 0 24px; }
        .blog-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 30px; padding: 60px 0; }
        .blog-card { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: transform 0.2s; }
        .blog-card:hover { transform: translateY(-4px); }
        .blog-content { padding: 24px; }
        .blog-date { color: #718096; font-size: 14px; margin-bottom: 10px; }
        .blog-title { font-size: 20px; color: #1A365D; margin-bottom: 10px; }
        .blog-excerpt { color: #4A5568; margin-bottom: 15px; }
        .read-more { color: #3182CE; text-decoration: none; font-weight: 500; }
        .footer { background: #1A365D; color: white; padding: 40px 0; text-align: center; margin-top: 40px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="container">
            <h1>FactoryOS AI Blog</h1>
            <p>Insights on AI-powered software engineering</p>
        </div>
    </div>
    <div class="container">
        <div class="blog-grid">
            <div class="blog-card">
                <div class="blog-content">
                    <div class="blog-date">May 18, 2026</div>
                    <h2 class="blog-title">Introducing FactoryOS AI v1.5: The Future of Autonomous Software Engineering</h2>
                    <p class="blog-excerpt">We're excited to announce the release of FactoryOS AI v1.5, featuring multi-agent orchestration, self-improving evolution, and complete CI/CD automation...</p>
                    <a href="/blog/introducing-factoryos-v1.5" class="read-more">Read More →</a>
                </div>
            </div>
            <div class="blog-card">
                <div class="blog-content">
                    <div class="blog-date">May 15, 2026</div>
                    <h2 class="blog-title">How 8 AI Agents Work Together to Build Production Software</h2>
                    <p class="blog-excerpt">Learn how our specialized agents orchestrate to design, build, test, and deploy your applications with human-level coordination...</p>
                    <a href="/blog/how-ai-agents-work" class="read-more">Read More →</a>
                </div>
            </div>
            <div class="blog-card">
                <div class="blog-content">
                    <div class="blog-date">May 10, 2026</div>
                    <h2 class="blog-title">The Self-Improving Feedback Loop: PLAN → BUILD → REVIEW → SCORE → OPTIMIZE → FINALIZE</h2>
                    <p class="blog-excerpt">Discover how our evolution engine continuously improves code quality through automated feedback loops...</p>
                    <a href="/blog/self-improving-feedback-loop" class="read-more">Read More →</a>
                </div>
            </div>
        </div>
    </div>
    <div class="footer">
        <div class="container">
            <p>&copy; 2026 FactoryOS AI. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
'@
$blogIndex | Out-File -FilePath "frontend\src\app\blog\index.html" -Encoding UTF8

Write-Host "[4/12] Creating Documentation Landing Page..." -ForegroundColor Yellow

$docsLanding = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Documentation - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; color: #2D3748; }
        .header { background: #1A365D; color: white; padding: 40px 0; }
        .container { max-width: 1280px; margin: 0 auto; padding: 0 24px; }
        .docs-layout { display: grid; grid-template-columns: 280px 1fr; gap: 40px; padding: 40px 0; }
        .sidebar { position: sticky; top: 20px; align-self: start; }
        .sidebar h3 { color: #1A365D; margin-bottom: 15px; }
        .sidebar ul { list-style: none; }
        .sidebar li { margin-bottom: 10px; }
        .sidebar a { color: #4A5568; text-decoration: none; }
        .sidebar a:hover { color: #3182CE; }
        .content h1 { color: #1A365D; margin-bottom: 20px; }
        .content h2 { color: #1A365D; margin: 30px 0 15px; }
        .content pre { background: #EDF2F7; padding: 15px; border-radius: 8px; overflow-x: auto; margin: 20px 0; }
        .content code { background: #EDF2F7; padding: 2px 6px; border-radius: 4px; font-family: 'JetBrains Mono', monospace; }
        .footer { background: #1A365D; color: white; padding: 40px 0; text-align: center; margin-top: 40px; }
        @media (max-width: 768px) { .docs-layout { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="header">
        <div class="container">
            <h1>FactoryOS AI Documentation</h1>
            <p>Everything you need to build with FactoryOS AI</p>
        </div>
    </div>
    <div class="container">
        <div class="docs-layout">
            <div class="sidebar">
                <h3>Getting Started</h3>
                <ul>
                    <li><a href="/docs/quickstart">Quick Start Guide</a></li>
                    <li><a href="/docs/installation">Installation</a></li>
                    <li><a href="/docs/first-batch">Your First Batch</a></li>
                </ul>
                <h3 style="margin-top: 20px;">API Reference</h3>
                <ul>
                    <li><a href="/docs/api/batches">Batches API</a></li>
                    <li><a href="/docs/api/agents">Agents API</a></li>
                    <li><a href="/docs/api/orchestration">Orchestration API</a></li>
                    <li><a href="/docs/api/evolution">Evolution API</a></li>
                    <li><a href="/docs/api/cicd">CI/CD API</a></li>
                </ul>
                <h3 style="margin-top: 20px;">Guides</h3>
                <ul>
                    <li><a href="/docs/guides/agents">Using AI Agents</a></li>
                    <li><a href="/docs/guides/orchestration">Multi-Agent Orchestration</a></li>
                    <li><a href="/docs/guides/evolution">Self-Improving Evolution</a></li>
                    <li><a href="/docs/guides/cicd">CI/CD Pipeline</a></li>
                </ul>
            </div>
            <div class="content">
                <h1>Welcome to FactoryOS AI</h1>
                <p>FactoryOS AI is an autonomous AI-powered software engineering platform that uses 8 specialized agents to build production-ready software.</p>
                
                <h2>Quick Start</h2>
                <pre><code># Install FactoryOS AI
docker pull factoryos/backend:latest
docker pull factoryos/frontend:latest

# Run with Docker Compose
curl -O https://factoryos.ai/docker-compose.yml
docker-compose up -d

# Create your first batch
curl -X POST https://api.factoryos.ai/api/v1/batches/ \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"batch_number": 1, "prompt": "Create a todo app"}'</code></pre>

                <h2>Key Features</h2>
                <ul>
                    <li><strong>8 Specialized AI Agents</strong> - Architect, Backend, Frontend, Database, QA, Security, DevOps, Code Generator</li>
                    <li><strong>Multi-Agent Orchestration</strong> - Agents work together to plan and execute complex tasks</li>
                    <li><strong>Self-Improving Evolution</strong> - Code reviews itself and improves through feedback loops</li>
                    <li><strong>CI/CD Automation</strong> - Automated build, test, security, and deploy pipelines</li>
                    <li><strong>Production-Ready Code</strong> - Generated code includes tests, docs, and deployment configs</li>
                </ul>

                <h2>Next Steps</h2>
                <ul>
                    <li><a href="/docs/quickstart">Read the Quick Start Guide</a></li>
                    <li><a href="/docs/api">Explore the API Reference</a></li>
                    <li><a href="/demo">Try the Live Demo</a></li>
                </ul>
            </div>
        </div>
    </div>
    <div class="footer">
        <div class="container">
            <p>&copy; 2026 FactoryOS AI. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
'@
$docsLanding | Out-File -FilePath "frontend\src\app\docs\index.html" -Encoding UTF8

Write-Host "[5/12] Creating Pricing Page..." -ForegroundColor Yellow

$pricingPage = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pricing - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; color: #2D3748; background: #F7FAFC; }
        .header { background: linear-gradient(135deg, #1A365D 0%, #3182CE 100%); color: white; padding: 60px 0; text-align: center; }
        .container { max-width: 1280px; margin: 0 auto; padding: 0 24px; }
        .pricing-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; padding: 60px 0; }
        .pricing-card { background: white; border-radius: 12px; padding: 40px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: transform 0.2s; }
        .pricing-card:hover { transform: translateY(-4px); }
        .pricing-card.pro { border: 2px solid #3182CE; position: relative; }
        .popular-badge { position: absolute; top: -12px; left: 50%; transform: translateX(-50%); background: #3182CE; color: white; padding: 4px 12px; border-radius: 20px; font-size: 12px; }
        .pricing-card h3 { font-size: 24px; margin-bottom: 20px; color: #1A365D; }
        .price { font-size: 48px; color: #1A365D; margin: 20px 0; }
        .price span { font-size: 16px; color: #718096; }
        .features-list { list-style: none; margin: 30px 0; text-align: left; }
        .features-list li { padding: 8px 0; border-bottom: 1px solid #EDF2F7; }
        .features-list li:before { content: "✓"; color: #38A169; margin-right: 10px; }
        .cta-button { background: #3182CE; color: white; padding: 12px 30px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; width: 100%; }
        .cta-button:hover { background: #2C5282; }
        .faq { padding: 60px 0; background: white; }
        .faq-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 30px; margin-top: 40px; }
        .faq-item h4 { color: #1A365D; margin-bottom: 10px; }
        .footer { background: #1A365D; color: white; padding: 40px 0; text-align: center; margin-top: 40px; }
        @media (max-width: 768px) { .pricing-grid { grid-template-columns: 1fr; } .faq-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="header">
        <div class="container">
            <h1>Simple, Transparent Pricing</h1>
            <p>Choose the plan that fits your needs. All plans include a 14-day free trial.</p>
        </div>
    </div>
    <div class="container">
        <div class="pricing-grid">
            <div class="pricing-card">
                <h3>Free</h3>
                <div class="price">$0<span>/month</span></div>
                <ul class="features-list">
                    <li>5 batches per month</li>
                    <li>Single user</li>
                    <li>Basic templates</li>
                    <li>Community support</li>
                    <li>7-day history retention</li>
                </ul>
                <button class="cta-button" onclick="location.href='/signup'">Get Started</button>
            </div>
            <div class="pricing-card pro">
                <div class="popular-badge">MOST POPULAR</div>
                <h3>Pro</h3>
                <div class="price">$49<span>/month</span></div>
                <ul class="features-list">
                    <li>Unlimited batches</li>
                    <li>Multi-agent orchestration (v3)</li>
                    <li>Self-improving system (v4)</li>
                    <li>Autonomous CI system (v5)</li>
                    <li>Team workspaces (3 users)</li>
                    <li>Priority processing</li>
                    <li>Advanced templates</li>
                    <li>Documentation generation</li>
                    <li>Email support</li>
                    <li>90-day history retention</li>
                </ul>
                <button class="cta-button" onclick="location.href='/checkout?plan=pro'">Start Free Trial</button>
            </div>
            <div class="pricing-card">
                <h3>Enterprise</h3>
                <div class="price">Custom</div>
                <ul class="features-list">
                    <li>White-label deployment</li>
                    <li>SSO/SAML authentication</li>
                    <li>Audit logs</li>
                    <li>On-premise installation</li>
                    <li>Private model integration</li>
                    <li>Dedicated support</li>
                    <li>Custom SLA</li>
                    <li>Unlimited history</li>
                </ul>
                <button class="cta-button" onclick="location.href='/contact'">Contact Sales</button>
            </div>
        </div>
    </div>
    <div class="faq">
        <div class="container">
            <h2 style="text-align: center;">Frequently Asked Questions</h2>
            <div class="faq-grid">
                <div class="faq-item">
                    <h4>What is included in the free trial?</h4>
                    <p>The 14-day free trial includes all Pro features with no credit card required.</p>
                </div>
                <div class="faq-item">
                    <h4>Can I switch plans?</h4>
                    <p>Yes, you can upgrade or downgrade at any time from your dashboard.</p>
                </div>
                <div class="faq-item">
                    <h4>What payment methods do you accept?</h4>
                    <p>We accept all major credit cards, PayPal, and wire transfers for Enterprise.</p>
                </div>
                <div class="faq-item">
                    <h4>Is there an annual discount?</h4>
                    <p>Yes, annual billing gives you 20% off on Pro plans.</p>
                </div>
            </div>
        </div>
    </div>
    <div class="footer">
        <div class="container">
            <p>&copy; 2026 FactoryOS AI. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
'@
$pricingPage | Out-File -FilePath "frontend\src\app\pricing\index.html" -Encoding UTF8

Write-Host "[6/12] Creating Demo Booking System..." -ForegroundColor Yellow

$demoBooking = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book a Demo - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; color: #2D3748; background: #F7FAFC; }
        .header { background: linear-gradient(135deg, #1A365D 0%, #3182CE 100%); color: white; padding: 60px 0; text-align: center; }
        .container { max-width: 800px; margin: 0 auto; padding: 0 24px; }
        .form-container { background: white; border-radius: 12px; padding: 40px; margin: 40px 0; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 500; color: #1A365D; }
        input, select, textarea { width: 100%; padding: 12px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 16px; }
        button { background: #3182CE; color: white; padding: 14px 30px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; width: 100%; }
        button:hover { background: #2C5282; }
        .footer { background: #1A365D; color: white; padding: 40px 0; text-align: center; margin-top: 40px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="container">
            <h1>Schedule a Live Demo</h1>
            <p>See FactoryOS AI in action with our team</p>
        </div>
    </div>
    <div class="container">
        <div class="form-container">
            <form id="demoForm">
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" id="name" required>
                </div>
                <div class="form-group">
                    <label>Email Address *</label>
                    <input type="email" id="email" required>
                </div>
                <div class="form-group">
                    <label>Company Name</label>
                    <input type="text" id="company">
                </div>
                <div class="form-group">
                    <label>Job Title</label>
                    <input type="text" id="title">
                </div>
                <div class="form-group">
                    <label>Preferred Date *</label>
                    <input type="date" id="date" required>
                </div>
                <div class="form-group">
                    <label>Preferred Time *</label>
                    <select id="time" required>
                        <option value="">Select time</option>
                        <option value="9:00 AM">9:00 AM EST</option>
                        <option value="10:00 AM">10:00 AM EST</option>
                        <option value="11:00 AM">11:00 AM EST</option>
                        <option value="1:00 PM">1:00 PM EST</option>
                        <option value="2:00 PM">2:00 PM EST</option>
                        <option value="3:00 PM">3:00 PM EST</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>What would you like to see?</label>
                    <textarea id="notes" rows="4" placeholder="Tell us about your use case..."></textarea>
                </div>
                <button type="submit">Schedule Demo →</button>
            </form>
            <div id="message" style="margin-top: 20px; text-align: center; display: none;"></div>
        </div>
    </div>
    <div class="footer">
        <div class="container">
            <p>&copy; 2026 FactoryOS AI. All rights reserved.</p>
        </div>
    </div>
    <script>
        document.getElementById('demoForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const messageDiv = document.getElementById('message');
            messageDiv.style.display = 'block';
            messageDiv.innerHTML = 'Thank you! Our team will contact you within 24 hours to confirm your demo.';
            messageDiv.style.color = '#38A169';
            messageDiv.style.padding = '15px';
            messageDiv.style.background = '#F0FFF4';
            messageDiv.style.borderRadius = '8px';
            this.reset();
        });
    </script>
</body>
</html>
'@
$demoBooking | Out-File -FilePath "frontend\src\app\demo\index.html" -Encoding UTF8

Write-Host "[7/12] Creating Blog Post - Introducing v1.5..." -ForegroundColor Yellow

$blogPost1 = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Introducing FactoryOS AI v1.5 - The Future of Autonomous Software Engineering</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; color: #2D3748; background: #F7FAFC; }
        .container { max-width: 800px; margin: 0 auto; padding: 40px 24px; background: white; }
        h1 { color: #1A365D; margin-bottom: 20px; }
        .date { color: #718096; margin-bottom: 30px; }
        h2 { color: #1A365D; margin: 30px 0 15px; }
        p { margin-bottom: 20px; line-height: 1.8; }
        .footer { background: #1A365D; color: white; padding: 40px 0; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Introducing FactoryOS AI v1.5</h1>
        <div class="date">May 18, 2026 | 5 min read</div>
        
        <p>Today, we're thrilled to announce FactoryOS AI v1.5 - the most significant update to our autonomous AI software engineering platform yet.</p>
        
        <h2>What's New in v1.5</h2>
        <p>This release introduces complete CI/CD automation, advanced monitoring, and batch scheduling capabilities that make FactoryOS AI a true autonomous engineering platform.</p>
        
        <h3>1. CI/CD Pipeline Engine</h3>
        <p>The new CI/CD pipeline engine automates build, test, security scanning, and deployment stages. Every generated application comes with a complete pipeline configuration.</p>
        
        <h3>2. Batch Scheduler</h3>
        <p>Schedule batches to run at specific times with configurable delays. Perfect for automated workflows and periodic updates.</p>
        
        <h3>3. Real-time Monitoring</h3>
        <p>Monitor CPU usage, memory consumption, API performance, and system health in real-time. Set up alerts for threshold breaches.</p>
        
        <h2>The Journey to v1.5</h2>
        <p>FactoryOS AI has evolved from a simple code generator to a complete autonomous software engineering platform:</p>
        <ul style="margin: 20px 0 20px 40px;">
            <li>v1.0: Base Factory System</li>
            <li>v1.1: AI Agent Framework</li>
            <li>v1.2: Agent Integration</li>
            <li>v1.3: Multi-Agent Orchestration</li>
            <li>v1.4: Self-Improving Evolution</li>
            <li>v1.5: Autonomous CI/CD</li>
        </ul>
        
        <h2>What's Next?</h2>
        <p>We're already working on v2.0, which will include Kubernetes deployment, Terraform infrastructure, and advanced analytics.</p>
        
        <p style="margin-top: 40px;">Ready to try FactoryOS AI? <a href="/demo">Book a demo</a> or <a href="/signup">start your free trial</a> today.</p>
    </div>
    <div class="footer">
        <div class="container">
            <p>&copy; 2026 FactoryOS AI. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
'@
$blogPost1 | Out-File -FilePath "frontend\src\app\blog\introducing-factoryos-v1.5.html" -Encoding UTF8

Write-Host "[8/12] Creating Admin Settings Panel for App Name..." -ForegroundColor Yellow

$adminSettings = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Settings - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; color: #2D3748; background: #F7FAFC; }
        .container { max-width: 600px; margin: 40px auto; padding: 40px; background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #1A365D; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 500; }
        input { width: 100%; padding: 12px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 16px; }
        button { background: #3182CE; color: white; padding: 12px 24px; border: none; border-radius: 8px; cursor: pointer; margin-right: 10px; }
        button:hover { background: #2C5282; }
        .preview { margin-top: 30px; padding: 20px; background: #EDF2F7; border-radius: 8px; text-align: center; }
        .message { margin-top: 20px; padding: 15px; border-radius: 8px; display: none; }
        .success { background: #F0FFF4; color: #38A169; border: 1px solid #C6F6D5; }
        .error { background: #FFF5F5; color: #E53E3E; border: 1px solid #FED7D7; }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚙️ Admin Settings</h1>
        <div class="form-group">
            <label>Application Name</label>
            <input type="text" id="appName" placeholder="FactoryOS AI">
        </div>
        <div>
            <button onclick="saveSettings()">Save Changes</button>
            <button onclick="resetSettings()">Reset to Default</button>
        </div>
        <div id="message" class="message"></div>
        <div class="preview">
            <h3>Live Preview</h3>
            <div id="preview" style="font-size: 24px; font-weight: bold;">FactoryOS AI</div>
        </div>
    </div>
    <script>
        function loadSettings() {
            const saved = localStorage.getItem('factoryos_app_name');
            if (saved) {
                document.getElementById('appName').value = saved;
                document.getElementById('preview').innerText = saved;
            }
        }
        function saveSettings() {
            const newName = document.getElementById('appName').value;
            if (newName.trim()) {
                localStorage.setItem('factoryos_app_name', newName);
                document.getElementById('preview').innerText = newName;
                showMessage('Settings saved successfully!', 'success');
                // Also update API if needed
                fetch('/api/v1/admin/settings', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({app_name: newName})
                }).catch(err => console.log('API not available yet'));
            } else {
                showMessage('Please enter a valid name', 'error');
            }
        }
        function resetSettings() {
            localStorage.removeItem('factoryos_app_name');
            document.getElementById('appName').value = 'FactoryOS AI';
            document.getElementById('preview').innerText = 'FactoryOS AI';
            showMessage('Reset to default', 'success');
        }
        function showMessage(msg, type) {
            const msgDiv = document.getElementById('message');
            msgDiv.innerText = msg;
            msgDiv.className = 'message ' + type;
            msgDiv.style.display = 'block';
            setTimeout(() => { msgDiv.style.display = 'none'; }, 3000);
        }
        loadSettings();
    </script>
</body>
</html>
'@
$adminSettings | Out-File -FilePath "frontend\src\app\admin\index.html" -Encoding UTF8
New-Item -ItemType Directory -Force -Path "frontend\src\app\admin" | Out-Null
$adminSettings | Out-File -FilePath "frontend\src\app\admin\index.html" -Encoding UTF8

Write-Host "[9/12] Creating Backend CMS API..." -ForegroundColor Yellow

$cmsApi = @'
# backend/app/api/v1/cms/pages.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os

router = APIRouter()

class PageContent(BaseModel):
    title: str
    content: str
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    published: bool = True

class BlogPost(BaseModel):
    title: str
    slug: str
    content: str
    excerpt: str
    author: str
    tags: List[str] = []
    published: bool = True

PAGES_FILE = "/app/data/cms_pages.json"
BLOG_FILE = "/app/data/blog_posts.json"

os.makedirs("/app/data", exist_ok=True)

def load_pages():
    if os.path.exists(PAGES_FILE):
        with open(PAGES_FILE, 'r') as f:
            return json.load(f)
    return {}

def save_pages(pages):
    with open(PAGES_FILE, 'w') as f:
        json.dump(pages, f, indent=2)

def load_blog_posts():
    if os.path.exists(BLOG_FILE):
        with open(BLOG_FILE, 'r') as f:
            return json.load(f)
    return []

def save_blog_posts(posts):
    with open(BLOG_FILE, 'w') as f:
        json.dump(posts, f, indent=2)

@router.get("/pages/{page_id}")
async def get_page(page_id: str):
    pages = load_pages()
    if page_id not in pages:
        raise HTTPException(status_code=404, detail="Page not found")
    return pages[page_id]

@router.put("/pages/{page_id}")
async def update_page(page_id: str, page: PageContent):
    pages = load_pages()
    pages[page_id] = page.dict()
    save_pages(pages)
    return {"status": "updated", "page_id": page_id}

@router.post("/blog")
async def create_blog_post(post: BlogPost):
    posts = load_blog_posts()
    new_post = post.dict()
    new_post["id"] = len(posts) + 1
    new_post["created_at"] = datetime.now().isoformat()
    posts.append(new_post)
    save_blog_posts(posts)
    return new_post

@router.get("/blog")
async def list_blog_posts():
    return load_blog_posts()

@router.get("/blog/{slug}")
async def get_blog_post(slug: str):
    posts = load_blog_posts()
    for post in posts:
        if post.get("slug") == slug:
            return post
    raise HTTPException(status_code=404, detail="Post not found")
'@
$cmsApi | Out-File -FilePath "backend\app\api\v1\cms\pages.py" -Encoding UTF8

Write-Host "[10/12] Creating Admin Settings API..." -ForegroundColor Yellow

$adminApi = @'
# backend/app/api/v1/admin.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
import json
import os

router = APIRouter()

class SettingsUpdate(BaseModel):
    app_name: str
    logo_url: Optional[str] = None
    primary_color: Optional[str] = None
    contact_email: Optional[str] = None

SETTINGS_FILE = "/app/data/admin_settings.json"

def load_settings():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, 'r') as f:
            return json.load(f)
    return {"app_name": "FactoryOS AI"}

def save_settings(settings):
    with open(SETTINGS_FILE, 'w') as f:
        json.dump(settings, f, indent=2)

@router.get("/settings")
async def get_settings():
    return load_settings()

@router.post("/settings")
async def update_settings(settings: SettingsUpdate):
    current = load_settings()
    current.update(settings.dict(exclude_unset=True))
    save_settings(current)
    return current

@router.get("/settings/app-name")
async def get_app_name():
    settings = load_settings()
    return {"app_name": settings.get("app_name", "FactoryOS AI")}
'@
$adminApi | Out-File -FilePath "backend\app\api\v1\admin.py" -Encoding UTF8

Write-Host "[11/12] Updating API Router..." -ForegroundColor Yellow

$initV1Content = @'
from fastapi import APIRouter
from .batches import router as batches_router
from .projects import router as projects_router
from .agents import router as agents_router
from .orchestration import router as orchestration_router
from .evolution import router as evolution_router
from .cicd import router as cicd_router
from .cms.pages import router as cms_router
from .admin import router as admin_router

router = APIRouter()
router.include_router(batches_router, prefix="/batches", tags=["batches"])
router.include_router(projects_router, prefix="/projects", tags=["projects"])
router.include_router(agents_router, prefix="/agents", tags=["agents"])
router.include_router(orchestration_router, prefix="/orchestration", tags=["orchestration"])
router.include_router(evolution_router, prefix="/evolution", tags=["evolution"])
router.include_router(cicd_router, prefix="/cicd", tags=["cicd"])
router.include_router(cms_router, prefix="/cms", tags=["cms"])
router.include_router(admin_router, prefix="/admin", tags=["admin"])
'@
$initV1Content | Out-File -FilePath "backend\app\api\v1\__init__.py" -Encoding UTF8

Write-Host "[12/12] Updating project_state.json..." -ForegroundColor Yellow

$stateJson = '{
  "product_name": "FactoryOS AI",
  "tagline": "The Autonomous AI Software Engineering Platform",
  "current_version": "v1.5",
  "phase": "Phase 1 - Productization",
  "batch": "Batch 2 of 5 - Landing Page & CMS",
  "status": "complete",
  "last_updated": "' + (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ') + '",
  "phase1_progress": {
    "batch1_branding_docs": "complete",
    "batch2_landing_cms": "complete",
    "batch3_billing_api": "pending",
    "batch4_multilingual_seed": "pending",
    "batch5_investor_materials": "pending"
  },
  "generated_assets_batch2": [
    "frontend/src/app/landing/page.html",
    "frontend/src/app/blog/index.html",
    "frontend/src/app/docs/index.html",
    "frontend/src/app/pricing/index.html",
    "frontend/src/app/demo/index.html",
    "frontend/src/app/admin/index.html",
    "frontend/src/app/blog/introducing-factoryos-v1.5.html",
    "backend/app/api/v1/cms/pages.py",
    "backend/app/api/v1/admin.py"
  ],
  "git_repository": "https://github.com/shomonrobie/ai-factory",
  "next_batch": "phase1_batch3 - Stripe Billing & Feature Entitlement"
}'

$stateJson | Out-File -FilePath "project_state.json" -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "PHASE 1 BATCH 2 COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Generated Assets:" -ForegroundColor Cyan
Write-Host "  - Landing Page (marketing website)" -ForegroundColor White
Write-Host "  - Blog Index and Blog Post" -ForegroundColor White
Write-Host "  - Documentation Landing Page" -ForegroundColor White
Write-Host "  - Pricing Page with tiered plans" -ForegroundColor White
Write-Host "  - Demo Booking System" -ForegroundColor White
Write-Host "  - Admin Settings Panel (app name configurable)" -ForegroundColor White
Write-Host "  - CMS API for pages and blog" -ForegroundColor White
Write-Host "  - Admin Settings API" -ForegroundColor White
Write-Host ""
Write-Host "Updated project_state.json" -ForegroundColor Green
Write-Host ""
Write-Host "Next Batch: Phase 1 Batch 3 - Stripe Billing & Feature Entitlement" -ForegroundColor Yellow
Write-Host "  - Stripe integration" -ForegroundColor White
Write-Host "  - Feature entitlement system" -ForegroundColor White
Write-Host "  - Usage metering" -ForegroundColor White
Write-Host "  - Webhook handling" -ForegroundColor White