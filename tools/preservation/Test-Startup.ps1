[CmdletBinding()]
param(
  [string]$Root,
  [ValidateRange(1, 120)]
  [int]$Seconds = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
  $Root = (Resolve-Path $Root).Path
}

$gamePath = Join-Path $Root "Game.exe"
$logPath = Join-Path $Root "errorlog.txt"
if (!(Test-Path -LiteralPath $gamePath -PathType Leaf)) {
  throw "Game executable not found: $gamePath"
}

$beforeExists = Test-Path -LiteralPath $logPath -PathType Leaf
$beforeLength = if ($beforeExists) { (Get-Item -LiteralPath $logPath).Length } else { -1 }
$beforeWrite = if ($beforeExists) { (Get-Item -LiteralPath $logPath).LastWriteTimeUtc.Ticks } else { -1 }
$process = $null

try {
  $process = Start-Process -FilePath $gamePath -WorkingDirectory $Root -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds $Seconds
  $alive = !$process.HasExited
  $exitCode = if ($alive) { $null } else { $process.ExitCode }

  $afterExists = Test-Path -LiteralPath $logPath -PathType Leaf
  $afterLength = if ($afterExists) { (Get-Item -LiteralPath $logPath).Length } else { -1 }
  $afterWrite = if ($afterExists) { (Get-Item -LiteralPath $logPath).LastWriteTimeUtc.Ticks } else { -1 }
  $logChanged = ($beforeExists -ne $afterExists) -or
    ($beforeLength -ne $afterLength) -or ($beforeWrite -ne $afterWrite)

  [pscustomobject]@{
    ProcessId = $process.Id
    AliveAfterSeconds = $alive
    Seconds = $Seconds
    ExitCode = $exitCode
    ErrorLogChanged = $logChanged
    ErrorLogLengthBefore = $beforeLength
    ErrorLogLengthAfter = $afterLength
  } | Format-List

  if (!$alive -or $logChanged) {
    if ($logChanged -and $afterExists) {
      Write-Host "Latest error log output:" -ForegroundColor Red
      Get-Content -LiteralPath $logPath -Tail 100
    }
    exit 1
  }
} finally {
  if ($process -and !$process.HasExited) {
    Stop-Process -Id $process.Id -Force
  }
}

exit 0
