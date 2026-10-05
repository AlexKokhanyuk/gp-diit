param(
  [Parameter(Mandatory = $true)]
  [string] $ScriptPath,

  [Parameter(Mandatory = $true)]
  [string] $LogFile
)

$ErrorActionPreference = 'Stop'

$scriptFullPath = (Resolve-Path -LiteralPath $ScriptPath).Path
$workDir = Split-Path -Parent $scriptFullPath
$logDir = Split-Path -Parent $LogFile
if ($logDir -and -not (Test-Path -LiteralPath $logDir)) {
  New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$writer = [System.IO.StreamWriter]::new($LogFile, $true, [System.Text.Encoding]::UTF8)
$writer.AutoFlush = $true
$writeLock = [object]::new()

$writeLine = {
  param([string] $Line)
  if ($null -eq $Line) {
    return
  }
  [System.Threading.Monitor]::Enter($writeLock)
  try {
    Write-Host $Line
    $writer.WriteLine($Line)
  }
  finally {
    [System.Threading.Monitor]::Exit($writeLock)
  }
}

try {
  $psi = [System.Diagnostics.ProcessStartInfo]::new()
  $psi.FileName = $env:ComSpec
  $psi.WorkingDirectory = $workDir
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.Arguments = '/d /c call "' + $scriptFullPath + '" __main'

  $process = [System.Diagnostics.Process]::new()
  $process.StartInfo = $psi
  $process.add_OutputDataReceived({
    param($sender, $eventArgs)
    & $writeLine $eventArgs.Data
  })
  $process.add_ErrorDataReceived({
    param($sender, $eventArgs)
    & $writeLine $eventArgs.Data
  })

  [void] $process.Start()
  $process.BeginOutputReadLine()
  $process.BeginErrorReadLine()
  $process.WaitForExit()
  $process.WaitForExit()

  exit $process.ExitCode
}
finally {
  $writer.Dispose()
}
