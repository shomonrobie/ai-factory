Write-Host "Testing AI Factory API" -ForegroundColor Cyan
$baseUrl = "http://localhost:4001"

Write-Host "`n1. Health Check:" -ForegroundColor Yellow
$result = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
Write-Host "   Status: $($result.status)" -ForegroundColor Green

Write-Host "`n2. Creating Batch #1:" -ForegroundColor Yellow
$body = @{batch_number = 1; prompt = "Create a todo app"} | ConvertTo-Json
$batch = Invoke-RestMethod -Uri "$baseUrl/api/v1/batches/" -Method POST -ContentType "application/json" -Body $body
Write-Host "   Batch #$($batch.batch_number) created! ID: $($batch.id)" -ForegroundColor Green

Write-Host "`n3. Creating Batch #2:" -ForegroundColor Yellow
$body = @{batch_number = 2; prompt = "Create a blog platform"} | ConvertTo-Json
$batch2 = Invoke-RestMethod -Uri "$baseUrl/api/v1/batches/" -Method POST -ContentType "application/json" -Body $body
Write-Host "   Batch #$($batch2.batch_number) created!" -ForegroundColor Green

Write-Host "`n4. Listing All Batches:" -ForegroundColor Yellow
$batches = Invoke-RestMethod -Uri "$baseUrl/api/v1/batches/" -Method GET
Write-Host "   Total Batches: $($batches.Count)" -ForegroundColor Green
foreach ($b in $batches) {
    Write-Host "     Batch #$($b.batch_number): $($b.status)" -ForegroundColor Gray
}

Write-Host "`n5. Creating Project:" -ForegroundColor Yellow
$body = @{name = "MySaaSApp"; description = "AI generated app"} | ConvertTo-Json
$project = Invoke-RestMethod -Uri "$baseUrl/api/v1/projects/" -Method POST -ContentType "application/json" -Body $body
Write-Host "   Project '$($project.name)' created! ID: $($project.id)" -ForegroundColor Green

Write-Host "`n6. Listing Projects:" -ForegroundColor Yellow
$projects = Invoke-RestMethod -Uri "$baseUrl/api/v1/projects/" -Method GET
Write-Host "   Total Projects: $($projects.Count)" -ForegroundColor Green
foreach ($p in $projects) {
    Write-Host "     Project #$($p.id): $($p.name)" -ForegroundColor Gray
}

Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
Write-Host "TEST COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 50) -ForegroundColor Cyan
Write-Host "`nAccess:"
Write-Host "  Frontend: http://localhost:4000"
Write-Host "  Backend API: http://localhost:4001"
Write-Host "  API Docs: http://localhost:4001/docs"