[CmdletBinding()]
param(
  [string]$Root,
  [string]$PackageRoot,
  [ValidateRange(1,120)]
  [int]$Seconds = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
  $Root = (Resolve-Path $Root).Path
}
if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
  $PackageRoot = Join-Path $Root "tools\engine_test\package-ruby31"
}
$PackageRoot = (Resolve-Path $PackageRoot).Path
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $Root "tools\engine_test")).TrimEnd('\') + '\'
if (!$PackageRoot.StartsWith($allowedRoot,[System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Engine test package must remain inside $allowedRoot."
}

$gamePath = Join-Path $PackageRoot "Game.exe"
$orderPath = Join-Path $PackageRoot "Scripts\!script_order.csv"
$runtimeStatusPath = Join-Path $PackageRoot "engine_runtime.status.txt"
$timingStatusPath = Join-Path $PackageRoot "timing_runtime.status.txt"
$developerToolsStatusPath = Join-Path $PackageRoot "developer_tools_runtime.status.txt"
foreach ($path in @($gamePath,$orderPath)) {
  if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required package file is missing: $path" }
}

function Get-FileState([string]$Path) {
  $exists = Test-Path -LiteralPath $Path -PathType Leaf
  return [pscustomobject]@{
    Exists=$exists
    Length=if ($exists) { (Get-Item -LiteralPath $Path).Length } else { -1 }
    Ticks=if ($exists) { (Get-Item -LiteralPath $Path).LastWriteTimeUtc.Ticks } else { -1 }
  }
}

function Get-TreeState([string]$Path) {
  $state=@{}
  if (!(Test-Path -LiteralPath $Path -PathType Container)) { return $state }
  foreach ($file in Get-ChildItem -LiteralPath $Path -File -Recurse) {
    $relative=$file.FullName.Substring($Path.Length).TrimStart('\')
    $state[$relative]="$($file.Length):$($file.LastWriteTimeUtc.Ticks)"
  }
  return $state
}

$packageLog = Join-Path $PackageRoot "errorlog.txt"
$isolatedLog = Join-Path $PackageRoot "save\errorlog.txt"
$beforePackageLog = Get-FileState $packageLog
$beforeIsolatedLog = Get-FileState $isolatedLog
$productionSave = Join-Path $env:USERPROFILE "Saved Games\Pokemon Azure"
$beforeProductionSave = Get-TreeState $productionSave
$beforeRuntime = Get-FileState $runtimeStatusPath
$orderTime = (Get-Item -LiteralPath $orderPath).LastWriteTimeUtc
$process=$null
try {
  $future=[DateTime]::UtcNow
  if ($orderTime -gt $future) { $future=$orderTime }
  [System.IO.File]::SetLastWriteTimeUtc($orderPath,$future.AddMinutes(5))
  $started=[DateTime]::UtcNow
  $process=Start-Process -FilePath $gamePath -WorkingDirectory $PackageRoot -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds $Seconds
  $alive=!$process.HasExited
  $afterPackageLog = Get-FileState $packageLog
  $afterIsolatedLog = Get-FileState $isolatedLog
  $afterProductionSave = Get-TreeState $productionSave
  $productionSaveUnchanged=($beforeProductionSave.Count -eq $afterProductionSave.Count)
  if ($productionSaveUnchanged) {
    foreach ($key in $beforeProductionSave.Keys) {
      if (!$afterProductionSave.ContainsKey($key) -or $afterProductionSave[$key] -ne $beforeProductionSave[$key]) {
        $productionSaveUnchanged=$false
        break
      }
    }
  }
  $logsUnchanged=($beforePackageLog.Exists -eq $afterPackageLog.Exists -and
                  $beforePackageLog.Length -eq $afterPackageLog.Length -and
                  $beforePackageLog.Ticks -eq $afterPackageLog.Ticks -and
                  $beforeIsolatedLog.Exists -eq $afterIsolatedLog.Exists -and
                  $beforeIsolatedLog.Length -eq $afterIsolatedLog.Length -and
                  $beforeIsolatedLog.Ticks -eq $afterIsolatedLog.Ticks)
  $runtimeFresh=(Test-Path -LiteralPath $runtimeStatusPath -PathType Leaf) -and
                ((Get-Item -LiteralPath $runtimeStatusPath).LastWriteTimeUtc -ge $started)
  $timingFresh=(Test-Path -LiteralPath $timingStatusPath -PathType Leaf) -and
               ((Get-Item -LiteralPath $timingStatusPath).LastWriteTimeUtc -ge $started)
  $developerToolsFresh=(Test-Path -LiteralPath $developerToolsStatusPath -PathType Leaf) -and
                       ((Get-Item -LiteralPath $developerToolsStatusPath).LastWriteTimeUtc -ge $started)
  $runtimeContent=if ($runtimeFresh) { [System.IO.File]::ReadAllText($runtimeStatusPath) } else { "" }
  $timingContent=if ($timingFresh) { [System.IO.File]::ReadAllText($timingStatusPath) } else { "" }
  $developerToolsContent=if ($developerToolsFresh) { [System.IO.File]::ReadAllText($developerToolsStatusPath) } else { "" }
  $runtimeValid=($runtimeContent -match '(?m)^result=PASS\r?$' -and
                 $runtimeContent -match '(?m)^ruby_version=3\.1\.3\r?$' -and
                 $runtimeContent -match '(?m)^mkxp=true\r?$' -and
                 $runtimeContent -match '(?m)^graphics_api=true\r?$' -and
                 $runtimeContent -match '(?m)^input_api=true\r?$' -and
                 $runtimeContent -match '(?m)^audio_api=true\r?$' -and
                 $runtimeContent -match '(?m)^win32api_shim=true\r?$' -and
                 $runtimeContent -match '(?m)^graphics_render=true\r?$' -and
                 $runtimeContent -match '(?m)^font_render=true\r?$' -and
                 $runtimeContent -match '(?m)^input_update=true\r?$' -and
                 $runtimeContent -match '(?m)^audio_decode=true\r?$' -and
                 $runtimeContent -match '(?m)^native_win32_call=true\r?$' -and
                 $runtimeContent -match '(?m)^video_mci_bridge=true\r?$' -and
                 $runtimeContent -match '(?m)^network_hostname=true\r?$' -and
                 $runtimeContent -match '(?m)^zlib=true\r?$' -and
                 $runtimeContent -match '(?m)^openssl=true\r?$' -and
                 $runtimeContent -match '(?m)^updater_integrity=true\r?$' -and
                 $runtimeContent -match '(?m)^marshal_save_load=true\r?$' -and
                 $runtimeContent -match '(?m)^production_save_isolated=true\r?$')
  $timingValid=($timingContent -match '(?m)^result=PASS\r?$' -and
                $timingContent -match '(?m)^rates=44,88,110,132,176\r?$' -and
                $timingContent -match '(?m)^logical_rate_parity=true\r?$' -and
                $timingContent -match '(?m)^frameskip_logical_parity=true\r?$' -and
                $timingContent -match '(?m)^movement_animation_exact=true\r?$' -and
                $timingContent -match '(?m)^second_scaled_timers_exact=true\r?$' -and
                $timingContent -match '(?m)^paced_updates_valid=true\r?$' -and
                $timingContent -match '(?m)^fixed_44_playtime_policy=preserved\r?$')
  $developerToolsValid=($developerToolsContent -match '(?m)^result=PASS\r?$' -and
                        $developerToolsContent -match '(?m)^profiler_preloaded=false\r?$' -and
                        $developerToolsContent -match '(?m)^validator_preloaded=false\r?$' -and
                        $developerToolsContent -match '(?m)^profiler_ordered=false\r?$' -and
                        $developerToolsContent -match '(?m)^validator_ordered=false\r?$' -and
                        $developerToolsContent -match '(?m)^profiler_loaded=true\r?$' -and
                        $developerToolsContent -match '(?m)^validator_loaded=true\r?$' -and
                        $developerToolsContent -match '(?m)^profiler_output_outside_data=true\r?$')
  [pscustomobject]@{
    ProcessId=$process.Id
    AliveAfterSeconds=$alive
    Seconds=$Seconds
    RuntimeStatusFresh=$runtimeFresh
    RuntimeCompatibility=$runtimeValid
    TimingStatusFresh=$timingFresh
    TimingCompatibility=$timingValid
    DeveloperToolsStatusFresh=$developerToolsFresh
    DeveloperToolsCompatibility=$developerToolsValid
    ErrorLogsChanged=!$logsUnchanged
    ProductionSaveChanged=!$productionSaveUnchanged
    RubyVersion=if ($runtimeContent -match '(?m)^ruby_version=(.+)\r?$') { $Matches[1] } else { "" }
  } | Format-List
  if (!$alive -or !$runtimeFresh -or !$runtimeValid -or !$timingFresh -or !$timingValid -or !$developerToolsFresh -or !$developerToolsValid -or !$logsUnchanged -or !$productionSaveUnchanged) { exit 1 }
} finally {
  if ($process -and !$process.HasExited) { Stop-Process -Id $process.Id -Force }
  [System.IO.File]::SetLastWriteTimeUtc($orderPath,$orderTime)
}
exit 0
