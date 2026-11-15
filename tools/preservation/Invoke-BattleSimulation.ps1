#Requires -Version 7.2
[CmdletBinding(DefaultParameterSetName = 'Scenario')]
param(
  [Parameter(Mandatory, ParameterSetName = 'Scenario')]
  [string]$Scenario,
  [Parameter(Mandatory, ParameterSetName = 'MoveRegressions')]
  [switch]$MoveRegressions,
  [Parameter(Mandatory, ParameterSetName = 'CustomMoves')]
  [switch]$CustomMoves,
  [Parameter(Mandatory, ParameterSetName = 'DoubleDose')]
  [switch]$DoubleDose,
  [Parameter(Mandatory, ParameterSetName = 'AIRegressions')]
  [switch]$AIRegressions,
  [Parameter(ParameterSetName = 'AIRegressions')]
  [string]$AIFilter,
  [Parameter(Mandatory, ParameterSetName = 'CatalogAudit')]
  [ValidateSet('all','species','moves','abilities','items','teams','tributes')]
  [string]$CatalogAudit,
  [Parameter(Mandatory, ParameterSetName = 'CompileBattleData')]
  [string]$CompileBattleData,
  [Parameter(ParameterSetName = 'CompileBattleData')]
  [string]$ReferenceBattleData,
  [string]$Report,
  [Parameter(ParameterSetName = 'Scenario')]
  [int]$Seed,
  [ValidateRange(15,600)]
  [int]$TimeoutSeconds = 120
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if (!$IsWindows) { throw "The bundled battle engine requires Windows." }

function Write-ScenarioValue([Text.Json.JsonElement]$Value, [IO.TextWriter]$Writer) {
  switch ($Value.ValueKind) {
    'Object' {
      $properties = @($Value.EnumerateObject())
      $Writer.WriteLine("h $($properties.Count)")
      $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
      foreach ($property in $properties) {
        if (!$seen.Add($property.Name)) { throw "Duplicate scenario key: $($property.Name)" }
        $Writer.WriteLine("s " + [Convert]::ToHexString([Text.Encoding]::UTF8.GetBytes($property.Name)))
        Write-ScenarioValue $property.Value $Writer
      }
    }
    'Array' {
      $Writer.WriteLine("a $($Value.GetArrayLength())")
      foreach ($entry in $Value.EnumerateArray()) { Write-ScenarioValue $entry $Writer }
    }
    'String' { $Writer.WriteLine("s " + [Convert]::ToHexString([Text.Encoding]::UTF8.GetBytes($Value.GetString()))) }
    'Number' {
      $number = [long]0
      if (!$Value.TryGetInt64([ref]$number)) { throw "Scenario numbers must be 64-bit integers: $($Value.GetRawText())" }
      $Writer.WriteLine("i " + $number.ToString([Globalization.CultureInfo]::InvariantCulture))
    }
    'True' { $Writer.WriteLine('t') }
    'False' { $Writer.WriteLine('f') }
    'Null' { $Writer.WriteLine('n') }
    default { throw "Unsupported JSON value: $($Value.ValueKind)" }
  }
}

$scenarioFile = $null
if ($PSCmdlet.ParameterSetName -eq 'Scenario') {
  $scenarioFile = Get-Item -LiteralPath $Scenario
  if ($scenarioFile.PSIsContainer) { throw "Scenario must be a JSON file." }
}
if ($Report) {
  $Report = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Report)
  if ($scenarioFile -and $Report -eq $scenarioFile.FullName) { throw "Scenario and report must be different files." }
  if (Test-Path -LiteralPath $Report -PathType Container) { throw "Report must be a file path." }
  if (!(Test-Path -LiteralPath (Split-Path -Parent $Report) -PathType Container)) {
    throw "Report directory does not exist: $(Split-Path -Parent $Report)"
  }
}

$project = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$fixtures = Join-Path $PSScriptRoot "engine_test"
$launcher = Get-Item -LiteralPath (Join-Path $fixtures "AzureBattleSimulationMod.rb")
. (Join-Path $PSScriptRoot "PrivateBattleDesktop.ps1")
$tempRoot = (Resolve-Path ([IO.Path]::GetTempPath())).Path
$runRoot = (New-Item -ItemType Directory -Path (Join-Path $tempRoot ("azure-battle-" + [guid]::NewGuid().ToString("N")))).FullName
$runtimeReport = Join-Path $runRoot "battle.txt"
$runtimeScenario = Join-Path $runRoot "scenario.txt"
$compiledOutput = if ($CompileBattleData) { $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CompileBattleData) } else { $null }
$assetLinks = @()
$run = $null
$result = $null
$engineExitCode = $null
try {
  if ($scenarioFile) {
    $json = [Text.Json.JsonDocument]::Parse([IO.File]::ReadAllText($scenarioFile.FullName))
    try {
      if ($json.RootElement.ValueKind -ne 'Object') { throw "Scenario must contain a JSON object." }
      $writer = [IO.StreamWriter]::new($runtimeScenario, $false, [Text.UTF8Encoding]::new($false))
      try { Write-ScenarioValue $json.RootElement $writer } finally { $writer.Dispose() }
    } finally {
      $json.Dispose()
    }
  }

  foreach ($dir in @("Data","Scripts")) {
    robocopy (Join-Path $project $dir) (Join-Path $runRoot $dir) /E /XJ /NFL /NDL /NJH /NJS /NP /XF "AzureExternalScripts.cache*" "debuglog.txt" /XD "Mods" | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Failed to copy $dir into the battle fixture." }
  }
  if ($compiledOutput) {
    robocopy (Join-Path $project 'PBS') (Join-Path $runRoot 'PBS') /E /XJ /NFL /NDL /NJS /NJH /NP /XD 'LegacyBackup' | Out-Null
    if ($LASTEXITCODE -ge 8) { throw 'Failed to copy PBS into the battle fixture.' }
  }
  foreach ($dir in @("Graphics","Audio","Fonts")) {
    $link = New-Item -ItemType Junction -Path (Join-Path $runRoot $dir) -Target (Join-Path $project $dir)
    $assetLinks += $link.FullName
  }
  Get-ChildItem -LiteralPath $project -File |
    Where-Object { $_.Extension -eq ".dll" -or $_.Name -in "Game.exe","Game.ini","mkxp.json","intl.dat","version" } |
    Copy-Item -Destination $runRoot
  $modFolder = New-Item -ItemType Directory -Path (Join-Path $runRoot "Data\Mods")
  Copy-Item -LiteralPath $launcher.FullName -Destination $modFolder.FullName

  $profile = Join-Path $runRoot "profile"
  $null = New-Item -ItemType Directory -Path (Join-Path $profile "Saved Games\Pokemon Azure") -Force
  $childEnvironment = @{
    USERPROFILE = $profile
    AZURE_BATTLE_SIMULATION_SOURCE = $fixtures
    AZURE_BATTLE_SIMULATION_SCENARIO = $runtimeScenario
    AZURE_BATTLE_SIMULATION_REPORT = $runtimeReport
    AZURE_BATTLE_SIMULATION_SEED = $null
    AZURE_BATTLE_MOVE_REGRESSIONS = $(if ($MoveRegressions) { '1' })
    AZURE_BATTLE_CUSTOM_MOVES = $(if ($CustomMoves) { '1' })
    AZURE_BATTLE_DOUBLE_DOSE = $(if ($DoubleDose) { '1' })
    AZURE_BATTLE_AI_REGRESSIONS = $(if ($AIRegressions) { '1' })
    AZURE_BATTLE_AI_FILTER = $(if ($AIFilter) { $AIFilter })
    AZURE_BATTLE_CATALOG_AUDIT = $(if ($CatalogAudit) { $CatalogAudit.ToLowerInvariant() })
    AZURE_BATTLE_CATALOG_PBS = $(if ($CatalogAudit) { Join-Path $project 'PBS' })
    AZURE_BATTLE_COMPILE_DATA = $(if ($compiledOutput) { '1' })
    AZURE_BATTLE_REFERENCE_DATA = $(if ($ReferenceBattleData) { (Resolve-Path -LiteralPath $ReferenceBattleData).Path })
  }
  if ($PSBoundParameters.ContainsKey("Seed")) {
    $childEnvironment.AZURE_BATTLE_SIMULATION_SEED = $Seed.ToString([Globalization.CultureInfo]::InvariantCulture)
  }
  $run = Start-AzurePrivateBattleProcess -FilePath (Join-Path $runRoot "Game.exe") -WorkingDirectory $runRoot -Environment $childEnvironment
  $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)

  do {
    if (Test-Path -LiteralPath $runtimeReport -PathType Leaf) {
      $result = Get-Content -LiteralPath $runtimeReport -Encoding UTF8 -Tail 1
      if ($compiledOutput -and $result -match '^result=PASS\b') {
        foreach ($directory in @('Data','Scripts')) {
          $destination = Join-Path $compiledOutput $directory
          $null = New-Item -ItemType Directory -Path $destination -Force
          foreach ($filename in (Get-Content -LiteralPath $runtimeReport | Where-Object { $_ -like "OUTPUT $directory/*" })) {
            Copy-Item -LiteralPath (Join-Path $runRoot $filename.Substring(7)) -Destination $destination
          }
        }
      }
      if ($result -match "^result=(PASS|FAIL)\b") { break }
    }
    if ($run.Process.HasExited) { break }
    Start-Sleep -Milliseconds 100
  } while ([DateTime]::UtcNow -lt $deadline)
  if ($run.Process.HasExited) { $engineExitCode = $run.Process.ExitCode }
} finally {
  try {
    if ($run) { Stop-AzurePrivateBattleProcess -Run $run }
    if (Test-Path -LiteralPath $runtimeReport -PathType Leaf) {
      $result = Get-Content -LiteralPath $runtimeReport -Encoding UTF8 -Tail 1
      if ($Report) {
        Copy-Item -LiteralPath $runtimeReport -Destination $Report
        Write-Output "Report $Report"
      } else {
        Get-Content -LiteralPath $runtimeReport -Encoding UTF8
      }
    }
    if ($result -notmatch "^result=(PASS|FAIL)\b") {
      $logs = @(
        (Join-Path $runRoot "errorlog.txt"),
        (Join-Path $runRoot "profile\Saved Games\Pokemon Azure\errorlog.txt")
      )
      foreach ($log in $logs) {
        if (Test-Path -LiteralPath $log -PathType Leaf) {
          Get-Content -LiteralPath $log -Tail 25 | Write-Warning
        }
      }
    }
  } finally {
    # Remove junctions themselves before removing the private fixture directory.
    foreach ($link in $assetLinks) { [IO.Directory]::Delete($link) }
    $runItem = Get-Item -LiteralPath $runRoot
    if ($runItem.Parent.FullName -eq $tempRoot.TrimEnd('\') -and
        $runItem.Name -match '^azure-battle-[0-9a-f]{32}$') {
      Remove-Item -LiteralPath $runItem.FullName -Recurse -Force
    }
  }
}
if ($result -notmatch "^result=(PASS|FAIL)\b") {
  if ($null -ne $engineExitCode) { throw "Battle engine exited with code $engineExitCode before completing the report." }
  throw "Battle simulation exceeded the $TimeoutSeconds second timeout."
}
if ($result -match "^result=FAIL\b") { exit 1 }
exit 0
