[CmdletBinding()]
param(
  [string]$Root,
  [ValidateRange(5, 120)]
  [int]$Seconds = 45
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

function Invoke-StartupPass {
  param(
    [Parameter(Mandatory)][ValidateSet("Cold", "Warm", "Invalidated")][string]$Mode
  )

  $token = [Guid]::NewGuid().ToString("N")
  $probePath = Join-Path ([IO.Path]::GetTempPath()) "PokemonAzureStartup-$token.status"
  $tracePath = Join-Path ([IO.Path]::GetTempPath()) "PokemonAzureLoader-$token.status"
  $beforeLogs = @{}
  foreach ($path in $logPaths) { $beforeLogs[$path] = Get-ErrorLogState -Path $path }

  $previousProbe = [Environment]::GetEnvironmentVariable("AZURE_STARTUP_PROBE_TOKEN", "Process")
  $previousBypass = [Environment]::GetEnvironmentVariable("AZURE_SCRIPT_CACHE_BYPASS", "Process")
  $previousNoWrite = [Environment]::GetEnvironmentVariable("AZURE_SCRIPT_CACHE_NO_WRITE", "Process")
  $process = $null
  $stopwatch = [Diagnostics.Stopwatch]::StartNew()
  $probeReached = $false
  $probeContent = ""

  try {
    [Environment]::SetEnvironmentVariable("AZURE_STARTUP_PROBE_TOKEN", $token, "Process")
    [Environment]::SetEnvironmentVariable(
      "AZURE_SCRIPT_CACHE_BYPASS",
      $(if ($Mode -eq "Cold") { "1" } else { $null }),
      "Process"
    )
    [Environment]::SetEnvironmentVariable(
      "AZURE_SCRIPT_CACHE_NO_WRITE",
      $(if ($Mode -eq "Invalidated") { "1" } else { $null }),
      "Process"
    )
    $process = Start-Process -FilePath $gamePath -WorkingDirectory $Root -WindowStyle Hidden -PassThru
  } finally {
    [Environment]::SetEnvironmentVariable("AZURE_STARTUP_PROBE_TOKEN", $previousProbe, "Process")
    [Environment]::SetEnvironmentVariable("AZURE_SCRIPT_CACHE_BYPASS", $previousBypass, "Process")
    [Environment]::SetEnvironmentVariable("AZURE_SCRIPT_CACHE_NO_WRITE", $previousNoWrite, "Process")
  }

  try {
    $deadline = [DateTime]::UtcNow.AddSeconds($Seconds)
    while ([DateTime]::UtcNow -lt $deadline -and !$process.HasExited) {
      if (Test-Path -LiteralPath $probePath -PathType Leaf) {
        try {
          $probeContent = [System.IO.File]::ReadAllText($probePath)
          $probeReached = (
            $probeContent -match "(?m)^token=$([regex]::Escape($token))\r?$" -and
            $probeContent -match '(?m)^title_bootstrap_reached=true\r?$'
          )
        } catch [System.IO.IOException] {
          $probeReached = $false
        }
        if ($probeReached) { break }
      }
      Start-Sleep -Milliseconds 100
      $process.Refresh()
    }

    $process.Refresh()
    $alive = !$process.HasExited
    $exitCode = if ($alive) { $null } else { $process.ExitCode }
    $expectedCacheState = if ($Mode -eq "Warm") { "hit" } else { "miss" }
    $cacheStateReached = $probeContent -match "(?m)^script_cache=$expectedCacheState\r?$"

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
    $passed = $alive -and $probeReached -and $cacheStateReached -and !$logChanged

    $summary = [pscustomobject]@{
      Mode = $Mode
      ProcessId = $process.Id
      TitleBootstrapReached = $probeReached
      ScriptCacheExpected = $expectedCacheState
      ScriptCacheMatched = $cacheStateReached
      ElapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
      TimeoutSeconds = $Seconds
      AliveAtProbe = $alive
      ExitCode = $exitCode
      ErrorLogChanged = $logChanged
      ErrorLogsChecked = $logPaths -join "; "
      ChangedErrorLogs = $changedLogs -join "; "
      Passed = $passed
    }
    Write-Host ($summary | Format-List | Out-String)

    if (!$passed) {
      if (!$probeReached) {
        Write-Host "$Mode startup never reached the title bootstrap." -ForegroundColor Red
        if (Test-Path -LiteralPath $tracePath -PathType Leaf) {
          Write-Host "Latest loader checkpoint: $([IO.File]::ReadAllText($tracePath).Trim())" -ForegroundColor Red
        }
      } elseif (!$cacheStateReached) {
        Write-Host "$Mode startup reported an unexpected script-cache state:" -ForegroundColor Red
        Write-Host $probeContent
      }
      foreach ($path in $changedLogs) {
        if ($afterLogs[$path].Exists) {
          Write-Host "Latest error log output from ${path}:" -ForegroundColor Red
          Write-Host ((Get-Content -LiteralPath $path -Tail 100) -join [Environment]::NewLine)
        }
      }
      return $false
    }
    return $true
  } finally {
    if ($process -and !$process.HasExited) {
      Stop-Process -Id $process.Id -Force
    }
    if (Test-Path -LiteralPath $probePath -PathType Leaf) {
      Remove-Item -LiteralPath $probePath -Force
    }
    if (Test-Path -LiteralPath $tracePath -PathType Leaf) {
      Remove-Item -LiteralPath $tracePath -Force
    }
  }
}

$coldOutput = @(Invoke-StartupPass -Mode Cold)
$coldPassed = $coldOutput.Count -gt 0 -and $coldOutput[-1] -eq $true
$warmOutput = @(Invoke-StartupPass -Mode Warm)
$warmPassed = $warmOutput.Count -gt 0 -and $warmOutput[-1] -eq $true
$invalidationTarget = Join-Path $Root "Scripts\Settings.rb"
$originalInvalidationTime = (Get-Item -LiteralPath $invalidationTarget).LastWriteTimeUtc
$invalidationPassed = $false
try {
  [System.IO.File]::SetLastWriteTimeUtc($invalidationTarget, [DateTime]::UtcNow.AddMinutes(5))
  $invalidationOutput = @(Invoke-StartupPass -Mode Invalidated)
  $invalidationPassed = $invalidationOutput.Count -gt 0 -and $invalidationOutput[-1] -eq $true
} finally {
  [System.IO.File]::SetLastWriteTimeUtc($invalidationTarget, $originalInvalidationTime)
}
$restoredWarmOutput = @(Invoke-StartupPass -Mode Warm)
$restoredWarmPassed = $restoredWarmOutput.Count -gt 0 -and $restoredWarmOutput[-1] -eq $true
if (!$coldPassed -or !$warmPassed -or !$invalidationPassed -or !$restoredWarmPassed) { exit 1 }

Write-Host "Cold, warm, invalidated, and restored-cache startup passes all reached the title bootstrap."
exit 0
