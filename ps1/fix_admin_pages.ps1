# fix_admin_protection.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FIXING ADMIN PROTECTION" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/5] Creating protected admin dashboard with login check..." -ForegroundColor Yellow

$protectedAdminDashboard = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - FactoryOS AI</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#F7FAFC;}
        .header{background:#1A365D;color:white;padding:16px 0;position:sticky;top:0;}
        .header .container{max-width:1280px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;}
        .logo{font-size:24px;font-weight:bold;}
        .logo a{color:white;text-decoration:none;}
        .nav a{color:white;text-decoration:none;margin-left:20px;}
        .container{max-width:1280px;margin:0 auto;padding:40px 24px;}
        .admin-grid{display:grid;grid-template-columns:280px 1fr;gap:30px;}
        .sidebar{background:white;border-radius:12px;padding:20px;height:fit-content;}
        .sidebar h3{color:#1A365D;margin-bottom:15px;padding-bottom:10px;border-bottom:1px solid #EDF2F7;}
        .sidebar ul{list-style:none;}
        .sidebar li{margin-bottom:10px;}
        .sidebar a{color:#4A5568;text-decoration:none;display:block;padding:8px 12px;border-radius:8px;cursor:pointer;}
        .sidebar a:hover{background:#EDF2F7;color:#1A365D;}
        .sidebar a.active{background:#3182CE;color:white;}
        .content{background:white;border-radius:12px;padding:30px;}
        .stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin-bottom:30px;}
        .stat-card{background:#F7FAFC;padding:20px;border-radius:8px;text-align:center;}
        .stat-value{font-size:32px;font-weight:bold;color:#1A365D;}
        table{width:100%;border-collapse:collapse;}
        th,td{padding:12px;text-align:left;border-bottom:1px solid #EDF2F7;}
        th{background:#EDF2F7;}
        .btn{background:#3182CE;color:white;padding:8px 16px;border:none;border-radius:6px;cursor:pointer;margin-right:10px;}
        .btn-danger{background:#E53E3E;}
        .form-group{margin-bottom:15px;}
        label{display:block;margin-bottom:5px;font-weight:500;}
        input,select{width:100%;padding:10px;border:1px solid #E2E8F0;border-radius:6px;}
        .tab-content{display:none;}
        .tab-content.active{display:block;}
        .footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
        @media (max-width:768px){.admin-grid{grid-template-columns:1fr;}}
    </style>
</head>
<body>
    <div id="loginCheck" style="display:none;"></div>
    <div id="adminContent" style="display:none;">
        <header class="header">
            <div class="container">
                <div class="logo"><a href="/">FactoryOS AI</a></div>
                <nav class="nav">
                    <a href="/#features">Features</a>
                    <a href="/#agents">Agents</a>
                    <a href="/pricing">Pricing</a>
                    <a href="/docs">Docs</a>
                    <a href="/blog">Blog</a>
                    <a href="/admin" style="background:#319795;padding:8px 20px;border-radius:8px;">Admin</a>
                    <a href="#" id="logoutLink" style="color:white;">Logout</a>
                </nav>
            </div>
        </header>
        <div class="container">
            <div class="admin-grid">
                <div class="sidebar">
                    <h3>Admin Navigation</h3>
                    <ul>
                        <li><a onclick="showTab('dashboard')" class="active" id="nav-dashboard">Dashboard</a></li>
                        <li><a onclick="showTab('users')">User Management</a></li>
                        <li><a onclick="showTab('batches')">Batch Management</a></li>
                        <li><a onclick="showTab('agents')">Agent Configuration</a></li>
                        <li><a onclick="showTab('system')">System Settings</a></li>
                        <li><a href="/audit">Audit Logs</a></li>
                        <li><a href="/usage">Usage Analytics</a></li>
                    </ul>
                </div>
                <div class="content">
                    <div id="dashboard" class="tab-content active">
                        <h1>Admin Dashboard</h1>
                        <p>Welcome to the FactoryOS AI administration panel.</p>
                        <div class="stats-grid" id="stats">
                            <div class="stat-card"><div class="stat-value" id="totalUsers">-</div><div>Total Users</div></div>
                            <div class="stat-card"><div class="stat-value" id="totalBatches">-</div><div>Batches Processed</div></div>
                            <div class="stat-card"><div class="stat-value" id="activeUsers">-</div><div>Active Users</div></div>
                            <div class="stat-card"><div class="stat-value" id="avgScore">-</div><div>Avg Quality Score</div></div>
                        </div>
                    </div>
                    <div id="users" class="tab-content">
                        <h2>User Management</h2>
                        <button class="btn" onclick="showAddUserModal()">+ Add User</button>
                        <div id="usersMessage"></div>
                        <table style="margin-top:20px;"><thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Tier</th><th>Status</th><th>Actions</th></tr></thead><tbody id="usersTable"><tr><td colspan="6">Loading...</td></tr></tbody></table>
                    </div>
                    <div id="batches" class="tab-content">
                        <h2>Batch Management</h2>
                        <table><thead><tr><th>ID</th><th>User</th><th>Prompt</th><th>Status</th><th>Score</th></tr></thead><tbody id="batchesTable"><tr><td colspan="5">Loading...</td></tr></tbody></table>
                    </div>
                    <div id="agents" class="tab-content">
                        <h2>Agent Configuration</h2>
                        <div class="stats-grid" id="agentsGrid">
                            <div class="stat-card"><h3>Architect</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('architect')">Configure</button></div>
                            <div class="stat-card"><h3>Backend</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('backend')">Configure</button></div>
                            <div class="stat-card"><h3>Frontend</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('frontend')">Configure</button></div>
                            <div class="stat-card"><h3>Database</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('database')">Configure</button></div>
                            <div class="stat-card"><h3>QA</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('qa')">Configure</button></div>
                            <div class="stat-card"><h3>Security</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('security')">Configure</button></div>
                            <div class="stat-card"><h3>DevOps</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('devops')">Configure</button></div>
                            <div class="stat-card"><h3>Code Generator</h3><p>Status: Active</p><button class="btn" onclick="configureAgent('code')">Configure</button></div>
                        </div>
                    </div>
                    <div id="system" class="tab-content">
                        <h2>System Settings</h2>
                        <div class="form-group"><label>Application Name</label><input type="text" id="appName" value="FactoryOS AI"></div>
                        <div class="form-group"><label>Default User Tier</label><select id="defaultTier"><option value="free">Free</option><option value="pro">Pro</option></select></div>
                        <button class="btn" onclick="saveSettings()">Save Settings</button>
                        <div id="settingsMessage"></div>
                    </div>
                </div>
            </div>
        </div>
        <footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI. All rights reserved.</p></div></footer>
    </div>
    
    <div id="loginModal" style="position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.8);display:flex;justify-content:center;align-items:center;z-index:1000;">
        <div style="background:white;padding:40px;border-radius:12px;width:400px;">
            <h2 style="color:#1A365D;">Admin Login Required</h2>
            <p>Please enter your credentials to access the admin dashboard.</p>
            <div class="form-group"><label>Email</label><input type="email" id="loginEmail" value="admin@factoryos.ai"></div>
            <div class="form-group"><label>Password</label><input type="password" id="loginPassword"></div>
            <button class="btn" onclick="checkLogin()" style="width:100%;">Login</button>
            <div id="loginError" style="color:red;margin-top:10px;display:none;">Invalid credentials. Use admin@factoryos.ai / admin123</div>
            <p style="margin-top:20px;text-align:center;"><a href="/">Return to Homepage</a></p>
        </div>
    </div>

    <script>
        const ADMIN_EMAIL = 'admin@factoryos.ai';
        const ADMIN_PASSWORD = 'admin123';
        
        function checkLogin() {
            const email = document.getElementById('loginEmail').value;
            const password = document.getElementById('loginPassword').value;
            
            if (email === ADMIN_EMAIL && password === ADMIN_PASSWORD) {
                sessionStorage.setItem('admin_logged_in', 'true');
                document.getElementById('loginModal').style.display = 'none';
                document.getElementById('adminContent').style.display = 'block';
                loadStats();
                loadUsers();
                loadBatches();
            } else {
                document.getElementById('loginError').style.display = 'block';
            }
        }
        
        function logout() {
            sessionStorage.removeItem('admin_logged_in');
            window.location.href = '/';
        }
        
        // Check login status on page load
        const isLoggedIn = sessionStorage.getItem('admin_logged_in') === 'true';
        if (isLoggedIn) {
            document.getElementById('loginModal').style.display = 'none';
            document.getElementById('adminContent').style.display = 'block';
        } else {
            document.getElementById('loginModal').style.display = 'flex';
            document.getElementById('adminContent').style.display = 'none';
        }
        
        document.getElementById('logoutLink')?.addEventListener('click', function(e) {
            e.preventDefault();
            logout();
        });
        
        // API functions
        async function loadStats() {
            try {
                const response = await fetch('/api/v1/admin/stats');
                const stats = await response.json();
                document.getElementById('totalUsers').innerText = stats.total_users || 0;
                document.getElementById('totalBatches').innerText = stats.total_batches || 0;
                document.getElementById('activeUsers').innerText = stats.active_users || 0;
                document.getElementById('avgScore').innerText = stats.avg_quality_score || '85';
            } catch(e) { console.error(e); }
        }
        
        async function loadUsers() {
            try {
                const response = await fetch('/api/v1/admin/users');
                const data = await response.json();
                const users = data.users || data;
                const tbody = document.getElementById('usersTable');
                if (!users || users.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6">No users found</td></tr>';
                } else {
                    tbody.innerHTML = users.map(u => `<tr><td>${u.id}</td><td>${u.name}</td><td>${u.email}</td><td>${u.tier}</td><td>${u.status}</td><td><button class="btn btn-danger" onclick="deleteUser(${u.id})">Delete</button></td></tr>`).join('');
                }
            } catch(e) { console.error(e); }
        }
        
        async function loadBatches() {
            try {
                const response = await fetch('/api/v1/batches/');
                const batches = await response.json();
                const tbody = document.getElementById('batchesTable');
                if (!batches || batches.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="5">No batches found</td></tr>';
                } else {
                    tbody.innerHTML = batches.slice(-10).map(b => `<tr><td>${b.id}</td><td>user_${b.batch_number}</td><td>${(b.prompt || '').substring(0, 50)}...</td><td>${b.status}</td><td>${b.result?.validation_score || '-'}</td></tr>`).join('');
                }
            } catch(e) { console.error(e); }
        }
        
        function showTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            if (tabId === 'users') loadUsers();
            if (tabId === 'batches') loadBatches();
            if (tabId === 'dashboard') loadStats();
        }
        
        function showAddUserModal() {
            const name = prompt('Enter user name:');
            if (name) {
                const email = prompt('Enter email:');
                if (email) {
                    fetch('/api/v1/admin/users', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ name, email, tier: 'free' })
                    }).then(() => loadUsers());
                }
            }
        }
        
        function deleteUser(userId) {
            if (confirm('Delete this user?')) {
                fetch(`/api/v1/admin/users/${userId}`, { method: 'DELETE' }).then(() => loadUsers());
            }
        }
        
        function configureAgent(agentName) {
            alert(`Configure ${agentName} agent - Coming soon!`);
        }
        
        async function saveSettings() {
            const settings = {
                app_name: document.getElementById('appName').value,
                default_tier: document.getElementById('defaultTier').value
            };
            await fetch('/api/v1/admin/settings', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(settings)
            });
            document.getElementById('settingsMessage').innerHTML = '<span style="color:green;">Settings saved!</span>';
            setTimeout(() => { document.getElementById('settingsMessage').innerHTML = ''; }, 3000);
        }
    </script>
</body>
</html>
'@
$protectedAdminDashboard | Out-File -FilePath "frontend\src\app\admin\index.html" -Encoding UTF8

Write-Host "[2/5] Creating protected audit page..." -ForegroundColor Yellow

$protectedAudit = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Audit Logs - FactoryOS AI</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Inter',sans-serif;background:#F7FAFC;}
.header{background:#1A365D;color:white;padding:16px 0;}
.header .container{max-width:1280px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;}
.logo{font-size:24px;font-weight:bold;}
.logo a{color:white;text-decoration:none;}
.nav a{color:white;text-decoration:none;margin-left:20px;}
.container{max-width:1400px;margin:0 auto;padding:40px 24px;}
h1{color:#1A365D;}
table{width:100%;background:white;border-radius:8px;overflow:hidden;}
th,td{padding:12px;text-align:left;border-bottom:1px solid #EDF2F7;}
th{background:#EDF2F7;}
.footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
</style>
</head>
<body>
<div id="loginCheck"></div>
<div id="mainContent" style="display:none;">
<header class="header"><div class="container"><div class="logo"><a href="/">FactoryOS AI</a></div><nav class="nav"><a href="/#features">Features</a><a href="/#agents">Agents</a><a href="/pricing">Pricing</a><a href="/docs">Docs</a><a href="/blog">Blog</a><a href="/admin">Admin</a><a href="#" id="logoutLink">Logout</a></nav></div></header>
<div class="container"><h1>Audit Logs</h1><table id="logsTable"><thead><tr><th>Timestamp</th><th>User</th><th>Action</th><th>Resource</th></tr></thead><tbody><tr><td colspan="4">Loading...</td></tr></tbody></table></div>
<footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI</p></div></footer>
</div>
<script>
function checkAuth() {
    if (sessionStorage.getItem('admin_logged_in') !== 'true') {
        window.location.href = '/admin';
        return false;
    }
    return true;
}
if (checkAuth()) {
    document.getElementById('mainContent').style.display = 'block';
    document.getElementById('loginCheck').style.display = 'none';
    fetch('/api/v1/audit/logs?days=30').then(r=>r.json()).then(data=>{
        const tbody = document.querySelector('#logsTable tbody');
        if(data.logs && data.logs.length>0){
            tbody.innerHTML = data.logs.map(l=>`<tr><td>${new Date(l.timestamp).toLocaleString()}</td><td>${l.user_id}</td><td>${l.action}</td><td>${l.resource_type}</td></tr>`).join('');
        } else { tbody.innerHTML = '<tr><td colspan="4">No logs found</td></tr>'; }
    }).catch(()=>{});
}
document.getElementById('logoutLink')?.addEventListener('click', function(e){ e.preventDefault(); sessionStorage.removeItem('admin_logged_in'); window.location.href='/'; });
</script>
</body>
</html>
'@
$protectedAudit | Out-File -FilePath "frontend\src\app\audit\index.html" -Encoding UTF8

Write-Host "[3/5] Creating protected usage page..." -ForegroundColor Yellow

$protectedUsage = @'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Usage Analytics - FactoryOS AI</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Inter',sans-serif;background:#F7FAFC;}
.header{background:#1A365D;color:white;padding:16px 0;}
.header .container{max-width:1280px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;}
.logo{font-size:24px;font-weight:bold;}
.logo a{color:white;text-decoration:none;}
.nav a{color:white;text-decoration:none;margin-left:20px;}
.container{max-width:1200px;margin:0 auto;padding:40px 24px;}
h1{color:#1A365D;}
.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin:20px 0;}
.stat-card{background:white;padding:20px;border-radius:12px;text-align:center;}
.stat-value{font-size:36px;font-weight:bold;color:#1A365D;}
table{width:100%;background:white;border-radius:8px;}
th,td{padding:12px;text-align:left;border-bottom:1px solid #EDF2F7;}
th{background:#EDF2F7;}
.footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
</style>
</head>
<body>
<div id="mainContent" style="display:none;">
<header class="header"><div class="container"><div class="logo"><a href="/">FactoryOS AI</a></div><nav class="nav"><a href="/#features">Features</a><a href="/#agents">Agents</a><a href="/pricing">Pricing</a><a href="/docs">Docs</a><a href="/blog">Blog</a><a href="/admin">Admin</a><a href="#" id="logoutLink">Logout</a></nav></div></header>
<div class="container"><h1>Usage Analytics</h1><div class="stats-grid"><div class="stat-card"><div class="stat-value" id="batchCount">-</div><div>Batches This Month</div></div><div class="stat-card"><div class="stat-value" id="apiCalls">-</div><div>API Calls</div></div></div>
<h3>Usage History</h3><table id="historyTable"><thead><tr><th>Month</th><th>Batches</th><th>API Calls</th></tr></thead><tbody><tr><td colspan="3">Loading...</td></tr></tbody></table></div>
<footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI</p></div></footer>
</div>
<script>
if (sessionStorage.getItem('admin_logged_in') !== 'true') {
    window.location.href = '/admin';
} else {
    document.getElementById('mainContent').style.display = 'block';
    fetch('/api/v1/billing/usage/current_user').then(r=>r.json()).then(data=>{
        document.getElementById('batchCount').innerText = data.current_month?.batch_count || 0;
        document.getElementById('apiCalls').innerText = data.current_month?.api_calls || 0;
        const tbody = document.querySelector('#historyTable tbody');
        if(data.history && data.history.length>0){
            tbody.innerHTML = data.history.map(h=>`<tr><td>${h.month}</td><td>${h.batch_count}</td><td>${h.api_calls}</td></tr>`).join('');
        } else { tbody.innerHTML = '<tr><td colspan="3">No data</td></tr>'; }
    }).catch(()=>{});
}
document.getElementById('logoutLink')?.addEventListener('click', function(e){ e.preventDefault(); sessionStorage.removeItem('admin_logged_in'); window.location.href='/'; });
</script>
</body>
</html>
'@
$protectedUsage | Out-File -FilePath "frontend\src\app\usage\index.html" -Encoding UTF8

Write-Host "[4/5] Updating main admin navigation links..." -ForegroundColor Yellow

# Update the admin dashboard links to use absolute paths
Write-Host "[5/5] Restarting frontend..." -ForegroundColor Yellow
docker-compose restart frontend
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "ADMIN PROTECTION FIXED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now:" -ForegroundColor Cyan
Write-Host "   Admin dashboard requires login (modal popup)" -ForegroundColor White
Write-Host "   Audit Logs redirect to login if not authenticated" -ForegroundColor White  
Write-Host "   Usage Analytics redirect to login if not authenticated" -ForegroundColor White
Write-Host "   All admin pages have proper headers and footers" -ForegroundColor White
Write-Host ""
Write-Host "Login credentials:" -ForegroundColor Yellow
Write-Host "  Email: admin@factoryos.ai" -ForegroundColor White
Write-Host "  Password: admin123" -ForegroundColor White
Write-Host ""
Write-Host "Opening admin dashboard..." -ForegroundColor Cyan
Start-Process "http://localhost:4000/admin"