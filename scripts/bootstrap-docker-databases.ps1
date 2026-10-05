param(
    [ValidateSet("mssql")]
    [string]$Target = "mssql"
)

$ErrorActionPreference = "Stop"
. $PSScriptRoot\set-java.ps1

Write-Host "Compiling bootstrap utility..."
mvn -q -DskipTests compile

Write-Host "Creating Docker MSSQL database deadlock_lab if needed..."
mvn -q -DskipTests exec:java "-Dexec.mainClass=edu.diploma.deadlocklab.bootstrap.DockerDatabaseBootstrap"
