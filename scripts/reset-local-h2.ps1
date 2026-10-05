param(
    [string]$DataDir = "data",
    [string]$DatabaseName = "deadlock-lab"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $DataDir)) {
    Write-Host "Data directory does not exist: $DataDir"
    exit 0
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$patterns = @(
    "$DatabaseName.mv.db",
    "$DatabaseName.trace.db",
    "$DatabaseName.lock.db"
)

foreach ($pattern in $patterns) {
    $path = Join-Path $DataDir $pattern
    if (Test-Path -LiteralPath $path) {
        $backup = "$path.$timestamp.bak"
        Move-Item -LiteralPath $path -Destination $backup -Force
        Write-Host "Moved $path -> $backup"
    }
}
