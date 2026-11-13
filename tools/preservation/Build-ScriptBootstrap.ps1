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

$sourcePath = Join-Path $Root "tools\preservation\AzureExternalScriptBootstrap.rb"
$archivePath = Join-Path $Root "Data\Scripts.rxdata"
$source = [System.IO.File]::ReadAllBytes($sourcePath)

function Write-RubyFixnum {
  param(
    [Parameter(Mandatory)][System.IO.Stream]$Stream,
    [Parameter(Mandatory)][long]$Value
  )
  if ($Value -eq 0) {
    $Stream.WriteByte(0)
    return
  }
  if ($Value -gt 0 -and $Value -lt 123) {
    $Stream.WriteByte([byte]($Value + 5))
    return
  }
  if ($Value -lt 0 -and $Value -gt -124) {
    $Stream.WriteByte([byte](256 + $Value - 5))
    return
  }
  if ($Value -lt 0) { throw "Negative multi-byte Ruby fixnums are not required here." }
  $bytes = [System.Collections.Generic.List[byte]]::new()
  while ($Value -gt 0) {
    $bytes.Add([byte]($Value -band 0xFF))
    $Value = $Value -shr 8
  }
  $Stream.WriteByte([byte]$bytes.Count)
  $Stream.Write($bytes.ToArray(), 0, $bytes.Count)
}

function Write-RubyString {
  param(
    [Parameter(Mandatory)][System.IO.Stream]$Stream,
    [Parameter(Mandatory)][byte[]]$Bytes
  )
  $Stream.WriteByte(0x22)
  Write-RubyFixnum -Stream $Stream -Value $Bytes.Length
  $Stream.Write($Bytes, 0, $Bytes.Length)
}

$compressedStream = [System.IO.MemoryStream]::new()
$zlib = [System.IO.Compression.ZLibStream]::new(
  $compressedStream,
  [System.IO.Compression.CompressionLevel]::Optimal,
  $true
)
try {
  $zlib.Write($source, 0, $source.Length)
} finally {
  $zlib.Dispose()
}
$compressed = $compressedStream.ToArray()
$compressedStream.Dispose()

$archive = [System.IO.MemoryStream]::new()
try {
  $archive.WriteByte(0x04)
  $archive.WriteByte(0x08)
  $archive.WriteByte(0x5B)
  Write-RubyFixnum -Stream $archive -Value 1
  $archive.WriteByte(0x5B)
  Write-RubyFixnum -Stream $archive -Value 3
  # RPG Maker script archives use a randomized 32-bit Bignum identifier. Some
  # mkxp-z builds treat a zero/small Fixnum identifier as an empty section, so
  # retain the original archive's valid identifier encoding.
  $scriptIdentifier = [byte[]](0x6C, 0x2B, 0x07, 0x81, 0x89, 0x03, 0x58)
  $archive.Write($scriptIdentifier, 0, $scriptIdentifier.Length)
  Write-RubyString -Stream $archive -Bytes ([Text.Encoding]::UTF8.GetBytes("Export/Import Scripts"))
  Write-RubyString -Stream $archive -Bytes $compressed
  $generated = $archive.ToArray()
} finally {
  $archive.Dispose()
}

if ($Verify) {
  if (!(Test-Path -LiteralPath $archivePath -PathType Leaf)) {
    throw "Script bootstrap archive is missing: $archivePath"
  }
  $existing = [System.IO.File]::ReadAllBytes($archivePath)
  if (![System.Linq.Enumerable]::SequenceEqual[byte]($existing, $generated)) {
    throw "Data/Scripts.rxdata is stale. Run Build-ScriptBootstrap.ps1."
  }
  Write-Host "Verified Data/Scripts.rxdata against the tracked bootstrap source."
  exit 0
}

[System.IO.File]::WriteAllBytes($archivePath, $generated)
Write-Host "Built Data/Scripts.rxdata from AzureExternalScriptBootstrap.rb ($($generated.Length) bytes)."
