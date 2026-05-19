# add_batch_agent_management.ps1
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "ADDING BATCH MANAGEMENT & AGENT CONFIGURATION" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

cd D:\aisfs\ai-factory

Write-Host "[1/4] Updating admin dashboard with batch management..." -ForegroundColor Yellow

# Read the current admin dashboard
$adminDashboardPath = "frontend\src\app\admin\index.html"
$currentDashboard = Get-Content $adminDashboardPath -Raw

# Create the updated dashboard with full batch and agent management
$updatedDashboard = @'
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
        .btn-success{background:#38A169;}
        .btn-warning{background:#D69E2E;}
        .form-group{margin-bottom:15px;}
        label{display:block;margin-bottom:5px;font-weight:500;}
        input,select,textarea{width:100%;padding:10px;border:1px solid #E2E8F0;border-radius:6px;}
        .tab-content{display:none;}
        .tab-content.active{display:block;}
        .modal{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);justify-content:center;align-items:center;z-index:1000;}
        .modal-content{background:white;padding:30px;border-radius:12px;width:500px;max-width:90%;}
        .search-box{margin-bottom:20px;padding:10px;border:1px solid #E2E8F0;border-radius:6px;width:100%;}
        .filter-row{display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap;}
        .agent-config-card{background:#F7FAFC;padding:15px;border-radius:8px;margin-bottom:15px;}
        .agent-config-card h4{color:#1A365D;margin-bottom:10px;}
        .footer{background:#1A365D;color:white;padding:40px 0;text-align:center;margin-top:40px;}
        @media (max-width:768px){.admin-grid{grid-template-columns:1fr;}}
    </style>
</head>
<body>
    <div id="loginModal" style="position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.8);display:flex;justify-content:center;align-items:center;z-index:1000;">
        <div style="background:white;padding:40px;border-radius:12px;width:400px;">
            <h2 style="color:#1A365D;">Admin Login Required</h2>
            <p>Please enter your credentials to access the admin dashboard.</p>
            <div class="form-group"><label>Email</label><input type="email" id="loginEmail" value="admin@factoryos.ai"></div>
            <div class="form-group"><label>Password</label><input type="password" id="loginPassword"></div>
            <button class="btn" onclick="checkLogin()" style="width:100%;">Login</button>
            <div id="loginError" style="color:red;margin-top:10px;display:none;">Invalid credentials</div>
        </div>
    </div>

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
                    <!-- Dashboard Tab -->
                    <div id="dashboard" class="tab-content active">
                        <h1>Admin Dashboard</h1>
                        <p>Welcome to the FactoryOS AI administration panel.</p>
                        <div class="stats-grid" id="stats">
                            <div class="stat-card"><div class="stat-value" id="totalUsers">-</div><div>Total Users</div></div>
                            <div class="stat-card"><div class="stat-value" id="totalBatches">-</div><div>Total Batches</div></div>
                            <div class="stat-card"><div class="stat-value" id="activeAgents">8</div><div>Active Agents</div></div>
                            <div class="stat-card"><div class="stat-value" id="avgScore">-</div><div>Avg Quality Score</div></div>
                        </div>
                        <h3>Recent Batches</h3>
                        <table id="recentBatchesTable"><thead><tr><th>ID</th><th>Prompt</th><th>Status</th><th>Score</th><th>Date</th></tr></thead><tbody><tr><td colspan="5">Loading...</td></tr></tbody></table>
                    </div>

                    <!-- Users Tab -->
                    <div id="users" class="tab-content">
                        <h2>User Management</h2>
                        <button class="btn" onclick="showAddUserModal()">+ Add User</button>
                        <div class="filter-row"><input type="text" id="userSearch" placeholder="Search users..." class="search-box" onkeyup="filterUsers()"></div>
                        <div id="usersMessage"></div>
                        <table><thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Tier</th><th>Status</th><th>Actions</th></tr></thead><tbody id="usersTable"><tr><td colspan="6">Loading...</td></tr></tbody></table>
                    </div>

                    <!-- Batches Tab -->
                    <div id="batches" class="tab-content">
                        <h2>Batch Management</h2>
                        <div class="filter-row">
                            <select id="batchStatusFilter" onchange="loadAllBatches()" style="width:auto;">
                                <option value="">All Status</option>
                                <option value="pending">Pending</option>
                                <option value="processing">Processing</option>
                                <option value="completed">Completed</option>
                                <option value="failed">Failed</option>
                            </select>
                            <input type="text" id="batchSearch" placeholder="Search by prompt..." class="search-box" onkeyup="filterBatches()">
                            <button class="btn" onclick="loadAllBatches()">Refresh</button>
                        </div>
                        <table><thead><tr><th>ID</th><th>Batch #</th><th>Prompt</th><th>Status</th><th>Score</th><th>Created</th><th>Actions</th></tr></thead><tbody id="batchesTable"><tr><td colspan="7">Loading...</td></tr></tbody></table>
                    </div>

                    <!-- Agents Tab -->
                    <div id="agents" class="tab-content">
                        <h2>Agent Configuration</h2>
                        <p>Configure each AI agent's behavior, confidence thresholds, and enable/disable status.</p>
                        <div id="agentsConfigList"></div>
                    </div>

                    <!-- System Tab -->
                    <div id="system" class="tab-content">
                        <h2>System Settings</h2>
                        <div class="form-group"><label>Application Name</label><input type="text" id="appName" value="FactoryOS AI"></div>
                        <div class="form-group"><label>Default User Tier</label><select id="defaultTier"><option value="free">Free</option><option value="pro">Pro</option><option value="enterprise">Enterprise</option></select></div>
                        <div class="form-group"><label>Max Batches (Free Tier)</label><input type="number" id="maxBatchesFree" value="5"></div>
                        <div class="form-group"><label>Maintenance Mode</label><select id="maintenanceMode"><option value="false">Normal Operation</option><option value="true">Maintenance Mode</option></select></div>
                        <button class="btn" onclick="saveSystemSettings()">Save Settings</button>
                        <div id="settingsMessage"></div>
                    </div>
                </div>
            </div>
        </div>
        <footer class="footer"><div class="container"><p>&copy; 2026 FactoryOS AI. All rights reserved.</p></div></footer>
    </div>

    <!-- Add User Modal -->
    <div id="addUserModal" class="modal"><div class="modal-content"><h3>Add New User</h3><div class="form-group"><label>Name</label><input type="text" id="newUserName"></div><div class="form-group"><label>Email</label><input type="email" id="newUserEmail"></div><div class="form-group"><label>Tier</label><select id="newUserTier"><option value="free">Free</option><option value="pro">Pro</option><option value="enterprise">Enterprise</option></select></div><button class="btn" onclick="createUser()">Create</button><button class="btn" style="background:#718096;" onclick="closeAddUserModal()">Cancel</button></div></div>

    <!-- Edit Batch Modal -->
    <div id="editBatchModal" class="modal"><div class="modal-content"><h3>Edit Batch</h3><div class="form-group"><label>Prompt</label><textarea id="editBatchPrompt" rows="4"></textarea></div><div class="form-group"><label>Status</label><select id="editBatchStatus"><option value="pending">Pending</option><option value="processing">Processing</option><option value="completed">Completed</option><option value="failed">Failed</option></select></div><button class="btn" onclick="updateBatch()">Save Changes</button><button class="btn" style="background:#718096;" onclick="closeEditBatchModal()">Cancel</button></div></div>

    <!-- Configure Agent Modal -->
    <div id="configureAgentModal" class="modal"><div class="modal-content"><h3 id="agentModalTitle">Configure Agent</h3><div class="form-group"><label>Enabled</label><select id="agentEnabled"><option value="true">Enabled</option><option value="false">Disabled</option></select></div><div class="form-group"><label>Confidence Threshold (0-100)</label><input type="number" id="agentConfidence" value="70" min="0" max="100"></div><div class="form-group"><label>Max Retries</label><input type="number" id="agentMaxRetries" value="3" min="0" max="10"></div><div class="form-group"><label>Timeout (seconds)</label><input type="number" id="agentTimeout" value="30" min="5" max="300"></div><button class="btn" onclick="saveAgentConfig()">Save Configuration</button><button class="btn" style="background:#718096;" onclick="closeAgentModal()">Cancel</button></div></div>

    <script>
        const ADMIN_EMAIL = 'admin@factoryos.ai';
        const ADMIN_PASSWORD = 'admin123';
        let allBatches = [];
        let allUsers = [];
        
        function checkLogin() {
            const email = document.getElementById('loginEmail').value;
            const password = document.getElementById('loginPassword').value;
            if (email === ADMIN_EMAIL && password === ADMIN_PASSWORD) {
                sessionStorage.setItem('admin_logged_in', 'true');
                document.getElementById('loginModal').style.display = 'none';
                document.getElementById('adminContent').style.display = 'block';
                loadAllData();
            } else {
                document.getElementById('loginError').style.display = 'block';
            }
        }
        
        if (sessionStorage.getItem('admin_logged_in') === 'true') {
            document.getElementById('loginModal').style.display = 'none';
            document.getElementById('adminContent').style.display = 'block';
            loadAllData();
        }
        
        document.getElementById('logoutLink')?.addEventListener('click', function(e) { e.preventDefault(); sessionStorage.removeItem('admin_logged_in'); window.location.href = '/'; });
        
        async function loadAllData() {
            await loadStats();
            await loadUsers();
            await loadAllBatches();
            await loadAgentsConfig();
        }
        
        async function loadStats() {
            try {
                const response = await fetch('/api/v1/admin/stats');
                const stats = await response.json();
                document.getElementById('totalUsers').innerText = stats.total_users || 0;
                document.getElementById('totalBatches').innerText = stats.total_batches || 0;
                document.getElementById('avgScore').innerText = stats.avg_quality_score || '85';
            } catch(e) { console.error(e); }
        }
        
        async function loadUsers() {
            try {
                const response = await fetch('/api/v1/admin/users');
                const data = await response.json();
                allUsers = data.users || data;
                displayUsers();
            } catch(e) { console.error(e); }
        }
        
        function displayUsers() {
            const searchTerm = document.getElementById('userSearch')?.value.toLowerCase() || '';
            const filtered = allUsers.filter(u => u.name?.toLowerCase().includes(searchTerm) || u.email?.toLowerCase().includes(searchTerm));
            const tbody = document.getElementById('usersTable');
            if (!filtered || filtered.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">No users found</td></tr>';
            } else {
                tbody.innerHTML = filtered.map(u => `<tr><td>${u.id}</td><td>${u.name}</td><td>${u.email}</td><td><span style="background:#EDF2F7;padding:4px 8px;border-radius:4px;">${u.tier}</span></td><td><span style="background:#C6F6D5;padding:4px 8px;border-radius:4px;">${u.status}</span></td><td><button class="btn btn-danger" onclick="deleteUser(${u.id})">Delete</button></td></tr>`).join('');
            }
        }
        
        function filterUsers() { displayUsers(); }
        
        async function loadAllBatches() {
            try {
                const response = await fetch('/api/v1/batches/');
                allBatches = await response.json();
                displayBatches();
                displayRecentBatches();
            } catch(e) { console.error(e); }
        }
        
        function displayBatches() {
            const statusFilter = document.getElementById('batchStatusFilter')?.value || '';
            const searchTerm = document.getElementById('batchSearch')?.value.toLowerCase() || '';
            let filtered = allBatches;
            if (statusFilter) filtered = filtered.filter(b => b.status === statusFilter);
            if (searchTerm) filtered = filtered.filter(b => b.prompt?.toLowerCase().includes(searchTerm));
            const tbody = document.getElementById('batchesTable');
            if (!filtered || filtered.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7">No batches found</td></tr>';
            } else {
                tbody.innerHTML = filtered.slice().reverse().map(b => `<tr>
                    <td>${b.id}</td>
                    <td>#${b.batch_number}</td>
                    <td style="max-width:300px;overflow:hidden;text-overflow:ellipsis;">${(b.prompt || '').substring(0, 80)}${(b.prompt || '').length > 80 ? '...' : ''}</td>
                    <td><span style="background:${b.status === 'completed' ? '#C6F6D5' : b.status === 'failed' ? '#FED7D7' : '#FEFCBF'};padding:4px 8px;border-radius:4px;">${b.status}</span></td>
                    <td>${b.result?.validation_score || '-'}</td>
                    <td>${new Date(b.created_at).toLocaleDateString()}</td>
                    <td><button class="btn btn-warning" onclick="editBatch(${b.id})">Edit</button> <button class="btn btn-danger" onclick="deleteBatch(${b.id})">Delete</button></td>
                </tr>`).join('');
            }
        }
        
        function displayRecentBatches() {
            const tbody = document.querySelector('#recentBatchesTable tbody');
            const recent = allBatches.slice(-5).reverse();
            if (!recent || recent.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">No batches found</td></tr>';
            } else {
                tbody.innerHTML = recent.map(b => `<tr><td>${b.id}</td><td style="max-width:300px;">${(b.prompt || '').substring(0, 50)}...</td><td>${b.status}</td><td>${b.result?.validation_score || '-'}</td><td>${new Date(b.created_at).toLocaleDateString()}</td></tr>`).join('');
            }
        }
        
        function filterBatches() { displayBatches(); }
        
        function editBatch(batchId) {
            const batch = allBatches.find(b => b.id === batchId);
            if (batch) {
                document.getElementById('editBatchPrompt').value = batch.prompt || '';
                document.getElementById('editBatchStatus').value = batch.status || 'pending';
                document.getElementById('editBatchModal').style.display = 'flex';
                window.currentEditBatchId = batchId;
            }
        }
        
        async function updateBatch() {
            const batchId = window.currentEditBatchId;
            const prompt = document.getElementById('editBatchPrompt').value;
            const status = document.getElementById('editBatchStatus').value;
            try {
                await fetch(`/api/v1/batches/${batchId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ prompt, status })
                });
                closeEditBatchModal();
                loadAllBatches();
            } catch(e) { alert('Error updating batch'); }
        }
        
        async function deleteBatch(batchId) {
            if (confirm('Are you sure you want to delete this batch?')) {
                try {
                    await fetch(`/api/v1/batches/${batchId}`, { method: 'DELETE' });
                    loadAllBatches();
                } catch(e) { alert('Error deleting batch'); }
            }
        }
        
        function closeEditBatchModal() { document.getElementById('editBatchModal').style.display = 'none'; }
        
        // Agent Configuration
        const agents = [
            { id: 'architect', name: 'Architect', description: 'System design and architecture planning' },
            { id: 'backend', name: 'Backend', description: 'API and service code generation' },
            { id: 'frontend', name: 'Frontend', description: 'UI components and pages' },
            { id: 'database', name: 'Database', description: 'Schema design and migrations' },
            { id: 'qa', name: 'QA', description: 'Test generation and quality assurance' },
            { id: 'security', name: 'Security', description: 'Vulnerability scanning' },
            { id: 'devops', name: 'DevOps', description: 'CI/CD and deployment' },
            { id: 'code', name: 'Code Generator', description: 'General code generation' }
        ];
        
        let agentConfigs = {};
        
        function loadAgentsConfig() {
            const saved = localStorage.getItem('agent_configs');
            if (saved) {
                agentConfigs = JSON.parse(saved);
            } else {
                agents.forEach(a => { agentConfigs[a.id] = { enabled: true, confidence_threshold: 70, max_retries: 3, timeout: 30 }; });
            }
            displayAgentsConfig();
        }
        
        function displayAgentsConfig() {
            const container = document.getElementById('agentsConfigList');
            container.innerHTML = agents.map(agent => `
                <div class="agent-config-card">
                    <h4>🤖 ${agent.name}</h4>
                    <p style="color:#718096;margin-bottom:10px;">${agent.description}</p>
                    <div style="display:flex;gap:20px;flex-wrap:wrap;">
                        <div><strong>Status:</strong> <span style="color:${agentConfigs[agent.id]?.enabled ? '#38A169' : '#E53E3E'}">${agentConfigs[agent.id]?.enabled ? 'Enabled' : 'Disabled'}</span></div>
                        <div><strong>Confidence Threshold:</strong> ${agentConfigs[agent.id]?.confidence_threshold || 70}%</div>
                        <div><strong>Max Retries:</strong> ${agentConfigs[agent.id]?.max_retries || 3}</div>
                        <div><strong>Timeout:</strong> ${agentConfigs[agent.id]?.timeout || 30}s</div>
                        <button class="btn" onclick="configureAgentModal('${agent.id}', '${agent.name}')">Configure</button>
                    </div>
                </div>
            `).join('');
        }
        
        function configureAgentModal(agentId, agentName) {
            const config = agentConfigs[agentId] || { enabled: true, confidence_threshold: 70, max_retries: 3, timeout: 30 };
            document.getElementById('agentModalTitle').innerText = `Configure ${agentName} Agent`;
            document.getElementById('agentEnabled').value = config.enabled ? 'true' : 'false';
            document.getElementById('agentConfidence').value = config.confidence_threshold;
            document.getElementById('agentMaxRetries').value = config.max_retries;
            document.getElementById('agentTimeout').value = config.timeout;
            document.getElementById('configureAgentModal').style.display = 'flex';
            window.currentAgentId = agentId;
        }
        
        function saveAgentConfig() {
            const agentId = window.currentAgentId;
            agentConfigs[agentId] = {
                enabled: document.getElementById('agentEnabled').value === 'true',
                confidence_threshold: parseInt(document.getElementById('agentConfidence').value),
                max_retries: parseInt(document.getElementById('agentMaxRetries').value),
                timeout: parseInt(document.getElementById('agentTimeout').value)
            };
            localStorage.setItem('agent_configs', JSON.stringify(agentConfigs));
            closeAgentModal();
            displayAgentsConfig();
            alert(`Agent ${agentId} configuration saved!`);
        }
        
        function closeAgentModal() { document.getElementById('configureAgentModal').style.display = 'none'; }
        
        // User Management
        function showAddUserModal() { document.getElementById('addUserModal').style.display = 'flex'; }
        function closeAddUserModal() { document.getElementById('addUserModal').style.display = 'none'; }
        
        async function createUser() {
            const name = document.getElementById('newUserName').value;
            const email = document.getElementById('newUserEmail').value;
            const tier = document.getElementById('newUserTier').value;
            if (!name || !email) { alert('Please fill all fields'); return; }
            await fetch('/api/v1/admin/users', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, email, tier, status: 'active' })
            });
            closeAddUserModal();
            loadUsers();
            loadStats();
        }
        
        async function deleteUser(userId) {
            if (confirm('Delete this user?')) {
                await fetch(`/api/v1/admin/users/${userId}`, { method: 'DELETE' });
                loadUsers();
                loadStats();
            }
        }
        
        // System Settings
        async function saveSystemSettings() {
            const settings = {
                app_name: document.getElementById('appName').value,
                default_tier: document.getElementById('defaultTier').value,
                max_batches_free: parseInt(document.getElementById('maxBatchesFree').value),
                maintenance_mode: document.getElementById('maintenanceMode').value === 'true'
            };
            await fetch('/api/v1/admin/settings', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(settings)
            });
            document.getElementById('settingsMessage').innerHTML = '<span style="color:green;">Settings saved successfully!</span>';
            setTimeout(() => { document.getElementById('settingsMessage').innerHTML = ''; }, 3000);
        }
        
        function showTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            if (tabId === 'users') loadUsers();
            if (tabId === 'batches') loadAllBatches();
            if (tabId === 'agents') loadAgentsConfig();
            if (tabId === 'dashboard') loadStats();
        }
    </script>
</body>
</html>
'@

$updatedDashboard | Out-File -FilePath $adminDashboardPath -Encoding UTF8

Write-Host "[2/4] Adding backend endpoints for batch management..." -ForegroundColor Yellow

$batchManagementEndpoints = @'
# backend/app/api/v1/batches_admin.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
import json
import os

router = APIRouter()

BATCHES_FILE = "/app/data/batches.json"

def load_batches():
    if os.path.exists(BATCHES_FILE):
        with open(BATCHES_FILE, 'r') as f:
            return json.load(f)
    return []

def save_batches(batches):
    with open(BATCHES_FILE, 'w') as f:
        json.dump(batches, f, indent=2)

class BatchUpdate(BaseModel):
    prompt: Optional[str] = None
    status: Optional[str] = None
    result: Optional[Dict] = None

@router.put("/{batch_id}")
async def update_batch(batch_id: int, update: BatchUpdate):
    batches = load_batches()
    for i, batch in enumerate(batches):
        if batch.get("id") == batch_id:
            if update.prompt is not None:
                batches[i]["prompt"] = update.prompt
            if update.status is not None:
                batches[i]["status"] = update.status
            if update.result is not None:
                batches[i]["result"] = update.result
            save_batches(batches)
            return batches[i]
    raise HTTPException(status_code=404, detail="Batch not found")

@router.delete("/{batch_id}")
async def delete_batch(batch_id: int):
    batches = load_batches()
    for i, batch in enumerate(batches):
        if batch.get("id") == batch_id:
            deleted = batches.pop(i)
            save_batches(batches)
            return {"message": f"Batch #{deleted.get('batch_number')} deleted"}
    raise HTTPException(status_code=404, detail="Batch not found")
'@

$batchManagementEndpoints | Out-File -FilePath "backend\app\api\v1\batches_admin.py" -Encoding UTF8

Write-Host "[3/4] Updating API router..." -ForegroundColor Yellow

$updatedInit = @'
from fastapi import APIRouter
from .batches import router as batches_router
from .batches_admin import router as batches_admin_router
from .projects import router as projects_router
from .agents import router as agents_router
from .orchestration import router as orchestration_router
from .evolution import router as evolution_router
from .cicd import router as cicd_router
from .cms.pages import router as cms_router
from .admin import router as admin_router
from .billing_usage import router as billing_usage_router
from .workspaces.routes import router as workspaces_router
from .audit.routes import router as audit_router

router = APIRouter()
router.include_router(batches_router, prefix="/batches", tags=["batches"])
router.include_router(batches_admin_router, prefix="/batches", tags=["batches_admin"])
router.include_router(projects_router, prefix="/projects", tags=["projects"])
router.include_router(agents_router, prefix="/agents", tags=["agents"])
router.include_router(orchestration_router, prefix="/orchestration", tags=["orchestration"])
router.include_router(evolution_router, prefix="/evolution", tags=["evolution"])
router.include_router(cicd_router, prefix="/cicd", tags=["cicd"])
router.include_router(cms_router, prefix="/cms", tags=["cms"])
router.include_router(admin_router, prefix="/admin", tags=["admin"])
router.include_router(billing_usage_router, prefix="/billing", tags=["billing"])
router.include_router(workspaces_router, prefix="/workspaces", tags=["workspaces"])
router.include_router(audit_router, prefix="/audit", tags=["audit"])
'@

$updatedInit | Out-File -FilePath "backend\app\api\v1\__init__.py" -Encoding UTF8

Write-Host "[4/4] Restarting backend and frontend..." -ForegroundColor Yellow

docker-compose restart backend
Start-Sleep -Seconds 5
docker-compose restart frontend
Start-Sleep -Seconds 8

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "BATCH & AGENT MANAGEMENT ADDED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "New Admin Features:" -ForegroundColor Cyan
Write-Host "   Batch Management:" -ForegroundColor White
Write-Host "     - View all batches with filtering (by status, search by prompt)" -ForegroundColor Gray
Write-Host "     - Edit batch prompts and status" -ForegroundColor Gray
Write-Host "     - Delete batches" -ForegroundColor Gray
Write-Host "     - View batch scores and details" -ForegroundColor Gray
Write-Host ""
Write-Host "   Agent Configuration:" -ForegroundColor White
Write-Host "     - Configure all 8 AI agents individually" -ForegroundColor Gray
Write-Host "     - Enable/disable each agent" -ForegroundColor Gray
Write-Host "     - Set confidence thresholds (0-100)" -ForegroundColor Gray
Write-Host "     - Configure max retries and timeouts" -ForegroundColor Gray
Write-Host "     - Settings persist in local storage" -ForegroundColor Gray
Write-Host ""
Write-Host "Opening admin dashboard..." -ForegroundColor Cyan
Start-Process "http://localhost:4000/admin"