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
  $PackageRoot = Join-Path $Root "tools\engine_test\package-ruby31-compatibility"
}
$PackageRoot = (Resolve-Path $PackageRoot).Path
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $Root "tools\engine_test")).TrimEnd('\') + '\'
if (!$PackageRoot.StartsWith($allowedRoot,[System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Release compatibility package must remain inside $allowedRoot."
}

$gamePath=Join-Path $PackageRoot "Game.exe"
$orderPath=Join-Path $PackageRoot "Scripts\!script_order.csv"
$statusPath=Join-Path $PackageRoot "release_compatibility_runtime.status.txt"
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
  return "${exists}:$(if ($exists) { (Get-Item -LiteralPath $Path).Length } else { -1 }):$(if ($exists) { (Get-Item -LiteralPath $Path).LastWriteTimeUtc.Ticks } else { -1 })"
}

$beforeTrees=@{}
foreach ($name in @("Data","PBS","Scripts")) { $beforeTrees[$name]=Get-TreeHashes (Join-Path $Root $name) }
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
    '(?m)^phase=5_step_4_save_and_numeric_compatibility\r?$',
    '(?m)^save_files=117\r?$',
    '(?m)^save_files_passed=117\r?$',
    '(?m)^save_files_failed=0\r?$',
    '(?m)^marshal_objects=1872\r?$',
    '(?m)^pokemon_checked=234\r?$',
    '(?m)^numeric_references_resolved=true\r?$',
    '(?m)^roundtrip_scope=isolated_package_only\r?$',
    '(?m)^roundtrip_class_sequences_exact=true\r?$',
    '(?m)^probe_errors=none\r?$',
    '(?m)^moves_id_count=1079\r?$',
    '(?m)^moves_id_sha256=0698488654ADE273CB354A5474C0D52DA42B0598734C02DA921560297347D0CC\r?$',
    '(?m)^species_id_count=1034\r?$',
    '(?m)^species_id_sha256=BF299CCB7DA6862918DFA9E505062AA42A2DAAACF893488B162059EFBF0C45F2\r?$',
    '(?m)^items_id_count=1114\r?$',
    '(?m)^items_id_sha256=75A18582607BDE884C9BE2C6E8EBCFDCA600A565B9BB500C09FC1FE04914ED7B\r?$',
    '(?m)^abilities_id_count=376\r?$',
    '(?m)^abilities_id_sha256=BCA84D9F2B26D63657A4D74DCA4AF1CB48E773B95D457A420304C3C57D0FA5C8\r?$',
    '(?m)^types_id_count=21\r?$',
    '(?m)^types_id_sha256=1DBED5B28B1DB112973E749FA04C4D56B2DFA0E4D74E9C0BF365E3C31B44DE49\r?$',
    '(?m)^trainer_types_id_count=278\r?$',
    '(?m)^trainer_types_id_sha256=D4FC0484BE9DA081D698EC39336E202ECCB434AB32298EE008EBB3525F30CD7F\r?$'
  )
  $valid=$true
  foreach ($pattern in $required) { if ($content -notmatch $pattern) { $valid=$false } }
  $treesUnchanged=$true
  foreach ($name in @("Data","PBS","Scripts")) {
    if (!(Compare-TreeHashes $beforeTrees[$name] (Get-TreeHashes (Join-Path $Root $name)))) { $treesUnchanged=$false }
  }
  $saveUnchanged=Compare-TreeHashes $beforeSave (Get-TreeHashes $productionSave)
  $logsUnchanged=($beforePackageLog -eq (Get-FileState $packageLog) -and
                  $beforeIsolatedLog -eq (Get-FileState $isolatedLog))
  $alive=!$process.HasExited
  [pscustomobject]@{
    ProcessId=$process.Id
    CompatibilityStatusFresh=$fresh
    SaveAndNumericCompatibility=$valid
    ProcessAlive=$alive
    TimeoutSeconds=$TimeoutSeconds
    ProductionTreesChanged=!$treesUnchanged
    ProductionSaveChanged=!$saveUnchanged
    ErrorLogsChanged=!$logsUnchanged
  } | Format-List
  if ($fresh) { Write-Host $content }
  if (!$fresh -or !$valid -or !$alive -or !$treesUnchanged -or !$saveUnchanged -or !$logsUnchanged) { exit 1 }
} finally {
  if ($process -and !$process.HasExited) { Stop-Process -Id $process.Id -Force }
  [System.IO.File]::SetLastWriteTimeUtc($orderPath,$orderTime)
}
exit 0
