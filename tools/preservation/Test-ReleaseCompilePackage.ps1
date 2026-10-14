[CmdletBinding()]
param(
  [string]$Root,
  [string]$PackageRoot,
  [ValidateRange(10,600)]
  [int]$TimeoutSeconds = 240
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
  $Root = (Resolve-Path $Root).Path
}
if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
  $PackageRoot = Join-Path $Root "tools\engine_test\package-ruby31-release"
}
$PackageRoot = (Resolve-Path $PackageRoot).Path
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $Root "tools\engine_test")).TrimEnd('\') + '\'
if (!$PackageRoot.StartsWith($allowedRoot,[System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Release compile package must remain inside $allowedRoot."
}

$gamePath = Join-Path $PackageRoot "Game.exe"
$orderPath = Join-Path $PackageRoot "Scripts\!script_order.csv"
$statusPath = Join-Path $PackageRoot "release_compile_runtime.status.txt"
foreach ($path in @($gamePath,$orderPath)) {
  if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required package file is missing: $path" }
}

function Get-TreeHashes([string]$Path) {
  $state=@{}
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
  $length=if ($exists) { (Get-Item -LiteralPath $Path).Length } else { -1 }
  $ticks=if ($exists) { (Get-Item -LiteralPath $Path).LastWriteTimeUtc.Ticks } else { -1 }
  return "${exists}:$length`:$ticks"
}

$productionTrees=@("Data","PBS","Scripts")
$beforeTrees=@{}
foreach ($name in $productionTrees) { $beforeTrees[$name]=Get-TreeHashes (Join-Path $Root $name) }
$productionSave=Join-Path $env:USERPROFILE "Saved Games\Pokemon Azure"
$beforeSave=if (Test-Path -LiteralPath $productionSave -PathType Container) { Get-TreeHashes $productionSave } else { @{} }
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
    Start-Sleep -Milliseconds 500
  }
  $content=if ($fresh) { [System.IO.File]::ReadAllText($statusPath) } else { "" }
  $valid=($content -match '(?m)^result=PASS\r?$' -and
          $content -match '(?m)^outputs=29\r?$' -and
          $content -match '(?m)^mismatched=0\r?$' -and
          $content -match '(?m)^missing_before=0\r?$' -and
          $content -match '(?m)^missing_after=0\r?$' -and
          $content -match '(?m)^sources=21\r?$' -and
          $content -match '(?m)^sources_unchanged=true\r?$' -and
          $content -match '(?m)^messages_saved=true\r?$' -and
          $content -match '(?m)^production_install=false\r?$')
  $afterTrees=@{}
  foreach ($name in $productionTrees) { $afterTrees[$name]=Get-TreeHashes (Join-Path $Root $name) }
  $productionTreesUnchanged=$true
  foreach ($name in $productionTrees) {
    if (!(Compare-TreeHashes $beforeTrees[$name] $afterTrees[$name])) { $productionTreesUnchanged=$false }
  }
  $afterSave=if (Test-Path -LiteralPath $productionSave -PathType Container) { Get-TreeHashes $productionSave } else { @{} }
  $productionSaveUnchanged=Compare-TreeHashes $beforeSave $afterSave
  $logsUnchanged=($beforePackageLog -eq (Get-FileState $packageLog) -and
                  $beforeIsolatedLog -eq (Get-FileState $isolatedLog))
  [pscustomobject]@{
    ProcessId=$process.Id
    CompileStatusFresh=$fresh
    CompileCompatibility=$valid
    ProcessAlive=!$process.HasExited
    TimeoutSeconds=$TimeoutSeconds
    ProductionTreesChanged=!$productionTreesUnchanged
    ProductionSaveChanged=!$productionSaveUnchanged
    ErrorLogsChanged=!$logsUnchanged
  } | Format-List
  if (!$fresh -or !$valid -or $process.HasExited -or !$productionTreesUnchanged -or !$productionSaveUnchanged -or !$logsUnchanged) { exit 1 }
} finally {
  if ($process -and !$process.HasExited) { Stop-Process -Id $process.Id -Force }
  [System.IO.File]::SetLastWriteTimeUtc($orderPath,$orderTime)
}
exit 0
