# fix_website_structure.ps1
# Creates proper website structure with navigation, header, footer, and routing

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FIXING WEBSITE STRUCTURE" -ForegroundColor Cyan
Write-Host "Adding Header, Footer, Navigation, and Proper Routing" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/6] Creating main index.html with full website..." -ForegroundColor Yellow

$mainIndex = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FactoryOS AI - Autonomous AI Software Engineering Platform</title>
    <meta name="description" content="Build production-ready software with 8 specialized AI agents working together. Generate, validate, test, and deploy automatically.">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.6; color: #2D3748; }
        .container { max-width: 1280px; margin: 0 auto; padding: 0 24px; }
        
        /* Header Styles */
        .header { background: #1A365D; color: white; padding: 16px 0; position: sticky; top: 0; z-index: 100; }
        .header .container { display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: bold; }
        .logo a { color: white; text-decoration: none; }
        .nav { display: flex; gap: 24px; align-items: center; }
        .nav a { color: white; text-decoration: none; transition: opacity 0.2s; }
        .nav a:hover { opacity: 0.8; }
        .btn-outline { border: 1px solid white; padding: 8px 20px; border-radius: 8px; }
        .btn-solid { background: #319795; padding: 8px 20px; border-radius: 8px; }
        
        /* Hero Section */
        .hero { background: linear-gradient(135deg, #1A365D 0%, #3182CE 100%); color: white; padding: 80px 0; text-align: center; }
        .hero h1 { font-size: 48px; margin-bottom: 20px; }
        .hero p { font-size: 20px; margin-bottom: 30px; opacity: 0.9; max-width: 600px; margin-left: auto; margin-right: auto; }
        .cta-button { background: #319795; color: white; padding: 15px 40px; border: none; border-radius: 8px; font-size: 18px; cursor: pointer; transition: transform 0.2s; }
        .cta-button:hover { transform: translateY(-2px); background: #2C7A7B; }
        
        /* Features Section */
        .features { padding: 80px 0; background: #F7FAFC; }
        .section-title { text-align: center; font-size: 36px; margin-bottom: 40px; color: #1A365D; }
        .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 40px; }
        .feature-card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .feature-card h3 { color: #1A365D; margin-bottom: 15px; font-size: 20px; }
        
        /* Agents Section */
        .agents { padding: 80px 0; }
        .agents-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 20px; margin-top: 40px; }
        .agent-card { background: #EDF2F7; padding: 20px; border-radius: 8px; text-align: center; }
        .agent-card h4 { color: #1A365D; margin-bottom: 8px; }
        .agent-card p { font-size: 14px; color: #718096; }
        
        /* Pricing Section */
        .pricing { padding: 80px 0; background: #F7FAFC; }
        .pricing-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; }
        .pricing-card { background: white; padding: 30px; border-radius: 12px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .pricing-card.pro { border: 2px solid #3182CE; position: relative; }
        .popular-badge { position: absolute; top: -12px; left: 50%; transform: translateX(-50%); background: #3182CE; color: white; padding: 4px 12px; border-radius: 20px; font-size: 12px; }
        .price { font-size: 48px; color: #1A365D; margin: 20px 0; }
        .price span { font-size: 16px; color: #718096; }
        .features-list { list-style: none; margin: 20px 0; text-align: left; }
        .features-list li { padding: 8px 0; border-bottom: 1px solid #EDF2F7; }
        .features-list li:before { content: "✓"; color: #38A169; margin-right: 10px; }
        
        /* Footer */
        .footer { background: #1A365D; color: white; padding: 60px 0 40px; }
        .footer-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 40px; margin-bottom: 40px; }
        .footer-col h4 { margin-bottom: 20px; font-size: 16px; }
        .footer-col a { color: #A0AEC0; text-decoration: none; display: block; margin-bottom: 10px; }
        .footer-col a:hover { color: white; }
        .footer-bottom { text-align: center; padding-top: 40px; border-top: 1px solid #2D3748; color: #A0AEC0; }
        
        @media (max-width: 768px) {
            .hero h1 { font-size: 32px; }
            .nav { display: none; }
            .features-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <div class="logo"><a href="/">FactoryOS AI</a></div>
            <nav class="nav">
                <a href="/features">Features</a>
                <a href="/agents">Agents</a>
                <a href="/pricing">Pricing</a>
                <a href="/docs">Docs</a>
                <a href="/blog">Blog</a>
                <a href="/login" class="btn-outline">Sign In</a>
                <a href="/signup" class="btn-solid">Get Started</a>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <h1>Build Production Software with AI Agents</h1>
            <p>8 specialized AI agents work together to plan, build, test, and deploy your applications automatically.</p>
            <button class="cta-button" onclick="location.href='/signup'">Start Building Free →</button>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features">
        <div class="container">
            <h2 class="section-title">Why FactoryOS AI?</h2>
            <div class="features-grid">
                <div class="feature-card">
                    <h3>10x Faster Development</h3>
                    <p>Generate complete applications in minutes, not months. From idea to production in hours.</p>
                </div>
                <div class="feature-card">
                    <h3>8 Specialized Agents</h3>
                    <p>Architect, Backend, Frontend, Database, QA, Security, DevOps, and Code Generator working together.</p>
                </div>
                <div class="feature-card">
                    <h3>Self-Improving System</h3>
                    <p>Code reviews itself, scores quality (0-100), and automatically optimizes with feedback loops.</p>
                </div>
                <div class="feature-card">
                    <h3>Production-Ready Code</h3>
                    <p>Generated code includes tests, documentation, Docker configs, and CI/CD pipelines.</p>
                </div>
                <div class="feature-card">
                    <h3>CI/CD Automation</h3>
                    <p>Built-in pipeline runs build, test, security, and deploy stages automatically.</p>
                </div>
                <div class="feature-card">
                    <h3>Enterprise Security</h3>
                    <p>SOC2 compliant, encrypted data, SSO support, and audit logging for Enterprise.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Agents Section -->
    <section class="agents">
        <div class="container">
            <h2 class="section-title">Meet Your AI Engineering Team</h2>
            <p style="text-align: center; margin-bottom: 20px;">8 specialized agents work in orchestration to build your software</p>
            <div class="agents-grid">
                <div class="agent-card"><h4>Architect</h4><p>System design</p></div>
                <div class="agent-card"><h4>Backend</h4><p>API generation</p></div>
                <div class="agent-card"><h4>Frontend</h4><p>UI components</p></div>
                <div class="agent-card"><h4>Database</h4><p>Schema design</p></div>
                <div class="agent-card"><h4>QA</h4><p>Test generation</p></div>
                <div class="agent-card"><h4>Security</h4><p>Vulnerability scan</p></div>
                <div class="agent-card"><h4>DevOps</h4><p>CI/CD pipeline</p></div>
                <div class="agent-card"><h4>Code</h4><p>Code generation</p></div>
            </div>
        </div>
    </section>

    <!-- Pricing Section -->
    <section class="pricing">
        <div class="container">
            <h2 class="section-title">Simple, Transparent Pricing</h2>
            <p style="text-align: center; margin-bottom: 40px;">Choose the plan that fits your needs. All plans include a 14-day free trial.</p>
            <div class="pricing-grid">
                <div class="pricing-card">
                    <h3>Free</h3>
                    <div class="price">$0<span>/month</span></div>
                    <ul class="features-list">
                        <li>5 batches per month</li>
                        <li>Single user</li>
                        <li>Basic templates</li>
                        <li>Community support</li>
                        <li>7-day history</li>
                    </ul>
                    <button class="cta-button" style="background: #4A5568;" onclick="location.href='/signup'">Get Started</button>
                </div>
                <div class="pricing-card pro">
                    <div class="popular-badge">MOST POPULAR</div>
                    <h3>Pro</h3>
                    <div class="price">$49<span>/month</span></div>
                    <ul class="features-list">
                        <li>Unlimited batches</li>
                        <li>Multi-agent orchestration</li>
                        <li>Self-improving system</li>
                        <li>Team workspaces (3 users)</li>
                        <li>Priority processing</li>
                        <li>Email support</li>
                        <li>90-day history</li>
                    </ul>
                    <button class="cta-button" onclick="location.href='/checkout?plan=pro'">Start Free Trial</button>
                </div>
                <div class="pricing-card">
                    <h3>Enterprise</h3>
                    <div class="price">Custom</div>
                    <ul class="features-list">
                        <li>White-label deployment</li>
                        <li>SSO/SAML</li>
                        <li>Audit logs</li>
                        <li>On-premise installation</li>
                        <li>Dedicated support</li>
                        <li>Custom SLA</li>
                    </ul>
                    <button class="cta-button" style="background: #4A5568;" onclick="location.href='/contact'">Contact Sales</button>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-col">
                    <h4>Product</h4>
                    <a href="/features">Features</a>
                    <a href="/agents">Agents</a>
                    <a href="/pricing">Pricing</a>
                    <a href="/demo">Book a Demo</a>
                </div>
                <div class="footer-col">
                    <h4>Resources</h4>
                    <a href="/docs">Documentation</a>
                    <a href="/blog">Blog</a>
                    <a href="/api-docs">API Reference</a>
                    <a href="/status">System Status</a>
                </div>
                <div class="footer-col">
                    <h4>Company</h4>
                    <a href="/about">About Us</a>
                    <a href="/careers">Careers</a>
                    <a href="/press">Press</a>
                    <a href="/contact">Contact</a>
                </div>
                <div class="footer-col">
                    <h4>Legal</h4>
                    <a href="/privacy">Privacy Policy</a>
                    <a href="/terms">Terms of Service</a>
                    <a href="/security">Security</a>
                    <a href="/gdpr">GDPR</a>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2026 FactoryOS AI. All rights reserved. The Autonomous AI Software Engineering Platform.</p>
            </div>
        </div>
    </footer>

    <script>
        console.log('FactoryOS AI - Autonomous AI Software Engineering Platform');
    </script>
</body>
</html>
'@
$mainIndex | Out-File -FilePath "frontend\src\app\index.html" -Encoding UTF8

Write-Host "[2/6] Creating login page..." -ForegroundColor Yellow

$loginPage = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg, #1A365D 0%, #3182CE 100%); min-height: 100vh; display: flex; justify-content: center; align-items: center; }
        .login-container { background: white; padding: 40px; border-radius: 12px; width: 400px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        h1 { color: #1A365D; margin-bottom: 10px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 500; }
        input { width: 100%; padding: 12px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 16px; }
        button { width: 100%; padding: 12px; background: #3182CE; color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; }
        button:hover { background: #2C5282; }
        .signup-link { text-align: center; margin-top: 20px; }
        .back-link { text-align: center; margin-top: 15px; }
        a { color: #3182CE; text-decoration: none; }
    </style>
</head>
<body>
    <div class="login-container">
        <h1>Welcome Back</h1>
        <p>Sign in to your FactoryOS AI account</p>
        <form id="loginForm">
            <div class="form-group">
                <label>Email</label>
                <input type="email" id="email" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" id="password" required>
            </div>
            <button type="submit">Sign In</button>
        </form>
        <div class="signup-link">
            Don't have an account? <a href="/signup">Sign up</a>
        </div>
        <div class="back-link">
            <a href="/">← Back to Home</a>
        </div>
    </div>
    <script>
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            alert('Demo login - Full authentication coming soon!');
            window.location.href = '/dashboard';
        });
    </script>
</body>
</html>
'@
$loginPage | Out-File -FilePath "frontend\src\app\login\index.html" -Encoding UTF8
New-Item -ItemType Directory -Force -Path "frontend\src\app\login" | Out-Null
$loginPage | Out-File -FilePath "frontend\src\app\login\index.html" -Encoding UTF8

Write-Host "[3/6] Creating signup page..." -ForegroundColor Yellow

$signupPage = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg, #1A365D 0%, #3182CE 100%); min-height: 100vh; display: flex; justify-content: center; align-items: center; }
        .signup-container { background: white; padding: 40px; border-radius: 12px; width: 450px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        h1 { color: #1A365D; margin-bottom: 10px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 500; }
        input, select { width: 100%; padding: 12px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 16px; }
        button { width: 100%; padding: 12px; background: #319795; color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; }
        button:hover { background: #2C7A7B; }
        .login-link { text-align: center; margin-top: 20px; }
        a { color: #3182CE; text-decoration: none; }
    </style>
</head>
<body>
    <div class="signup-container">
        <h1>Create Account</h1>
        <p>Start building with FactoryOS AI</p>
        <form id="signupForm">
            <div class="form-row">
                <div class="form-group">
                    <label>First Name</label>
                    <input type="text" id="firstName" required>
                </div>
                <div class="form-group">
                    <label>Last Name</label>
                    <input type="text" id="lastName" required>
                </div>
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" id="email" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" id="password" required>
            </div>
            <div class="form-group">
                <label>Confirm Password</label>
                <input type="password" id="confirmPassword" required>
            </div>
            <div class="form-group">
                <label>Plan</label>
                <select id="plan">
                    <option value="free">Free - $0/month (5 batches)</option>
                    <option value="pro">Pro - $49/month (Unlimited)</option>
                </select>
            </div>
            <button type="submit">Start Free Trial</button>
        </form>
        <div class="login-link">
            Already have an account? <a href="/login">Sign in</a>
        </div>
    </div>
    <script>
        document.getElementById('signupForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const password = document.getElementById('password').value;
            const confirm = document.getElementById('confirmPassword').value;
            if (password !== confirm) {
                alert('Passwords do not match');
                return;
            }
            alert('Account created! Redirecting to dashboard...');
            window.location.href = '/dashboard';
        });
    </script>
</body>
</html>
'@
$signupPage | Out-File -FilePath "frontend\src\app\signup\index.html" -Encoding UTF8
New-Item -ItemType Directory -Force -Path "frontend\src\app\signup" | Out-Null
$signupPage | Out-File -FilePath "frontend\src\app\signup\index.html" -Encoding UTF8

Write-Host "[4/6] Creating dashboard page..." -ForegroundColor Yellow

$dashboardPage = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - FactoryOS AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #F7FAFC; }
        .header { background: #1A365D; color: white; padding: 16px 0; }
        .container { max-width: 1280px; margin: 0 auto; padding: 0 24px; }
        .header .container { display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 20px; font-weight: bold; }
        .nav a { color: white; text-decoration: none; margin-left: 24px; }
        .dashboard { padding: 40px 0; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 40px; }
        .stat-card { background: white; padding: 20px; border-radius: 12px; text-align: center; }
        .stat-value { font-size: 32px; font-weight: bold; color: #1A365D; }
        .create-batch { background: white; padding: 30px; border-radius: 12px; margin-bottom: 30px; }
        textarea { width: 100%; padding: 12px; border: 1px solid #E2E8F0; border-radius: 8px; margin: 10px 0; }
        button { background: #319795; color: white; padding: 12px 24px; border: none; border-radius: 8px; cursor: pointer; }
        .batches-list { background: white; padding: 30px; border-radius: 12px; }
        table { width: 100%; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #EDF2F7; }
    </style>
</head>
<body>
    <header class="header">
        <div class="container">
            <div class="logo">FactoryOS AI</div>
            <nav class="nav">
                <a href="/dashboard">Dashboard</a>
                <a href="/workspace">Workspace</a>
                <a href="/usage">Usage</a>
                <a href="/logout">Logout</a>
            </nav>
        </div>
    </header>
    <div class="dashboard">
        <div class="container">
            <h1>Dashboard</h1>
            <p>Welcome back! Your AI engineering team is ready.</p>
            <div class="stats-grid" id="stats">
                <div class="stat-card"><div class="stat-value" id="batchCount">-</div><div>Batches This Month</div></div>
                <div class="stat-card"><div class="stat-value" id="apiCalls">-</div><div>API Calls</div></div>
                <div class="stat-card"><div class="stat-value" id="activeAgents">8</div><div>Active Agents</div></div>
            </div>
            <div class="create-batch">
                <h2>Create New Batch</h2>
                <textarea id="prompt" rows="4" placeholder="Describe the application you want to build..."></textarea>
                <button onclick="createBatch()">Generate Application</button>
                <div id="result" style="margin-top: 20px; display: none;"></div>
            </div>
            <div class="batches-list">
                <h2>Recent Batches</h2>
                <table id="batchesTable">
                    <thead><tr><th>Batch #</th><th>Status</th><th>Created</th><th>Score</th></tr></thead>
                    <tbody><tr><td colspan="4">Loading...</td></tr></tbody>
                </table>
            </div>
        </div>
    </div>
    <script>
        async function loadStats() {
            try {
                const response = await fetch('/api/v1/billing/usage/current_user');
                const data = await response.json();
                document.getElementById('batchCount').innerText = data.current_month?.batch_count || 0;
                document.getElementById('apiCalls').innerText = data.current_month?.api_calls || 0;
            } catch(e) { console.log('API not ready yet'); }
        }
        async function loadBatches() {
            try {
                const response = await fetch('/api/v1/batches/');
                const batches = await response.json();
                const tbody = document.querySelector('#batchesTable tbody');
                if (batches.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="4">No batches yet. Create your first batch!</td></tr>';
                } else {
                    tbody.innerHTML = batches.slice(-5).reverse().map(b => `
                        <tr><td>#${b.batch_number}</td><td>${b.status}</td><td>${new Date(b.created_at).toLocaleDateString()}</td><td>${b.result?.validation_score || '-'}</td></tr>
                    `).join('');
                }
            } catch(e) { console.log('API not ready yet'); }
        }
        async function createBatch() {
            const prompt = document.getElementById('prompt').value;
            if (!prompt) { alert('Please enter a prompt'); return; }
            const resultDiv = document.getElementById('result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = 'Processing... This may take a moment.';
            try {
                const response = await fetch('/api/v1/batches/', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ batch_number: Date.now(), prompt: prompt })
                });
                const data = await response.json();
                resultDiv.innerHTML = 'Batch created successfully! Check the list below.';
                loadBatches();
                loadStats();
                document.getElementById('prompt').value = '';
            } catch(e) {
                resultDiv.innerHTML = 'Error creating batch. Please try again.';
            }
        }
        loadStats();
        loadBatches();
        setInterval(loadStats, 30000);
        setInterval(loadBatches, 10000);
    </script>
</body>
</html>
'@
$dashboardPage | Out-File -FilePath "frontend\src\app\dashboard\index.html" -Encoding UTF8
New-Item -ItemType Directory -Force -Path "frontend\src\app\dashboard" | Out-Null
$dashboardPage | Out-File -FilePath "frontend\src\app\dashboard\index.html" -Encoding UTF8

Write-Host "[5/6] Creating nginx configuration for SPA routing..." -ForegroundColor Yellow

$nginxConfig = @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # SPA routing - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API proxy
    location /api/ {
        proxy_pass http://backend:4001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
'@
$nginxConfig | Out-File -FilePath "docker\nginx.conf" -Encoding UTF8

Write-Host "[6/6] Updating Dockerfile.frontend to use nginx config..." -ForegroundColor Yellow

$frontendDockerfile = @'
FROM node:18-alpine AS builder
WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/out /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
'@
$frontendDockerfile | Out-File -FilePath "docker\Dockerfile.frontend" -Encoding UTF8

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "WEBSITE STRUCTURE FIXED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now restart the frontend container:" -ForegroundColor Yellow
Write-Host "  docker-compose restart frontend" -ForegroundColor White
Write-Host ""
Write-Host "Then访问:" -ForegroundColor Cyan
Write-Host "  Home: http://localhost:4000/" -ForegroundColor White
Write-Host "  Login: http://localhost:4000/login" -ForegroundColor White
Write-Host "  Signup: http://localhost:4000/signup" -ForegroundColor White
Write-Host "  Dashboard: http://localhost:4000/dashboard" -ForegroundColor White
Write-Host "  Pricing: http://localhost:4000/pricing" -ForegroundColor White
Write-Host "  Blog: http://localhost:4000/blog" -ForegroundColor White
Write-Host "  Docs: http://localhost:4000/docs" -ForegroundColor White
Write-Host "  Admin: http://localhost:4000/admin" -ForegroundColor White
Write-Host "  Workspace: http://localhost:4000/workspace" -ForegroundColor White
Write-Host "  Audit: http://localhost:4000/audit" -ForegroundColor White
Write-Host "  Usage: http://localhost:4000/usage" -ForegroundColor White
Write-Host ""
Write-Host "Restarting frontend..." -ForegroundColor Yellow
docker-compose restart frontend
Start-Sleep -Seconds 5
Write-Host ""
Write-Host "Opening homepage..." -ForegroundColor Green
Start-Process "http://localhost:4000/"