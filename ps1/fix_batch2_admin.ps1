# fix_batch2_admin.ps1
Write-Host "Fixing admin directory and file..." -ForegroundColor Yellow

cd D:\aisfs\ai-factory

# Create the admin directory
New-Item -ItemType Directory -Force -Path "frontend\src\app\admin" | Out-Null

# Create the admin settings page
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
        <h1>Admin Settings</h1>
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
                fetch('/api/v1/admin/settings', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({app_name: newName})
                }).catch(err => console.log('API not available'));
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

Write-Host "Admin settings page created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Phase 1 Batch 2 is now fully complete." -ForegroundColor Cyan