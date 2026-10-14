[CmdletBinding()]
param(
  [string]$Root,
  [string]$PackageRoot,
  [ValidateRange(10,600)]
  [int]$TimeoutSeconds = 180
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
  $Root = (Resolve-Path $Root).Path
}
if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
  $PackageRoot = Join-Path $Root "tools\engine_test\package-ruby31-smoke"
}
$PackageRoot = (Resolve-Path $PackageRoot).Path
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $Root "tools\engine_test")).TrimEnd('\') + '\'
if (!$PackageRoot.StartsWith($allowedRoot,[System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Release smoke package must remain inside $allowedRoot."
}

$gamePath = Join-Path $PackageRoot "Game.exe"
$orderPath = Join-Path $PackageRoot "Scripts\!script_order.csv"
$statusPath = Join-Path $PackageRoot "release_smoke_runtime.status.txt"
$runtimeStatusPath = Join-Path $PackageRoot "engine_runtime.status.txt"
$timingStatusPath = Join-Path $PackageRoot "timing_runtime.status.txt"
$toolsStatusPath = Join-Path $PackageRoot "developer_tools_runtime.status.txt"
foreach ($path in @($gamePath,$orderPath)) {
  if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required package file is missing: $path" }
}

function Get-TreeHashes([string]$Path) {
  $state=@{}
  if (!(Test-Path -LiteralPath $Path -PathType Container)) { return $state }
  foreach ($file in Get-ChildItem -LiteralPath $Path -File -Recurse) {
    $relative=$file.FullName.Substring($Path.Length).TrimStart('\')
    $state[$relative]=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
  }
  return $state
}

function Compare-TreeHashes($Before,$After) {
  if ($Before.Count -ne $After.Count) { return $false }
  foreach ($key in $Before.Keys) {
    if (!$After.ContainsKey($key) -or $After[$key] -ne $Before[$key]) { return $false }
  }
  return $true
}

function Get-FileState([string]$Path) {
  $exists=Test-Path -LiteralPath $Path -PathType Leaf
  return [pscustomobject]@{
    Exists=$exists
    Length=if ($exists) { (Get-Item -LiteralPath $Path).Length } else { -1 }
    Ticks=if ($exists) { (Get-Item -LiteralPath $Path).LastWriteTimeUtc.Ticks } else { -1 }
  }
}

function Test-UnchangedFileState($Before,$After) {
  return ($Before.Exists -eq $After.Exists -and
          $Before.Length -eq $After.Length -and
          $Before.Ticks -eq $After.Ticks)
}

$productionTrees=@("Data","PBS","Scripts")
$beforeTrees=@{}
foreach ($name in $productionTrees) { $beforeTrees[$name]=Get-TreeHashes (Join-Path $Root $name) }
$productionSave=Join-Path $env:USERPROFILE "Saved Games\Pokemon Azure"
$beforeSave=Get-TreeHashes $productionSave
$packageLog=Join-Path $PackageRoot "errorlog.txt"
$isolatedLog=Join-Path $PackageRoot "save\errorlog.txt"
$beforePackageLog=Get-FileState $packageLog
$beforeIsolatedLog=Get-FileState $isolatedLog
$orderTime=(Get-Item -LiteralPath $orderPath).LastWriteTimeUtc
$process=$null
try {
  $future=[DateTime]::UtcNow
  if ($orderTime -gt $future) { $future=$orderTime }
  [System.IO.File]::SetLastWriteTimeUtc($orderPath,$future.AddMinutes(5))
  $started=[DateTime]::UtcNow
  $process=Start-Process -FilePath $gamePath -WorkingDirectory $PackageRoot -WindowStyle Hidden -PassThru
  $deadline=[DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
  $fresh=$false
  while ([DateTime]::UtcNow -lt $deadline -and !$process.HasExited) {
    if (Test-Path -LiteralPath $statusPath -PathType Leaf) {
      $fresh=(Get-Item -LiteralPath $statusPath).LastWriteTimeUtc -ge $started
      if ($fresh) {
        $probe=[System.IO.File]::ReadAllText($statusPath)
        if ($probe -match '(?m)^result=(?:PASS|FAIL)\r?$') { break }
      }
    }
    Start-Sleep -Milliseconds 250
  }

  $content=if ($fresh) { [System.IO.File]::ReadAllText($statusPath) } else { "" }
  $required=@(
    '(?m)^result=PASS\r?$',
    '(?m)^phase=5_step_3_release_interaction_smoke\r?$',
    '(?m)^old_save_fixture=true\r?$',
    '(?m)^old_save_header=true\r?$',
    '(?m)^old_save_objects=16\r?$',
    '(?m)^save_roundtrip=true\r?$',
    '(?m)^save_roundtrip_objects=16\r?$',
    '(?m)^save_write_scope=isolated_package_only\r?$',
    '(?m)^new_game_setup=true\r?$',
    '(?m)^load_panel_render=true\r?$',
    '(?m)^pause_menu=true\r?$',
    '(?m)^debug_menu_render=true\r?$',
    '(?m)^debug_registry_identity=true\r?$',
    '(?m)^editor_sources=\d+\r?$',
    '(?m)^map_transfer=true\r?$',
    '(?m)^map_transfer_same_object=true\r?$',
    '(?m)^map_transfer_handoff_cleared=true\r?$',
    '(?m)^single_battle=true\r?$',
    '(?m)^single_battle_decision=[125]\r?$',
    '(?m)^double_battle=true\r?$',
    '(?m)^double_battle_decision=[125]\r?$',
    '(?m)^cached_move_reads=1000\r?$',
    '(?m)^probe_errors=none\r?$'
  )
  $smokeValid=$true
  foreach ($pattern in $required) {
    if ($content -notmatch $pattern) { $smokeValid=$false }
  }

  $supportValid=$true
  foreach ($support in @(
    @{Path=$runtimeStatusPath; Pattern='(?m)^result=PASS\r?$'},
    @{Path=$timingStatusPath; Pattern='(?m)^result=PASS\r?$'},
    @{Path=$toolsStatusPath; Pattern='(?m)^result=PASS\r?$'}
  )) {
    if (!(Test-Path -LiteralPath $support.Path -PathType Leaf) -or
        (Get-Item -LiteralPath $support.Path).LastWriteTimeUtc -lt $started -or
        [System.IO.File]::ReadAllText($support.Path) -notmatch $support.Pattern) {
      $supportValid=$false
    }
  }

  $productionTreesUnchanged=$true
  foreach ($name in $productionTrees) {
    if (!(Compare-TreeHashes $beforeTrees[$name] (Get-TreeHashes (Join-Path $Root $name)))) {
      $productionTreesUnchanged=$false
    }
  }
  $productionSaveUnchanged=Compare-TreeHashes $beforeSave (Get-TreeHashes $productionSave)
  $logsUnchanged=(Test-UnchangedFileState $beforePackageLog (Get-FileState $packageLog)) -and
                 (Test-UnchangedFileState $beforeIsolatedLog (Get-FileState $isolatedLog))
  $alive=!$process.HasExited

  [pscustomobject]@{
    ProcessId=$process.Id
    SmokeStatusFresh=$fresh
    SmokeCompatibility=$smokeValid
    SupportingGates=$supportValid
    ProcessAlive=$alive
    TimeoutSeconds=$TimeoutSeconds
    ProductionTreesChanged=!$productionTreesUnchanged
    ProductionSaveChanged=!$productionSaveUnchanged
    ErrorLogsChanged=!$logsUnchanged
  } | Format-List
  if ($fresh) { Write-Host $content }
  if (!$fresh -or !$smokeValid -or !$supportValid -or !$alive -or
      !$productionTreesUnchanged -or !$productionSaveUnchanged -or !$logsUnchanged) {
    exit 1
  }
} finally {
  if ($process -and !$process.HasExited) { Stop-Process -Id $process.Id -Force }
  [System.IO.File]::SetLastWriteTimeUtc($orderPath,$orderTime)
}
exit 0
