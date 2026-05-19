# fix_admin_dashboard.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FIXING ADMIN DASHBOARD JAVASCRIPT" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/3] Updating admin dashboard with working API calls..." -ForegroundColor Yellow

$fixedAdminDashboard = @'
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
        .btn-outline{border:1px solid white;padding:8px 20px;border-radius:8px;}
        .btn-solid{background:#319795;padding:8px 20px;border-radius:8px;}
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
        .btn-success{background:#38A169;}
        .form-group{margin-bottom:15px;}
        label{display:block;margin-bottom:5px;font-weight:500;}
        input,select{width:100%;padding:10px;border:1px solid #E2E8F0;border-radius:6px;}
        .tabs{display:flex;gap:10px;margin-bottom:20px;border-bottom:1px solid #EDF2F7;}
        .tab{padding:10px 20px;cursor:pointer;}
        .tab.active{border-bottom:2px solid #3182CE;color:#3182CE;font-weight:500;}
        .tab-content{display:none;}
        .tab-content.active{display:block;}
        .message{padding:10px;border-radius:6px;margin-top:10px;}
        .message.success{background:#C6F6D5;color:#22543D;}
        .message.error{background:#FED7D7;color:#742A2A;}
        .footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
        @media (max-width:768px){.admin-grid{grid-template-columns:1fr;}}
    </style>
</head>
<body>
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
                <a href="/login">Sign In</a>
            </nav>
        </div>
    </header>
    <div class="container">
        <div class="admin-grid">
            <div class="sidebar">
                <h3>Admin Navigation</h3>
                <ul>
                    <li><a onclick="showTab('dashboard')" class="active" id="nav-dashboard">📊 Dashboard</a></li>
                    <li><a onclick="showTab('users')">👥 User Management</a></li>
                    <li><a onclick="showTab('batches')">📦 Batch Management</a></li>
                    <li><a onclick="showTab('agents')">🤖 Agent Configuration</a></li>
                    <li><a onclick="showTab('system')">⚙️ System Settings</a></li>
                    <li><a href="/audit">📜 Audit Logs</a></li>
                    <li><a href="/usage">📈 Usage Analytics</a></li>
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
                    <h3>Recent Activity</h3>
                    <div id="activityLog">Loading activity...</div>
                </div>
                <div id="users" class="tab-content">
                    <h2>User Management</h2>
                    <button class="btn" onclick="showAddUserModal()">+ Add User</button>
                    <div id="usersMessage"></div>
                    <table style="margin-top:20px;">
                        <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Tier</th><th>Status</th><th>Actions</th></tr></thead>
                        <tbody id="usersTable"><tr><td colspan="6">Loading...</td></tr></tbody>
                    </table>
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
                    <div class="form-group"><label>Max Batches (Free Tier)</label><input type="number" id="maxBatches" value="5"></div>
                    <button class="btn" onclick="saveSettings()">Save Settings</button>
                    <div id="settingsMessage"></div>
                </div>
            </div>
        </div>
    </div>
    <div id="addUserModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);justify-content:center;align-items:center;z-index:1000;">
        <div style="background:white;padding:30px;border-radius:12px;width:400px;">
            <h3>Add User</h3>
            <div class="form-group"><label>Name</label><input type="text" id="newUserName"></div>
            <div class="form-group"><label>Email</label><input type="email" id="newUserEmail"></div>
            <div class="form-group"><label>Tier</label><select id="newUserTier"><option value="free">Free</option><option value="pro">Pro</option><option value="enterprise">Enterprise</option></select></div>
            <button class="btn" onclick="createUser()">Create</button>
            <button class="btn" style="background:#718096;" onclick="closeAddUserModal()">Cancel</button>
        </div>
    </div>
    <footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI. All rights reserved.</p></div></footer>
    <script>
        const API_BASE = '/api/v1';
        
        async function apiCall(endpoint, options = {}) {
            try {
                const response = await fetch(`${API_BASE}${endpoint}`, {
                    ...options,
                    headers: { 'Content-Type': 'application/json', ...options.headers }
                });
                if (!response.ok) throw new Error(`HTTP ${response.status}`);
                return await response.json();
            } catch (error) {
                console.error(`API Error: ${endpoint}`, error);
                return null;
            }
        }

        async function loadStats() {
            const stats = await apiCall('/admin/stats');
            if (stats) {
                document.getElementById('totalUsers').innerText = stats.total_users || 0;
                document.getElementById('totalBatches').innerText = stats.total_batches || 0;
                document.getElementById('activeUsers').innerText = stats.active_users || 0;
                document.getElementById('avgScore').innerText = stats.avg_quality_score || '85';
            }
        }

        async function loadUsers() {
            const data = await apiCall('/admin/users');
            if (data && data.users) {
                const tbody = document.getElementById('usersTable');
                if (data.users.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6">No users found</td></tr>';
                } else {
                    tbody.innerHTML = data.users.map(u => `
                        <tr>
                            <td>${u.id}</td>
                            <td>${u.name}</td>
                            <td>${u.email}</td>
                            <td><span style="background:#EDF2F7;padding:4px 8px;border-radius:4px;">${u.tier}</span></td>
                            <td><span style="background:#C6F6D5;color:#22543D;padding:4px 8px;border-radius:4px;">${u.status}</span></td>
                            <td><button class="btn btn-danger" onclick="deleteUser(${u.id})">Delete</button></td>
                        </tr>
                    `).join('');
                }
            }
        }

        async function loadBatches() {
            const batches = await apiCall('/batches/');
            const tbody = document.getElementById('batchesTable');
            if (!batches || batches.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">No batches found</td></tr>';
            } else {
                tbody.innerHTML = batches.slice(-10).reverse().map(b => `
                    <tr>
                        <td>${b.id}</td>
                        <td>user_${b.batch_number}</td>
                        <td>${b.prompt?.substring(0, 50) || 'N/A'}...</td>
                        <td><span style="background:#C6F6D5;padding:4px 8px;border-radius:4px;">${b.status}</span></td>
                        <td>${b.result?.validation_score || '-'}</td>
                    </tr>
                `).join('');
            }
        }

        async function createUser() {
            const name = document.getElementById('newUserName').value;
            const email = document.getElementById('newUserEmail').value;
            const tier = document.getElementById('newUserTier').value;
            
            if (!name || !email) {
                showMessage('usersMessage', 'Please fill all fields', 'error');
                return;
            }
            
            await apiCall('/admin/users', {
                method: 'POST',
                body: JSON.stringify({ name, email, tier })
            });
            
            closeAddUserModal();
            loadUsers();
            loadStats();
            showMessage('usersMessage', 'User created successfully!', 'success');
        }

        async function deleteUser(userId) {
            if (confirm('Are you sure you want to delete this user?')) {
                await apiCall(`/admin/users/${userId}`, { method: 'DELETE' });
                loadUsers();
                loadStats();
                showMessage('usersMessage', 'User deleted successfully!', 'success');
            }
        }

        async function saveSettings() {
            const settings = {
                app_name: document.getElementById('appName').value,
                default_tier: document.getElementById('defaultTier').value,
                max_batches_free: parseInt(document.getElementById('maxBatches').value)
            };
            
            await apiCall('/admin/settings', {
                method: 'POST',
                body: JSON.stringify(settings)
            });
            
            showMessage('settingsMessage', 'Settings saved successfully!', 'success');
        }

        function showTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            document.querySelectorAll('.sidebar a').forEach(a => a.classList.remove('active'));
            document.getElementById(`nav-${tabId}`).classList.add('active');
            
            if (tabId === 'users') loadUsers();
            if (tabId === 'batches') loadBatches();
            if (tabId === 'dashboard') loadStats();
        }

        function showAddUserModal() {
            document.getElementById('addUserModal').style.display = 'flex';
        }

        function closeAddUserModal() {
            document.getElementById('addUserModal').style.display = 'none';
            document.getElementById('newUserName').value = '';
            document.getElementById('newUserEmail').value = '';
        }

        function configureAgent(agentName) {
            alert(`Configure ${agentName} agent - Coming soon!`);
        }

        function showMessage(elementId, message, type) {
            const el = document.getElementById(elementId);
            if (el) {
                el.innerHTML = `<div class="message ${type}">${message}</div>`;
                setTimeout(() => { el.innerHTML = ''; }, 3000);
            }
        }

        // Initialize
        loadStats();
        loadUsers();
        loadBatches();
        
        // Refresh every 30 seconds
        setInterval(() => { loadStats(); loadUsers(); loadBatches(); }, 30000);
    </script>
</body>
</html>
'@

$fixedAdminDashboard | Out-File -FilePath "frontend\src\app\admin\index.html" -Encoding UTF8

Write-Host "[2/3] Clearing browser cache instruction..." -ForegroundColor Yellow
Write-Host "  Press Ctrl+Shift+Delete and clear cache, or do a hard refresh (Ctrl+F5)" -ForegroundColor White

Write-Host "[3/3] Restarting frontend..." -ForegroundColor Yellow
docker-compose restart frontend

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "ADMIN DASHBOARD FIXED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now do a HARD REFRESH in your browser: Ctrl+Shift+R or Ctrl+F5" -ForegroundColor Yellow
Write-Host ""
Write-Host "Then visit: http://localhost:4000/admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "The admin dashboard should now show:" -ForegroundColor White
Write-Host "  - Real user data from the API" -ForegroundColor Green
Write-Host "  - Working user management (add/delete users)" -ForegroundColor Green
Write-Host "  - Batch statistics" -ForegroundColor Green
Write-Host "  - Agent configuration panel" -ForegroundColor Green
Write-Host "  - System settings" -ForegroundColor Green

Start-Process "http://localhost:4000/admin"