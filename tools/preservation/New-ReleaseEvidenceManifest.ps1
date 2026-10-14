[CmdletBinding()]
param(
  [string]$Root,
  [switch]$Verify
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
  $Root = (Resolve-Path $Root).Path
}
$preservationRoot=Join-Path $Root "tools\preservation"
$manifestPath=Join-Path $preservationRoot "release_validation\RELEASE_EVIDENCE.sha256"

function Get-NormalizedTextHash([string]$Path) {
  $inputBytes=[System.IO.File]::ReadAllBytes($Path)
  $normalized=[System.IO.MemoryStream]::new($inputBytes.Length)
  try {
    for ($i=0; $i -lt $inputBytes.Length; $i++) {
      if ($inputBytes[$i] -eq 13 -and $i+1 -lt $inputBytes.Length -and $inputBytes[$i+1] -eq 10) { continue }
      $normalized.WriteByte($inputBytes[$i])
    }
    $sha=[System.Security.Cryptography.SHA256]::Create()
    try { $hash=$sha.ComputeHash($normalized.ToArray()) } finally { $sha.Dispose() }
    return ([BitConverter]::ToString($hash)).Replace('-','')
  } finally {
    $normalized.Dispose()
  }
}

function Get-EvidenceFiles {
  $files=[System.Collections.Generic.List[System.IO.FileInfo]]::new()
  foreach ($path in @(
    (Join-Path $preservationRoot "README.md"),
    (Join-Path $preservationRoot "REJUVENATION_PORT_MATRIX.md")
  )) {
    $files.Add((Get-Item -LiteralPath $path))
  }
  foreach ($pattern in @("*.ps1")) {
    foreach ($file in Get-ChildItem -LiteralPath $preservationRoot -File -Filter $pattern) { $files.Add($file) }
  }
  foreach ($directory in @("runtime_performance","engine_test","release_validation")) {
    $path=Join-Path $preservationRoot $directory
    foreach ($file in Get-ChildItem -LiteralPath $path -File) {
      if ($directory -eq "release_validation" -and $file.Name -eq "RELEASE_EVIDENCE.sha256") { continue }
      if ($file.Extension -in @(".txt",".md",".rb")) { $files.Add($file) }
    }
  }
  return @($files | Sort-Object FullName -Unique)
}

function Get-ManifestRows {
  $rows=[System.Collections.Generic.List[string]]::new()
  foreach ($file in Get-EvidenceFiles) {
    $relative=$file.FullName.Substring($Root.Length).TrimStart('\').Replace('\','/')
    $hash=Get-NormalizedTextHash $file.FullName
    $rows.Add("$hash  $relative")
  }
  return $rows
}

if ($Verify) {
  if (!(Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Release evidence manifest is missing." }
  $expected=@([System.IO.File]::ReadAllLines($manifestPath) | Where-Object { $_.Trim().Length -gt 0 })
  $actual=@(Get-ManifestRows)
  if ($expected.Count -ne $actual.Count) {
    throw "Release evidence manifest entry count changed: expected $($expected.Count), actual $($actual.Count)."
  }
  for ($i=0; $i -lt $expected.Count; $i++) {
    if ($expected[$i] -cne $actual[$i]) {
      throw "Release evidence mismatch at entry $($i+1): '$($expected[$i])' != '$($actual[$i])'."
    }
  }
  Write-Host "Release evidence manifest verified: $($actual.Count) files."
  exit 0
}

$rows=Get-ManifestRows
[System.IO.File]::WriteAllLines($manifestPath,$rows,[System.Text.UTF8Encoding]::new($false))
Write-Host "Release evidence manifest written: $($rows.Count) files."
