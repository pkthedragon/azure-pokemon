[CmdletBinding()]
param(
  [string]$Root,
  [string]$CandidateRoot = "C:\Users\prana\Downloads\Rejuvenation-14.0-windows",
  [string]$OutputRoot,
  [switch]$ReleaseCompile,
  [switch]$ReleaseSmoke,
  [switch]$ReleaseCompatibility
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
  $Root = (Resolve-Path $Root).Path
}
$CandidateRoot = (Resolve-Path $CandidateRoot).Path
$engineTestRoot = [System.IO.Path]::GetFullPath((Join-Path $Root "tools\engine_test"))
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
  $OutputRoot = Join-Path $engineTestRoot "package-ruby31"
} else {
  $OutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)
}
$requiredPrefix = $engineTestRoot.TrimEnd('\') + '\'
if (!$OutputRoot.StartsWith($requiredPrefix,[System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Engine test output must remain inside $engineTestRoot."
}
if (Test-Path -LiteralPath $OutputRoot) {
  throw "Engine test package already exists: $OutputRoot. Remove it explicitly before rebuilding."
}

$candidateFiles = @(
  "Rejuvenation.exe",
  "x64-msvcrt-ruby310.dll",
  "zlib1.dll",
  "libcrypto-3-x64.dll",
  "libssl-3-x64.dll",
  "discord_game_sdk.dll",
  "cacert.pem"
)
foreach ($name in $candidateFiles) {
  $path = Join-Path $CandidateRoot $name
  if (!(Test-Path -LiteralPath $path -PathType Leaf)) {
    throw "Candidate engine dependency is missing: $path"
  }
}
foreach ($name in @("gems","stdlib")) {
  $path = Join-Path $CandidateRoot $name
  if (!(Test-Path -LiteralPath $path -PathType Container)) {
    throw "Candidate engine runtime directory is missing: $path"
  }
}

New-Item -ItemType Directory -Path $engineTestRoot -Force | Out-Null
New-Item -ItemType Directory -Path $OutputRoot | Out-Null

Copy-Item -LiteralPath (Join-Path $CandidateRoot "Rejuvenation.exe") -Destination (Join-Path $OutputRoot "Game.exe")
foreach ($name in $candidateFiles | Where-Object { $_ -ne "Rejuvenation.exe" }) {
  Copy-Item -LiteralPath (Join-Path $CandidateRoot $name) -Destination (Join-Path $OutputRoot $name)
}
foreach ($name in @("gems","stdlib")) {
  Copy-Item -LiteralPath (Join-Path $CandidateRoot $name) -Destination $OutputRoot -Recurse
}

# Data and authoring inputs are private copies so the candidate can rebuild its
# script archive or compiler outputs without touching production. The two very
# large media trees are read-only junctions for this compatibility phase.
foreach ($name in @("Data","Scripts","PBS","Fonts")) {
  Copy-Item -LiteralPath (Join-Path $Root $name) -Destination $OutputRoot -Recurse
}
foreach ($name in @("Audio","Graphics")) {
  New-Item -ItemType Junction -Path (Join-Path $OutputRoot $name) -Target (Join-Path $Root $name) | Out-Null
}
foreach ($name in @("fields_10_50_data.rb","intl.dat","version")) {
  $path = Join-Path $Root $name
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    Copy-Item -LiteralPath $path -Destination (Join-Path $OutputRoot $name)
  }
}
foreach ($name in @("updater.exe","updater.rb","updater.yaml")) {
  $path = Join-Path $Root $name
  if (!(Test-Path -LiteralPath $path -PathType Leaf)) {
    throw "Production updater component is missing: $path"
  }
  Copy-Item -LiteralPath $path -Destination (Join-Path $OutputRoot $name)
}
$productionSaveRoot = Join-Path $env:USERPROFILE "Saved Games\Pokemon Azure"
$saveFixture = $null
if (Test-Path -LiteralPath $productionSaveRoot -PathType Container) {
  $saveFixture = Get-ChildItem -LiteralPath $productionSaveRoot -File |
    Where-Object { $_.Name -match '^Game(?:_\d+)?\.rxdata$' } |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1
}
if ($saveFixture) {
  $saveFixtureRoot = Join-Path $OutputRoot "save_fixture"
  New-Item -ItemType Directory -Path $saveFixtureRoot | Out-Null
  Copy-Item -LiteralPath $saveFixture.FullName -Destination (Join-Path $saveFixtureRoot "Game.rxdata")
}
$compatibilitySaveCount = 0
if ($ReleaseCompatibility) {
  $compatibilitySaveRoot = Join-Path $OutputRoot "save_compatibility_fixture"
  New-Item -ItemType Directory -Path $compatibilitySaveRoot | Out-Null
  if (Test-Path -LiteralPath $productionSaveRoot -PathType Container) {
    $compatibilitySaves = @(Get-ChildItem -LiteralPath $productionSaveRoot -File |
      Where-Object { $_.Extension -ieq ".rxdata" } |
      Sort-Object Name)
    foreach ($file in $compatibilitySaves) {
      Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $compatibilitySaveRoot $file.Name)
    }
    $compatibilitySaveCount = $compatibilitySaves.Count
  }
  if ($compatibilitySaveCount -eq 0) {
    throw "Release compatibility requires at least one Azure .rxdata save fixture."
  }
}

$gameIni = @"
[Game]
Library=RGSS104E.dll
Scripts=Data\Scripts.rxdata
Title=Pokemon Azure Engine Test
RTP1=
RTP2=
RTP3=
"@
[System.IO.File]::WriteAllText((Join-Path $OutputRoot "Game.ini"),$gameIni,[System.Text.UTF8Encoding]::new($false))

$mkxpConfig = @"
{
  "rgssVersion": 1,
  "enableBlitting": false,
  "pathCache": true,
  "useScriptNames": true,
  "dataPathOrg": "PokemonAzureDevelopment",
  "dataPathApp": "Ruby31EngineTest",
  "bindingNames": {
    "c": "Use",
    "b": "Back",
    "a": "Action",
    "x": "Misc",
    "y": "Autorun",
    "z": "Quicksave,Special",
    "l": "Previous Page",
    "r": "Next Page"
  }
}
"@
[System.IO.File]::WriteAllText((Join-Path $OutputRoot "mkxp.json"),$mkxpConfig,[System.Text.UTF8Encoding]::new($false))

$bootstrapSource = Join-Path $PSScriptRoot "engine_test\AzureEngineTestBootstrap.rb"
$bootstrapDestination = Join-Path $OutputRoot "Scripts\AzureEngineTestBootstrap.rb"
Copy-Item -LiteralPath $bootstrapSource -Destination $bootstrapDestination
$timingSource = Join-Path $PSScriptRoot "engine_test\AzureTimingFixture.rb"
$timingDestination = Join-Path $OutputRoot "Scripts\AzureTimingFixture.rb"
Copy-Item -LiteralPath $timingSource -Destination $timingDestination
$developerToolsSource = Join-Path $PSScriptRoot "engine_test\AzureDeveloperToolsFixture.rb"
$developerToolsDestination = Join-Path $OutputRoot "Scripts\AzureDeveloperToolsFixture.rb"
Copy-Item -LiteralPath $developerToolsSource -Destination $developerToolsDestination
$orderPath = Join-Path $OutputRoot "Scripts\!script_order.csv"
$order = [System.Collections.Generic.List[string]]::new()
$order.AddRange([string[]][System.IO.File]::ReadAllLines($orderPath))
$mainIndex = $order.IndexOf("Main")
if ($mainIndex -lt 0) { throw "Generated script order has no Main entry." }
$order.Insert($mainIndex,"AzureEngineTestBootstrap")
$mainIndex = $order.IndexOf("Main")
$order.Insert($mainIndex,"AzureTimingFixture")
$mainIndex = $order.IndexOf("Main")
$order.Insert($mainIndex,"AzureDeveloperToolsFixture")
if ($ReleaseCompile) {
  $releaseCompileSource = Join-Path $PSScriptRoot "engine_test\AzureReleaseCompileFixture.rb"
  $releaseCompileDestination = Join-Path $OutputRoot "Scripts\AzureReleaseCompileFixture.rb"
  Copy-Item -LiteralPath $releaseCompileSource -Destination $releaseCompileDestination
  $mainIndex = $order.IndexOf("Main")
  $order.Insert($mainIndex,"AzureReleaseCompileFixture")
}
if ($ReleaseSmoke) {
  $releaseSmokeSource = Join-Path $PSScriptRoot "engine_test\AzureReleaseSmokeFixture.rb"
  $releaseSmokeDestination = Join-Path $OutputRoot "Scripts\AzureReleaseSmokeFixture.rb"
  Copy-Item -LiteralPath $releaseSmokeSource -Destination $releaseSmokeDestination
  $mainIndex = $order.IndexOf("Main")
  $order.Insert($mainIndex,"AzureReleaseSmokeFixture")
}
if ($ReleaseCompatibility) {
  $releaseCompatibilitySource = Join-Path $PSScriptRoot "engine_test\AzureReleaseCompatibilityFixture.rb"
  $releaseCompatibilityDestination = Join-Path $OutputRoot "Scripts\AzureReleaseCompatibilityFixture.rb"
  Copy-Item -LiteralPath $releaseCompatibilitySource -Destination $releaseCompatibilityDestination
  $mainIndex = $order.IndexOf("Main")
  $order.Insert($mainIndex,"AzureReleaseCompatibilityFixture")
}
[System.IO.File]::WriteAllLines($orderPath,$order,[System.Text.UTF8Encoding]::new($false))

$engine = Get-Item -LiteralPath (Join-Path $OutputRoot "Game.exe")
$ruby = Get-Item -LiteralPath (Join-Path $OutputRoot "x64-msvcrt-ruby310.dll")
$engineHash = (Get-FileHash -LiteralPath $engine.FullName -Algorithm SHA256).Hash
$rubyHash = (Get-FileHash -LiteralPath $ruby.FullName -Algorithm SHA256).Hash
$manifest = @(
  "result=BUILT",
  "package=$($OutputRoot.Replace('\','/'))",
  "candidate_source=$($CandidateRoot.Replace('\','/'))",
  "engine_product=$($engine.VersionInfo.ProductName)",
  "engine_version=$($engine.VersionInfo.FileVersion)",
  "engine_sha256=$engineHash",
  "ruby_version=$($ruby.VersionInfo.FileVersion)",
  "ruby_sha256=$rubyHash",
  "data_isolation=copied",
  "scripts_isolation=copied_with_test_bootstrap",
  "pbs_isolation=copied",
  "fonts_isolation=copied",
  "audio_assets=read_only_junction",
  "graphics_assets=read_only_junction",
  "save_isolation=package_local_bootstrap",
  "save_fixture=$(if ($saveFixture) { $saveFixture.Name } else { 'absent' })",
  "updater_components=copied_not_launched",
  "release_compile_fixture=$($ReleaseCompile.IsPresent.ToString().ToLowerInvariant())",
  "release_smoke_fixture=$($ReleaseSmoke.IsPresent.ToString().ToLowerInvariant())",
  "release_compatibility_fixture=$($ReleaseCompatibility.IsPresent.ToString().ToLowerInvariant())",
  "compatibility_save_count=$compatibilitySaveCount",
  "production_executable_modified=false",
  "production_configuration_modified=false"
)
[System.IO.File]::WriteAllLines((Join-Path $OutputRoot "engine_package.status.txt"),$manifest,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built isolated engine test package: $OutputRoot"
Write-Host "Candidate: $($engine.VersionInfo.ProductName) $($engine.VersionInfo.FileVersion), Ruby $($ruby.VersionInfo.FileVersion)"
