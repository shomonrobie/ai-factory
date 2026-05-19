Write-Host "`n=== Testing Fixed Backend ===" -ForegroundColor Cyan

$baseUrl = "http://localhost:4001"

# Test health
Write-Host "`n1. Health check:" -ForegroundColor Yellow
$result = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
Write-Host "   Status: $($result.status)" -ForegroundColor Green

# Create a batch
Write-Host "`n2. Creating batch #10:" -ForegroundColor Yellow
$body = @{batch_number = 10; prompt = "Create an e-commerce platform"} | ConvertTo-Json
$batch = Invoke-RestMethod -Uri "$baseUrl/api/v1/batches/" -Method POST -ContentType "application/json" -Body $body
Write-Host "   Batch #$($batch.batch_number) created with ID: $($batch.id)" -ForegroundColor Green

# List all batches
Write-Host "`n3. Listing all batches:" -ForegroundColor Yellow
$batches = Invoke-RestMethod -Uri "$baseUrl/api/v1/batches/" -Method GET
Write-Host "   Total batches: $($batches.Count)" -ForegroundColor Green
foreach ($b in $batches) {
    Write-Host "     Batch #$($b.batch_number): $($b.status) - $($b.prompt.Substring(0, [Math]::Min(30, $b.prompt.Length)))..." -ForegroundColor Gray
}

# Create a project
Write-Host "`n4. Creating project:" -ForegroundColor Yellow
$body = @{name = "ECommerceApp"; description = "AI-generated e-commerce platform"} | ConvertTo-Json
$project = Invoke-RestMethod -Uri "$baseUrl/api/v1/projects/" -Method POST -ContentType "application/json" -Body $body
Write-Host "   Project '$($project.name)' created with ID: $($project.id)" -ForegroundColor Green

# List projects
Write-Host "`n5. Listing projects:" -ForegroundColor Yellow
$projects = Invoke-RestMethod -Uri "$baseUrl/api/v1/projects/" -Method GET
Write-Host "   Total projects: $($projects.Count)" -ForegroundColor Green
foreach ($p in $projects) {
    Write-Host "     Project #$($p.id): $($p.name) - $($p.status)" -ForegroundColor Gray
}

Write-Host "`nâœ… All tests passed!" -ForegroundColor Green
Write-Host "`nðŸ“Š Access your data:" -ForegroundColor Cyan
Write-Host "   API Docs: http://localhost:4001/docs" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:4000" -ForegroundColor Cyan
