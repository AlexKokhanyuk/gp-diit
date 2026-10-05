param(
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"

Write-Host "Starting MSSQL container..."
docker compose up -d mssql
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Creating deadlock_lab database if needed..."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap-docker-databases.ps1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Starting application with mssql profile..."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-local-low-memory.ps1 -Profile mssql -Port $Port
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
