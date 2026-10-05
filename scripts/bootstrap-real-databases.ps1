param(
    [ValidateSet("all", "postgresql", "mssql", "oracle")]
    [string]$Target = "all",
    [switch]$Migrate,
    [switch]$ConfirmRealServers
)

$ErrorActionPreference = "Stop"
. $PSScriptRoot\set-java.ps1

if (-not $ConfirmRealServers) {
    throw "This script targets shared real database servers. Re-run with -ConfirmRealServers after checking the target profiles."
}

Write-Host "Compiling bootstrap utility..."
mvn -q -DskipTests compile

Write-Host "Creating isolated lab schemas/databases for target: $Target"
mvn -q -DskipTests exec:java "-Dexec.mainClass=edu.diploma.deadlocklab.bootstrap.RealDatabaseBootstrap" "-Dexec.args=$Target"

if ($Migrate) {
    $profiles = @()
    if ($Target -eq "all" -or $Target -eq "postgresql") { $profiles += "postgresql-real" }
    if ($Target -eq "all" -or $Target -eq "mssql") { $profiles += "mssql-real" }
    if ($Target -eq "all" -or $Target -eq "oracle") { $profiles += "oracle-real" }

    foreach ($profile in $profiles) {
        Write-Host "Applying Flyway migrations for profile: $profile"
        mvn -q spring-boot:run "-Dspring-boot.run.profiles=$profile" "-Dspring-boot.run.arguments=--spring.main.web-application-type=none"
    }
}
