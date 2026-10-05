param(
    [int]$Port = 8080,
    [string]$Profile = "h2"
)

$ErrorActionPreference = "Stop"
. $PSScriptRoot\set-java.ps1

$jar = "target\neutral-delete-deadlock-lab-0.0.1-SNAPSHOT.jar"
if (-not (Test-Path -LiteralPath $jar)) {
    throw "Jar not found: $jar. Run scripts\build-low-memory.ps1 first."
}

java -Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC -jar $jar --spring.profiles.active=$Profile --server.port=$Port
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
