[CmdletBinding()]
param(
  [string]$Filter,
  [string]$Report,
  [ValidateRange(15,600)][int]$TimeoutSeconds = 120
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$project = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ("azure-ability-game-" + [guid]::NewGuid().ToString("N"))
if (!$Report) { $Report = Join-Path $testRoot "abilities.status.txt" }
$Report = [IO.Path]::GetFullPath($Report)
$null = New-Item -ItemType Directory -Path $testRoot
$runReport = Join-Path $testRoot "ability-test-runtime.status.txt"

foreach ($dir in @("Data","Scripts")) {
  robocopy (Join-Path $project $dir) (Join-Path $testRoot $dir) /E /NFL /NDL /NJH /NJS /NP /XF "AzureExternalScripts.cache*" "debuglog.txt" | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "Failed to copy $dir into $testRoot" }
}
foreach ($dir in @("Graphics","Audio","Fonts")) {
  $null = New-Item -ItemType Junction -Path (Join-Path $testRoot $dir) -Target (Join-Path $project $dir)
}
Get-ChildItem -LiteralPath $project -File |
  Where-Object { $_.Extension -in ".exe",".dll",".json",".ini",".dat",".rb" -or $_.Name -eq "version" } |
  Copy-Item -Destination $testRoot
$ini = Join-Path $testRoot "Game.ini"
(Get-Content -LiteralPath $ini -Raw) -replace "(?m)^Title=.*", "Title=Pokemon Azure Ability Test" |
  Set-Content -LiteralPath $ini
$modFolder = Join-Path $testRoot "Data\Mods"
$null = New-Item -ItemType Directory -Path $modFolder -Force
$fixtures = Join-Path $PSScriptRoot "engine_test"
Copy-Item -LiteralPath (Join-Path $fixtures "AzureAbilityTestMod.rb") -Destination (Join-Path $modFolder "000_ability_test.rb")
$env:AZURE_ABILITY_TEST_FILTER = $Filter
$env:AZURE_ABILITY_TEST_REPORT = $runReport
$env:AZURE_ABILITY_TEST_SOURCE = $fixtures
$proc = Start-Process -FilePath (Join-Path $testRoot "Game.exe") -WorkingDirectory $testRoot -WindowStyle Hidden -PassThru
$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
try {
  do {
    $complete = (Test-Path -LiteralPath $runReport) -and
      (Select-String -LiteralPath $runReport -Pattern "^result=" -Quiet)
    if ($complete -or $proc.HasExited) { break }
    Start-Sleep -Milliseconds 250
  } while ([DateTime]::UtcNow -lt $deadline)
  if (!$complete -and !$proc.HasExited) { throw "Game timed out. Partial report: $runReport." }
} finally {
  if (!$proc.HasExited) { Stop-Process -Id $proc.Id -Force }
}
if (!(Test-Path -LiteralPath $runReport)) { throw "Game produced no report. Fixture: $testRoot." }
if ($Report -ne $runReport) { Copy-Item -LiteralPath $runReport -Destination $Report }
Get-Content -LiteralPath $Report
Write-Output "Report $Report"
if (!(Select-String -LiteralPath $Report -Pattern "^result=PASS " -Quiet)) { exit 1 }
exit 0
