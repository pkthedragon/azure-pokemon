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
if (!(Test-Path -LiteralPath $gamePath -PathType Leaf)) {
  throw "Game executable not found: $gamePath"
}

$logPaths = [System.Collections.Generic.List[string]]::new()
$logPaths.Add((Join-Path $Root "errorlog.txt"))
$gameIniPath = Join-Path $Root "Game.ini"
if (Test-Path -LiteralPath $gameIniPath -PathType Leaf) {
  $titleMatch = [regex]::Match(
    [System.IO.File]::ReadAllText($gameIniPath),
    '(?m)^Title\s*=\s*(.+?)\s*$'
  )
  if ($titleMatch.Success -and $env:USERPROFILE) {
    $gameTitle = $titleMatch.Groups[1].Value.Trim()
    $savedLog = Join-Path $env:USERPROFILE ("Saved Games\{0}\errorlog.txt" -f $gameTitle)
    if (!$logPaths.Contains($savedLog)) { $logPaths.Add($savedLog) }
  }
}

function Get-ErrorLogState {
  param([Parameter(Mandatory)][string]$Path)
  $exists = Test-Path -LiteralPath $Path -PathType Leaf
  [pscustomobject]@{
    Path = $Path
    Exists = $exists
    Length = if ($exists) { (Get-Item -LiteralPath $Path).Length } else { -1 }
    WriteTicks = if ($exists) { (Get-Item -LiteralPath $Path).LastWriteTimeUtc.Ticks } else { -1 }
  }
}

$beforeLogs = @{}
foreach ($path in $logPaths) { $beforeLogs[$path] = Get-ErrorLogState -Path $path }
$process = $null
$scriptOrderPath = Join-Path $Root "Scripts\!script_order.csv"
$scriptOrderWriteTime = $null
$coldScriptImportForced = $false

try {
  # A warm launch can reuse the previously imported script archive and miss
  # syntax errors in edited external scripts. Advance the manifest timestamp
  # for this run so the loader evaluates every source file, then restore the
  # original timestamp in finally.
  if (Test-Path -LiteralPath $scriptOrderPath -PathType Leaf) {
    $scriptOrderWriteTime = (Get-Item -LiteralPath $scriptOrderPath).LastWriteTimeUtc
    # The external-script cache and synchronized filesystems can use coarse or
    # slightly future-skewed timestamps. A two-second advance can therefore
    # leave a warm archive looking newer than the manifest. Move the manifest
    # five minutes ahead for the launch, then restore its exact timestamp in
    # finally, so edited external scripts are reliably imported.
    $futureBase = [DateTime]::UtcNow
    if ($scriptOrderWriteTime -gt $futureBase) { $futureBase = $scriptOrderWriteTime }
    [System.IO.File]::SetLastWriteTimeUtc($scriptOrderPath, $futureBase.AddMinutes(5))
    $coldScriptImportForced = $true
  }
  $process = Start-Process -FilePath $gamePath -WorkingDirectory $Root -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds $Seconds
  $alive = !$process.HasExited
  $exitCode = if ($alive) { $null } else { $process.ExitCode }

  $afterLogs = @{}
  $changedLogs = [System.Collections.Generic.List[string]]::new()
  foreach ($path in $logPaths) {
    $before = $beforeLogs[$path]
    $after = Get-ErrorLogState -Path $path
    $afterLogs[$path] = $after
    if (($before.Exists -ne $after.Exists) -or
        ($before.Length -ne $after.Length) -or
        ($before.WriteTicks -ne $after.WriteTicks)) {
      $changedLogs.Add($path)
    }
  }
  $logChanged = $changedLogs.Count -gt 0

  [pscustomobject]@{
    ProcessId = $process.Id
    AliveAfterSeconds = $alive
    Seconds = $Seconds
    ExitCode = $exitCode
    ErrorLogChanged = $logChanged
    ColdScriptImportForced = $coldScriptImportForced
    ErrorLogsChecked = $logPaths -join "; "
    ChangedErrorLogs = $changedLogs -join "; "
  } | Format-List

  if (!$alive -or $logChanged) {
    foreach ($path in $changedLogs) {
      if ($afterLogs[$path].Exists) {
        Write-Host "Latest error log output from ${path}:" -ForegroundColor Red
        Get-Content -LiteralPath $path -Tail 100
      }
    }
    exit 1
  }
} finally {
  if ($process -and !$process.HasExited) {
    Stop-Process -Id $process.Id -Force
  }
  if ($scriptOrderWriteTime) {
    [System.IO.File]::SetLastWriteTimeUtc($scriptOrderPath, $scriptOrderWriteTime)
  }
}

exit 0
