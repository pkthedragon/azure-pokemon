[CmdletBinding()]
param(
  [string]$Root,
  [switch]$WarningsAsErrors
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
  $Root = (Resolve-Path $Root).Path
}

$script:Errors = [System.Collections.Generic.List[string]]::new()
$script:Warnings = [System.Collections.Generic.List[string]]::new()
$script:Checks = [System.Collections.Generic.List[string]]::new()

function Add-AuditError([string]$Message) {
  $script:Errors.Add($Message)
}

function Add-AuditWarning([string]$Message) {
  $script:Warnings.Add($Message)
}

function Add-AuditCheck([string]$Message) {
  $script:Checks.Add($Message)
}

function Resolve-ProjectPath([string]$RelativePath) {
  return Join-Path $Root $RelativePath
}

function Read-SectionedPBS([string]$RelativePath) {
  $path = Resolve-ProjectPath $RelativePath
  $sections = [System.Collections.Generic.List[object]]::new()
  $seen = @{}
  $current = $null
  $lineNumber = 0

  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) { continue }

    if ($line -match '^\[([^\]]+)\]$') {
      $id = $Matches[1].Trim()
      if ($seen.ContainsKey($id)) {
        Add-AuditWarning "$RelativePath has duplicate section [$id] at lines $($seen[$id]) and $lineNumber; the later definition is the effective symbol mapping."
      } else {
        $seen[$id] = $lineNumber
      }
      $current = [pscustomobject]@{
        Id = $id
        Line = $lineNumber
        Fields = @{}
      }
      $sections.Add($current)
      continue
    }

    if ($null -eq $current) { continue }
    if ($line -match '^([^=]+?)\s*=\s*(.*)$') {
      $key = $Matches[1].Trim()
      $value = $Matches[2].Trim()
      if ($current.Fields.ContainsKey($key)) {
        $existing = $current.Fields[$key]
        if ($existing -isnot [System.Collections.IList]) {
          $existing = [System.Collections.Generic.List[string]]@([string]$existing)
          $current.Fields[$key] = $existing
        }
        $existing.Add($value)
      } else {
        $current.Fields[$key] = $value
      }
    }
  }

  return $sections
}

function Read-NumericConstants([string]$RelativePath) {
  $path = Resolve-ProjectPath $RelativePath
  $constants = @{}
  $lineNumber = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    if ($rawLine -match '^\s*([A-Z][A-Z0-9_]*)\s*=\s*(-?\d+)\s*(?:#.*)?$') {
      $name = $Matches[1]
      $value = [int]$Matches[2]
      if ($constants.ContainsKey($name)) {
        Add-AuditWarning "$RelativePath assigns $name more than once; Ruby keeps the last assignment."
      }
      $constants[$name] = $value
    }
  }
  return $constants
}

function Convert-ToInteger([string]$Value, [string]$Context) {
  $number = 0
  if (![int]::TryParse($Value, [ref]$number)) {
    Add-AuditError "$Context has non-numeric legacy ID '$Value'."
    return $null
  }
  return $number
}

function Convert-ToMoveInteger([object]$Value, [string]$Context, [int]$Minimum, [int]$Maximum) {
  $text = ([string]$Value).Trim()
  $number = 0
  try {
    if ($text -match '^0[xX]([0-9A-Fa-f]+)$') {
      $number = [Convert]::ToInt32($Matches[1], 16)
    } elseif ($text -match '^\d+$') {
      $number = [Convert]::ToInt32($text, 10)
    } elseif ($text -match '^[0-9A-Fa-f]+$' -and $text -match '[A-Fa-f]') {
      $number = [Convert]::ToInt32($text, 16)
    } else {
      throw "not an integer"
    }
  } catch {
    Add-AuditError "$Context has invalid decimal/hexadecimal integer '$text'."
    return $null
  }
  if ($number -lt $Minimum -or $number -gt $Maximum) {
    Add-AuditError "$Context is $number; expected $Minimum-$Maximum."
    return $null
  }
  return $number
}

function Test-SectionedConstants(
  [string]$DatasetName,
  [object[]]$Sections,
  [string]$LegacyField,
  [hashtable]$Constants
) {
  $ids = @{}
  $effectiveSections = @{}
  foreach ($section in $Sections) {
    if ($section.Id.Contains(',')) { continue }
    $effectiveSections[$section.Id] = $section
  }
  foreach ($section in $effectiveSections.Values) {
    if (!$section.Fields.ContainsKey($LegacyField)) {
      Add-AuditError "$DatasetName [$($section.Id)] is missing $LegacyField."
      continue
    }
    $id = Convert-ToInteger ([string]$section.Fields[$LegacyField]) "$DatasetName [$($section.Id)]"
    if ($null -eq $id) { continue }
    if ($ids.ContainsKey($id)) {
      Add-AuditWarning "$DatasetName legacy ID $id is shared by [$($ids[$id])] and [$($section.Id)]; preserve this alias until an explicit ID migration exists."
    } else {
      $ids[$id] = $section.Id
    }
    if (!$Constants.ContainsKey($section.Id)) {
      Add-AuditError "$DatasetName [$($section.Id)] is missing from its generated PB constant module."
    } elseif ($Constants[$section.Id] -ne $id) {
      Add-AuditError "$DatasetName [$($section.Id)] has legacy ID $id but its PB constant is $($Constants[$section.Id])."
    }
  }
  Add-AuditCheck "${DatasetName}: $($effectiveSections.Count) effective source symbols agree with generated constants."
}

function Split-PBSList([object]$Value) {
  if ($null -eq $Value) { return @() }
  $values = if ($Value -is [System.Collections.IList]) { $Value } else { @([string]$Value) }
  return @($values | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Read-StrictKeyValuePBS([string]$RelativePath) {
  $path = Resolve-ProjectPath $RelativePath
  $sections = [System.Collections.Generic.List[object]]::new()
  $seenSections = @{}
  $current = $null
  $lineNumber = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) { continue }
    if ($line -match '^\[([^\]]+)\]$') {
      $id = $Matches[1].Trim()
      if ($seenSections.ContainsKey($id)) {
        Add-AuditError "$RelativePath line $lineNumber duplicates section [$id] from line $($seenSections[$id])."
      } else {
        $seenSections[$id] = $lineNumber
      }
      $current = [pscustomobject]@{
        Id = $id
        Line = $lineNumber
        Fields = @{}
        FieldLines = @{}
      }
      $sections.Add($current)
      continue
    }
    if ($null -eq $current) {
      Add-AuditError "$RelativePath line $lineNumber appears before any section."
      continue
    }
    if ($line -notmatch '^([^=]+?)\s*=\s*(.*)$') {
      Add-AuditError "$RelativePath line $lineNumber must use Property = Value syntax."
      continue
    }
    $key = $Matches[1].Trim()
    $value = $Matches[2].Trim()
    if ($current.Fields.ContainsKey($key)) {
      Add-AuditError "$RelativePath line $lineNumber duplicates property '$key' from line $($current.FieldLines[$key])."
    }
    $current.Fields[$key] = $value
    $current.FieldLines[$key] = $lineNumber
  }
  return $sections
}

function Test-UnsignedList([string]$Value, [int]$Count, [string]$Context) {
  $parts = @($Value -split ',' | ForEach-Object { $_.Trim() })
  if ($parts.Count -ne $Count) {
    Add-AuditError "$Context must contain exactly $Count comma-separated integers; found $($parts.Count)."
    return
  }
  foreach ($part in $parts) {
    $number = 0
    if (![int]::TryParse($part, [ref]$number) -or $number -lt 0) {
      Add-AuditError "$Context contains invalid nonnegative integer '$part'."
    }
  }
}

function Test-Reference([string]$Kind, [string]$Owner, [string]$Symbol, [hashtable]$Known) {
  if (!$Known.ContainsKey($Symbol)) {
    Add-AuditError "$Owner references unknown $Kind '$Symbol'."
  }
}

function Read-LegacyItems {
  $relativePath = "PBS\items.txt"
  $path = Resolve-ProjectPath $relativePath
  Add-Type -AssemblyName Microsoft.VisualBasic
  $parser = [Microsoft.VisualBasic.FileIO.TextFieldParser]::new($path)
  $parser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
  $parser.SetDelimiters(",")
  $parser.HasFieldsEnclosedInQuotes = $true
  $items = [System.Collections.Generic.List[object]]::new()
  $recordNumber = 0
  try {
    while (!$parser.EndOfData) {
      $recordNumber++
      $fields = $parser.ReadFields()
      if ($null -eq $fields -or $fields.Count -lt 2) { continue }
      if ($fields[0].Trim().StartsWith("#")) { continue }
      if ($fields.Count -lt 9 -or $fields.Count -gt 10) {
        Add-AuditError "$relativePath record $recordNumber has $($fields.Count) CSV fields; expected 9 or 10."
        continue
      }
      $id = Convert-ToInteger $fields[0].Trim() "$relativePath item '$($fields[1])'"
      if ($null -eq $id) { continue }
      $move = if ($fields.Count -gt 9) { $fields[9].Trim() } else { "" }
      $items.Add([pscustomobject]@{
        Id = $id
        Symbol = $fields[1].Trim()
        Name = $fields[2].Trim()
        Pocket = $fields[3].Trim()
        Price = $fields[4].Trim()
        Description = $fields[5].Trim()
        FieldUse = $fields[6].Trim()
        BattleUse = $fields[7].Trim()
        Type = $fields[8].Trim()
        Move = $move
        Source = "$relativePath record $recordNumber"
      })
    }
  } finally {
    $parser.Close()
  }
  return $items
}

function Read-Items {
  $path = Resolve-ProjectPath "PBS\items.txt"
  $isSectioned = $false
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $line = $rawLine.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) { continue }
    $isSectioned = $line.StartsWith("[")
    break
  }
  if (!$isSectioned) { return @(Read-LegacyItems) }

  $items = [System.Collections.Generic.List[object]]::new()
  $allowed = @("LegacyItemID", "Name", "Pocket", "Price", "Description", "FieldUse", "BattleUse", "Type", "Move")
  $required = @("LegacyItemID", "Name", "Pocket", "Price", "Description", "FieldUse", "BattleUse", "Type")
  foreach ($section in @(Read-SectionedPBS "PBS\items.txt")) {
    foreach ($key in $section.Fields.Keys) {
      if ($key -notin $allowed) { Add-AuditError "Item [$($section.Id)] has unknown property '$key'." }
    }
    foreach ($key in $required) {
      if (!$section.Fields.ContainsKey($key)) { Add-AuditError "Item [$($section.Id)] is missing $key." }
    }
    if (!$section.Fields.ContainsKey("LegacyItemID")) { continue }
    $id = Convert-ToInteger ([string]$section.Fields["LegacyItemID"]) "Item [$($section.Id)]"
    if ($null -eq $id) { continue }
    $move = if ($section.Fields.ContainsKey("Move")) { [string]$section.Fields["Move"] } else { "" }
    $items.Add([pscustomobject]@{
      Id = $id
      Symbol = $section.Id
      Name = [string]$section.Fields["Name"]
      Pocket = [string]$section.Fields["Pocket"]
      Price = [string]$section.Fields["Price"]
      Description = [string]$section.Fields["Description"]
      FieldUse = [string]$section.Fields["FieldUse"]
      BattleUse = [string]$section.Fields["BattleUse"]
      Type = [string]$section.Fields["Type"]
      Move = $move
      Source = "PBS\items.txt section [$($section.Id)]"
    })
  }
  return $items
}

function Test-Items([object[]]$Items, [hashtable]$Constants, [hashtable]$MoveSymbols) {
  $ids = @{}
  $symbols = @{}
  $effectiveItems = @{}
  foreach ($item in $Items) {
    if ($item.Id -lt 1) { Add-AuditError "$($item.Source) has legacy item ID $($item.Id); IDs must be positive." }
    if ($item.Symbol -notmatch '^[A-Z][A-Z0-9_]*$') {
      Add-AuditError "$($item.Source) has invalid item symbol '$($item.Symbol)'."
    }
    if ([string]::IsNullOrWhiteSpace($item.Name)) { Add-AuditError "$($item.Source) is missing its display name." }
    if ([string]::IsNullOrWhiteSpace($item.Description)) { Add-AuditError "$($item.Source) is missing its description." }
    $numericValues = @{}
    foreach ($spec in @(
      @{ Name = "Pocket"; Minimum = 1; Maximum = 8 },
      @{ Name = "Price"; Minimum = 0; Maximum = $null },
      @{ Name = "FieldUse"; Minimum = 0; Maximum = 5 },
      @{ Name = "BattleUse"; Minimum = 0; Maximum = 4 }
    )) {
      $number = 0
      $text = [string]$item.($spec.Name)
      if (![int]::TryParse($text, [ref]$number) -or $number -lt $spec.Minimum -or
          ($null -ne $spec.Maximum -and $number -gt $spec.Maximum)) {
        $range = if ($null -eq $spec.Maximum) { "$($spec.Minimum) or greater" } else { "$($spec.Minimum)-$($spec.Maximum)" }
        Add-AuditError "$($item.Source) has invalid $($spec.Name) '$text'; expected $range."
      } else {
        $numericValues[$spec.Name] = $number
      }
    }
    if (![string]::IsNullOrWhiteSpace([string]$item.Type)) {
      $typeNumber = 0
      if (![int]::TryParse([string]$item.Type, [ref]$typeNumber) -or $typeNumber -lt 0 -or $typeNumber -gt 13) {
        Add-AuditError "$($item.Source) has invalid Type '$($item.Type)'; expected blank or 0-13."
      }
    }
    if ($numericValues.ContainsKey("FieldUse")) {
      $isMachine = $numericValues["FieldUse"] -eq 3 -or $numericValues["FieldUse"] -eq 4
      if ($isMachine -and [string]::IsNullOrWhiteSpace([string]$item.Move)) {
        Add-AuditError "$($item.Source) is a machine but does not define Move."
      } elseif (!$isMachine -and ![string]::IsNullOrWhiteSpace([string]$item.Move)) {
        Add-AuditError "$($item.Source) defines Move '$($item.Move)' but FieldUse is not 3 or 4."
      }
    }
  }
  foreach ($item in $Items) { $effectiveItems[$item.Symbol] = $item }
  foreach ($item in $effectiveItems.Values) {
    if ($ids.ContainsKey($item.Id)) {
      Add-AuditWarning "Items legacy ID $($item.Id) is shared by $($ids[$item.Id]) and $($item.Symbol); preserve this alias until an explicit ID migration exists."
    } else {
      $ids[$item.Id] = $item.Symbol
    }
    $symbols[$item.Symbol] = $item.Id
    if (!$Constants.ContainsKey($item.Symbol)) {
      Add-AuditError "Item $($item.Symbol) is missing from PBItems."
    } elseif ($Constants[$item.Symbol] -ne $item.Id) {
      Add-AuditError "Item $($item.Symbol) has legacy ID $($item.Id) but PBItems uses $($Constants[$item.Symbol])."
    }
    if ($item.Move -and !$MoveSymbols.ContainsKey($item.Move)) {
      Add-AuditError "Item $($item.Symbol) references unknown machine move '$($item.Move)'."
    }
  }
  $duplicates = $Items | Group-Object Symbol | Where-Object Count -gt 1
  foreach ($duplicate in $duplicates) {
    Add-AuditWarning "PBS\items.txt defines $($duplicate.Name) $($duplicate.Count) times; the last numeric mapping is effective."
  }
  Add-AuditCheck "Items: $($Items.Count) source rows satisfy the schema and $($effectiveItems.Count) effective symbols agree with generated constants."
  return $symbols
}

function Test-Types([object[]]$Sections, [hashtable]$Constants) {
  $symbols = @{}
  $ids = @{}
  $allowed = @("Name", "InternalName", "IsPseudoType", "IsSpecialType", "Weaknesses", "Resistances", "Immunities")
  $booleanValues = @("true", "false", "1", "0", "yes", "no")
  $relationships = 0
  foreach ($section in $Sections) {
    foreach ($key in $section.Fields.Keys) {
      if ($key -notin $allowed) { Add-AuditError "Type section [$($section.Id)] has unknown property '$key'." }
      if ($section.Fields[$key] -is [System.Collections.IList]) {
        Add-AuditError "Type section [$($section.Id)] defines property '$key' more than once."
      }
    }
    foreach ($key in @("Name", "InternalName")) {
      if (!$section.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) {
        Add-AuditError "Type section [$($section.Id)] is missing required property '$key'."
      }
    }
    $symbol = if ($section.Fields.ContainsKey("InternalName")) { [string]$section.Fields["InternalName"] } else { "" }
    if ($symbol -and $symbol -notmatch '^[A-Z][A-Z0-9_]*$') {
      Add-AuditError "Type section [$($section.Id)] has invalid InternalName '$symbol'."
    }
    $id = Convert-ToInteger $section.Id "Type [$symbol] ID"
    if ($null -eq $id) { continue }
    if ($id -lt 0 -or $id -gt 255) {
      Add-AuditError "Type [$symbol] has ID $id; expected 0-255."
    }
    if ($ids.ContainsKey($id)) {
      Add-AuditError "Type ID $id is shared by $($ids[$id]) and $symbol."
    } else {
      $ids[$id] = $symbol
    }
    if ($symbols.ContainsKey($symbol)) {
      Add-AuditError "Internal type symbol $symbol is shared by sections [$($symbols[$symbol])] and [$($section.Id)]."
    } elseif ($symbol) {
      $symbols[$symbol] = $id
    }
    if (!$Constants.ContainsKey($symbol)) {
      Add-AuditError "Type $symbol is missing from PBTypes."
    } elseif ($Constants[$symbol] -ne $id) {
      Add-AuditError "Type $symbol has ID $id but PBTypes uses $($Constants[$symbol])."
    }

    foreach ($key in @("IsPseudoType", "IsSpecialType")) {
      if (!$section.Fields.ContainsKey($key)) { continue }
      $value = ([string]$section.Fields[$key]).Trim().ToLowerInvariant()
      if ($value -notin $booleanValues) {
        Add-AuditError "Type section [$($section.Id)] $key '$($section.Fields[$key])' is not a supported Boolean."
      }
    }

    $seenRelations = @{}
    foreach ($key in @("Weaknesses", "Resistances", "Immunities")) {
      if (!$section.Fields.ContainsKey($key)) { continue }
      $raw = [string]$section.Fields[$key]
      if ($raw -match '^\s*,' -or $raw -match ',\s*,' -or $raw -match ',\s*$') {
        Add-AuditError "Type section [$($section.Id)] $key contains an empty entry."
      }
      $withinList = @{}
      foreach ($related in (Split-PBSList $section.Fields[$key])) {
        $relationships++
        if ($related -notmatch '^[A-Z][A-Z0-9_]*$') {
          Add-AuditError "Type section [$($section.Id)] $key contains invalid symbol '$related'."
        }
        if ($withinList.ContainsKey($related)) {
          Add-AuditError "Type section [$($section.Id)] $key repeats $related."
        } else {
          $withinList[$related] = $true
        }
        if ($seenRelations.ContainsKey($related)) {
          Add-AuditError "Type section [$($section.Id)] lists $related in both $($seenRelations[$related]) and $key."
        } else {
          $seenRelations[$related] = $key
        }
      }
    }
  }

  foreach ($section in $Sections) {
    foreach ($key in @("Weaknesses", "Resistances", "Immunities")) {
      if (!$section.Fields.ContainsKey($key)) { continue }
      foreach ($symbol in (Split-PBSList $section.Fields[$key])) {
        Test-Reference "type" "Type section [$($section.Id)] $key" $symbol $symbols
      }
    }
  }
  Add-AuditCheck "Types: $($Sections.Count) source records and $relationships type-chart relationships satisfy the named schema."
  return $symbols
}

function Find-MoveExecutors {
  $executors = @{}
  foreach ($file in Get-ChildItem -LiteralPath (Resolve-ProjectPath "Scripts") -Filter "*.rb" -File) {
    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
      $lineNumber++
      if ($line -match '^\s*class\s+PokeBattle_Move_([0-9A-Fa-f]{3})\b') {
        $code = $Matches[1].ToUpperInvariant()
        if (!$executors.ContainsKey($code)) {
          $executors[$code] = [System.Collections.Generic.List[string]]::new()
        }
        $executors[$code].Add("$($file.Name):$lineNumber")
      }
    }
  }
  return $executors
}

function Test-Moves(
  [object[]]$Moves,
  [hashtable]$MoveConstants,
  [hashtable]$TypeSymbols,
  [hashtable]$Executors
) {
  $moveSymbols = @{}
  foreach ($move in $Moves) { $moveSymbols[$move.Id] = $true }

  $allowed = @(
    "LegacyMoveID", "Name", "Type", "Category", "Power", "Accuracy", "TotalPP",
    "EffectChance", "Priority", "Description", "LegacyFunctionCode", "FunctionCode",
    "LegacyTarget", "Target", "LegacyFlags", "Flags"
  )
  $required = @("LegacyMoveID", "Name", "Type", "Category", "Power", "Accuracy", "TotalPP", "EffectChance", "Priority")
  $ignoredLegacyFlags = 0

  foreach ($move in $Moves) {
    if ($move.Id -notmatch '^[A-Z][A-Z0-9_]*$') {
      Add-AuditError "Move section [$($move.Id)] is not a valid constant symbol."
    }
    foreach ($key in $move.Fields.Keys) {
      if ($key -notin $allowed) { Add-AuditError "Move [$($move.Id)] has unknown property '$key'." }
      if ($move.Fields[$key] -is [System.Collections.IList]) {
        Add-AuditError "Move [$($move.Id)] defines property '$key' more than once."
      }
    }
    foreach ($key in $required) {
      if (!$move.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$move.Fields[$key])) {
        Add-AuditError "Move [$($move.Id)] is missing required property '$key'."
      }
    }

    $functionKeys = @(@("LegacyFunctionCode", "FunctionCode") | Where-Object { $move.Fields.ContainsKey($_) })
    $targetKeys = @(@("LegacyTarget", "Target") | Where-Object { $move.Fields.ContainsKey($_) })
    $flagKeys = @(@("LegacyFlags", "Flags") | Where-Object { $move.Fields.ContainsKey($_) })
    if ($functionKeys.Count -ne 1) {
      Add-AuditError "Move [$($move.Id)] must define exactly one of LegacyFunctionCode or FunctionCode."
    }
    if ($targetKeys.Count -ne 1) {
      Add-AuditError "Move [$($move.Id)] must define exactly one of LegacyTarget or Target."
    }
    if ($flagKeys.Count -gt 1) {
      Add-AuditError "Move [$($move.Id)] must not define both LegacyFlags and Flags."
    }

    if ($move.Fields.ContainsKey("LegacyMoveID")) {
      [void](Convert-ToMoveInteger $move.Fields["LegacyMoveID"] "Move [$($move.Id)] LegacyMoveID" 1 ([int]::MaxValue))
    }
    $power = $null
    foreach ($spec in @(
      @{ Name = "Power"; Minimum = 0; Maximum = 255 },
      @{ Name = "Accuracy"; Minimum = 0; Maximum = 255 },
      @{ Name = "TotalPP"; Minimum = 0; Maximum = 255 },
      @{ Name = "EffectChance"; Minimum = 0; Maximum = 255 },
      @{ Name = "Priority"; Minimum = -128; Maximum = 127 }
    )) {
      if (!$move.Fields.ContainsKey($spec.Name)) { continue }
      $value = Convert-ToInteger ([string]$move.Fields[$spec.Name]) "Move [$($move.Id)] $($spec.Name)"
      if ($null -eq $value) { continue }
      if ($value -lt $spec.Minimum -or $value -gt $spec.Maximum) {
        Add-AuditError "Move [$($move.Id)] $($spec.Name) is $value; expected $($spec.Minimum)-$($spec.Maximum)."
      }
      if ($spec.Name -eq "Power") { $power = $value }
    }

    if ($move.Fields.ContainsKey("Type")) {
      Test-Reference "type" "Move [$($move.Id)]" ([string]$move.Fields["Type"]) $TypeSymbols
    }
    $category = if ($move.Fields.ContainsKey("Category")) { [string]$move.Fields["Category"] } else { "" }
    if ($category -notin @("Physical", "Special", "Status")) {
      Add-AuditError "Move [$($move.Id)] has unknown Category '$category'."
    } elseif ($null -ne $power) {
      if ($category -eq "Status" -and $power -ne 0) {
        Add-AuditError "Move [$($move.Id)] is Status but has nonzero Power $power."
      } elseif ($category -ne "Status" -and $power -eq 0) {
        Add-AuditError "Move [$($move.Id)] is $category but has zero Power; compilation would silently convert it to Status."
      }
    }

    if ($functionKeys.Count -eq 1) {
      $functionKey = $functionKeys[0]
      $function = Convert-ToMoveInteger $move.Fields[$functionKey] "Move [$($move.Id)] $functionKey" 0 65535
      if ($null -ne $function) {
        $executor = "{0:X3}" -f $function
        if (!$Executors.ContainsKey($executor)) {
          Add-AuditError "Move [$($move.Id)] uses function $function (executor $executor), but no PokeBattle_Move_$executor class exists."
        }
      }
    }
    if ($targetKeys.Count -eq 1) {
      $targetKey = $targetKeys[0]
      [void](Convert-ToMoveInteger $move.Fields[$targetKey] "Move [$($move.Id)] $targetKey" 0 65535)
    }
    if ($flagKeys.Count -eq 1) {
      $flagKey = $flagKeys[0]
      $flags = [string]$move.Fields[$flagKey]
      if ($flags -notmatch '^[a-ps]*$') {
        Add-AuditError "Move [$($move.Id)] $flagKey '$flags' contains unsupported flags; expected a-p."
      }
      $duplicates = @($flags.ToCharArray() | Group-Object | Where-Object { $_.Count -gt 1 })
      if ($duplicates.Count -gt 0) {
        Add-AuditError "Move [$($move.Id)] $flagKey '$flags' repeats one or more flags."
      }
      if ($flags.Contains('s')) {
        if ($move.Id -ne "DOUBLEKICK") {
          Add-AuditError "Move [$($move.Id)] uses ignored legacy flag s; only DOUBLEKICK's preserved source token is grandfathered."
        } else {
          $ignoredLegacyFlags++
        }
      }
    }
  }
  if ($ignoredLegacyFlags -ne 1) {
    Add-AuditError "Move data must preserve exactly one documented ignored legacy flag token (DOUBLEKICK s); found $ignoredLegacyFlags."
  }
  Add-AuditCheck "Moves: $($Moves.Count) source rows satisfy the named schema, numeric semantics, flag policy, type references, and executor coverage."
  return $moveSymbols
}

function Test-PokemonSchemas([object[]]$Pokemon) {
  $allowed = @(
    "LegacySpeciesID", "Name", "Types", "BaseStats", "GenderRatio", "GrowthRate", "BaseExp",
    "EVs", "CatchRate", "Happiness", "Abilities", "HiddenAbilities", "Moves", "EggMoves",
    "EggGroups", "HatchSteps", "Height", "Weight", "Color", "Habitat", "Category", "Pokedex",
    "Evolutions", "WildItemCommon", "WildItemUncommon", "WildItemRare", "LegacyRegionalNumbers",
    "LegacyFormNames", "LegacyFormName", "Legacytoobig"
  )
  $required = @(
    "LegacySpeciesID", "Name", "Types", "BaseStats", "GenderRatio", "GrowthRate", "BaseExp",
    "EVs", "CatchRate", "Happiness", "Abilities", "Moves", "EggGroups", "HatchSteps",
    "Height", "Weight", "Color", "Category", "Pokedex"
  )
  $genderRatios = @("AlwaysMale", "FemaleOneEighth", "Female25Percent", "Female50Percent", "Female75Percent", "FemaleSevenEighths", "AlwaysFemale", "Genderless")
  $growthRates = @("Medium", "MediumFast", "Erratic", "Fluctuating", "Parabolic", "MediumSlow", "Fast", "Slow")
  $colors = @("Red", "Blue", "Yellow", "Green", "Black", "Brown", "Purple", "Gray", "White", "Pink")
  $habitats = @("Grassland", "Forest", "WatersEdge", "Sea", "Cave", "Mountain", "RoughTerrain", "Urban", "Rare")
  $eggGroups = @("Monster", "Water1", "Bug", "Flying", "Field", "Ground", "Fairy", "Grass", "Plant", "Human-like", "Human-Like", "Humanlike", "HumanLike", "Humanoid", "Humanshape", "Human", "Water3", "Mineral", "Amorphous", "Indeterminate", "Water2", "Ditto", "Dragon", "Undiscovered", "No eggs", "NoEggs", "None", "NA")
  $evStats = @("HP", "ATTACK", "ATK", "DEFENSE", "DEF", "SPEED", "SPD", "SPECIAL_ATTACK", "SPATK", "SP_ATTACK", "SPECIAL_DEFENSE", "SPDEF", "SP_DEFENSE")
  $speciesCounts = @{}

  foreach ($section in $Pokemon) {
    $legacyNidoran = $section.Id -cin @("NIDORANfE", "NIDORANmA")
    if (!$legacyNidoran -and $section.Id -cnotmatch '^[A-Z][A-Z0-9_]*$') {
      Add-AuditError "Pokémon section [$($section.Id)] is not a valid constant symbol."
    }
    $speciesCounts[$section.Id] = ($speciesCounts[$section.Id] + 1)
    foreach ($key in $section.Fields.Keys) {
      if ($key -cnotin $allowed) { Add-AuditError "Pokémon [$($section.Id)] has unknown property '$key'." }
      if ($section.Fields[$key] -is [System.Collections.IList]) {
        Add-AuditError "Pokémon [$($section.Id)] defines property '$key' more than once."
      }
    }
    foreach ($key in $required) {
      if (!$section.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) {
        Add-AuditError "Pokémon [$($section.Id)] is missing required property '$key'."
      }
    }
    if ($section.Fields.ContainsKey("LegacySpeciesID")) {
      [void](Convert-ToMoveInteger $section.Fields["LegacySpeciesID"] "Pokémon [$($section.Id)] LegacySpeciesID" 1 65535)
    }

    foreach ($spec in @(
      @{ Name = "Types"; Minimum = 1; Maximum = 2 },
      @{ Name = "Abilities"; Minimum = 1; Maximum = 2 },
      @{ Name = "HiddenAbilities"; Minimum = 0; Maximum = 1 },
      @{ Name = "BaseStats"; Minimum = 6; Maximum = 6 },
      @{ Name = "EggGroups"; Minimum = 1; Maximum = 2 }
    )) {
      if (!$section.Fields.ContainsKey($spec.Name)) { continue }
      $values = @(([string]$section.Fields[$spec.Name] -split ',') | ForEach-Object { $_.Trim().Trim('"') } | Where-Object { $_ })
      if ($values.Count -lt $spec.Minimum -or $values.Count -gt $spec.Maximum) {
        Add-AuditError "Pokémon [$($section.Id)] $($spec.Name) has $($values.Count) entries; expected $($spec.Minimum)-$($spec.Maximum)."
      }
      if ($spec.Name -eq "BaseStats") {
        foreach ($value in $values) {
          $number = 0
          if (![int]::TryParse($value, [ref]$number) -or $number -lt 1 -or $number -gt 255) {
            Add-AuditError "Pokémon [$($section.Id)] BaseStats contains '$value'; expected integers from 1-255."
          }
        }
      } elseif ($spec.Name -eq "EggGroups") {
        foreach ($value in $values) {
          if ($value -notin $eggGroups -and $value -notmatch '^\d+$') {
            Add-AuditError "Pokémon [$($section.Id)] has unknown egg group '$value'."
          }
        }
      } else {
        foreach ($value in $values) {
          if ($value -notmatch '^[A-Z][A-Z0-9_]*$') {
            Add-AuditError "Pokémon [$($section.Id)] $($spec.Name) contains invalid symbol '$value'."
          }
        }
      }
    }

    foreach ($enumSpec in @(
      @{ Name = "GenderRatio"; Values = $genderRatios },
      @{ Name = "GrowthRate"; Values = $growthRates },
      @{ Name = "Color"; Values = $colors },
      @{ Name = "Habitat"; Values = $habitats }
    )) {
      if (!$section.Fields.ContainsKey($enumSpec.Name)) { continue }
      $value = [string]$section.Fields[$enumSpec.Name]
      if ($value -notin $enumSpec.Values) {
        Add-AuditError "Pokémon [$($section.Id)] has unknown $($enumSpec.Name) '$value'."
      }
    }

    foreach ($numericSpec in @(
      @{ Name = "BaseExp"; Minimum = 0; Maximum = 65535 },
      @{ Name = "CatchRate"; Minimum = 0; Maximum = 255 },
      @{ Name = "Happiness"; Minimum = 0; Maximum = 255 },
      @{ Name = "HatchSteps"; Minimum = 1; Maximum = 65535 }
    )) {
      if (!$section.Fields.ContainsKey($numericSpec.Name)) { continue }
      $number = Convert-ToInteger ([string]$section.Fields[$numericSpec.Name]) "Pokémon [$($section.Id)] $($numericSpec.Name)"
      if ($null -ne $number -and ($number -lt $numericSpec.Minimum -or $number -gt $numericSpec.Maximum)) {
        Add-AuditError "Pokémon [$($section.Id)] $($numericSpec.Name) is $number; expected $($numericSpec.Minimum)-$($numericSpec.Maximum)."
      }
    }
    foreach ($key in @("Height", "Weight")) {
      if (!$section.Fields.ContainsKey($key)) { continue }
      $number = 0.0
      if (![double]::TryParse([string]$section.Fields[$key], [ref]$number) -or $number -lt 0.05) {
        Add-AuditError "Pokémon [$($section.Id)] $key '$($section.Fields[$key])' must round to a positive tenths value."
      }
    }

    if ($section.Fields.ContainsKey("Moves")) {
      $values = @(([string]$section.Fields["Moves"] -split ',') | ForEach-Object { $_.Trim() })
      if ($values.Count -eq 0 -or $values.Count % 2 -ne 0 -or $values[-1] -eq "") {
        Add-AuditError "Pokémon [$($section.Id)] Moves must contain complete level/move pairs without empty entries."
      } else {
        for ($i = 0; $i -lt $values.Count; $i += 2) {
          $level = 0
          if (![int]::TryParse($values[$i], [ref]$level) -or $level -lt 0 -or $level -gt 100) {
            Add-AuditError "Pokémon [$($section.Id)] has invalid move level '$($values[$i])'."
          }
          if ($values[$i + 1] -notmatch '^[A-Z][A-Z0-9_]*$') {
            Add-AuditError "Pokémon [$($section.Id)] has invalid move symbol '$($values[$i + 1])'."
          }
        }
      }
    }
    if ($section.Fields.ContainsKey("Evolutions")) {
      $values = @(([string]$section.Fields["Evolutions"] -split ',') | ForEach-Object { $_.Trim() })
      if ($values.Count % 3 -ne 0 -or $values[-1] -eq "") {
        Add-AuditError "Pokémon [$($section.Id)] Evolutions must contain complete species/method/parameter triples."
      }
    }
    if ($section.Fields.ContainsKey("EVs")) {
      $values = @(([string]$section.Fields["EVs"] -split ',') | ForEach-Object { $_.Trim() })
      if ($values.Count -eq 0 -or $values.Count % 2 -ne 0) {
        Add-AuditError "Pokémon [$($section.Id)] EVs must contain stat/amount pairs."
      } else {
        $seenStats = @{}
        for ($i = 0; $i -lt $values.Count; $i += 2) {
          $stat = $values[$i].ToUpperInvariant()
          if ($stat -notin $evStats) { Add-AuditError "Pokémon [$($section.Id)] has unknown EV stat '$stat'." }
          $amount = 0
          if (![int]::TryParse($values[$i + 1], [ref]$amount) -or $amount -lt 0 -or $amount -gt 255) {
            Add-AuditError "Pokémon [$($section.Id)] has invalid EV yield '$($values[$i + 1])'."
          }
          if ($seenStats.ContainsKey($stat)) { Add-AuditError "Pokémon [$($section.Id)] repeats EV stat '$stat'." }
          $seenStats[$stat] = $true
        }
      }
    }
  }

  $metrics = @(Read-SectionedPBS "PBS\pokemon_metrics.txt")
  $metricAllowed = @("LegacyBattlerPlayerY", "BattlerPlayerY", "LegacyBattlerEnemyY", "BattlerEnemyY", "LegacyBattlerAltitude", "BattlerAltitude")
  $metricCounts = @{}
  foreach ($section in $metrics) {
    if ($section.Id -notmatch '^[A-Z][A-Z0-9_]*$') { Add-AuditError "Pokémon metrics section [$($section.Id)] is not a valid symbol." }
    if (!$speciesCounts.ContainsKey($section.Id)) { Add-AuditError "Pokémon metrics section [$($section.Id)] has no species section." }
    $metricCounts[$section.Id] = ($metricCounts[$section.Id] + 1)
    foreach ($key in $section.Fields.Keys) {
      if ($key -notin $metricAllowed) { Add-AuditError "Pokémon metrics [$($section.Id)] has unknown property '$key'." }
      if ($section.Fields[$key] -is [System.Collections.IList]) { Add-AuditError "Pokémon metrics [$($section.Id)] repeats property '$key'." }
      if ([string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) { continue }
      $number = Convert-ToInteger ([string]$section.Fields[$key]) "Pokémon metrics [$($section.Id)] $key"
      if ($null -ne $number -and ($number -lt -32768 -or $number -gt 32767)) {
        Add-AuditError "Pokémon metrics [$($section.Id)] $key is outside -32768..32767."
      }
    }
  }
  foreach ($symbol in $speciesCounts.Keys) {
    if ($metricCounts[$symbol] -ne $speciesCounts[$symbol]) {
      Add-AuditError "Pokémon metrics has $($metricCounts[$symbol]) section(s) for $symbol; expected $($speciesCounts[$symbol])."
    }
  }

  $regionalPath = Resolve-ProjectPath "PBS\regional_dexes.txt"
  $seenRegions = @{}
  $regionSpecies = @{}
  $currentRegion = $null
  $regionalEntries = 0
  $lineNumber = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($regionalPath)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if (!$line -or $line.StartsWith("#")) { continue }
    if ($line -match '^\[(\d+)\]$') {
      $currentRegion = [int]$Matches[1]
      if ($seenRegions.ContainsKey($currentRegion)) { Add-AuditError "regional_dexes.txt duplicates region [$currentRegion]." }
      $seenRegions[$currentRegion] = $true
      $regionSpecies[$currentRegion] = @{}
      continue
    }
    if ($null -eq $currentRegion) {
      Add-AuditError "regional_dexes.txt line $lineNumber appears before a region header."
      continue
    }
    foreach ($symbol in @($line -split ',' | ForEach-Object { $_.Trim() })) {
      if (!$symbol) { Add-AuditError "regional_dexes.txt line $lineNumber contains an empty species entry."; continue }
      $regionalEntries++
      if (!$speciesCounts.ContainsKey($symbol)) { Add-AuditError "regional_dexes.txt line $lineNumber references unknown species '$symbol'." }
      if ($regionSpecies[$currentRegion].ContainsKey($symbol)) { Add-AuditError "Regional dex [$currentRegion] repeats species $symbol." }
      $regionSpecies[$currentRegion][$symbol] = $true
    }
  }
  Add-AuditCheck "Pokémon schema: $($Pokemon.Count) species rows, $($metrics.Count) metric rows, and $regionalEntries regional entries are structurally valid."
}

function Test-PokemonReferences(
  [object[]]$Pokemon,
  [hashtable]$SpeciesSymbols,
  [hashtable]$MoveSymbols,
  [hashtable]$AbilitySymbols,
  [hashtable]$TypeSymbols
) {
  foreach ($mon in $Pokemon) {
    foreach ($type in (Split-PBSList $mon.Fields["Types"])) {
      Test-Reference "type" "Pokémon [$($mon.Id)]" $type $TypeSymbols
    }
    foreach ($ability in (Split-PBSList $mon.Fields["Abilities"])) {
      Test-Reference "ability" "Pokémon [$($mon.Id)]" $ability $AbilitySymbols
    }
    foreach ($ability in (Split-PBSList $mon.Fields["HiddenAbilities"])) {
      Test-Reference "ability" "Pokémon [$($mon.Id)]" $ability $AbilitySymbols
    }
    foreach ($field in @("Moves", "EggMoves")) {
      if (!$mon.Fields.ContainsKey($field)) { continue }
      $values = Split-PBSList $mon.Fields[$field]
      if ($field -eq "Moves") {
        for ($i = 1; $i -lt $values.Count; $i += 2) {
          Test-Reference "move" "Pokémon [$($mon.Id)] $field" $values[$i] $MoveSymbols
        }
      } else {
        foreach ($move in $values) {
          Test-Reference "move" "Pokémon [$($mon.Id)] $field" $move $MoveSymbols
        }
      }
    }
    if ($mon.Fields.ContainsKey("Evolutions")) {
      $values = Split-PBSList $mon.Fields["Evolutions"]
      for ($i = 0; $i -lt $values.Count; $i += 3) {
        if ($i -lt $values.Count) {
          Test-Reference "species" "Pokémon [$($mon.Id)] Evolutions" $values[$i] $SpeciesSymbols
        }
      }
    }
  }
  Add-AuditCheck "Pokémon: type, ability, move, and evolution references are valid."
}

function Test-AbilityScriptReferences([hashtable]$AbilityConstants) {
  $expectedAliases = @{
    "SPIRITED" = 72
    "SNOWVEIL" = 81
    "MAJESTY" = 213
  }
  foreach ($entry in $expectedAliases.GetEnumerator()) {
    if (!$AbilityConstants.ContainsKey($entry.Key)) {
      Add-AuditError "Legacy ability alias $($entry.Key) is missing from Scripts\PBAbilities.rb."
    } elseif ($AbilityConstants[$entry.Key] -ne $entry.Value) {
      Add-AuditError "Legacy ability alias $($entry.Key) maps to $($AbilityConstants[$entry.Key]); expected $($entry.Value)."
    }
  }

  $references = [System.Collections.Generic.HashSet[string]]::new()
  $scriptsPath = Resolve-ProjectPath "Scripts"
  foreach ($file in Get-ChildItem -LiteralPath $scriptsPath -Filter "*.rb" -File) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $content = [regex]::Replace($content, '(?m)^\s*#.*$', '')
    foreach ($match in [regex]::Matches($content, 'PBAbilities::([A-Za-z][A-Za-z0-9_]*)')) {
      [void]$references.Add($match.Groups[1].Value)
    }
    foreach ($match in [regex]::Matches($content, 'PBAbilities\s*,\s*:([A-Za-z][A-Za-z0-9_]*)')) {
      [void]$references.Add($match.Groups[1].Value)
    }
  }
  $unresolved = 0
  foreach ($symbol in $references) {
    if (!$AbilityConstants.ContainsKey($symbol)) {
      $unresolved++
      Add-AuditWarning "Ruby scripts contain a pre-existing unresolved PBAbilities symbol '$symbol'; the related optional form remains unavailable until its intended ability data and behavior are authored."
    }
  }
  $resolved = $references.Count - $unresolved
  Add-AuditCheck "Ability scripts: $resolved of $($references.Count) active module-qualified references and 3 compatibility aliases resolve to generated constants."
}

function Test-TypeScriptReferences([hashtable]$TypeConstants) {
  $references = [System.Collections.Generic.HashSet[string]]::new()
  $scriptsPath = Resolve-ProjectPath "Scripts"
  foreach ($file in Get-ChildItem -LiteralPath $scriptsPath -Filter "*.rb" -File) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $content = [regex]::Replace($content, '(?m)^\s*#.*$', '')
    foreach ($match in [regex]::Matches($content, 'PBTypes::([A-Za-z][A-Za-z0-9_]*)')) {
      [void]$references.Add($match.Groups[1].Value)
    }
    foreach ($match in [regex]::Matches($content, 'PBTypes\s*,\s*:([A-Za-z][A-Za-z0-9_]*)')) {
      [void]$references.Add($match.Groups[1].Value)
    }
  }
  foreach ($symbol in $references) {
    if (!$TypeConstants.ContainsKey($symbol)) {
      Add-AuditError "Ruby scripts reference unknown PBTypes symbol '$symbol'."
    }
  }
  Add-AuditCheck "Type scripts: all $($references.Count) active module-qualified symbols resolve to generated constants."
}

function Test-TrainerReferences(
  [hashtable]$SpeciesSymbols,
  [hashtable]$MoveSymbols,
  [hashtable]$ItemSymbols
) {
  $path = Resolve-ProjectPath "PBS\trainers.txt"
  $lineNumber = 0
  $trainerKeys = @{}
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if ($line -match '^\[([^\]]+)\]$') {
      $key = $Matches[1].Trim().ToUpperInvariant()
      if ($trainerKeys.ContainsKey($key)) {
        Add-AuditError "PBS\trainers.txt has duplicate trainer [$key] at lines $($trainerKeys[$key]) and $lineNumber."
      } else {
        $trainerKeys[$key] = $lineNumber
      }
    } elseif ($line -match '^Pokemon\s*=\s*([^,\s]+)') {
      Test-Reference "species" "PBS\trainers.txt:$lineNumber" $Matches[1] $SpeciesSymbols
    } elseif ($line -match '^Item\s*=\s*([^,\s]+)') {
      Test-Reference "item" "PBS\trainers.txt:$lineNumber" $Matches[1] $ItemSymbols
    } elseif ($line -match '^Moves\s*=\s*(.+)$') {
      foreach ($move in ($Matches[1] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
        Test-Reference "move" "PBS\trainers.txt:$lineNumber" $move $MoveSymbols
      }
    }
  }
  Add-AuditCheck "Trainers: unique team keys and species, item, and move references are valid."
}

function Test-TMReferences(
  [hashtable]$SpeciesSymbols,
  [hashtable]$MoveSymbols,
  [hashtable]$SpeciesConstants,
  [hashtable]$MoveConstants
) {
  $path = Resolve-ProjectPath "PBS\tm.txt"
  $currentMove = $null
  $currentMoveID = $null
  $lineNumber = 0
  $sectionCount = 0
  $rawEntryCount = 0
  $duplicateEntryCount = 0
  $moveOwners = @{}
  $compatibility = @{}
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) { continue }
    if ($line -match '^\[([^\]]+)\]$') {
      $currentMove = $Matches[1].Trim()
      $currentMoveID = $null
      $sectionCount++
      if ($currentMove -notmatch '^[A-Z][A-Z0-9_]*$') {
        Add-AuditError "PBS\tm.txt:$lineNumber has invalid move section symbol '$currentMove'."
      }
      Test-Reference "move" "PBS\tm.txt:$lineNumber" $currentMove $MoveSymbols
      if ($MoveConstants.ContainsKey($currentMove)) {
        $currentMoveID = [int]$MoveConstants[$currentMove]
        if ($moveOwners.ContainsKey($currentMoveID) -and $moveOwners[$currentMoveID] -cne $currentMove) {
          Add-AuditError "PBS\tm.txt move sections [$($moveOwners[$currentMoveID])] and [$currentMove] resolve to numeric ID $currentMoveID."
        } else {
          $moveOwners[$currentMoveID] = $currentMove
        }
        if (!$compatibility.ContainsKey($currentMoveID)) {
          $compatibility[$currentMoveID] = [System.Collections.Generic.HashSet[int]]::new()
        }
      }
      continue
    }
    if ($line.StartsWith("[") -or $line.EndsWith("]")) {
      Add-AuditError "PBS\tm.txt:$lineNumber has malformed section syntax '$line'."
      $currentMove = $null
      $currentMoveID = $null
      continue
    }
    if ($null -eq $currentMove) {
      Add-AuditError "PBS\tm.txt:$lineNumber defines compatibility before a [MOVE] section."
      continue
    }
    foreach ($entry in $rawLine.Split([char]',')) {
      $rawEntryCount++
      $species = $entry.Trim()
      if ($species.Length -eq 0) {
        Add-AuditError "PBS\tm.txt:$lineNumber [$currentMove] contains an empty species entry."
        continue
      }
      if ($species -cnotmatch '^[A-Z][A-Z0-9_]*$' -and $species -cne 'NIDORANfE' -and $species -cne 'NIDORANmA') {
        Add-AuditError "PBS\tm.txt:$lineNumber [$currentMove] has invalid species symbol '$species'."
      }
      Test-Reference "species" "PBS\tm.txt:$lineNumber [$currentMove]" $species $SpeciesSymbols
      if ($null -ne $currentMoveID -and $SpeciesConstants.ContainsKey($species)) {
        $speciesID = [int]$SpeciesConstants[$species]
        if (!$compatibility[$currentMoveID].Add($speciesID)) { $duplicateEntryCount++ }
      }
    }
  }

  $canonical = [System.Collections.Generic.List[string]]::new()
  $moveIDs = [int[]]$compatibility.Keys
  [Array]::Sort($moveIDs)
  $effectivePairCount = 0
  foreach ($moveID in $moveIDs) {
    $speciesIDs = [int[]]$compatibility[$moveID]
    [Array]::Sort($speciesIDs)
    $effectivePairCount += $speciesIDs.Count
    $canonical.Add($moveID.ToString() + "=" + ($speciesIDs -join ','))
  }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($canonical -join "`n"))
    $hashBytes = $sha.ComputeHash($bytes)
    $compatibilityHash = ($hashBytes | ForEach-Object { $_.ToString('x2') }) -join ''
  } finally {
    $sha.Dispose()
  }
  $expectedHash = "1546f0b75d61fdb0a9bbb0916b0d3395d843620adfffa04333b083a2968c6a45"
  if ($compatibilityHash -cne $expectedHash) {
    Add-AuditError "PBS\tm.txt effective numeric compatibility map changed (SHA-256 $compatibilityHash; expected $expectedHash)."
  }
  Add-AuditCheck "TM compatibility: $sectionCount source sections merge into $($compatibility.Count) numeric moves and $effectivePairCount unique pairs; $duplicateEntryCount redundant entries are deduplicated and the preservation hash matches."
}

function Test-LegacyDuplicatePolicy(
  [object[]]$Moves,
  [object[]]$Pokemon,
  [object[]]$Abilities,
  [object[]]$TrainerTypes,
  [object[]]$Items
) {
  $records = [System.Collections.Generic.List[object]]::new()
  $sectionedDatasets = @(
    @{ Name = "Moves"; Sections = $Moves; LegacyField = "LegacyMoveID" },
    @{ Name = "Pokemon"; Sections = $Pokemon; LegacyField = "LegacySpeciesID" },
    @{ Name = "Abilities"; Sections = $Abilities; LegacyField = "LegacyAbilityID" },
    @{ Name = "TrainerTypes"; Sections = $TrainerTypes; LegacyField = "LegacyTrainerTypeID" }
  )
  foreach ($dataset in $sectionedDatasets) {
    foreach ($section in $dataset.Sections) {
      if (!$section.Fields.ContainsKey($dataset.LegacyField)) { continue }
      $id = Convert-ToInteger ([string]$section.Fields[$dataset.LegacyField]) "$($dataset.Name) [$($section.Id)]"
      $records.Add([pscustomobject]@{
        Dataset = $dataset.Name
        Symbol = [string]$section.Id
        Id = $id
        SymbolKey = "$($dataset.Name)|$($section.Id)"
        IdKey = "$($dataset.Name)|$id"
      })
    }
  }
  foreach ($item in $Items) {
    $records.Add([pscustomobject]@{
      Dataset = "Items"
      Symbol = [string]$item.Symbol
      Id = [int]$item.Id
      SymbolKey = "Items|$($item.Symbol)"
      IdKey = "Items|$($item.Id)"
    })
  }

  # These are compatibility aliases already embedded in Azure events, saves,
  # and generated constants. Any membership change must be reviewed explicitly.
  $allowedSymbols = @{
    "Moves|ORIGINPULSE" = "661,671"
    "Moves|PRECIPICEBLADES" = "662,672"
    "Moves|DRAGONASCENT" = "663,673"
    "Moves|THOUSANDARROWS" = "664,674"
    "Moves|THOUSANDWAVES" = "665,675"
    "Moves|DIAMONDSTORM" = "666,676"
    "Moves|STEAMERUPTION" = "668,678"
    "Moves|DISHEARTEN" = "1033,1049"
    "Moves|EPHEMERATE" = "1034,1050"
    "Moves|ANTICLINE" = "1035,1051"
    "Pokemon|IRONMOTH" = "994,994"
    "Abilities|TOXICCHAIN" = "371,396"
    "Abilities|CARETAKER" = "326,404"
    "Abilities|BLOODTHIRSTY" = "332,405"
    "Abilities|SCAVENGER" = "336,406"
    "Abilities|EXECUTIONER" = "342,407"
    "Abilities|EVENTHORIZON" = "346,408"
    "TrainerTypes|SCHOOLKID_F" = "14,15"
    "TrainerTypes|HADIEN" = "187,221"
    "Items|GREENKEY" = "606,625"
    "Items|TM115" = "885,1050"
    "Items|TM116" = "886,1051"
  }
  $allowedIds = @{
    "Moves|318" = "BONECLUB,SPIKECANNON"
    "Moves|680" = "DIMPULSE,DIMZAP"
    "Pokemon|306" = "AGGRON,DEOXYS"
    "Pokemon|994" = "IRONMOTH,IRONMOTH"
  }

  $seenSymbols = @{}
  foreach ($group in @($records | Group-Object SymbolKey | Where-Object Count -gt 1)) {
    $signature = (($group.Group | ForEach-Object { [int]$_.Id } | Sort-Object) -join ",")
    if (!$allowedSymbols.ContainsKey($group.Name) -or $allowedSymbols[$group.Name] -ne $signature) {
      Add-AuditError "Undocumented duplicate symbol $($group.Name) has IDs $signature."
    } else {
      $seenSymbols[$group.Name] = $true
    }
  }
  foreach ($key in $allowedSymbols.Keys) {
    if (!$seenSymbols.ContainsKey($key)) {
      Add-AuditError "Documented duplicate symbol $key no longer has the expected IDs $($allowedSymbols[$key]); review and update the compatibility policy."
    }
  }

  $seenIds = @{}
  foreach ($group in @($records | Group-Object IdKey | Where-Object Count -gt 1)) {
    $signature = (($group.Group | ForEach-Object { [string]$_.Symbol } | Sort-Object) -join ",")
    if (!$allowedIds.ContainsKey($group.Name) -or $allowedIds[$group.Name] -ne $signature) {
      Add-AuditError "Undocumented duplicate numeric ID $($group.Name) is shared by $signature."
    } else {
      $seenIds[$group.Name] = $true
    }
  }
  foreach ($key in $allowedIds.Keys) {
    if (!$seenIds.ContainsKey($key)) {
      Add-AuditError "Documented duplicate numeric ID $key is no longer shared by $($allowedIds[$key]); review and update the compatibility policy."
    }
  }

  Add-AuditCheck "Legacy duplicate policy: $($allowedSymbols.Count) symbolic and $($allowedIds.Count) numeric compatibility aliases match exactly."
}

function Test-MetadataSources([hashtable]$TrainerTypeSymbols) {
  $metadataPath = "PBS\metadata.txt"
  $mapMetadataPath = "PBS\map_metadata.txt"
  $globalAllowed = @("Home", "WildBattleBGM", "TrainerBattleBGM", "WildVictoryBGM",
                     "TrainerVictoryBGM", "SurfBGM", "BicycleBGM")
  $playerAllowed = @("LegacyPlayerSlot", "TrainerType", "WalkCharset", "CycleCharset",
                     "SurfCharset", "RunCharset", "DiveCharset", "FishCharset", "SurfFishCharset")
  $requiredPlayer = @("TrainerType", "WalkCharset", "CycleCharset", "SurfCharset",
                      "RunCharset", "DiveCharset", "FishCharset", "SurfFishCharset")
  $mapAllowed = @("Name", "Outdoor", "ShowArea", "Bicycle", "BicycleAlways", "HealingSpot",
                  "Weather", "MapPosition", "DiveMap", "DarkMap", "SafariMap", "SnapEdges",
                  "Dungeon", "BattleBack", "WildBattleBGM", "TrainerBattleBGM", "WildVictoryBGM",
                  "TrainerVictoryBGM", "MapSize")
  $booleanFields = @("Outdoor", "ShowArea", "Bicycle", "BicycleAlways", "DarkMap", "SafariMap", "SnapEdges", "Dungeon")
  $booleanValues = @("true", "false", "1", "0", "yes", "no")
  $weatherValues = @("", "Rain", "Storm", "Snow", "Sandstorm", "Sunny", "HeavyRain", "Blizzard")

  $metadataSections = @(Read-StrictKeyValuePBS $metadataPath)
  $metadataIds = @{}
  foreach ($section in $metadataSections) {
    $sectionId = 0
    if (![int]::TryParse($section.Id, [ref]$sectionId) -or $sectionId -lt 0 -or $sectionId -gt 25) {
      Add-AuditError "$metadataPath section [$($section.Id)] must use a numeric ID from 0 through 25."
      continue
    }
    if ($metadataIds.ContainsKey($sectionId)) {
      Add-AuditError "$metadataPath section [$sectionId] duplicates numeric section ID from line $($metadataIds[$sectionId])."
    } else {
      $metadataIds[$sectionId] = $section.Line
    }
    $allowed = if ($sectionId -eq 0) { $globalAllowed } else { $playerAllowed }
    foreach ($key in $section.Fields.Keys) {
      if ($key -notin $allowed -and !$key.StartsWith("Legacy")) {
        Add-AuditError "$metadataPath line $($section.FieldLines[$key]) has unknown property '$key' in section [$sectionId]."
      }
    }
    if ($sectionId -eq 0) {
      if (!$section.Fields.ContainsKey("Home")) {
        Add-AuditError "$metadataPath global section [0] is missing Home."
      } else {
        Test-UnsignedList ([string]$section.Fields["Home"]) 4 "$metadataPath line $($section.FieldLines['Home']) Home"
      }
      continue
    }
    foreach ($key in $requiredPlayer) {
      if (!$section.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) {
        Add-AuditError "$metadataPath player section [$sectionId] is missing required property '$key'."
      }
    }
    if ($section.Fields.ContainsKey("TrainerType") -and !$TrainerTypeSymbols.ContainsKey([string]$section.Fields["TrainerType"])) {
      Add-AuditError "$metadataPath line $($section.FieldLines['TrainerType']) references unknown trainer type '$($section.Fields['TrainerType'])'."
    }
    if ($section.Fields.ContainsKey("LegacyPlayerSlot")) {
      $expectedSlot = "Player$([char](64 + $sectionId))"
      if ($section.Fields["LegacyPlayerSlot"] -ne $expectedSlot) {
        Add-AuditError "$metadataPath line $($section.FieldLines['LegacyPlayerSlot']) uses LegacyPlayerSlot '$($section.Fields['LegacyPlayerSlot'])'; section [$sectionId] maps to $expectedSlot."
      }
    }
  }
  if (!$metadataIds.ContainsKey(0)) { Add-AuditError "$metadataPath is missing global section [0]." }
  if (!$metadataIds.ContainsKey(1)) { Add-AuditError "$metadataPath is missing player section [1]." }

  $mapSections = @(Read-StrictKeyValuePBS $mapMetadataPath)
  $mapIds = @{}
  foreach ($section in $mapSections) {
    $mapId = 0
    if (![int]::TryParse($section.Id, [ref]$mapId) -or $mapId -lt 1 -or $mapId -gt 999) {
      Add-AuditError "$mapMetadataPath section [$($section.Id)] must use a numeric map ID from 1 through 999."
      continue
    }
    if ($mapIds.ContainsKey($mapId)) {
      Add-AuditError "$mapMetadataPath section [$mapId] duplicates numeric map ID from line $($mapIds[$mapId])."
    } else {
      $mapIds[$mapId] = $section.Line
    }
    foreach ($key in $section.Fields.Keys) {
      if ($key -notin $mapAllowed -and !$key.StartsWith("Legacy")) {
        Add-AuditError "$mapMetadataPath line $($section.FieldLines[$key]) has unknown property '$key' in section [$mapId]."
        continue
      }
      $value = [string]$section.Fields[$key]
      $context = "$mapMetadataPath line $($section.FieldLines[$key]) $key"
      if ($key -in $booleanFields -and $value.ToLowerInvariant() -notin $booleanValues) {
        Add-AuditError "$context must be a Boolean value."
      } elseif ($key -eq "HealingSpot" -or $key -eq "MapPosition") {
        Test-UnsignedList $value 3 $context
      } elseif ($key -eq "DiveMap") {
        Test-UnsignedList $value 1 $context
      } elseif ($key -eq "Weather") {
        $parts = @($value -split ',' | ForEach-Object { $_.Trim() })
        if ($parts.Count -ne 2 -or $parts[0] -notin $weatherValues) {
          Add-AuditError "$context must contain a known weather name and duration."
        } elseif ($parts.Count -eq 2) {
          Test-UnsignedList $parts[1] 1 "$context duration"
        }
      } elseif ($key -eq "MapSize") {
        $parts = @($value -split ',' | ForEach-Object { $_.Trim() })
        if ($parts.Count -ne 2 -or [string]::IsNullOrWhiteSpace($parts[1])) {
          Add-AuditError "$context must contain a size and filename."
        } else {
          Test-UnsignedList $parts[0] 1 "$context size"
        }
      }
    }
  }
  Add-AuditCheck "Metadata: $($metadataSections.Count) global/player sections and $($mapSections.Count) map sections satisfy the split schema."
}

function Test-AbilitySchemas([object[]]$Sections) {
  $allowed = @("LegacyAbilityID", "Name", "Description")
  foreach ($section in $Sections) {
    if ($section.Id -notmatch '^[A-Z][A-Z0-9_]*$') {
      Add-AuditError "Ability section [$($section.Id)] is not a valid constant symbol."
    }
    foreach ($key in $section.Fields.Keys) {
      if ($key -notin $allowed) { Add-AuditError "Ability [$($section.Id)] has unknown property '$key'." }
      if ($section.Fields[$key] -is [System.Collections.IList]) {
        Add-AuditError "Ability [$($section.Id)] defines property '$key' more than once."
      }
    }
    foreach ($key in $allowed) {
      if (!$section.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) {
        Add-AuditError "Ability [$($section.Id)] is missing required property '$key'."
      }
    }
    if ($section.Fields.ContainsKey("LegacyAbilityID")) {
      $abilityId = 0
      if (![int]::TryParse([string]$section.Fields["LegacyAbilityID"], [ref]$abilityId) -or $abilityId -lt 1) {
        Add-AuditError "Ability [$($section.Id)] has invalid positive LegacyAbilityID '$($section.Fields['LegacyAbilityID'])'."
      }
    }
  }
  Add-AuditCheck "Abilities: $($Sections.Count) source rows satisfy the named schema."
}

function Test-TrainerTypeSchemas([object[]]$Sections) {
  $allowed = @("LegacyTrainerTypeID", "Name", "BaseMoney", "BattleBGM", "VictoryBGM", "IntroBGM", "Gender", "SkillLevel")
  $genders = @("", "Male", "M", "0", "Female", "F", "1", "Mixed", "X", "2")
  foreach ($section in $Sections) {
    if ($section.Id -cnotmatch '^[A-Z][A-Za-z0-9_]*$') {
      Add-AuditError "Trainer type section [$($section.Id)] is not a valid constant symbol."
    }
    foreach ($key in $section.Fields.Keys) {
      if ($key -notin $allowed) { Add-AuditError "Trainer type [$($section.Id)] has unknown property '$key'." }
      if ($section.Fields[$key] -is [System.Collections.IList]) {
        Add-AuditError "Trainer type [$($section.Id)] defines property '$key' more than once."
      }
    }
    foreach ($key in @("LegacyTrainerTypeID", "Name")) {
      if (!$section.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) {
        Add-AuditError "Trainer type [$($section.Id)] is missing required property '$key'."
      }
    }
    if ($section.Fields.ContainsKey("LegacyTrainerTypeID")) {
      $trainerTypeId = 0
      if (![int]::TryParse([string]$section.Fields["LegacyTrainerTypeID"], [ref]$trainerTypeId) -or $trainerTypeId -lt 0) {
        Add-AuditError "Trainer type [$($section.Id)] has invalid nonnegative LegacyTrainerTypeID '$($section.Fields['LegacyTrainerTypeID'])'."
      }
    }
    foreach ($key in @("BaseMoney", "SkillLevel")) {
      if (!$section.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) { continue }
      $number = 0
      if (![int]::TryParse([string]$section.Fields[$key], [ref]$number) -or $number -lt 0 -or $number -gt 255) {
        Add-AuditError "Trainer type [$($section.Id)] has invalid $key '$($section.Fields[$key])'; expected 0-255."
      }
    }
    if ($section.Fields.ContainsKey("Gender") -and [string]$section.Fields["Gender"] -notin $genders) {
      Add-AuditError "Trainer type [$($section.Id)] has unknown Gender '$($section.Fields['Gender'])'."
    }
  }
  Add-AuditCheck "Trainer types: $($Sections.Count) source rows satisfy the named schema."
}

function Split-TownMapCsv([string]$Value, [string]$Context) {
  Add-Type -AssemblyName Microsoft.VisualBasic
  $reader = [System.IO.StringReader]::new($Value)
  $parser = [Microsoft.VisualBasic.FileIO.TextFieldParser]::new($reader)
  $parser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
  $parser.SetDelimiters(",")
  $parser.HasFieldsEnclosedInQuotes = $true
  try {
    return @($parser.ReadFields())
  } catch {
    Add-AuditError "$Context has invalid CSV syntax: $($_.Exception.Message)"
    return @()
  } finally {
    $parser.Close()
    $reader.Close()
  }
}

function Test-TownMapSources {
  $relativePath = "PBS\townmap.txt"
  $path = Resolve-ProjectPath $relativePath
  $regions = @{}
  $current = $null
  $lineNumber = 0
  $pointCount = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) { continue }
    if ($line -match '^\[([^\]]+)\]$') {
      $regionId = 0
      if (![int]::TryParse($Matches[1].Trim(), [ref]$regionId) -or $regionId -lt 0 -or $regionId -gt 999) {
        Add-AuditError "$relativePath line $lineNumber has invalid region ID '$($Matches[1])'; expected 0-999."
        $current = $null
        continue
      }
      if ($regions.ContainsKey($regionId)) {
        Add-AuditError "$relativePath line $lineNumber duplicates region [$regionId] from line $($regions[$regionId].Line)."
        $current = $regions[$regionId]
      } else {
        $current = [pscustomobject]@{ Line = $lineNumber; Name = $null; Filename = $null; Properties = @{} }
        $regions[$regionId] = $current
      }
      continue
    }
    if ($null -eq $current) {
      Add-AuditError "$relativePath line $lineNumber appears before a valid region section."
      continue
    }
    if ($line -notmatch '^([^=]+?)\s*=\s*(.*)$') {
      Add-AuditError "$relativePath line $lineNumber must use Property = Value syntax."
      continue
    }
    $key = $Matches[1].Trim()
    $value = $Matches[2]
    if ($key -notin @("Name", "Filename", "Point")) {
      Add-AuditError "$relativePath line $lineNumber has unknown property '$key'."
      continue
    }
    if ($key -ne "Point" -and $current.Properties.ContainsKey($key)) {
      Add-AuditError "$relativePath line $lineNumber duplicates property '$key' from line $($current.Properties[$key])."
      continue
    }
    if ($key -ne "Point") { $current.Properties[$key] = $lineNumber }
    if ($key -eq "Name") {
      if ([string]::IsNullOrWhiteSpace($value)) { Add-AuditError "$relativePath line $lineNumber has an empty region Name." }
      $current.Name = $value
      continue
    }
    if ($key -eq "Filename") {
      if ([string]::IsNullOrWhiteSpace($value)) {
        Add-AuditError "$relativePath line $lineNumber has an empty Filename."
      } else {
        $assetPath = Resolve-ProjectPath ("Graphics\Pictures\" + $value.Trim('"'))
        if (!(Test-Path -LiteralPath $assetPath -PathType Leaf)) {
          Add-AuditError "$relativePath line $lineNumber references missing map image '$value'."
        }
      }
      $current.Filename = $value
      continue
    }
    $pointCount++
    $fields = @(Split-TownMapCsv $value "$relativePath line $lineNumber Point")
    if ($fields.Count -ne 8) {
      Add-AuditError "$relativePath line $lineNumber Point has $($fields.Count) CSV fields; expected 8."
      continue
    }
    foreach ($index in @(0,1)) {
      $number = 0
      if (![int]::TryParse($fields[$index], [ref]$number) -or $number -lt 0 -or $number -gt 65535) {
        Add-AuditError "$relativePath line $lineNumber Point field $($index + 1) must be an integer from 0 through 65535."
      }
    }
    if ([string]::IsNullOrWhiteSpace($fields[2])) {
      Add-AuditError "$relativePath line $lineNumber Point has an empty place name."
    }
    foreach ($index in 4..7) {
      if ([string]::IsNullOrWhiteSpace($fields[$index])) { continue }
      $number = 0
      if (![int]::TryParse($fields[$index], [ref]$number) -or $number -lt 0 -or $number -gt 65535) {
        Add-AuditError "$relativePath line $lineNumber Point field $($index + 1) must be blank or an integer from 0 through 65535."
      }
    }
    $healingCount = @($fields[4..6] | Where-Object { ![string]::IsNullOrWhiteSpace($_) }).Count
    if ($healingCount -ne 0 -and $healingCount -ne 3) {
      Add-AuditError "$relativePath line $lineNumber Point must define all three healing spot values or none."
    }
  }
  foreach ($entry in $regions.GetEnumerator()) {
    if ([string]::IsNullOrWhiteSpace($entry.Value.Name)) {
      Add-AuditError "$relativePath region [$($entry.Key)] is missing Name."
    }
    if ([string]::IsNullOrWhiteSpace($entry.Value.Filename)) {
      Add-AuditError "$relativePath region [$($entry.Key)] is missing Filename."
    }
  }
  Add-AuditCheck "Town map: $($regions.Count) regions and $pointCount points satisfy the numeric array schema."
}

function Test-BattleFacilitySources {
  $relativePath = "PBS\trainerlists.txt"
  $path = Resolve-ProjectPath $relativePath
  $sections = [System.Collections.Generic.List[object]]::new()
  $current = $null
  $lineNumber = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if (!$line -or $line.StartsWith("#")) { continue }
    if ($line -match '^\[\s*(.+?)\s*\]$') {
      $name = $Matches[1]
      if ($name -notin @("DefaultTrainerList", "TrainerList")) {
        Add-AuditError "$relativePath line $lineNumber has unknown section [$name]."
      }
      $current = [pscustomobject]@{
        Name = $name
        Line = $lineNumber
        Fields = @{}
        FieldLines = @{}
      }
      $sections.Add($current)
      continue
    }
    if ($null -eq $current) {
      Add-AuditError "$relativePath line $lineNumber appears before a list section."
      continue
    }
    if ($line -notmatch '^([^=]+?)\s*=\s*(.*)$') {
      Add-AuditError "$relativePath line $lineNumber must use Property = Value syntax."
      continue
    }
    $key = $Matches[1].Trim()
    $value = $Matches[2].Trim()
    if ($key -notin @("Trainers", "Pokemon", "Challenges")) {
      Add-AuditError "$relativePath line $lineNumber has unknown property '$key'."
      continue
    }
    if ($current.Fields.ContainsKey($key)) {
      Add-AuditError "$relativePath line $lineNumber duplicates property '$key' from line $($current.FieldLines[$key])."
      continue
    }
    $current.Fields[$key] = $value
    $current.FieldLines[$key] = $lineNumber
  }

  $defaultSections = @($sections | Where-Object { $_.Name -eq "DefaultTrainerList" })
  if ($defaultSections.Count -ne 1) {
    Add-AuditError "$relativePath must contain exactly one DefaultTrainerList section; found $($defaultSections.Count)."
  }
  $challengeLines = @{}
  $referenceCount = 0
  $presentReferenceCount = 0
  foreach ($section in $sections) {
    foreach ($key in @("Trainers", "Pokemon")) {
      if (!$section.Fields.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$section.Fields[$key])) {
        Add-AuditError "$relativePath section at line $($section.Line) is missing required property '$key'."
        continue
      }
      $filename = ([string]$section.Fields[$key]).Replace("\", "/")
      if ($filename.StartsWith("/") -or $filename -match '^[A-Za-z]:' -or @($filename -split '/') -contains ".." -or $filename.EndsWith("/")) {
        Add-AuditError "$relativePath line $($section.FieldLines[$key]) has unsafe $key path '$filename'."
        continue
      }
      $referenceCount++
      $referencePath = Resolve-ProjectPath ("PBS\" + $filename.Replace("/", "\"))
      if (Test-Path -LiteralPath $referencePath -PathType Leaf) { $presentReferenceCount++ }
    }
    if ($section.Name -eq "DefaultTrainerList") { continue }
    if (!$section.Fields.ContainsKey("Challenges")) { continue }
    foreach ($challenge in @(([string]$section.Fields["Challenges"]) -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
      if ($challengeLines.ContainsKey($challenge)) {
        Add-AuditError "$relativePath line $($section.FieldLines['Challenges']) repeats challenge '$challenge' from line $($challengeLines[$challenge])."
      } else {
        $challengeLines[$challenge] = $section.FieldLines["Challenges"]
      }
    }
  }
  $missingReferenceCount = $referenceCount - $presentReferenceCount
  Add-AuditCheck "Battle facilities: $($sections.Count) lists and $($challengeLines.Count) challenge routes satisfy the six-field legacy schema; $missingReferenceCount optional referenced datasets are absent and compile as empty arrays."
}

function Test-PhoneSources {
  $relativePath = "PBS\phone.txt"
  $path = Resolve-ProjectPath $relativePath
  $required = @(
    "<Generics>", "<BattleRequests>", "<GreetingsMorning>",
    "<GreetingsEvening>", "<Greetings>", "<Bodies1>", "<Bodies2>"
  )
  $sections = @{}
  $current = $null
  $lineNumber = 0
  $messageCount = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if (!$line -or $line.StartsWith("#")) { continue }
    if ($line -match '^\[\s*(.+?)\s*\]$') {
      $name = $Matches[1]
      if ($name -notin $required) {
        Add-AuditError "$relativePath line $lineNumber has unknown phone section [$name]."
        $current = $null
        continue
      }
      if ($sections.ContainsKey($name)) {
        Add-AuditError "$relativePath line $lineNumber duplicates section [$name] from line $($sections[$name].Line)."
        $current = $sections[$name]
        continue
      }
      $current = [pscustomobject]@{ Line = $lineNumber; Messages = 0 }
      $sections[$name] = $current
      continue
    }
    if ($null -eq $current) {
      Add-AuditError "$relativePath line $lineNumber has message text before a valid phone section."
      continue
    }
    $current.Messages++
    $messageCount++
  }
  foreach ($name in $required) {
    if (!$sections.ContainsKey($name)) {
      Add-AuditError "$relativePath is missing required section [$name]."
    } elseif ($sections[$name].Messages -lt 1) {
      Add-AuditError "$relativePath section [$name] has no messages."
    }
  }
  Add-AuditCheck "Phone data: $($sections.Count) required categories and $messageCount messages satisfy the section schema."
}

function Convert-ConnectionPoint([string]$Value, [string]$Context) {
  $fields = @($Value -split ',', -1)
  if ($fields.Count -ne 2) {
    Add-AuditError "$Context has $($fields.Count) fields; expected an edge and offset or X,Y."
    return $null
  }
  $first = $fields[0].Trim()
  $secondText = $fields[1].Trim()
  $second = 0
  if (![int]::TryParse($secondText, [ref]$second)) {
    Add-AuditError "$Context has non-numeric second coordinate '$secondText'."
    return $null
  }
  $sides = @{ N = "N"; North = "N"; E = "E"; East = "E"; S = "S"; South = "S"; W = "W"; West = "W" }
  if ($sides.ContainsKey($first)) {
    return [pscustomobject]@{ First = $sides[$first]; Second = $second; IsSide = $true }
  }
  $x = 0
  if (![int]::TryParse($first, [ref]$x)) {
    Add-AuditError "$Context has unknown edge or non-numeric X coordinate '$first'."
    return $null
  }
  return [pscustomobject]@{ First = $x; Second = $second; IsSide = $false }
}

function Convert-ConnectionMapId([string]$Value, [string]$Context) {
  $mapId = 0
  if (![int]::TryParse($Value.Trim(), [ref]$mapId) -or $mapId -lt 1 -or $mapId -gt 999) {
    Add-AuditError "$Context has invalid map ID '$Value'; expected 1-999."
    return $null
  }
  $rxPath = Resolve-ProjectPath ("Data\Map{0:D3}.rxdata" -f $mapId)
  $rvPath = Resolve-ProjectPath ("Data\Map{0:D3}.rvdata" -f $mapId)
  if (!(Test-Path -LiteralPath $rxPath -PathType Leaf) -and !(Test-Path -LiteralPath $rvPath -PathType Leaf)) {
    Add-AuditError "$Context references missing map $mapId."
  }
  return $mapId
}

function Test-ConnectionRecord(
  [object]$Map1,
  [object]$Point1,
  [object]$Map2,
  [object]$Point2,
  [string]$Context,
  [hashtable]$Seen
) {
  if ($null -eq $Map1 -or $null -eq $Point1 -or $null -eq $Map2 -or $null -eq $Point2) { return }
  if ($Map1 -eq $Map2) { Add-AuditError "$Context connects map $Map1 to itself." }
  $opposites = @{ N = "S"; S = "N"; E = "W"; W = "E" }
  if ($Point1.IsSide -and (!$Point2.IsSide -or $Point2.First -ne $opposites[$Point1.First])) {
    Add-AuditError "$Context connects the $($Point1.First) side of its first map to a non-opposite second point."
  }
  $forward = "$Map1|$($Point1.First)|$($Point1.Second)|$Map2|$($Point2.First)|$($Point2.Second)"
  $reverse = "$Map2|$($Point2.First)|$($Point2.Second)|$Map1|$($Point1.First)|$($Point1.Second)"
  $key = @($forward, $reverse) | Sort-Object | Select-Object -First 1
  if ($Seen.ContainsKey($key)) {
    Add-AuditError "$Context duplicates the symmetric connection first defined by $($Seen[$key])."
  } else {
    $Seen[$key] = $Context
  }
}

function Test-ConnectionSources {
  $relativePath = "PBS\connections.txt"
  $path = Resolve-ProjectPath $relativePath
  $dataLines = @([System.IO.File]::ReadLines($path) | ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and !$_.StartsWith("#") })
  if ($dataLines.Count -eq 0) {
    Add-AuditCheck "Map connections: the intentionally empty source compiles to an empty connection array."
    return
  }
  $seen = @{}
  $recordCount = 0
  if ($dataLines[0].StartsWith("[")) {
    $sections = @(Read-StrictKeyValuePBS $relativePath)
    $allowed = @("Map1", "Map1Point", "Map2", "Map2Point")
    foreach ($section in $sections) {
      foreach ($key in $section.Fields.Keys) {
        if ($key -notin $allowed) { Add-AuditError "$relativePath section [$($section.Id)] has unknown property '$key'." }
      }
      $missing = @($allowed | Where-Object { !$section.Fields.ContainsKey($_) })
      if ($missing.Count -gt 0) {
        Add-AuditError "$relativePath section [$($section.Id)] is missing: $($missing -join ', ')."
        continue
      }
      $map1 = Convert-ConnectionMapId ([string]$section.Fields["Map1"]) "$relativePath section [$($section.Id)] Map1"
      $point1 = Convert-ConnectionPoint ([string]$section.Fields["Map1Point"]) "$relativePath section [$($section.Id)] Map1Point"
      $map2 = Convert-ConnectionMapId ([string]$section.Fields["Map2"]) "$relativePath section [$($section.Id)] Map2"
      $point2 = Convert-ConnectionPoint ([string]$section.Fields["Map2Point"]) "$relativePath section [$($section.Id)] Map2Point"
      Test-ConnectionRecord $map1 $point1 $map2 $point2 "$relativePath section [$($section.Id)]" $seen
      $recordCount++
    }
    Add-AuditCheck "Map connections: $recordCount named sections satisfy the six-field runtime schema."
    return
  }
  $lineNumber = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if (!$line -or $line.StartsWith("#")) { continue }
    $fields = @($line -split ',', -1)
    if ($fields.Count -ne 6) {
      Add-AuditError "$relativePath line $lineNumber has $($fields.Count) fields; expected 6."
      continue
    }
    $map1 = Convert-ConnectionMapId $fields[0] "$relativePath line $lineNumber Map1"
    $point1 = Convert-ConnectionPoint "$($fields[1]),$($fields[2])" "$relativePath line $lineNumber first point"
    $map2 = Convert-ConnectionMapId $fields[3] "$relativePath line $lineNumber Map2"
    $point2 = Convert-ConnectionPoint "$($fields[4]),$($fields[5])" "$relativePath line $lineNumber second point"
    Test-ConnectionRecord $map1 $point1 $map2 $point2 "$relativePath line $lineNumber" $seen
    $recordCount++
  }
  Add-AuditCheck "Map connections: $recordCount legacy rows satisfy the six-field runtime schema."
}

function Test-ShadowMoveReferences([hashtable]$SpeciesSymbols, [hashtable]$MoveSymbols) {
  $relativePath = "PBS\shadowmoves.txt"
  $path = Resolve-ProjectPath $relativePath
  $dataLines = @([System.IO.File]::ReadLines($path) | ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and !$_.StartsWith("#") })
  if ($dataLines.Count -eq 0) {
    Add-AuditCheck "Shadow moves: the optional source is empty."
    return
  }

  if ($dataLines[0].StartsWith("[")) {
    $sections = @(Read-StrictKeyValuePBS $relativePath)
    $slotCount = 0
    foreach ($section in $sections) {
      if (!$SpeciesSymbols.ContainsKey($section.Id)) {
        Add-AuditError "$relativePath section [$($section.Id)] references unknown species."
      }
      foreach ($key in $section.Fields.Keys) {
        if ($key -ne "Moves") {
          Add-AuditError "$relativePath section [$($section.Id)] has unknown property '$key'."
        }
      }
      if (!$section.Fields.ContainsKey("Moves")) {
        Add-AuditError "$relativePath section [$($section.Id)] is missing Moves."
        continue
      }
      $moves = @(Split-PBSList $section.Fields["Moves"])
      if ($moves.Count -lt 1 -or $moves.Count -gt 4) {
        Add-AuditError "$relativePath section [$($section.Id)] has $($moves.Count) moves; expected 1-4."
      }
      foreach ($move in $moves) {
        if (!$MoveSymbols.ContainsKey($move)) {
          Add-AuditError "$relativePath section [$($section.Id)] references unknown move '$move'."
        }
      }
      $slotCount += $moves.Count
    }
    Add-AuditCheck "Shadow moves: $($sections.Count) named species sections and $slotCount move slots are valid."
    return
  }

  $seen = @{}
  $effective = @{}
  $rowCount = 0
  $lineNumber = 0
  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = $rawLine.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) { continue }
    if ($line -notmatch '^([^=]+)=(.*)$') {
      Add-AuditWarning "$relativePath line $lineNumber is ignored by the permissive legacy parser: '$line'."
      continue
    }
    $rowCount++
    $species = $Matches[1].Trim()
    $moveText = $Matches[2]
    if (!$SpeciesSymbols.ContainsKey($species)) {
      Add-AuditError "$relativePath line $lineNumber references unknown species '$species'."
      continue
    }
    if ($seen.ContainsKey($species)) {
      Add-AuditWarning "$relativePath defines $species again at line $lineNumber; the last row containing a valid move is effective over line $($seen[$species])."
    }
    $seen[$species] = $lineNumber
    $tokens = @($moveText -split ',')
    if ($tokens.Count -gt 4) {
      Add-AuditWarning "$relativePath line $lineNumber has $($tokens.Count) moves; the legacy parser keeps only the first 4."
    }
    $validMoves = [System.Collections.Generic.List[string]]::new()
    $limit = [Math]::Min(4, $tokens.Count)
    for ($index = 0; $index -lt $limit; $index++) {
      $move = $tokens[$index].Trim()
      if (!$MoveSymbols.ContainsKey($move)) {
        Add-AuditWarning "$relativePath line $lineNumber references unknown move '$move'; the permissive legacy parser drops it."
        continue
      }
      $validMoves.Add($move)
    }
    if ($validMoves.Count -gt 0) { $effective[$species] = @($validMoves) }
  }
  $slotCount = 0
  foreach ($moves in $effective.Values) { $slotCount += $moves.Count }
  Add-AuditCheck "Shadow moves: $rowCount legacy rows compile to $($effective.Count) effective species and $slotCount move slots."
}

function Test-EncounterReferences([hashtable]$SpeciesSymbols) {
  $relativePath = "PBS\encounters.txt"
  $path = Resolve-ProjectPath $relativePath
  $firstDataLine = [System.IO.File]::ReadLines($path) |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and !$_.StartsWith("#") } |
    Select-Object -First 1
  if (!$firstDataLine.StartsWith("[")) {
    Add-AuditCheck "Encounters: legacy source format is preserved; named-source validation was not applicable."
    return
  }

  $chanceDefinitions = [ordered]@{
    Land = @(20,20,10,10,10,10,5,5,4,4,1,1)
    Cave = @(20,20,10,10,10,10,5,5,4,4,1,1)
    Water = @(60,30,5,4,1)
    RockSmash = @(60,30,5,4,1)
    OldRod = @(70,30)
    GoodRod = @(60,20,20)
    SuperRod = @(40,40,15,4,1)
    HeadbuttLow = @(30,25,20,10,5,5,4,1)
    HeadbuttHigh = @(30,25,20,10,5,5,4,1)
    LandMorning = @(20,20,10,10,10,10,5,5,4,4,1,1)
    LandDay = @(20,20,10,10,10,10,5,5,4,4,1,1)
    LandNight = @(20,20,10,10,10,10,5,5,4,4,1,1)
    BugContest = @(20,20,10,10,10,10,5,5,4,4,1,1)
    WaterDay = @(60,30,5,4,1)
    WaterNight = @(60,30,5,4,1)
  }
  $densityTypes = @("Land", "Cave", "Water", "LandMorning", "LandDay", "LandNight", "BugContest", "WaterDay", "WaterNight")
  $maps = @{}
  $currentMap = $null
  $currentType = $null
  $lineNumber = 0
  $slotCount = 0

  foreach ($rawLine in [System.IO.File]::ReadLines($path)) {
    $lineNumber++
    $line = ($rawLine -replace '\s+#.*$', '').Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) { continue }

    if ($line -match '^\[(\d+)(?:\s*,\s*\d+)?\]$') {
      $mapId = [int]$Matches[1]
      if ($mapId -lt 1 -or $mapId -gt 999) {
        Add-AuditError "$relativePath line $lineNumber has map ID $mapId outside 1-999."
      }
      if ($maps.ContainsKey($mapId)) {
        Add-AuditError "$relativePath line $lineNumber duplicates encounter map [$mapId] first defined at line $($maps[$mapId].Line)."
        $currentMap = $maps[$mapId]
      } else {
        $currentMap = [pscustomobject]@{ Line = $lineNumber; Types = @{} }
        $maps[$mapId] = $currentMap
      }
      $currentType = $null
      continue
    }

    if ($line -match '^([A-Za-z0-9_]+)(?:\s*,\s*(\d+))?$') {
      $typeName = $Matches[1]
      $densityText = $Matches[2]
      if (!$chanceDefinitions.Contains($typeName)) {
        Add-AuditError "$relativePath line $lineNumber uses unknown encounter type '$typeName'."
        $currentType = $null
        continue
      }
      if ($null -eq $currentMap) {
        Add-AuditError "$relativePath line $lineNumber defines encounter type '$typeName' before a map section."
        $currentType = $null
        continue
      }
      if ($currentMap.Types.ContainsKey($typeName)) {
        Add-AuditError "$relativePath line $lineNumber duplicates encounter type '$typeName' from line $($currentMap.Types[$typeName].Line)."
        $currentType = $currentMap.Types[$typeName]
      } else {
        $currentType = [pscustomobject]@{
          Line = $lineNumber
          Density = $densityText
          Slots = [System.Collections.Generic.List[object]]::new()
        }
        $currentMap.Types[$typeName] = $currentType
      }
      if ($densityText -and $typeName -notin $densityTypes) {
        Add-AuditError "$relativePath line $lineNumber gives density $densityText to encounter type '$typeName', which has no density setting."
      }
      if ($densityText -and ([int]$densityText -lt 0 -or [int]$densityText -gt 255)) {
        Add-AuditError "$relativePath line $lineNumber has density $densityText outside 0-255."
      }
      continue
    }

    if ($line -match '^(\d+)\s*,\s*([^,]+)\s*,\s*(\d+)(?:\s*,\s*(\d+))?$') {
      if ($null -eq $currentType) {
        Add-AuditError "$relativePath line $lineNumber defines an encounter slot before an encounter type."
        continue
      }
      $weight = [int]$Matches[1]
      $species = $Matches[2].Trim()
      $minLevel = [int]$Matches[3]
      $maxLevel = if ($Matches[4]) { [int]$Matches[4] } else { $minLevel }
      if ($weight -lt 1 -or $weight -gt 100) {
        Add-AuditError "$relativePath line $lineNumber has slot weight $weight outside 1-100."
      }
      if ($minLevel -lt 1 -or $maxLevel -gt 100 -or $minLevel -gt $maxLevel) {
        Add-AuditError "$relativePath line $lineNumber has invalid level range $minLevel-$maxLevel."
      }
      if (!$SpeciesSymbols.ContainsKey($species)) {
        Add-AuditError "$relativePath line $lineNumber references unknown species '$species'."
      }
      $currentType.Slots.Add([pscustomobject]@{ Line = $lineNumber; Weight = $weight })
      $slotCount++
      continue
    }

    Add-AuditError "$relativePath line $lineNumber has invalid named encounter syntax: '$line'."
  }

  $typeCount = 0
  foreach ($mapEntry in $maps.GetEnumerator()) {
    $mapId = $mapEntry.Key
    $map = $mapEntry.Value
    if ($map.Types.ContainsKey("Cave") -and
        ($map.Types.ContainsKey("Land") -or $map.Types.ContainsKey("LandMorning") -or
         $map.Types.ContainsKey("LandDay") -or $map.Types.ContainsKey("LandNight") -or
         $map.Types.ContainsKey("BugContest"))) {
      Add-AuditError "$relativePath map [$mapId] defines both Land-family and Cave encounters."
    }
    foreach ($typeEntry in $map.Types.GetEnumerator()) {
      $typeCount++
      $typeName = $typeEntry.Key
      $type = $typeEntry.Value
      $expectedWeights = $chanceDefinitions[$typeName]
      if ($type.Slots.Count -ne $expectedWeights.Count) {
        Add-AuditError "$relativePath map [$mapId] type '$typeName' has $($type.Slots.Count) slots; expected $($expectedWeights.Count)."
        continue
      }
      for ($slot = 0; $slot -lt $expectedWeights.Count; $slot++) {
        if ($type.Slots[$slot].Weight -ne $expectedWeights[$slot]) {
          Add-AuditError "$relativePath line $($type.Slots[$slot].Line) has weight $($type.Slots[$slot].Weight) for $typeName slot $($slot + 1); expected $($expectedWeights[$slot])."
        }
      }
    }
  }
  Add-AuditCheck "Encounters: $($maps.Count) maps, $typeCount encounter types, and $slotCount slots satisfy the named schema."
}

function Test-FeatureContracts {
  $contracts = @(
    @{ Name = "Tributes"; File = "Scripts\Tributes.rb"; Pattern = 'def\s+pbTributeItemIDs\b' },
    @{ Name = "Heroic forms"; File = "Scripts\Tributes.rb"; Pattern = 'def\s+pbGetHeroicForm\b' },
    @{ Name = "Draco Tribute battle registration"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = 'def\s+pbRegisterDracoTribute\b' },
    @{ Name = "Hollows"; File = "Scripts\Hollows.rb"; Pattern = 'def\s+pbStartHollow\b' },
    @{ Name = "Boss battles"; File = "Scripts\PokemonBossBattle.rb"; Pattern = 'def\s+bossHandler\b' },
    @{ Name = "PWT"; File = "Scripts\PWT.rb"; Pattern = 'def\s+startPWT\b' },
    @{ Name = "Battle Arena"; File = "Scripts\PokeBattle_BattleArena.rb"; Pattern = 'class\s+PokeBattle_BattleArena\b' },
    @{ Name = "Battle Palace"; File = "Scripts\PokeBattle_BattlePalace.rb"; Pattern = 'class\s+PokeBattle_BattlePalace\b' },
    @{ Name = "Bug Contest"; File = "Scripts\PokemonBugContest.rb"; Pattern = 'def\s+pbBugContestBattle\b' },
    @{ Name = "Phone/rematches"; File = "Scripts\PokemonPhone.rb"; Pattern = 'def\s+pbPhoneRegister\b' },
    @{ Name = "Trainer Index"; File = "Scripts\PokemonTrainerIndex.rb"; Pattern = 'def\s+pbRegisterTrainerEncounter\b' },
    @{ Name = "Field Effect database"; File = "Scripts\FieldEffectInfo.rb"; Pattern = 'FIELDEFFECTDATA\s*=' },
    @{ Name = "Field Effects Manual"; File = "Scripts\PokemonFieldEffectsManual.rb"; Pattern = 'class\s+Scene_FieldEffectsManual\b' },
    @{ Name = "Interval autosave"; File = "Scripts\PokemonSave.rb"; Pattern = 'def\s+pbAutoSave\b' },
    @{ Name = "Perspective tilemap"; File = "Scripts\PerspectiveTilemap.rb"; Pattern = 'class\s+Draw_Tilemap\b' },
    @{ Name = "Mystery Gift"; File = "Scripts\PokemonMysteryGift.rb"; Pattern = 'def\s+pbReceiveMysteryGift\b' },
    @{ Name = "Random dungeons"; File = "Scripts\RandomDungeons.rb"; Pattern = 'class\s+Dungeon\b' },
    @{ Name = "Duel minigame"; File = "Scripts\PokemonMinigameDuel.rb"; Pattern = 'def\s+pbDuel\b' },
    @{ Name = "Triple Triad"; File = "Scripts\PokemonMinigameTripleTriad.rb"; Pattern = 'def\s+pbTriadDuel\b' },
    @{ Name = "Mega Evolution"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = 'def\s+pbRegisterMegaEvolution\b' },
    @{ Name = "Z-Moves"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = 'def\s+pbRegisterZMove\b' },
    @{ Name = "Gen 9 residual effect slots"; File = "Scripts\PBEffects.rb"; Pattern = '(?s)SaltCure\s*=\s*254.*SyrupBombTurns\s*=\s*255.*SyrupBombUser\s*=\s*256.*SilkTrap\s*=\s*257.*BurningBulwark\s*=\s*258.*Commander\s*=\s*259.*Commandee\s*=\s*260' },
    @{ Name = "Gen 9 residual initialization"; File = "Scripts\PokeBattle_Battler.rb"; Pattern = '(?s)PBEffects::SaltCure\]\s*=\s*false.*PBEffects::SyrupBombTurns\]\s*=\s*0.*PBEffects::SyrupBombUser\]\s*=\s*-1.*PBEffects::StatChangeHolder\]\s*=\s*Array\.new\(8,0\)' },
    @{ Name = "Gen 9 residual round processing"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)# Salt Cure.*PBEffects::SaltCure.*pbHasType\?\(:STEEL\).*pbHasType\?\(:WATER\).*# Syrup Bomb.*PBEffects::SyrupBombTurns.*pbReduceStat\(PBStats::SPEED,1' },
    @{ Name = "Turn stat-raise signal reset"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = 'azureStatsRaisedThisRound\s*=\s*false' },
    @{ Name = "Reactive protection interception"; File = "Scripts\PokeBattle_Battler.rb"; Pattern = '(?s)# Silk Trap.*PBEffects::SilkTrap.*PROTECTIVEPADS.*PBStats::SPEED.*# Burning Bulwark.*PBEffects::BurningBulwark.*PROTECTIVEPADS.*pbBurn' },
    @{ Name = "Reactive protection round reset"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)PBEffects::SilkTrap\]\s*=\s*false.*PBEffects::BurningBulwark\]\s*=\s*false' },
    @{ Name = "Shed Tail safe substitute handoff"; File = "Scripts\PokeBattle_Battler.rb"; Pattern = '(?s)@tributeOrthwormShedHP.*shed_data\[i\.index\].*!i\.isFainted\?.*pbSubstituteSprite' },
    @{ Name = "Commander target immunity"; File = "Scripts\PokeBattle_Battler.rb"; Pattern = '(?s)def\s+pbSuccessCheck.*PBEffects::Commander.*avoided the attack' },
    @{ Name = "Commander command and switch locks"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)def\s+pbCanShowCommands\?.*PBEffects::Commander.*def\s+pbCanSwitchLax\?.*PBEffects::Commandee' },
    @{ Name = "Aftershock end-round execution"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)# Aftershock delayed hits.*PBEffects::AftershockMove.*@azure_aftershock_echo.*move\.pbEffect.*pbAdditionalEffect' },
    @{ Name = "Counterpoise end-round swap"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)# Counterpoise retains doubled Defense.*PBEffects::CounterpoiseSwap.*PBEffects::PowerTrick.*PBEffects::CounterpoiseDouble\]=false' },
    @{ Name = "Jetstream weather and Tailwind extension"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)weatherduration>0\s*&&\s*!azureJetstreamWeatherExtended\?.*# Tailwind.*azureJetstreamForSide\?\(i\)' },
    @{ Name = "Pressure Plate duration"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)# Pressure Plate.*PBEffects::PressurePlate\]-=1.*pressure plate beneath' },
    @{ Name = "Vile Mercy poison and duration"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)PBEffects::VileMercy\]>0.*pbCanPoison\?.*vile miasma.*# Vile Mercy.*PBEffects::VileMercy\]-=1' },
    @{ Name = "Vile Mercy field initialization"; File = "Scripts\PokeBattle_ActiveSide.rb"; Pattern = 'PBEffects::VileMercy\]\s*=\s*0' },
    @{ Name = "Lotus Bloom permanent slot initialization"; File = "Scripts\PokeBattle_Battler.rb"; Pattern = '(?s)PBEffects::LotusBloom\]\s*=\s*0.*PBEffects::LotusBloomMove\]\s*=\s*0.*PBEffects::LotusBloomUser\]\s*=\s*-1.*PBEffects::LotusBloomPkmnIdx\]\s*=\s*-1' },
    @{ Name = "Lotus Bloom delayed round execution"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)# Lotus Bloom delayed hits.*PBEffects::LotusBloom\]-=1.*pbMakeFakeBattler.*@azure_lotus_bloom_strike.*move\.pbEffect' },
    @{ Name = "Sunfury and Red Sun side initialization"; File = "Scripts\PokeBattle_ActiveSide.rb"; Pattern = '(?s)PBEffects::RedSunStars\]\s*=\s*\[\].*PBEffects::Sunfury\]\s*=\s*0' },
    @{ Name = "Sunfury and Red Sun round processing"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)# Sunfury residual damage.*totalhp\*eff/48.*PBEffects::Sunfury\]-=1.*# Red Sun''s Zenith stars.*turns-1.*stars\.max\+1' },
    @{ Name = "Final Azure move-state initialization"; File = "Scripts\PokeBattle_Battler.rb"; Pattern = '(?s)PBEffects::CircadianRhythm\]\s*=\s*false.*PBEffects::Needles\]\s*=\s*0.*PBEffects::MoltenStance\]\s*=\s*false' },
    @{ Name = "Blue Shift field initialization"; File = "Scripts\PokeBattle_ActiveSide.rb"; Pattern = 'PBEffects::BlueShift\]\s*=\s*0' },
    @{ Name = "Blue Shift type inversion"; File = "Scripts\PokeBattle_Move.rb"; Pattern = '(?s)def\s+azure_inverse_type_matchup.*PBEffects::BlueShift.*typemod=azure_inverse_type_matchup.*when 36 # Inverse Field.*PBEffects::BlueShift' },
    @{ Name = "Blue Shift AI type awareness"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)def\s+pbTypeModifierAI.*Inverse Field / Blue Shift.*PBEffects::BlueShift.*def\s+pbTypeModNoMessages.*Inverse Field / Blue Shift.*PBEffects::BlueShift' },
    @{ Name = "Circadian Needle Molten and Blue round processing"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)# Circadian Rhythm sleep-turn growth.*PBStats::ATTACK,PBStats::SPATK,PBStats::SPEED.*# Molten Stance.*PBStats::DEFENSE,PBStats::SPDEF.*PBStats::SPEED,2.*# One embedded needle.*azureConsumeNeedle.*# Blue Shift.*PBEffects::BlueShift\]-=1' },
    @{ Name = "Typed cached move data registry"; File = "Scripts\PBMove.rb"; Pattern = '(?s)attr_reader\s+:id.*alias\s+azure_uncached_new\s+new.*def\s+normalize_id.*PBMoves\.const_defined\?.*def\s+new\(moveid\).*@azure_source_id.*@azure_source_row.*def\s+get\(move\).*def\s+try_get\(move\).*def\s+exists\?\(move\).*def\s+each.*def\s+clear_cache' },
    @{ Name = "Typed cached item data registry"; File = "Scripts\PokemonItems.rb"; Pattern = '(?s)class\s+PBItemData.*attr_reader\s+:id,:name,:pocket,:price,:description.*attr_reader\s+:field_use,:battle_use,:item_type,:move.*alias\s+azure_uncached_new\s+new.*def\s+normalize_id.*PBItems\.const_defined\?.*def\s+new\(itemid\).*@azure_source_id.*@azure_source_row.*def\s+get\(item\).*def\s+try_get\(item\).*def\s+exists\?\(item\).*def\s+each.*def\s+clear_cache' },
    @{ Name = "Typed cached ability data registry"; File = "Scripts\PBAbility.rb"; Pattern = '(?s)class\s+PBAbilityData.*attr_reader\s+:id.*def\s+ability.*def\s+name.*MessageTypes::Abilities.*def\s+desc.*MessageTypes::AbilityDescs.*def\s+fullName.*def\s+fullDesc.*alias\s+azure_uncached_new\s+new.*def\s+normalize_id.*PBAbilities\.const_defined\?.*def\s+valid_id\?.*def\s+new\(abilityid\).*@azure_cache.*def\s+get\(ability\).*def\s+try_get\(ability\).*def\s+exists\?\(ability\).*def\s+each.*def\s+clear_cache' },
    @{ Name = "Typed cached type data registry"; File = "Scripts\PBTypesExtra.rb"; Pattern = '(?s)class\s+PBTypeData.*attr_reader\s+:id,:weak,:resist,:immune,:specialtype.*PBTypes\.loadTypeData.*attack_type\*count\+@id.*@weak\.freeze.*@resist\.freeze.*@immune\.freeze.*def\s+type.*def\s+name.*def\s+pseudo\?.*def\s+weak\?.*def\s+resists\?.*def\s+immune\?.*def\s+specialtype\?.*alias\s+azure_uncached_new\s+new.*def\s+normalize_id.*PBTypes\.const_defined\?.*def\s+new\(typeid\).*def\s+wrapper_for.*@azure_source.*def\s+get\(type\).*def\s+try_get\(type\).*def\s+exists\?\(type\).*def\s+each.*def\s+clear_cache' },
    @{ Name = "Typed cached species data registry"; File = "Scripts\PBSpeciesData.rb"; Pattern = '(?s)class\s+PBSpeciesData.*attr_reader\s+:id,:color,:habitat,:type1,:type2,:base_stats,:catch_rate.*attr_reader\s+:gender_rate,:happiness,:growth_rate,:hatch_steps,:evs.*attr_reader\s+:abilities,:hidden_ability,:egg_groups,:height,:weight,:base_exp.*@azure_source_row.*def\s+species.*def\s+name.*MessageTypes::Kinds.*MessageTypes::Entries.*MessageTypes::FormNames.*def\s+moveset.*def\s+egg_moves.*Data/metrics\.dat.*def\s+Type1.*def\s+BaseStats.*def\s+data.*Data/dexdata\.dat.*def\s+move_data.*Data/attacksRS\.rxdata.*def\s+egg_data.*Data/eggEmerald\.dat.*def\s+normalize_id.*PBSpecies\.const_defined\?.*def\s+wrapper_for.*def\s+get\(species\).*def\s+try_get\(species\).*def\s+exists\?\(species\).*def\s+each.*def\s+clear_cache' },
    @{ Name = "Triple Triad marshaled species-data routing"; File = "Scripts\PokemonMinigameTripleTriad.rb"; Pattern = '(?s)def\s+initialize\(species\).*PBSpeciesData\.get\(species\).*stats=speciesdata\.base_stats.*@west=baseStatToValue\(stats\[1\]\).*@east=baseStatToValue\(stats\[2\]\).*@north=baseStatToValue\(stats\[4\]\).*@south=baseStatToValue\(stats\[5\]\).*@type=speciesdata\.type1.*type2=speciesdata\.type2' },
    @{ Name = "Typed cached global and map metadata registries"; File = "Scripts\PokemonMap.rb"; Pattern = '(?s)class\s+PBPlayerMetadataData.*attr_reader\s+:id,:trainer_type,:walk_charset.*class\s+PBGlobalMetadataData.*attr_reader\s+:home,:wild_battle_bgm,:trainer_battle_bgm.*@players=profiles\.freeze.*def\s+player.*def\s+get.*@azure_source_row.*def\s+clear_cache.*class\s+PBMapMetadataData.*attr_reader\s+:map_id,:outdoor,:show_area,:bicycle,:bicycle_always.*attr_reader\s+:healing_spot,:weather,:map_position,:dive_map,:dark_map.*def\s+Outdoor.*def\s+MapPosition.*def\s+data.*pbLoadMetadata.*def\s+normalize_id.*def\s+wrapper_for.*def\s+get\(mapid\).*def\s+try_get\(mapid\).*def\s+exists\?\(mapid\).*def\s+each.*def\s+clear_cache.*def\s+pbInvalidateMetadataData.*AzureDataCache\.clear\("Data/metadata\.dat"\).*def\s+pbLoadMetadata.*pbCachedData\("Data/metadata\.dat"\)' },
    @{ Name = "Cached town-map runtime with isolated editor data"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)def\s+pbLoadTownMapData.*pbCachedData\("Data/townmap\.dat"\)' },
    @{ Name = "Cached town-map consumer routing"; File = "Scripts\PokemonRegionMap.rb"; Pattern = '(?s)if\s+aseditor.*pbRgssOpen\("Data/townmap\.dat".*Marshal\.load.*else.*@mapdata=pbLoadTownMapData' },
    @{ Name = "Cached habitat town-map routing"; File = "Scripts\Habitats.rb"; Pattern = '@mapdata\s*=\s*pbLoadTownMapData' },
    @{ Name = "Cached Pokedex nest town-map routing"; File = "Scripts\PokemonNestAndForm.rb"; Pattern = '@mapdata\s*=\s*pbLoadTownMapData' },
    @{ Name = "Split metadata editor serialization"; File = "Scripts\PokemonEditor.rb"; Pattern = '(?s)class\s+AzurePBSStringWriter.*def\s+pbMetadataCsvString.*pbWriteCsvRecord.*def\s+pbSerializeSplitMetadataPBS.*WildVictoryBGM.*TrainerType.*LegacyPlayerSlot.*PokemonMetadata::NonGlobalTypes.*pbAltPBSWriteText\("PBS/metadata\.txt".*pbAltPBSWriteText\("PBS/map_metadata\.txt".*def\s+pbSerializeMetadata.*pbUsesSplitMetadataPBS.*pbSerializeSplitMetadataPBS.*save_data\(metadata,"Data/metadata\.dat"\).*pbInvalidateMetadataData\(metadata\)' },
    @{ Name = "Typed cached immutable encounter registry"; File = "Scripts\PokemonEncounters.rb"; Pattern = '(?s)class\s+PBEncounterSlotData.*attr_reader\s+:slot,:species,:min_level,:max_level,:weight.*class\s+PBEncounterTypeData.*attr_reader\s+:id,:name,:density,:encounters,:slots,:chances.*class\s+PBEncounterData.*attr_reader\s+:map_id,:densities,:encounters,:encounter_types.*def\s+get\(type\).*def\s+try_get\(type\).*def\s+exists\?\(type\).*def\s+each.*def\s+Land.*def\s+WaterNight.*def\s+data.*pbCachedData\("Data/encounters\.dat"\).*def\s+normalize_type.*EncounterTypes::Names.*def\s+immutable_encounters.*clone\.freeze.*def\s+get\(mapid\).*def\s+try_get\(mapid\).*def\s+exists\?\(mapid\).*def\s+clear_cache.*def\s+pbInvalidateEncounterData.*AzureDataCache\.clear\("Data/encounters\.dat"\)' },
    @{ Name = "Encounter adapter routing and allocation-safe per-roll isolation"; File = "Scripts\PokemonEncounters.rb"; Pattern = '(?s)EnctypeChanceTotals=EnctypeChances\.map.*def\s+setup\(mapID\).*PBEncounterData\.try_get\(mapID\).*@density=data\.densities.*@enctypes=data\.encounters.*def\s+pbMapHasEncounter\?.*PBEncounterData\.try_get.*data\.has_type\?.*def\s+pbMapEncounter.*PBEncounterData\.try_get.*enctypes=data\.encounters.*chancetotal=EncounterTypes::EnctypeChanceTotals\[enctype\].*def\s+pbEncounteredPokemon.*basechances=EncounterTypes::EnctypeChances\[enctype\].*chances=basechances.*chances=basechances\.clone.*aArr\s*=\s*nil.*aArr\s*=\s*\[\].*chances\.equal\?\(basechances\).*minlevel=encounter\[1\].*minlevel\s*\+=\s*\(encounter\[2\]\s*-\s*minlevel\)\s*/\s*2.*level=minlevel\+rand' },
    @{ Name = "Signature-aware cached binary species auxiliaries"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)def\s+self\.fetch\(path\).*entry\s*&&\s*\(!defined\?\(\$DEBUG\)\s*\|\|\s*!\$DEBUG\).*signature=file_signature\(path\).*data=yield\(path\).*module\s+AzureEvolutionDataCache.*EVOTYPEMASK.*Data/evolutions\.dat.*def\s+self\.parse.*entries\.push.*EVODATAMASK.*def\s+self\.forward.*def\s+self\.previous_record.*module\s+AzureRegionalDexCache.*Data/regionals\.dat.*def\s+self\.parse.*:num_regions.*reverse\[number\]=species\s+if\s+number!=0\s+&&\s+reverse\[number\]\.nil\?.*def\s+self\.regional_number.*def\s+self\.national_number.*def\s+self\.all_species' },
    @{ Name = "Cached evolution and regional-dex helper routing"; File = "Scripts\PokemonEvolutionHelper.rb"; Pattern = '(?s)def\s+pbGetEvolvedFormData.*MultipleForms\.call\("getEvo",pokemon\).*AzureEvolutionDataCache\.forward\(species\).*record\.clone.*def\s+pbGetPreviousForm.*AzureEvolutionDataCache\.previous_record.*def\s+pbGetMinimumLevel.*AzureEvolutionDataCache\.records.*PBEvolution::Level.*def\s+pbGetBabySpecies.*AzureEvolutionDataCache\.previous_record.*pbGetBabySpecies\(ret\).*def\s+pbGetLessBabySpecies.*AzureEvolutionDataCache\.previous_record' },
    @{ Name = "Typed cached trainer-type registry"; File = "Scripts\PokeBattle_Trainer.rb"; Pattern = '(?s)class\s+PBTrainerTypeData.*attr_reader\s+:id,:internal_name,:raw_name,:base_money.*attr_reader\s+:battle_bgm,:victory_bgm,:intro_bgm,:gender,:skill_level.*def\s+data.*pbCachedData\("Data/trainertypes\.dat"\).*def\s+normalize_id.*PBTrainers\.const_defined\?.*def\s+new\(trainertype\).*@azure_source_id.*@azure_source_row.*def\s+get\(trainertype\).*def\s+try_get\(trainertype\).*def\s+exists\?\(trainertype\).*def\s+each.*def\s+clear_cache.*class\s+PokeBattle_Trainer.*def\s+moneyEarned.*PBTrainerTypeData\.try_get.*def\s+skill.*PBTrainerTypeData\.try_get.*def\s+gender.*PBTrainerTypeData\.try_get' },
    @{ Name = "Trainer-type helper registry routing"; File = "Scripts\PokemonUtilities.rb"; Pattern = '(?s)def\s+pbGetTrainerTypeGender.*PBTrainerTypeData\.try_get.*def\s+pbPlayTrainerIntroME.*data\.intro_bgm.*def\s+pbGetTrainerBattleBGM.*data\.battle_bgm.*def\s+pbGetTrainerBattleBGMFromType.*data\.battle_bgm.*def\s+pbGetTrainerVictoryME.*data\.victory_bgm' },
    @{ Name = "Read-only cached battle-facility lists"; File = "Scripts\PokemonOrgBattle.rb"; Pattern = '(?s)def\s+pbInvalidateBTTrainerLists.*AzureDataCache\.clear\("Data/trainerlists\.dat"\).*def\s+pbLoadBTTrainerLists\(mutable=false\).*load_data\("Data/trainerlists\.dat"\).*if\s+mutable.*pbCachedData\("Data/trainerlists\.dat"\).*def\s+pbGetBTTrainers\(challengeID,mutable=false\).*pbLoadBTTrainerLists\(mutable\).*def\s+pbGetBTPokemon\(challengeID,mutable=false\)' },
    @{ Name = "Mutable battle-facility generator isolation"; File = "Scripts\PokemonOrgBattleGenerator.rb"; Pattern = '(?s)def\s+pbTrainerInfo.*independent mutable load.*pbGetBTTrainers\(trfile,true\).*save_data\(trlists,"Data/trainerlists\.dat"\).*pbInvalidateBTTrainerLists.*def\s+pbWriteCup.*save_data\(trlists,"Data/trainerlists\.dat"\).*pbInvalidateBTTrainerLists' },
    @{ Name = "Battle-facility Trainer schema reader"; File = "Scripts\Compiler.rb"; Pattern = 'def\s+pbReadBTTrainerSource\(filename\)' },
    @{ Name = "Battle-facility Pokemon schema reader"; File = "Scripts\Compiler.rb"; Pattern = 'def\s+pbReadBTPokemonSource\(filename\)' },
    @{ Name = "Source-aware battle-facility list validation"; File = "Scripts\Compiler.rb"; Pattern = 'def\s+pbValidateTrainerLists\(sourceFile="PBS/trainerlists\.txt",sourceDir=nil\)' },
    @{ Name = "Isolated battle-facility compiler"; File = "Scripts\Compiler.rb"; Pattern = 'def\s+pbCompileTrainerLists\(dataOutput="Data/trainerlists\.dat",installRuntime=true,' },
    @{ Name = "Isolated battle-facility PBS serializer"; File = "Scripts\PokemonEditor.rb"; Pattern = 'def\s+pbSaveTrainerLists\(sourceOutput="PBS/trainerlists\.txt",' },
    @{ Name = "Dependency-aware battle-facility compilation"; File = "Scripts\Compiler.rb"; Pattern = ':id=>:battle_facility,' },
    @{ Name = "Recoverable battle-facility source-file tracking"; File = "Scripts\Compiler.rb"; Pattern = 'def\s+pbAzurePBSTrackedFiles\(sourceDir="PBS"\)' },
    @{ Name = "Keyed cached trainer data registry"; File = "Scripts\PokemonTrainers.rb"; Pattern = '(?s)module\s+AzureTrainerDataCache.*def\s+self\.sync.*if\s+!@index\.has_key\?\(key\).*@index\[key\]=trainer.*def\s+self\.record.*def\s+self\.replace.*def\s+self\.clear.*trainer=AzureTrainerDataCache\.record' },
    @{ Name = "Typed keyed trainer TeamData adapters"; File = "Scripts\PokemonTrainers.rb"; Pattern = '(?s)class\s+PBTrainerPokemonData.*attr_reader\s+:species,:level,:item,:moves,:ability,:gender,:form,:shiny.*@evs=.*freeze.*@offsets=.*freeze.*class\s+PBTrainerTeamData.*attr_reader\s+:index,:name,:trainer_type,:party_id,:items,:party.*PBTrainerPokemonData\.new.*def\s+trainerType.*def\s+partyID.*def\s+teamid.*module\s+AzureTrainerDataCache.*@positions=.*@teams=.*def\s+self\.team.*PBTrainerTeamData\.new.*def\s+self\.exists\?.*def\s+self\.free_party_id.*def\s+self\.each_team' },
    @{ Name = "Mutable keyed trainer editor with legacy-array commits"; File = "Scripts\PokemonTrainers.rb"; Pattern = '(?s)class\s+AzureTrainerTeamEditorData.*attr_reader\s+:records.*load_data\("Data/trainers\.dat"\).*def\s+key_for.*def\s+rebuild.*@index\[key\]=index\s+if\s+!@index\.has_key\?\(key\).*def\s+index_for.*def\s+free_party_id.*def\s+conflicting_index.*def\s+add.*def\s+replace_at.*def\s+delete_at.*def\s+commit.*save_data\(@records,"Data/trainers\.dat"\).*AzureTrainerDataCache\.replace\(@records\).*def\s+pbNewTrainer\(trainerid,trainername,trainerparty,editorData=nil\).*editorData\.conflicting_index.*editorData\.commit.*def\s+pbGetFreeTrainerParty\(trainerid,trainername,editorData=nil\).*AzureTrainerDataCache\.free_party_id' },
    @{ Name = "Trainer battle editor keyed collection routing"; File = "Scripts\PokemonEditor.rb"; Pattern = '(?s)def\s+pbSaveTrainerBattles\(data=nil\).*class\s+TrainerBattleLister.*def\s+initialize\(selection,includeNew,editorData=nil\).*@trainers=@editorData\.records.*def\s+pbTrainerBattleEditor.*editorData=AzureTrainerTeamEditorData\.load.*editorData\.each.*TrainerBattleLister\.new\(selection,true,editorData\).*editorData\.delete_at.*pbGetFreeTrainerParty\(trainertype,trainername,editorData\).*pbNewTrainer\(trainertype,trainername,trainerparty,editorData\).*editorData\.conflicting_index\(trainerdata,index\).*editorData\.replace_at.*editorData\.commit' },
    @{ Name = "Schema-driven trainer compiler validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.error.*FileLineData\.linereport.*def\s+self\.required.*def\s+self\.integer.*def\s+self\.count.*def\s+self\.known_property.*def\s+self\.unique.*def\s+pbCompileTrainers.*trainerKeys=\{\}.*Incomplete trainer record.*AzurePBSValidation\.required\(name,"Trainer name"\).*AzurePBSValidation\.integer\(nameline\[1\],"Trainer party ID",0,255\).*AzurePBSValidation\.unique\(trainerKeys,trainerKey,"trainer team".*AzurePBSValidation\.integer\(items\[0\],"Trainer party size",1,6\).*at most 8 battle items.*def\s+pbAltPBSBuildLegacyTrainerLines.*AzurePBSValidation\.count\(trainer\[:pokemon\],"Trainer Pokemon list",1,6\).*AzurePBSValidation\.count\(headerParts,"Trainer section header",2,3\).*AzurePBSValidation\.known_property\(key,.*Trainer Pokemon.*Trainer Pokemon move list.*AzurePBSValidation\.known_property\(key,\["Items","LoseText","LegacyTrainerTypeID"\],"Trainer"\)' },
    @{ Name = "Schema-driven encounter compiler validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.encounter_type.*must contain exactly.*def\s+self\.encounter_map.*hasLand.*def\s+pbCompileEncounters.*pbIsSectionedPBSFile\("PBS/encounters\.txt"\).*FileLineData\.file="PBS/encounters\.txt".*mapKeys=\{\}.*AzurePBSValidation\.unique\(mapKeys,mapid,"encounter map".*typeKeys=\{\}.*AzurePBSValidation\.unique\(typeKeys,lastenctype.*does not support a density value.*Encounter minimum level.*more than its required.*AzurePBSValidation\.encounter_map\(thisenc,currentMapID\).*mapKeys=\{\}.*AzurePBSValidation\.unique\(mapKeys,lastmapid,"encounter map".*AzurePBSValidation\.unique\(typeKeys,enc.*AzurePBSValidation\.count\(splitarr,"Encounter slot",2,3\).*AzurePBSValidation\.count\(nums,"Encounter density list",3,3\).*AzurePBSValidation\.encounter_map\(thisenc,lastmapid\)' },
    @{ Name = "Isolated encounter compiler output"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileEncounters\(outputFile="Data/encounters\.dat",installRuntime=true\).*save_data\(encounters,outputFile\).*pbInvalidateEncounterData\s+if\s+installRuntime.*return\s+encounters.*save_data\(encounters,outputFile\).*pbInvalidateEncounterData\s+if\s+installRuntime.*return\s+encounters' },
    @{ Name = "Schema-driven split metadata validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.source.*FileLineData\.setLine.*def\s+self\.section_id.*def\s+self\.properties.*allow_legacy.*def\s+pbCompileMetadata.*pbUsesSplitMetadataPBS.*globalSectionKeys=\{\}.*requiredPlayerProperties=.*AzurePBSValidation\.section_id\(section,"Metadata section ID",0,25\).*AzurePBSValidation\.unique\(globalSectionKeys.*AzurePBSValidation\.properties\(section,allowedProperties.*AzurePBSValidation\.required\(data\[key\].*LegacyPlayerSlot.*does not match metadata section.*mapSectionKeys=\{\}.*AzurePBSValidation\.section_id\(section,"Map metadata section ID",1,999\).*AzurePBSValidation\.unique\(mapSectionKeys.*AzurePBSValidation\.properties\(section,mapKeyMap\.keys\+\["Name"\].*def\s+pbAltPBSParseLegacySections.*:lineno=>rawline\[0\].*current\[:fields\]\.push\(\[\$~\[1\],\$~\[2\],rawline\[0\]\]\).*Bad line syntax' },
    @{ Name = "Isolated metadata compiler output"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileMetadata\(outputFile="Data/metadata\.dat",installRuntime=true\).*File\.open\(outputFile,"wb"\).*pbInvalidateMetadataData\s+if\s+installRuntime.*return\s+sections.*File\.open\(outputFile,"wb"\).*pbInvalidateMetadataData\s+if\s+installRuntime.*return\s+sections' },
    @{ Name = "Schema-driven town-map validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileTownMap\(dataOutput="Data/townmap\.dat",installRuntime=true,\s*messagesOutput=nil\).*pbAltPBSParseLegacySections\("PBS/townmap\.txt"\).*AzurePBSValidation\.section_id\(section,"Town map region ID",0,999\).*AzurePBSValidation\.unique\(regionKeys.*AzurePBSValidation\.known_property\(settingname,nonglobaltypes\.keys,"town map"\).*settingname!="Point".*AzurePBSValidation\.unique\(propertyKeys.*healingCount!=0\s*&&\s*healingCount!=3.*Name in town map region.*Filename in town map region' },
    @{ Name = "Isolated town-map compiler outputs"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileTownMap\(dataOutput="Data/townmap\.dat",installRuntime=true,\s*messagesOutput=nil\).*File\.open\(dataOutput,"wb"\).*if\s+installRuntime.*MessageTypes\.setMessages\(MessageTypes::RegionNames,rgnnames\).*MessageTypes\.setMessagesAsHash\(MessageTypes::PlaceNames,placenames\).*MessageTypes\.setMessagesAsHash\(MessageTypes::PlaceDescriptions,placedescs\).*AzureDataCache\.clear\("Data/townmap\.dat"\).*if\s+messagesOutput.*messages\[MessageTypes::RegionNames\]=normalizedRegionNames.*Messages\.createHash\(MessageTypes::PlaceNames,placenames\).*Messages\.createHash\(MessageTypes::PlaceDescriptions,placedescs\).*File\.open\(messagesOutput,"wb"\).*return\s+\{:sections=>sections' },
    @{ Name = "Schema-driven dual-format map connections"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbConnectionPoint.*AzurePBSValidation\.count\(values,label,2,2\).*def\s+pbReadConnectionRecords\(sourceFile="PBS/connections\.txt"\).*pbIsSectionedPBSFile\(sourceFile\).*allowed=\["Map1","Map1Point","Map2","Map2Point"\].*pbConnectionRecordKey.*pbCompilerEachPreppedLine\(sourceFile\)' },
    @{ Name = "Isolated connection compiler and named exporter"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileConnections\(dataOutput="Data/connections\.dat",installRuntime=true,\s*sourceFile="PBS/connections\.txt"\).*save_data\(records,dataOutput\).*AzureDataCache\.clear\("Data/connections\.dat"\).*MapFactoryHelper\.clear.*return\s+records.*def\s+pbExportAltConnectionsPBS.*pbAltPBSAppendSection.*pbExportAltConnectionsPBS\(outputDir,sourceDir\)' },
    @{ Name = "Cached immutable connection source"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)def\s+pbLoadConnectionData.*pbCachedData\("Data/connections\.dat"\)' },
    @{ Name = "Indexed map-connection runtime routing"; File = "Scripts\PokemonMap.rb"; Pattern = '(?s)@@ConnectionsByMap=nil.*def\s+self\.clear.*@@ConnectionsByMap=nil.*def\s+self\.getMapConnections.*source=pbLoadConnectionData.*sourceConnection\.clone.*@@ConnectionsByMap\[conn\[0\]\].*def\s+self\.connectionsForMap.*def\s+self\.hasConnections\?.*connectionsForMap' },
    @{ Name = "Correct cross-map relative positions"; File = "Scripts\PokemonMap.rb"; Pattern = '(?s)def\s+getRelativePos\(thisMapID,thisX,thisY,otherMapID,otherX,otherY\).*conn\[0\]==thisMapID\s*&&\s*conn\[3\]==otherMapID.*posX=conn\[1\]-conn\[4\]\+otherX-thisX.*posY=conn\[2\]-conn\[5\]\+otherY-thisY.*conn\[3\]==thisMapID\s*&&\s*conn\[0\]==otherMapID.*posX=conn\[4\]-conn\[1\]\+otherX-thisX.*posY=conn\[5\]-conn\[2\]\+otherY-thisY' },
    @{ Name = "Named connection editor with cache invalidation"; File = "Scripts\PokemonEditor.rb"; Pattern = '(?s)def\s+pbSerializeConnectionData.*Map connections use named sections.*\[Connection_%03d\].*Map1Point.*Map2Point.*save_data\(conndata,"Data/connections\.dat"\).*AzureDataCache\.clear\("Data/connections\.dat"\).*MapFactoryHelper\.clear' },
    @{ Name = "Schema-driven isolated phone compiler"; File = "Scripts\Compiler.rb"; Pattern = '(?s)AZURE_PHONE_SECTIONS=.*<Generics>.*<BattleRequests>.*<GreetingsMorning>.*<GreetingsEvening>.*<Greetings>.*<Bodies1>.*<Bodies2>.*def\s+pbValidatePhoneSections.*known_property\(name,allowed\.keys,"phone section"\).*unique\(sectionKeys,name,"phone section".*must contain at least one message.*def\s+pbMergePhoneMessageHash.*hash\[key\]=message\s+if\s+!hash\[key\]\s*\|\|\s*hash\[key\]!=message.*def\s+pbCompilePhoneData\(dataOutput="Data/phone\.dat",installRuntime=true,\s*messagesOutput=nil,sourceFile="PBS/phone\.txt"\).*save_data\(database,dataOutput\).*MessageTypes\.addMessagesAsHash\(MessageTypes::PhoneMessages,messages\)\s+if\s+!runtimeCurrent.*pbInvalidatePhoneData\(database\).*pbMergePhoneMessageHash.*File\.open\(messagesOutput,"wb"\).*return\s+\{:database=>database,:messages=>messages' },
    @{ Name = "Cached phone runtime with explicit invalidation"; File = "Scripts\PokemonMap.rb"; Pattern = '(?s)def\s+pbInvalidatePhoneData\(replacement=nil\).*AzureDataCache\.clear\("Data/phone\.dat"\).*pokemonPhoneData=replacement.*def\s+pbLoadPhoneData.*pokemonPhoneData=pbLoadPhoneDataFile' },
    @{ Name = "Cached phone data file routing"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)def\s+pbLoadPhoneDataFile.*pbCachedData\("Data/phone\.dat"\)' },
    @{ Name = "Isolated phone PBS serializer"; File = "Scripts\PokemonEditor.rb"; Pattern = '(?s)def\s+pbSavePhoneData\(sourceOutput="PBS/phone\.txt",dataInput="Data/phone\.dat"\).*load_data\(dataInput\).*File\.open\(sourceOutput,"wb"\).*<Generics>.*<BattleRequests>.*<GreetingsMorning>.*<GreetingsEvening>.*<Greetings>.*<Bodies1>.*<Bodies2>.*return\s+data' },
    @{ Name = "Ruby-version-safe section BOM handling"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbEachSection\(f\).*line\.respond_to\?\(:getbyte\).*line\.getbyte\(0\)==0xEF.*line\.getbyte\(1\)==0xBB.*line\.getbyte\(2\)==0xBF.*line\.respond_to\?\(:byteslice\).*line\.byteslice\(3,line\.bytesize-3\)' },
    @{ Name = "Schema-driven dual-format item validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.item.*Item symbol.*pbPocketNames\.length-1.*Item field use.*0,5.*Item battle use.*0,4.*Item type.*0,13,true.*Machine move.*def\s+pbCompileItems.*pbIsSectionedPBSFile\("PBS/items\.txt"\).*AzurePBSValidation\.properties\(section,allowedFields.*AzurePBSValidation\.item\(row,_INTL\("section.*Item row contains more than 10 CSV fields.*AzurePBSValidation\.item\(row,_INTL\("line.*pbValidateAzureLegacyDuplicates\(:items' },
    @{ Name = "Isolated item compiler outputs"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileItems\(dataOutput="Data/pokmanitems\.rxdata",\s*scriptOutput="Scripts/PBItems\.rb",installRuntime=true,\s*messagesOutput=nil\).*File\.open\(dataOutput,"wb"\).*if\s+installRuntime.*MessageTypes\.setMessages\(MessageTypes::Items,itemnames\).*if\s+messagesOutput.*messages\[MessageTypes::Items\]=normalizedNames.*File\.open\(messagesOutput,"wb"\).*if\s+scriptOutput.*File\.open\(scriptOutput,"w"\).*Graphics\.update\s+if\s+installRuntime' },
    @{ Name = "Schema-driven dual-format ability validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.constant_symbol.*def\s+self\.ability.*Legacy ability ID.*Ability symbol.*Ability name.*Ability description.*def\s+pbCompileAbilities.*allowedFields=\["LegacyAbilityID","Name","Description"\].*AzurePBSValidation\.properties\(section,allowedFields.*Ability section.*is missing.*AzurePBSValidation\.ability.*Ability row contains more than 4 CSV fields.*pbValidateAzureLegacyDuplicates\(:abilities' },
    @{ Name = "Isolated ability compiler outputs"; File = "Scripts\Compiler.rb"; Pattern = '(?s)AZURE_LEGACY_ABILITY_ALIASES=.*SPIRITED.*SNOWVEIL.*MAJESTY.*def\s+pbCompileAbilities\(scriptOutput="Scripts/PBAbilities\.rb",\s*installRuntime=true,messagesOutput=nil\).*MessageTypes\.setMessages\(MessageTypes::Abilities,movenames\).*if\s+messagesOutput.*messages\[MessageTypes::Abilities\]=normalizedNames.*messages\[MessageTypes::AbilityDescs\]=normalizedDescriptions.*File\.open\(messagesOutput,"wb"\).*for\s+abilityAlias\s+in\s+AZURE_LEGACY_ABILITY_ALIASES.*eval\(code\)\s+if\s+installRuntime.*File\.open\(scriptOutput,"w"\).*PBAbilityData\.clear_cache\s+if\s+installRuntime.*return\s+\{:records=>records,:code=>code' },
    @{ Name = "Schema-driven dual-format trainer-type validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.trainer_type.*Legacy trainer type ID.*Base money.*0,255,true.*genderValues=.*Unknown trainer gender.*Skill level.*def\s+pbCompileTrainers.*allowedFields=\["LegacyTrainerTypeID","Name","BaseMoney","BattleBGM".*AzurePBSValidation\.properties\(section,allowedFields.*Trainer type section.*is missing.*AzurePBSValidation\.trainer_type\(raw.*Trainer type row contains more than 9 CSV fields.*AzurePBSValidation\.trainer_type\(record.*pbValidateAzureLegacyDuplicates\(:trainer_types' },
    @{ Name = "Case-preserving trainer type constants"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+self\.ruby_constant_symbol.*\^\[A-Z\]\[A-Za-z0-9_\]\*\$.*def\s+self\.trainer_type.*POKEMONTRAINER_Troy.*ruby_constant_symbol\(row\[1\].*Trainer type symbol' },
    @{ Name = "Isolated trainer compiler outputs"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileTrainers\(outputFiles=nil,installRuntime=true,messagesOutput=nil\).*trainerTypesOutput=outputFiles\[:trainer_types\].*trainersOutput=outputFiles\[:trainers\].*scriptOutput=outputFiles\[:trainer_script\].*trainerTypeNames=trainernames\.clone.*MessageTypes\.setMessages\(MessageTypes::TrainerTypes,trainerTypeNames\)\s+if\s+installRuntime.*eval\(code\)\s+if\s+installRuntime.*File\.open\(trainerTypesOutput.*MessageTypes\.setMessagesAsHash\(MessageTypes::TrainerNames,trainernames\)\s+if\s+installRuntime.*messages\[MessageTypes::TrainerTypes\]=normalizedTrainerTypes.*Messages\.createHash\(MessageTypes::TrainerNames,trainernames\).*save_data\(trainers,trainersOutput\).*PBTrainerTypeData\.clear_cache.*AzureTrainerDataCache\.replace\(trainers\).*return\s+\{:trainer_types=>records' },
    @{ Name = "Schema-driven dual-format move validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.move_number.*decimal or hexadecimal integer.*def\s+self\.move_flags.*DOUBLEKICK.*def\s+self\.move\(row,label,section=nil\).*Legacy move ID.*Move symbol.*Unknown move category.*Status moves must have a base damage of 0.*def\s+pbCompileMoves.*allowedFields=\["LegacyMoveID","Name","Type","Category","Power","Accuracy".*exactly one of LegacyFunctionCode or FunctionCode.*exactly one of LegacyTarget or Target.*must not define both LegacyFlags and Flags.*AzurePBSValidation\.move\(raw,label,section\).*Move row contains more than 14 CSV fields.*AzurePBSValidation\.move\(record,_INTL\("line.*pbValidateAzureLegacyDuplicates\(:moves' },
    @{ Name = "Isolated move compiler outputs"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileMoves\(dataOutput="Data/moves\.dat",scriptOutput="Scripts/PBMoves\.rb",\s*installRuntime=true,messagesOutput=nil\).*\$pkmn_move\s*=\s*movedata\s+if\s+installRuntime.*File\.open\(dataOutput,"wb"\).*MessageTypes\.setMessages\(MessageTypes::Moves,movenames\).*if\s+messagesOutput.*messages\[MessageTypes::Moves\]=normalizedNames.*messages\[MessageTypes::MoveDescriptions\]=normalizedDescriptions.*File\.open\(messagesOutput,"wb"\).*eval\(code\)\s+if\s+installRuntime.*File\.open\(scriptOutput,"w"\).*PBMoveData\.clear_cache.*AzureDataCache\.clear\("Data/moves\.dat"\).*return\s+\{:records=>records,:movedata=>movedata' },
    @{ Name = "Schema-driven type chart validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.boolean.*true, false, 1, 0, yes, or no.*def\s+self\.constant_list.*contains an empty entry.*contains duplicate value.*def\s+self\.type\(section\).*IsPseudoType.*IsSpecialType.*Type ID",0,255.*appears in both.*def\s+pbCompileTypes.*typeIDs=\{\}.*typeSymbols=\{\}.*pbAltPBSParseLegacySections\("PBS/types\.txt"\).*AzurePBSValidation\.type\(section\).*AzurePBSValidation\.unique\(typeIDs.*AzurePBSValidation\.unique\(typeSymbols.*AzurePBSValidation\.source\(typeSections.*not a defined type.*save_data\(\[pseudotypes,specialtypes,typechart\],dataOutput\)' },
    @{ Name = "Isolated type compiler outputs"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileTypes\(dataOutput="Data/types\.dat",scriptOutput="Scripts/PBTypes\.rb",\s*installRuntime=true,messagesOutput=nil\).*MessageTypes\.setMessages\(MessageTypes::Types,typenames\)\s+if\s+installRuntime.*if\s+messagesOutput.*messages\[MessageTypes::Types\]=normalizedNames.*File\.open\(messagesOutput,"wb"\).*eval\(code\)\s+if\s+installRuntime.*save_data\(\[pseudotypes,specialtypes,typechart\],dataOutput\).*File\.open\(scriptOutput,"w"\).*PBTypes\.class_variable_set\(:@@TypeData,nil\).*PBTypeData\.clear_cache.*return\s+\{:types=>types,:pseudotypes=>pseudotypes' },
    @{ Name = "Schema-driven named Pokémon validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.csv_values.*trailing empty CSV entry.*def\s+self\.property_value.*conflicting aliases.*def\s+self\.decimal.*def\s+self\.pokemon_section\(section\).*LegacySpeciesID.*LegacyFormName.*Legacytoobig.*Legacy species ID.*1,65535.*either Types or the legacy Type1/Type2.*Base stats.*1,255.*Hidden abilities.*1,1.*level/move pairs.*species/method/parameter triples.*EV yield.*Regional numbers.*def\s+self\.pokemon_metrics.*-32768,32767,true.*def\s+pbCompilePokemonData.*pbValidateAzureLegacyDuplicates\(:pokemon.*save_data\(metrics,metricsOutput\).*File\.open\(regionalsOutput.*File\.open\(evolutionsOutput.*File\.open\(dexdataOutput.*File\.open\(eggmovesOutput.*File\.open\(movesOutput.*def\s+pbAltPBSReadRegionalDexMap\(filename,speciesCounts=nil\).*Regional dex.*references undefined Pokemon.*def\s+pbAltPBSReadMetricsMap\(filename,speciesCounts=nil\).*has no matching Pokemon section.*def\s+pbAltPBSBuildLegacyPokemonSections.*validatedSections=.*AzurePBSValidation\.pokemon_section\(section\).*pbAltPBSReadMetricsMap\(metricsFile,speciesCounts\).*pbAltPBSReadRegionalDexMap\(regionalDexFile,speciesCounts\).*currentmap=validated\[:id\]' },
    @{ Name = "Isolated Pokémon compiler outputs"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompilePokemonData\(outputFiles=nil,installRuntime=true,messagesOutput=nil\).*metricsOutput=outputFiles\[:metrics\].*regionalsOutput=outputFiles\[:regionals\].*evolutionsOutput=outputFiles\[:evolutions\].*dexdataOutput=outputFiles\[:dexdata\].*eggmovesOutput=outputFiles\[:eggmoves\].*movesOutput=outputFiles\[:moves\].*scriptOutput=outputFiles\[:species_script\].*speciesConstants=\{\}.*speciesConstants\[value\]=currentmap.*eval\(code\)\s+if\s+installRuntime.*resolveSpecies=proc.*save_data\(metrics,metricsOutput\).*File\.open\(regionalsOutput.*File\.open\(evolutionsOutput.*File\.open\(dexdataOutput.*File\.open\(eggmovesOutput.*if\s+messagesOutput.*File\.open\(messagesOutput.*File\.open\(movesOutput.*if\s+installRuntime.*return\s+\{:dexdata=>dexdatas' },
    @{ Name = "Exact legacy Nidoran constant spellings"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+self\.constant_symbol.*legacyNidoran=\(symbol=="NIDORANfE"\s*\|\|\s*symbol=="NIDORANmA"\).*if\s+!legacyNidoran\s+&&\s+!symbol\[/\^\[A-Z\]' },
    @{ Name = "Union-preserving TM compiler validation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)module\s+AzurePBSValidation.*def\s+self\.csv_values.*trailing empty CSV entry.*def\s+self\.tm_species_list.*constant_symbol.*def\s+pbCompileMachines\(outputFile="Data/tm\.dat"\).*sectionSymbols=.*speciesSeen=.*pbAltPBSReadLines\("PBS/tm\.txt"\).*resolve to the same numeric move ID.*sections\[sectionname\]=WordArray\.new\s+if\s+!sections\[sectionname\].*AzurePBSValidation\.tm_species_list.*next\s+if\s+speciesSeen\[sectionname\]\[species\].*save_data\(sections,outputFile\).*return\s+sections' },
    @{ Name = "File-aware compiled runtime cache"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)module\s+AzureDataCache.*def\s+self\.file_signature.*File\.mtime.*File\.size.*def\s+self\.load.*Packaged/release data is immutable.*entry\s*&&\s*\(!defined\?\(\$DEBUG\)\s*\|\|\s*!\$DEBUG\).*signature=file_signature\(path\).*entry\[0\]==signature.*record_stat\(key,:hits\).*record_stat\(key,:loads\).*data=load_data\(path\).*def\s+self\.clear.*def\s+self\.stats.*def\s+self\.reset_stats.*def\s+pbCachedData.*def\s+pbCachedRxData' },
    @{ Name = "Deferred mutable battle-animation loader"; File = "Scripts\PBAnimation.rb"; Pattern = '(?s)def\s+pbLoadBattleAnimations.*defined\?\(\$pkmn_animations\).*load_data_anim\("Data/PkmnAnimations\.rxdata"\).*return\s+\$pkmn_animations' },
    @{ Name = "First-match battle-animation name index"; File = "Scripts\PBAnimation.rb"; Pattern = '(?s)module\s+AzureBattleAnimationIndex.*def\s+self\.clear.*@animations=nil.*@indices=nil.*def\s+self\.index_for\(animations,name\).*!@animations\.equal\?\(animations\).*@length!=animations\.length.*@indices\[animation\.name\]=i\s+if\s+!@indices\.has_key\?\(animation\.name\).*return\s+@indices\[name\].*def\s+pbInvalidateBattleAnimationIndex.*AzureBattleAnimationIndex\.clear.*def\s+pbFindBattleAnimationByName\(name,animations=nil\).*AzureBattleAnimationIndex\.index_for\(animations,name\)' },
    @{ Name = "Indexed common and capture animation routing"; File = "Scripts\PokeBattle_ActualScene.rb"; Pattern = '(?s)def\s+pbCommonAnimation\(animname.*animations=pbLoadBattleAnimations.*index=pbFindBattleAnimationByName\("Common:"\+animname,animations\).*return\s+if\s+!index.*pbAnimationCore\(animations\[index\].*def\s+pbThrow\(ball.*animations=pbLoadBattleAnimations.*index=pbFindBattleAnimationByName\("Common:BallBurst#\{t\}",animations\).*burst=t\s+if\s+index' },
    @{ Name = "Battle-animation editor index invalidation"; File = "Scripts\PokemonAnimEditor.rb"; Pattern = '(?s)save_data\(animation,"Data/PkmnAnimations\.rxdata"\).*\$pkmn_animations\s*=\s*animation.*pbInvalidateBattleAnimationIndex.*animationEditorMain\(animation\).*pbInvalidateBattleAnimationIndex.*save_data\(list,"Data/PkmnAnimations\.rxdata"\).*\$pkmn_animations\s*=\s*list.*pbInvalidateBattleAnimationIndex.*\$pkmn_animations\s*=\s*animations\s+if\s+count>0.*pbInvalidateBattleAnimationIndex\s+if\s+count>0' },
    @{ Name = "Battle-animation compiler index invalidation"; File = "Scripts\Compiler.rb"; Pattern = '(?s)if\s+ids\.include\?\(:animations\).*pbInvalidateBattleAnimationIndex\s+if\s+defined\?\(pbInvalidateBattleAnimationIndex\).*\$pkmn_animations=nil\s+if\s+defined\?\(\$pkmn_animations\)' },
    @{ Name = "Battle-boundary animation preload"; File = "Scripts\PokeBattle_ActualScene.rb"; Pattern = 'def\s+pbStartBattle\(battle\)\s*\r?\n\s*# Called whenever the battle begins\s*\r?\n\s*pbLoadBattleAnimations' },
    @{ Name = "Z-Move animation loader routing"; File = "Scripts\PokeBattle_ZMoves.rb"; Pattern = 'animations=pbLoadBattleAnimations' },
    @{ Name = "Deferred mutable tileset loader"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)def\s+pbLoadTilesetData.*\$data_tilesets=pbLoadRxData\("Data/Tilesets"\)\s+if\s+!\$data_tilesets.*return\s+\$data_tilesets.*def\s+pbReloadTilesetData.*\$data_tilesets=pbLoadRxData\("Data/Tilesets"\).*return\s+\$data_tilesets' },
    @{ Name = "Map-boundary tileset loading"; File = "Scripts\Game_Map_.rb"; Pattern = '(?s)def\s+setup\(map_id\).*tileset\s*=\s*pbLoadTilesetData\[@map\.tileset_id\].*Events\.onMapCreate\.trigger\(self,map_id,\s*@map,\s*tileset\)' },
    @{ Name = "Tileset refresh ownership routing"; File = "Scripts\PokemonMap.rb"; Pattern = '(?s)def\s+pbClearData.*pbReloadTilesetData.*class\s+Game_Map.*def\s+updateTileset.*tileset\s*=\s*pbLoadTilesetData\[@map\.tileset_id\]' },
    @{ Name = "Minimap tileset loading"; File = "Scripts\PerspectiveTilemap.rb"; Pattern = '(?s)def\s+getPassabilityMinimap\(mapid\).*tileset=pbLoadTilesetData\[map\.tileset_id\]' },
    @{ Name = "Deferred RPG animation loader"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)def\s+pbLoadRPGAnimations.*\$data_animations=pbLoadRxData\("Data/Animations"\)\s+if\s+!\$data_animations.*return\s+\$data_animations' },
    @{ Name = "User animation loader routing"; File = "Scripts\AnimationSprite.rb"; Pattern = 'self\.animation\(pbLoadRPGAnimations\[animID\],true\)' },
    @{ Name = "Character animation loader routing"; File = "Scripts\Sprite_Character.rb"; Pattern = 'animation\s*=\s*pbLoadRPGAnimations\[@character\.animation_id\]' },
    @{ Name = "Shadow animation loader routing"; File = "Scripts\Shadow.rb"; Pattern = 'animation\s*=\s*pbLoadRPGAnimations\[@character\.animation_id\]' },
    @{ Name = "One-shot map transfer handoff"; File = "Scripts\AzureDataCache.rb"; Pattern = '(?s)module\s+AzureMapTransferHandoff.*def\s+self\.preload\(map_id\).*clear.*@map_id=map_id.*@map=pbLoadRxData\(sprintf\("Data/Map%03d",map_id\)\).*def\s+self\.take\(map_id\).*@map\s*&&\s*@map_id==map_id.*map=@map.*clear.*return\s+map.*clear.*return\s+pbLoadRxData\(sprintf\("Data/Map%03d",map_id\)\).*def\s+self\.clear.*@map_id=nil.*@map=nil' },
    @{ Name = "Map setup transfer ownership"; File = "Scripts\Game_Map_.rb"; Pattern = '(?s)def\s+setup\(map_id\).*@map=AzureMapTransferHandoff\.take\(map_id\).*tileset\s*=\s*pbLoadTilesetData\[@map\.tileset_id\]' },
    @{ Name = "Map autofade transfer preload and clear"; File = "Scripts\Scene_Map.rb"; Pattern = '(?s)def\s+autofade\(mapid\).*map=AzureMapTransferHandoff\.preload\(mapid\).*def\s+transfer_player.*if\s+\$game_map\.map_id!=\$game_temp\.player_new_map_id.*\$MapFactory\.setup\(\$game_temp\.player_new_map_id\).*else\s+AzureMapTransferHandoff\.clear' },
    @{ Name = "Allocation-free map refresh iteration"; File = "Scripts\Game_Map_.rb"; Pattern = '(?s)def\s+refresh.*@events\.each_value\s+do\s+\|event\|.*event\.refresh.*@common_events\.each_value\s+do\s+\|common_event\|.*common_event\.refresh' },
    @{ Name = "Allocation-free map update iteration"; File = "Scripts\Game_Map_.rb"; Pattern = '(?s)def\s+update.*@events\.each_value\s+do\s+\|event\|.*event\.update.*@common_events\.each_value\s+do\s+\|common_event\|.*common_event\.update' },
    @{ Name = "Allocation-free map spriteset reconciliation"; File = "Scripts\Scene_Map.rb"; Pattern = '(?s)def\s+updateSpritesets.*@spritesets\.delete_if\s+do\s+\|map_id,spriteset\|.*if\s+!\$MapFactory\.hasMap\?\(map_id\).*spriteset\.dispose\s+if\s+spriteset.*true.*else.*spriteset\.update.*false.*for\s+map\s+in\s+\$MapFactory\.maps.*@spritesets\[map\.map_id\]=Spriteset_Map\.new\(map\)' },
    @{ Name = "Allocation-free event page scan"; File = "Scripts\Game_Event_.rb"; Pattern = '(?s)def\s+refresh.*@event\.pages\.reverse_each\s+do\s+\|page\|.*new_page\s*=\s*page.*break' },
    @{ Name = "Allocation-free connected-map collision iteration"; File = "Scripts\PokemonMap.rb"; Pattern = '(?s)def\s+isPassableStrict\?.*map\.events\.each_value\s+do\s+\|event\|.*def\s+isPassable\?.*map\.events\.each_value\s+do\s+\|event\|' },
    @{ Name = "Allocation-free sprite hash updates"; File = "Scripts\SpriteWindow.rb"; Pattern = '(?s)def\s+pbUpdateSpriteHash\(windows\)\s*windows\.each_value\s+do\s+\|window\|.*window\.respond_to\?\(:update\).*rescue\s+RGSSError' },
    @{ Name = "Allocation-free party bitmap iteration"; File = "Scripts\PokemonParty.rb"; Pattern = '(?s)class\s+ChangelingSprite.*def\s+dispose.*@bitmaps\.each_value\s+\{\|bm\|\s*bm\.dispose\}.*def\s+update.*@bitmaps\.each_value\s+\{\|bm\|\s*bm\.update\}' },
    @{ Name = "Allocation-free AI rough-stat scaling"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)AI_ROUGH_STAT_STAGE_MULTIPLIERS=\[2,2,2,2,2,2,2,3,4,5,6,7,8\]\.freeze.*AI_ROUGH_STAT_STAGE_DIVISORS=\[8,7,6,5,4,3,2,2,2,2,2,2,2\]\.freeze.*def\s+pbRoughStat\(battler,stat,skill\).*return\s+battler\.pbSpeed.*stage=battler\.stages\[stat\]\+6.*AI_ROUGH_STAT_STAGE_MULTIPLIERS\[stage\]/AI_ROUGH_STAT_STAGE_DIVISORS\[stage\]' },
    @{ Name = "Allocation-free AI rough-damage stage scaling"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)def\s+pbRoughDamage\(move,attacker,opponent,skill,basedamage,hardswitch=false\).*AI_ROUGH_STAT_STAGE_MULTIPLIERS\[gl3\]/AI_ROUGH_STAT_STAGE_DIVISORS\[gl3\].*AI_ROUGH_STAT_STAGE_MULTIPLIERS\[gl4\]/AI_ROUGH_STAT_STAGE_DIVISORS\[gl4\]' },
    @{ Name = "Canonical AI damage-move reuse"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)AI_CONTEXT_SENSITIVE_DAMAGE_MOVES=\{.*PBMoves::WEATHERBALL=>true.*PBMoves::JUDGMENT=>true.*PBMoves::MULTIATTACK=>true.*PBMoves::TECHNOBLAST=>true.*PBMoves::HIDDENPOWER=>true.*PBMoves::GILDEDARROW=>true.*PBMoves::GILDEDARROWS=>true.*PBMoves::NATUREPOWER=>true.*\}\.freeze.*def\s+pbAIDamageMoveNeedsNormalization\?\(move,attacker\).*move\.battle\.equal\?\(self\).*move\.id==PBMoves::STRUGGLE.*move\.user\.equal\?\(attacker\).*move\.basedamage!=data\[1\].*move\.type!=data\[2\].*move\.flags!=data\[9\].*move\.id==PBMoves::THOUSANDARROWS.*def\s+pbRoughDamage\(move,attacker,opponent,skill,basedamage,hardswitch=false\).*pbAIDamageMoveNeedsNormalization\?\(move,attacker\)\s*move\s*=\s*pbChangeMove\(move,attacker\)' },
    @{ Name = "Allocation-light AI cache keys and ordered foe iteration"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)def\s+each_ordered_foe_battler_for_ai\(attacker, preferred_target = nil\).*preferred\.respond_to\?\(:index\).*primary = pbAIPrimaryTarget\(attacker, preferred\).*yield primary if primary && !primary\.isFainted\?.*next if primary && foe\.index == primary\.index.*yield foe.*def\s+pbAIOrderedFoes\(attacker, preferred_target = nil\).*each_ordered_foe_battler_for_ai\(attacker, preferred_target\)\s*\{\s*\|foe\|\s*foes << foe\s*\}.*def\s+pbAIAnyOrderedFoe\?.*return true if yield foe.*def\s+pbAIAnyFoeHasMove\?.*each_ordered_foe_battler_for_ai.*def\s+pbAIAnyFoeHasWorkingAbility\?.*each_ordered_foe_battler_for_ai.*def\s+pbAIAnyFoeMoveMemoryMatches\?.*each_ordered_foe_battler_for_ai.*def\s+checkAIdamage\(memory,attacker,opponent,skill,shutup=false,movename=false,hardswitch=false\).*cacheKey=nil.*cacheKey=\(\(attacker\.index\*@battlers\.length\+opponent\.index\)\*2\)\+\s*\(hardswitch \? 1 : 0\).*@aiDamageCache\.has_key\?\(cacheKey\).*@aiDamageCache\[cacheKey\] = maxdam' },
    @{ Name = "Allocation-free AI ally query iteration"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)def\s+pbAIAllies\(attacker, include_self = false\).*each_same_side_battler_for_ai.*def\s+pbAIAnyAlly\?\(attacker, include_self = false\).*if block_given\?.*return true if yield ally.*each_same_side_battler_for_ai\(attacker, include_self\)\s*\{\s*\|ally\|\s*return true\s*\}.*def\s+pbAIFirstAlly\(attacker, preferred_index = nil, include_self = false\).*first=ally if !first.*return ally if !preferred_index\.nil\? && ally\.index==preferred_index.*def\s+pbAIAnyAllyCanKOAnyFoe\?.*each_same_side_battler_for_ai\(attacker\).*ally_target = pbAIFirstAlly\(attacker,opponent \? opponent\.index : nil\).*electric_weak = pbAIAnyAlly\?\(attacker, true\).*fire_weak = pbAIAnyAlly\?\(attacker, true\)' },
    @{ Name = "Allocation-free AI same-side membership"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)def\s+pbAISameSideBattler\?\(attacker, target, include_self = false\).*return false if !attacker \|\| !target.*eachSameSideBattler\(attacker\.index\).*next if !battler.*next if !include_self && battler\.index==attacker\.index.*return true if battler==target.*return false' },
    @{ Name = "Allocation-free AI foe speed maxima"; File = "Scripts\PokeBattle_AI.rb"; Pattern = 'if\s+!foes\.empty\?\s+&&\s+foes\.all\?\s*\{\s*\|foe\|\s*opponent\.pbSpeed\s*>\s*foe\.pbSpeed\s*\}' },
    @{ Name = "Allocation-free scalar-or-collection AI query arguments"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)def\s+pbAIAnyFoeHasMove\?\(attacker, preferred_target = nil, move_ids = nil\).*multiple=move_ids\.is_a\?\(Array\).*def\s+pbAIAnyFoeHasWorkingAbility\?\(attacker, preferred_target = nil, abilities = nil\).*multiple=abilities\.is_a\?\(Array\).*def\s+pbAIAnyFoeMoveMemoryMatches\?\(attacker, preferred_target = nil, move_ids = nil\).*multiple=move_ids\.is_a\?\(Array\).*def\s+pbAIAnyAllyHasWorkingAbility\?\(attacker, abilities\).*multiple=abilities\.is_a\?\(Array\).*def\s+pbAIAnyOtherAllyHasWorkingAbility\?\(attacker, abilities\).*multiple=abilities\.is_a\?\(Array\).*def\s+pbAIAnyReadyFoeHasMove\?\(attacker, preferred_target = nil, move_ids = nil\).*multiple=move_ids\.is_a\?\(Array\).*AI_REDIRECTION_MOVES=\[PBMoves::FOLLOWME,PBMoves::RAGEPOWDER\]\.freeze.*AI_SCREEN_BREAK_MEMORY_MOVES=\[PBMoves::BRICKBREAK,PBMoves::PSYCHICFANGS,PBMoves::DEFOG\]\.freeze.*AI_ELECTRIC_IMMUNITY_ABILITIES=.*\.freeze.*AI_ALLY_SPREAD_IMMUNITY_ABILITIES=.*\.freeze' },
    @{ Name = "Frozen AI move-query groups"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)AI_SLEEP_TALK_MOVES=\[PBMoves::SLEEPTALK,PBMoves::SNORE\]\.freeze.*AI_STAT_RESET_MOVES=\[PBMoves::CLEARSMOG,PBMoves::HAZE\]\.freeze.*AI_WEIGHT_BASED_MOVES=.*AI_HEAVY_WEIGHT_MOVES=.*AI_HEATED_FIELD_MOVES=.*AI_GROUND_SPREAD_MOVES=.*AI_SOUND_SPREAD_MOVES=.*AI_RAIN_ACCURATE_MOVES=.*AI_SLEEP_PUNISH_MOVES=.*AI_ESCAPE_MOVES=.*AI_HAZARD_CONTROL_MOVES=.*AI_BERRY_DESTROY_MOVES=.*AI_ITEM_STEAL_MOVES=.*AI_COMMON_STATUS_MOVES=.*AI_HAZARD_CLEAR_MOVES=.*AI_SLEEP_TALK_EXTENDED_MOVES=\[PBMoves::SLEEPTALK,PBMoves::SNORE,PBMoves::HOTTEMPO\]\.freeze' },
    @{ Name = "Frozen AI static membership groups"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)AI_TERRAIN_FIELD_IDS=\[1,2,3,18,21,22,26,37\]\.freeze.*AI_SUCCESSIVE_USE_FUNCTIONS=\[0x91,0x92,0xD3,0x247\]\.freeze.*AI_CRITICAL_ABILITIES=\[PBAbilities::SUPERLUCK,PBAbilities::SNIPER\]\.freeze.*AI_PHYSICAL_STAT_DROP_FUNCTIONS=\[0x43,0x44,0x45,0x46,0x47\]\.freeze.*AI_SPECIAL_STAT_DROP_FUNCTIONS=\[0x48,0x49,0x4A,0x4B,0x4C\]\.freeze.*AI_SEMI_INVULNERABLE_FUNCTIONS=\[0xC9,0xCA,0xCB,0xCC,0xCD,0xCE\]\.freeze' },
    @{ Name = "Scalar-aware allocation-free AI move-memory predicates"; File = "Scripts\PokeBattle_AI.rb"; Pattern = '(?s)def\s+pbAIEffectiveMemoryMoveID\(move\).*move\.id==PBMoves::NATUREPOWER.*return move\.id.*def\s+checkAImoves\(moveID,memory\).*singleMove=moveID\.is_a\?\(Integer\).*for j in memory.*effective_id=pbAIEffectiveMemoryMoveID\(j\).*if singleMove.*moveID==effective_id.*else.*moveID\.include\?\(effective_id\).*def\s+checkAIaccuracy\(memory\).*j\.id==PBMoves::NATUREPOWER.*pbChangeMove\(j,nil\)\.accuracy==0.*return true if j\.accuracy==0.*def\s+checkAIHas\?\(moveID,attacker\).*singleMove=moveID\.is_a\?\(Integer\).*for j in attacker\.moves.*effective_id=pbAIEffectiveMemoryMoveID\(j\).*if singleMove.*moveID==effective_id.*else.*moveID\.include\?\(effective_id\)' },
    @{ Name = "Move availability opposing-battler binding"; File = "Scripts\PokeBattle_Battle.rb"; Pattern = '(?s)def\s+pbCanChooseMove\?\(idxPokemon,idxMove,showMessages,sleeptalk=false\).*opp1=thispkmn\.pbOpposing1\s*opp2=thispkmn\.pbOpposing2.*opp1\.effects\[PBEffects::Imprison\].*opp2\.effects\[PBEffects::Imprison\]' },
    @{ Name = "Battler-owned initialized battle moves"; File = "Scripts\PokeBattle_Battler.rb"; Pattern = '(?s)def\s+pbInitPokemon\(pkmn,pkmnIndex,wonderroom=false\).*@moves\s*=\s*\[\s*PokeBattle_Move\.pbFromPBMove\(@battle,pkmn\.moves\[0\],self\),\s*PokeBattle_Move\.pbFromPBMove\(@battle,pkmn\.moves\[1\],self\),\s*PokeBattle_Move\.pbFromPBMove\(@battle,pkmn\.moves\[2\],self\),\s*PokeBattle_Move\.pbFromPBMove\(@battle,pkmn\.moves\[3\],self\)' },
    @{ Name = "Cold-import-safe field manual mapping"; File = "Scripts\PokemonFieldEffectsManual.rb"; Pattern = '(?s)def\s+pbFieldEffectsSeen.*field_id_to_switch\s*=\s*\{.*field_id_to_switch\.each\s+do' },
    @{ Name = "Cold-import-safe trainer record indices"; File = "Scripts\PokemonTrainerIndex.rb"; Pattern = '(?s)class\s+Scene_TrainerIndex\s+.*TSPECIES\s*=\s*0.*TPBOSS\s*=\s*18.*def\s+pbFormatPokemonInfo\(poke\)' },
    @{ Name = "Outrage AI skill branch structure"; File = "Scripts\PokeBattle_AI.rb"; Pattern = 'if\s+skill>=PBTrainerAI\.highSkill\s*\r?\n\s*if\s+\$fefieldeffect==16\s+# Superheated Field\s*\r?\n\s*score\*=0\.8\s*\r?\n\s*end\s*\r?\n\s*else\s*\r?\n\s*score\s*\*=\s*1\.2' },
    @{ Name = "Dual-format named item PBS compiler"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileItems.*pbIsSectionedPBSFile\("PBS/items\.txt"\).*LegacyItemID.*FieldUse.*BattleUse.*sourceRecords.*def\s+pbExportAltItemsPBS.*pbAltPBSWriteText\(outputDir\+"/items\.txt".*pbExportAltItemsPBS\(outputDir,sourceDir\)' },
    @{ Name = "Dual-format named Shadow move PBS compiler"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileShadowMoves.*pbIsSectionedPBSFile\("PBS/shadowmoves\.txt"\).*Unknown Shadow move property.*missing Moves.*at most 4 are supported.*Preserve the original parser.*def\s+pbExportAltShadowMovesPBS.*\[\["Moves",moves\]\].*pbExportAltShadowMovesPBS\(outputDir,sourceDir\)' },
    @{ Name = "Isolated Shadow move compiler output"; File = "Scripts\Compiler.rb"; Pattern = '(?s)def\s+pbCompileShadowMoves\(outputFile="Data/shadowmoves\.dat",installRuntime=true\).*save_data\(sections,outputFile\).*AzureDataCache\.clear\("Data/shadowmoves\.dat"\)\s+if\s+installRuntime.*return\s+sections' },
    @{ Name = "Cached Shadow move assignment and fallback"; File = "Scripts\PokemonShadowPokemon.rb"; Pattern = '(?s)def\s+makeShadow.*self\.shadowmoves=\[0,0,0,0,0,0,0,0\].*moves=pbCachedData\("Data/shadowmoves\.dat"\).*moves\[self\.species\].*self\.shadowmovenum=moves\[self\.species\]\.length.*self\.shadowmoves\[0\]=getConst\(PBMoves,:SHADOWRUSH\)\|\|0.*self\.shadowmoves\[4\+i\]=self\.moves\[i\]\.id.*pbUpdateShadowMoves' },
    @{ Name = "Opt-in renderer frame skipping"; File = "Scripts\PokemonOptions.rb"; Pattern = '(?s)def\s+frameskip.*@frameskip.*def\s+frameskip=\(value\).*pbApplyFrameSkipSetting.*EnumOption\.new\(_INTL\("Frame Skip"\).*\[_INTL\("Off"\),_INTL\("On"\)\]' },
    @{ Name = "Dependency-aware incremental PBS compiler"; File = "Scripts\Compiler.rb"; Pattern = '(?s)AZURE_PBS_COMPILE_STEPS=.*:dependencies=>\[\].*def\s+pbAzurePBSCompileStepStatus.*File\.mtime\(latestSource\)>File\.mtime\(oldestOutput\).*def\s+pbPBSCompilePlan.*:reason=>:dependency.*pbCompileTrainerEvents.*belongs to Compile All Data.*def\s+pbCompileChangedData.*MessageTypes\.saveMessages.*pbRefreshAzureCompiledData' },
    @{ Name = "Explicit Compile Changed Data command"; File = "Scripts\PokemonDebug.rb"; Pattern = '(?s)commands\.add\("compilechanged",\s*_INTL\("Compile Changed Data"\)\).*elsif\s+cmd=="compilechanged".*pbPBSCompilePlan.*Maps will not be modified\. Continue\?.*pbCompileChangedData' },
    @{ Name = "Read-only PBS validation runner"; File = "Scripts\AzurePBSValidator.rb"; Pattern = '(?s)module\s+AzurePBSValidator.*AUDIT_PATH="tools/preservation/Audit-Azure\.ps1".*LOG_PATH="tools/preservation/pbs_validation\.log".*def\s+self\.run\(root=Dir\.pwd\).*IO\.popen\(command,"rb"\).*:ok=>\(exitCode==0\).*def\s+pbValidateAzureProject\(root=Dir\.pwd\)' },
    @{ Name = "Explicit Validate PBS Data command"; File = "Scripts\PokemonDebug.rb"; Pattern = '(?s)commands\.add\("validatepbs",\s*_INTL\("Validate PBS Data"\)\).*elsif\s+cmd=="validatepbs".*Validating PBS data without compiling.*pbValidateAzureProject.*result\[:ok\].*Full log' },
    @{ Name = "Recoverable named PBS authoring tools"; File = "Scripts\Compiler.rb"; Pattern = '(?s)AZURE_PBS_TRACKED_FILES=.*types\.txt.*tm\.txt.*trainerlists\.txt.*def\s+pbExportNamedPBSSnapshot.*pbExportAltPBSFiles.*def\s+pbAvailablePBSBackups.*PBS/RestoreBackup.*def\s+pbBackupCurrentPBS.*def\s+pbRestorePBSBackup.*File\.dirname\(sourceDir\).*safetyDir=pbBackupCurrentPBS.*File\.delete\(destination\).*pbLogPBSTool' },
    @{ Name = "Explicit named PBS export and restore commands"; File = "Scripts\PokemonDebug.rb"; Pattern = '(?s)commands\.add\("exportnamedpbs",\s*_INTL\("Export Named PBS Snapshot"\)\).*commands\.add\("restorepbs",\s*_INTL\("Restore PBS Backup"\)\).*elsif\s+cmd=="exportnamedpbs".*pbExportNamedPBSSnapshot.*elsif\s+cmd=="restorepbs".*pbAvailablePBSBackups.*pbConfirmMessageSerious.*pbRestorePBSBackup' },
    @{ Name = "Compiled-data cache statistics command"; File = "Scripts\PokemonDebug.rb"; Pattern = '(?s)commands\.add\("datacachestats",\s*_INTL\("Compiled Data Cache Stats"\)\).*elsif\s+cmd=="datacachestats".*AzureDataCache\.stats.*totalHits.*totalLoads.*hit rate' },
    @{ Name = "Deterministic legacy duplicate compiler policy"; File = "Scripts\Compiler.rb"; Pattern = '(?s)AZURE_LEGACY_DUPLICATE_SYMBOLS\s*=.*AZURE_LEGACY_DUPLICATE_IDS\s*=.*def\s+pbValidateAzureLegacyDuplicates.*allowedSymbols.*allowedIDs.*pbValidateAzureLegacyDuplicates\(:items.*pbValidateAzureLegacyDuplicates\(:moves.*pbValidateAzureLegacyDuplicates\(:abilities.*pbValidateAzureLegacyDuplicates\(:trainer_types.*pbValidateAzureLegacyDuplicates\(:pokemon' }
  )

  $orderPath = Resolve-ProjectPath "Scripts\!script_order.csv"
  $orderEntries = @([System.IO.File]::ReadLines($orderPath) | ForEach-Object { $_.Trim() } | Where-Object { $_ -and !$_.Contains("~blank") })
  foreach ($contract in $contracts) {
    $path = Resolve-ProjectPath $contract.File
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) {
      Add-AuditError "$($contract.Name) contract file is missing: $($contract.File)."
      continue
    }
    $content = [System.IO.File]::ReadAllText($path)
    if ($content -notmatch $contract.Pattern) {
      Add-AuditError "$($contract.Name) contract is missing expected API '$($contract.Pattern)' in $($contract.File)."
    }
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($contract.File)
    if ($orderEntries -notcontains $scriptName) {
      Add-AuditError "$($contract.Name) exists but '$scriptName' is absent from Scripts\!script_order.csv."
    }
  }
  $aiContent = [System.IO.File]::ReadAllText((Resolve-ProjectPath "Scripts\PokeBattle_AI.rb"))
  if ($aiContent -match 'checkAI(?:moves|Has\?)\(\[(?:PBMoves::[A-Z0-9_]+\s*,?\s*)+\]') {
    Add-AuditError "AI move predicates still allocate literal PBMoves query arrays."
  }
  if ($aiContent -match 'pbAIAllies\([^\r\n]*\)\.(?:any\?|empty\?|find)') {
    Add-AuditError "Single-pass AI ally queries still materialize temporary ally arrays."
  }
  $foeSpeedScans = [regex]::Matches($aiContent, 'if\s+!foes\.empty\?\s+&&\s+foes\.all\?\s*\{\s*\|foe\|\s*opponent\.pbSpeed\s*>\s*foe\.pbSpeed\s*\}')
  if ($foeSpeedScans.Count -ne 3 -or $aiContent -match 'foes\.map\s*\{\s*\|foe\|\s*foe\.pbSpeed\s*\}\.max') {
    Add-AuditError "The three AI foe-speed comparisons must use allocation-free all? scans."
  }
  $sameSideTargetScans = [regex]::Matches($aiContent, 'pbAISameSideBattler\?\(attacker,opponent\)')
  if ($sameSideTargetScans.Count -ne 19 -or $aiContent -match 'attacker\.sameSideBattlers\(false\)\.include\?\(opponent\)') {
    Add-AuditError "The 19 AI same-side target checks must use allocation-free membership scans."
  }
  $staticMembershipUseCounts = @{
    'AI_TERRAIN_FIELD_IDS\.include\?' = 1
    'AI_SUCCESSIVE_USE_FUNCTIONS\.include\?' = 1
    'AI_CRITICAL_ABILITIES\.include\?' = 2
    'AI_PHYSICAL_STAT_DROP_FUNCTIONS\.include\?' = 2
    'AI_SPECIAL_STAT_DROP_FUNCTIONS\.include\?' = 2
    'AI_SEMI_INVULNERABLE_FUNCTIONS\.include\?' = 1
  }
  foreach ($membershipPattern in $staticMembershipUseCounts.Keys) {
    $expectedCount = $staticMembershipUseCounts[$membershipPattern]
    $actualCount = [regex]::Matches($aiContent, $membershipPattern).Count
    if ($actualCount -ne $expectedCount) {
      Add-AuditError "AI static membership group '$membershipPattern' has $actualCount uses; expected $expectedCount."
    }
  }
  $staticMembershipLiterals = '\[(?:1,\s*2,\s*3,\s*18,\s*21,\s*22,\s*26,\s*37|0x91,\s*0x92,\s*0xD3,\s*0x247|PBAbilities::SUPERLUCK,\s*PBAbilities::SNIPER|0x43,\s*0x44,\s*0x45,\s*0x46,\s*0x47|0x48,\s*0x49,\s*0x4A,\s*0x4B,\s*0x4C|0xC9,\s*0xCA,\s*0xCB,\s*0xCC,\s*0xCD,\s*0xCE)\]\.include\?'
  if ($aiContent -match $staticMembershipLiterals) {
    Add-AuditError "AI scoring still rebuilds a static membership array at an evaluation site."
  }
  foreach ($deferredFile in @("Scripts\Scene_Intro.rb", "Scripts\PokemonLoad.rb")) {
    $deferredContent = [System.IO.File]::ReadAllText((Resolve-ProjectPath $deferredFile))
    if ($deferredContent -match 'PkmnAnimations\.rxdata|pbLoadBattleAnimations') {
      Add-AuditError "$deferredFile eagerly loads battle animations before the battle boundary."
    }
  }
  $mainContent = [System.IO.File]::ReadAllText((Resolve-ProjectPath "Scripts\Main.rb"))
  foreach ($deferredData in @("Tilesets", "Animations")) {
    if ($mainContent -match ('pbLoadRxData\("Data/{0}"\)' -f $deferredData)) {
      Add-AuditError "Scripts\Main.rb eagerly loads deferred Data/$deferredData before its runtime boundary."
    }
  }
  foreach ($iterationFile in @("Scripts\Game_Map_.rb", "Scripts\PokemonMap.rb")) {
    $iterationContent = [System.IO.File]::ReadAllText((Resolve-ProjectPath $iterationFile))
    if ($iterationContent -match '(?:@?events|@common_events)\.values') {
      Add-AuditError "$iterationFile reintroduced an allocating Hash#values loop in a hot map path."
    }
  }
  Add-AuditCheck "Azure feature contracts: $($contracts.Count) required systems are present and ordered for loading."
}

function Test-MoveCompatibilitySemantics {
  $relativePath = "Scripts\PokeBattle_MoveEffectCompatibility.rb"
  $path = Resolve-ProjectPath $relativePath
  if (!(Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-AuditError "Move compatibility layer is missing: $relativePath."
    return
  }
  $content = [System.IO.File]::ReadAllText($path)
  $contracts = @(
    @{ Name = "Heal Order adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_B74\s*<\s*PokeBattle_Move_29G\b' },
    @{ Name = "Razor Wind adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_B75\s*<\s*PokeBattle_Move_29H\b' },
    @{ Name = "Poison Tail adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_AF7\s*<\s*PokeBattle_Move_25Z\b' },
    @{ Name = "Snuff Out adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_27B\s*<\s*PokeBattle_Move_897\b' },
    @{ Name = "Surging Strikes hit and critical rules"; Pattern = '(?ms)^class\s+PokeBattle_Move_231\b(?:(?!^class\s).)*?include\s+AzureAlwaysCriticalMove(?:(?!^class\s).)*?def\s+pbNumHits\b(?:(?!^class\s).)*?return\s+3\b' },
    @{ Name = "Flower Trick critical rule"; Pattern = '(?ms)^class\s+PokeBattle_Move_28B\b(?:(?!^class\s).)*?include\s+AzureAlwaysCriticalMove' },
    @{ Name = "Triple Dive hit rule"; Pattern = '(?ms)^class\s+PokeBattle_Move_250\b(?:(?!^class\s).)*?def\s+pbNumHits\b(?:(?!^class\s).)*?return\s+3\b' },
    @{ Name = "Tachyon Cutter hit adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_284\s*<\s*PokeBattle_Move_0BD\b' },
    @{ Name = "Collision Course multiplier"; Pattern = '(?ms)^class\s+PokeBattle_Move_260\b(?:(?!^class\s).)*?pbTypeModifier(?:(?!^class\s).)*?4\.0/3\.0' },
    @{ Name = "Fickle Beam roll and multiplier"; Pattern = '(?ms)^class\s+PokeBattle_Move_288\b(?:(?!^class\s).)*?pbRandom\(10\)<3(?:(?!^class\s).)*?basedmg\*2' },
    @{ Name = "Make It Rain stat and payout effects"; Pattern = '(?ms)^class\s+PokeBattle_Move_271\b(?:(?!^class\s).)*?azure_make_it_rain_drop_applied(?:(?!^class\s).)*?extramoney\s*\+=(?:(?!^class\s).)*?PBStats::SPATK' },
    @{ Name = "Spin Out Speed drop"; Pattern = '(?ms)^class\s+PokeBattle_Move_254\b(?:(?!^class\s).)*?azure_spin_out_drop_applied(?:(?!^class\s).)*?pbReduceStat\(PBStats::SPEED,2\b' },
    @{ Name = "Bitter Malice Attack-drop adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_227\s*<\s*PokeBattle_Move_042\b' },
    @{ Name = "Barb Barrage poison rules"; Pattern = '(?ms)^class\s+PokeBattle_Move_226\b(?:(?!^class\s).)*?PBStatuses::POISON(?:(?!^class\s).)*?basedmg\*2(?:(?!^class\s).)*?pbPoison' },
    @{ Name = "Infernal Parade status and burn rules"; Pattern = '(?ms)^class\s+PokeBattle_Move_230\b(?:(?!^class\s).)*?opponent\.status>0(?:(?!^class\s).)*?basedmg\*2(?:(?!^class\s).)*?pbBurn' },
    @{ Name = "Victory Dance stat boosts"; Pattern = '(?ms)^class\s+PokeBattle_Move_225\b(?:(?!^class\s).)*?PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED(?:(?!^class\s).)*?pbIncreaseStat\(stat,1\b' },
    @{ Name = "Spicy Extract opposing stat changes"; Pattern = '(?ms)^class\s+PokeBattle_Move_253\b(?:(?!^class\s).)*?pbIncreaseStat\(PBStats::ATTACK,2\b(?:(?!^class\s).)*?pbReduceStat\(PBStats::DEFENSE,2\b' },
    @{ Name = "Take Heart cure and boosts"; Pattern = '(?ms)^class\s+PokeBattle_Move_233\b(?:(?!^class\s).)*?azureCureStatus(?:(?!^class\s).)*?PBStats::SPATK,PBStats::SPDEF' },
    @{ Name = "Jungle and Lunar active-ally healing"; Pattern = '(?ms)^class\s+PokeBattle_Move_232\b(?:(?!^class\s).)*?sameSideLivingBattlers\(true\)(?:(?!^class\s).)*?totalhp\+1\)/4(?:(?!^class\s).)*?azureCureStatus' },
    @{ Name = "Eerie Spell PP reduction"; Pattern = '(?ms)^class\s+PokeBattle_Move_246\b(?:(?!^class\s).)*?lastMoveUsed(?:(?!^class\s).)*?\[3,move\.pp\]\.min' },
    @{ Name = "Stone Axe hazard"; Pattern = '(?ms)^class\s+PokeBattle_Move_220\b(?:(?!^class\s).)*?azure_stone_axe_hazard_applied(?:(?!^class\s).)*?PBEffects::StealthRock' },
    @{ Name = "Ceaseless Edge hazard"; Pattern = '(?ms)^class\s+PokeBattle_Move_221\b(?:(?!^class\s).)*?azure_ceaseless_edge_hazard_applied(?:(?!^class\s).)*?PBEffects::Spikes' },
    @{ Name = "Rising Voltage terrain rule"; Pattern = '(?ms)^class\s+PokeBattle_Move_228\b(?:(?!^class\s).)*?ElectricTerrain(?:(?!^class\s).)*?basedmg\*2\s+if\s+electricterrain\s+&&\s+!opponent\.isAirborne\?' },
    @{ Name = "Expanding Force and Coaching dispatch"; Pattern = '(?ms)^class\s+PokeBattle_Move_245\b(?:(?!^class\s).)*?PBMoves::EXPANDINGFORCE(?:(?!^class\s).)*?PsychicTerrain(?:(?!^class\s).)*?PBMoves::COACHING(?:(?!^class\s).)*?pbPartner(?:(?!^class\s).)*?PBStats::ATTACK,PBStats::DEFENSE' },
    @{ Name = "Expanding Force dynamic target"; Pattern = '(?ms)^class\s+PokeBattle_Battler\b(?:(?!^class\s).)*?PBMoves::EXPANDINGFORCE(?:(?!^class\s).)*?PBTargets::AllOpposing' },
    @{ Name = "Steel Roller temporary-terrain removal"; Pattern = '(?ms)^class\s+PokeBattle_Move_235\b(?:(?!^class\s).)*?DampTerrain(?:(?!^class\s).)*?azure_steel_roller_cleared(?:(?!^class\s).)*?effects\[effect\]=0' },
    @{ Name = "Scale Shot hit and stat rules"; Pattern = '(?ms)^class\s+PokeBattle_Move_236\b(?:(?!^class\s).)*?\[2,2,3,3,4,5\](?:(?!^class\s).)*?azure_scale_shot_changes_applied(?:(?!^class\s).)*?PBStats::SPEED,1(?:(?!^class\s).)*?PBStats::DEFENSE,1' },
    @{ Name = "Misty Explosion self-faint and terrain power"; Pattern = '(?ms)^class\s+PokeBattle_Move_234\s*<\s*PokeBattle_Move_0E0\b(?:(?!^class\s).)*?MistyTerrain(?:(?!^class\s).)*?basedmg\*2' },
    @{ Name = "Grassy Glide terrain priority"; Pattern = '(?ms)^class\s+PokeBattle_Move_239\b(?:(?!^class\s).)*?def\s+priority\b(?:(?!^class\s).)*?GrassyTerrain(?:(?!^class\s).)*?pri\+=1' },
    @{ Name = "Terrain Pulse type and power rules"; Pattern = '(?ms)^class\s+PokeBattle_Move_240\b(?:(?!^class\s).)*?PBTypes::ELECTRIC(?:(?!^class\s).)*?PBTypes::GRASS(?:(?!^class\s).)*?PBTypes::FAIRY(?:(?!^class\s).)*?PBTypes::PSYCHIC(?:(?!^class\s).)*?basedmg\*2' },
    @{ Name = "Lash Out stat-lowered multiplier"; Pattern = '(?ms)^class\s+PokeBattle_Move_242\b(?:(?!^class\s).)*?attacker\.statLowered\s*\?\s*basedmg\*2' },
    @{ Name = "Poltergeist item requirement"; Pattern = '(?ms)^class\s+PokeBattle_Move_243\b(?:(?!^class\s).)*?def\s+pbMoveFailed(?:(?!^class\s).)*?opponent\.item==0' },
    @{ Name = "Chloroblast once-per-use recoil"; Pattern = '(?ms)^class\s+PokeBattle_Move_222\b(?:(?!^class\s).)*?azure_chloroblast_recoil_applied(?:(?!^class\s).)*?pbAdjustAbilityRecoilCrashDamage\(\(attacker\.totalhp/2\.0\)\.ceil\)' },
    @{ Name = "Ice Spinner terrain removal"; Pattern = '(?ms)^class\s+PokeBattle_Move_255\s*<\s*PokeBattle_Move_235\b(?:(?!^class\s).)*?azure_steel_roller_cleared=false' },
    @{ Name = "Fillet Away HP cost and boosts"; Pattern = '(?ms)^class\s+PokeBattle_Move_257\b(?:(?!^class\s).)*?PBStats::ATTACK,PBStats::SPATK,PBStats::SPEED(?:(?!^class\s).)*?totalhp/2(?:(?!^class\s).)*?pbIncreaseStat\(stat,2\b' },
    @{ Name = "Snowscape Hail adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_262\s*<\s*PokeBattle_Move_102\b' },
    @{ Name = "Double Shock Fire-removal adapter"; Pattern = '(?m)^class\s+PokeBattle_Move_264\s*<\s*PokeBattle_Move_15E\b' },
    @{ Name = "Mighty Cleave protection bypass"; Pattern = '(?ms)^class\s+PokeBattle_Move_285\b(?:(?!^class\s).)*?def\s+canProtectAgainst\?(?:(?!^class\s).)*?return\s+false' },
    @{ Name = "Dragon Cheer critical-stage boost"; Pattern = '(?ms)^class\s+PokeBattle_Move_286\b(?:(?!^class\s).)*?PBEffects::FocusEnergy(?:(?!^class\s).)*?pbHasType\?\(:DRAGON\)\s*\?\s*2\s*:\s*1' },
    @{ Name = "Psychic Noise Heal Block"; Pattern = '(?ms)^class\s+PokeBattle_Move_287\b(?:(?!^class\s).)*?PBEffects::HealBlock\]=2' },
    @{ Name = "Upper Hand priority and flinch rules"; Pattern = '(?ms)^class\s+PokeBattle_Move_289\b(?:(?!^class\s).)*?chosenmove\.priority<=0(?:(?!^class\s).)*?PBEffects::Flinch\]=true' },
    @{ Name = "Matcha Gotcha drain and burn adapter"; Pattern = '(?ms)^class\s+PokeBattle_Move_28C\s*<\s*PokeBattle_Move_0DD\b(?:(?!^class\s).)*?pbBurn' },
    @{ Name = "Corrosive Gas item suppression"; Pattern = '(?ms)^class\s+PokeBattle_Move_244\b(?:(?!^class\s).)*?PBEffects::Substitute(?:(?!^class\s).)*?pbIsUnlosableItem(?:(?!^class\s).)*?STICKYHOLD(?:(?!^class\s).)*?opponent\.item=0' },
    @{ Name = "Raging Bull type and screen adapter"; Pattern = '(?ms)^class\s+PokeBattle_Move_258\s*<\s*PokeBattle_Move_10A\b(?:(?!^class\s).)*?PBSpecies,:TAUROS(?:(?!^class\s).)*?PBTypes::FIGHTING(?:(?!^class\s).)*?PBTypes::FIRE(?:(?!^class\s).)*?PBTypes::WATER' },
    @{ Name = "Doodle ally Ability copy"; Pattern = '(?ms)^class\s+PokeBattle_Move_263\b(?:(?!^class\s).)*?ABILITYBLACKLIST(?:(?!^class\s).)*?pbPartner(?:(?!^class\s).)*?FIXEDABILITIES(?:(?!^class\s).)*?ABILITYSHIELD(?:(?!^class\s).)*?battler\.ability=copiedability' },
    @{ Name = "Tidy Up complete cleanup and boosts"; Pattern = '(?ms)^class\s+PokeBattle_Move_259\b(?:(?!^class\s).)*?PBEffects::Substitute(?:(?!^class\s).)*?PBEffects::StealthRock(?:(?!^class\s).)*?PBEffects::Caltrops(?:(?!^class\s).)*?PBStats::ATTACK,PBStats::SPEED(?:(?!^class\s).)*?pbUnSubstituteSprite' },
    @{ Name = "Ivy Cudgel mask typing"; Pattern = '(?ms)^class\s+PokeBattle_Move_272\b(?:(?!^class\s).)*?PBSpecies,:OGERPON(?:(?!^class\s).)*?WELLSPRINGMASK(?:(?!^class\s).)*?HEARTHFLAMEMASK(?:(?!^class\s).)*?CORNERSTONEMASK' },
    @{ Name = "Mortal Spin poison and cleanup"; Pattern = '(?ms)^class\s+PokeBattle_Move_256\b(?:(?!^class\s).)*?azure_mortal_spin_cleanup_applied(?:(?!^class\s).)*?pbPoison(?:(?!^class\s).)*?PBEffects::MultiTurn(?:(?!^class\s).)*?PBEffects::LeechSeed(?:(?!^class\s).)*?PBEffects::Caltrops' },
    @{ Name = "Chilly Reception weather and pivot"; Pattern = '(?ms)^class\s+PokeBattle_Move_261\s*<\s*PokeBattle_Move_102\b(?:(?!^class\s).)*?azureCanStartHail\?(?:(?!^class\s).)*?pbCanChooseNonActive\?(?:(?!^class\s).)*?attacker\.userSwitch=true' },
    @{ Name = "Rage Fist battle-persistent hit tracking"; Pattern = '(?ms)(?=.*^class\s+PokeBattle_Battler\b.*?def\s+azureHitsTaken.*?@pokemon\.object_id)(?=.*^class\s+PokeBattle_Move\b.*?azure_move_compat_pbOnDamageLost.*?counts\.fetch\(key,0\)\+1)' },
    @{ Name = "Rage Fist capped power scaling"; Pattern = '(?ms)^class\s+PokeBattle_Move_268\b(?:(?!^class\s).)*?50\*\[attacker\.azureHitsTaken,6\]\.min' },
    @{ Name = "Glaive Rush exposure lifecycle"; Pattern = '(?ms)(?=.*^class\s+PokeBattle_Battler\b.*?azureGlaiveRush=false.*?def\s+pbBeginTurn.*?azureGlaiveRush=false)(?=.*^class\s+PokeBattle_Move\b.*?def\s+pbAccuracyCheck.*?opponent\.azureGlaiveRush.*?def\s+pbCalcDamage.*?damage\*=2)(?=.*^class\s+PokeBattle_Move_267\b.*?attacker\.azureGlaiveRush=true)' },
    @{ Name = "Salt Cure target marking"; Pattern = '(?ms)^class\s+PokeBattle_Move_269\b(?:(?!^class\s).)*?damagestate\.calcdamage>0(?:(?!^class\s).)*?PBEffects::SaltCure\]=true' },
    @{ Name = "Syrup Bomb three-turn marking"; Pattern = '(?ms)^class\s+PokeBattle_Move_276\b(?:(?!^class\s).)*?PBEffects::SyrupBombTurns\]=3(?:(?!^class\s).)*?PBEffects::SyrupBombUser\]=attacker\.index' },
    @{ Name = "Shell Side Arm smart category and poison"; Pattern = '(?ms)^class\s+PokeBattle_Move_238\b(?:(?!^class\s).)*?pbCalcAttack\.to_f(?:(?!^class\s).)*?pbCalcDefense(?:(?!^class\s).)*?pbCalcSpAtk\.to_f(?:(?!^class\s).)*?pbCalcSpDef(?:(?!^class\s).)*?def\s+pbIsPhysical\?(?:(?!^class\s).)*?def\s+isContactMove\?(?:(?!^class\s).)*?pbPoison' },
    @{ Name = "Triple Arrows independent stat drops"; Pattern = '(?ms)^class\s+PokeBattle_Move_229\b(?:(?!^class\s).)*?pbReduceStat\(PBStats::SPEED,1(?:(?!^class\s).)*?SHEERFORCE(?:(?!^class\s).)*?SHIELDDUST(?:(?!^class\s).)*?LuckyChant(?:(?!^class\s).)*?chance=50(?:(?!^class\s).)*?pbReduceStat\(PBStats::DEFENSE,1' },
    @{ Name = "Turn-scoped stat-raise tracking"; Pattern = '(?ms)^class\s+PokeBattle_Battler\b(?:(?!^class\s).)*?azureStatsRaisedThisRound(?:(?!^class\s).)*?azure_move_compat_pbIncreaseStatBasic(?:(?!^class\s).)*?StatChangeHolder(?:(?!^class\s).)*?azureStatsRaisedThisRound=true' },
    @{ Name = "Burning Jealousy conditional burn"; Pattern = '(?ms)^class\s+PokeBattle_Move_241\b(?:(?!^class\s).)*?opponent\.azureStatsRaisedThisRound(?:(?!^class\s).)*?pbCanBurn\?\(false\)(?:(?!^class\s).)*?pbBurn' },
    @{ Name = "Reactive Protect-family activation"; Pattern = '(?ms)^module\s+AzureReactiveProtectMove\b(?:(?!^(?:class|module)\s).)*?PBStuff::RATESHARER(?:(?!^(?:class|module)\s).)*?PBEffects::ProtectRate(?:(?!^(?:class|module)\s).)*?azureReactiveProtectEffect' },
    @{ Name = "Silk Trap effect adapter"; Pattern = '(?ms)^class\s+PokeBattle_Move_252\b(?:(?!^class\s).)*?include\s+AzureReactiveProtectMove(?:(?!^class\s).)*?PBEffects::SilkTrap' },
    @{ Name = "Burning Bulwark effect adapter"; Pattern = '(?ms)^class\s+PokeBattle_Move_283\b(?:(?!^class\s).)*?include\s+AzureReactiveProtectMove(?:(?!^class\s).)*?PBEffects::BurningBulwark' },
    @{ Name = "Shed Tail HP cost and pivot handoff"; Pattern = '(?ms)^class\s+PokeBattle_Move_265\b(?:(?!^class\s).)*?totalhp/2\.0\)\.ceil(?:(?!^class\s).)*?pbCanChooseNonActive\?(?:(?!^class\s).)*?PBEffects::Substitute(?:(?!^class\s).)*?totalhp/4\.0\)\.floor(?:(?!^class\s).)*?@tributeOrthwormShedHP(?:(?!^class\s).)*?userSwitch=true' },
    @{ Name = "Commander activation and lifecycle"; Pattern = '(?ms)^class\s+PokeBattle_Battler\b(?:(?!^class\s).)*?def\s+azureReleaseCommander(?:(?!^class\s).)*?PBEffects::Commander(?:(?!^class\s).)*?def\s+azureCommanderCheck(?:(?!^class\s).)*?PBSpecies,:TATSUGIRI(?:(?!^class\s).)*?PBSpecies,:DONDOZO(?:(?!^class\s).)*?hasWorkingAbility\(:COMMANDER\)(?:(?!^class\s).)*?PBEffects::Commandee\]=true(?:(?!^class\s).)*?pbIncreaseStat\(stat,2(?:(?!^class\s).)*?azure_move_compat_pbFaint' },
    @{ Name = "Order Up Commander-dependent boost"; Pattern = '(?ms)^class\s+PokeBattle_Move_270\b(?:(?!^class\s).)*?azure_order_up_boost_applied(?:(?!^class\s).)*?PBEffects::Commandee(?:(?!^class\s).)*?PBEffects::Commander(?:(?!^class\s).)*?PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED(?:(?!^class\s).)*?pbIncreaseStat\(stat,1' },
    @{ Name = "Foul Gambit knockout recovery"; Pattern = '(?ms)^class\s+PokeBattle_Move_21F\b(?:(?!^class\s).)*?opponent\.isFainted\?(?:(?!^class\s).)*?damagestate\.hplost\*3/4\.0(?:(?!^class\s).)*?pbRecoverHP' },
    @{ Name = "Sweltering Strike authored placeholder"; Pattern = '(?m)^class\s+PokeBattle_Move_22C\s*<\s*PokeBattle_Move\b' },
    @{ Name = "Ergo Proxy reciprocal type changes"; Pattern = '(?ms)^class\s+PokeBattle_Move_22D\b(?:(?!^class\s).)*?copiedtype1=opponent\.type1(?:(?!^class\s).)*?attacker\.type1=copiedtype1(?:(?!^class\s).)*?opponent\.type1=PBTypes::GHOST' },
    @{ Name = "Dust Bowl weather accuracy and trapping"; Pattern = '(?ms)^class\s+PokeBattle_Move_22E\b(?:(?!^class\s).)*?PBWeather::SANDSTORM(?:(?!^class\s).)*?PBEffects::MultiTurn\]=5(?:(?!^class\s).)*?PBEffects::MultiTurnAttack\]=@id' },
    @{ Name = "Coral Burst resisted pivot"; Pattern = '(?ms)^class\s+PokeBattle_Move_24A\b(?:(?!^class\s).)*?typemod>0\s*&&\s*typemod<4(?:(?!^class\s).)*?basedmg/2(?:(?!^class\s).)*?pbCanChooseNonActive\?(?:(?!^class\s).)*?userSwitch=true' },
    @{ Name = "Direct-damage round signal"; Pattern = '(?ms)^class\s+PokeBattle_Move\b(?:(?!^class\s).)*?azure_move_compat_pbOnDamageLost(?:(?!^class\s).)*?DamagingMoveThisTurn\]=true' },
    @{ Name = "Pestilence prior-damage power and drain"; Pattern = '(?ms)^class\s+PokeBattle_Move_24F\s*<\s*PokeBattle_Move_0DD\b(?:(?!^class\s).)*?DamagingMoveThisTurn(?:(?!^class\s).)*?basedmg\*2' },
    @{ Name = "Glacial Slam crash and freeze"; Pattern = '(?ms)^class\s+PokeBattle_Move_26F\b(?:(?!^class\s).)*?return\s+0x10B(?:(?!^class\s).)*?pbCanFreeze\?(?:(?!^class\s).)*?pbFreeze' },
    @{ Name = "Spirit Fist Special Defense targeting"; Pattern = '(?ms)^class\s+PokeBattle_Move_278\b(?:(?!^class\s).)*?oldfunction=@function(?:(?!^class\s).)*?@function=0x205(?:(?!^class\s).)*?ensure(?:(?!^class\s).)*?@function=oldfunction' },
    @{ Name = "Jetstream and Battle Cry dispatch"; Pattern = '(?ms)^class\s+PokeBattle_Move_277\b(?:(?!^class\s).)*?PBMoves::BATTLECRY(?:(?!^class\s).)*?PBEffects::BattleCry\]\+=2(?:(?!^class\s).)*?azureJetstream=true' },
    @{ Name = "Vile Mercy and Bellow dispatch"; Pattern = '(?ms)^class\s+PokeBattle_Move_282\b(?:(?!^class\s).)*?PBMoves::BELLOW(?:(?!^class\s).)*?PBEffects::VileMercy\]=4(?:(?!^class\s).)*?PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF' },
    @{ Name = "Counterpoise and Pierce the Veil dispatch"; Pattern = '(?ms)^class\s+PokeBattle_Move_224\b(?:(?!^class\s).)*?PBMoves::POWERSHIFT(?:(?!^class\s).)*?PBEffects::CounterpoiseDouble\]=true(?:(?!^class\s).)*?PBEffects::CounterpoiseSwap\]=true(?:(?!^class\s).)*?PBEffects::PowerTrick\]=!' },
    @{ Name = "Aftershock delayed-hit scheduling"; Pattern = '(?ms)^class\s+PokeBattle_Move_27D\b(?:(?!^class\s).)*?@azure_aftershock_echo(?:(?!^class\s).)*?PBEffects::Aftershock\]=1(?:(?!^class\s).)*?PBEffects::AftershockMove\]=@id(?:(?!^class\s).)*?pbParalyze' },
    @{ Name = "Pressure Plate power and PP rules"; Pattern = '(?ms)(?=.*^class\s+PokeBattle_Battler\b.*?azure_move_compat_pbReducePP.*?PBEffects::PressurePlate.*?pbSetPP\(move,move\.pp-1\))(?=.*^class\s+PokeBattle_Move\b.*?damage\*1\.2)(?=.*^class\s+PokeBattle_Move_281\b.*?PBEffects::PressurePlate\]=5)' },
    @{ Name = "Vile Mercy global damage reduction"; Pattern = '(?ms)^class\s+PokeBattle_Move\b(?:(?!^class\s).)*?PBEffects::VileMercy(?:(?!^class\s).)*?damage\*0\.8' },
    @{ Name = "Gilded Bargain Dragon conversion and shared HP"; Pattern = '(?ms)^class\s+PokeBattle_Move_22B\b(?:(?!^class\s).)*?PBTypes,:DRAGON(?:(?!^class\s).)*?sharedhp=\(\(attacker\.hp\+opponent\.hp\)/2\)\.floor(?:(?!^class\s).)*?pbHPChanged\(attacker,olda\)(?:(?!^class\s).)*?pbHPChanged\(opponent,oldo\)' },
    @{ Name = "Tale's End blade cap and execution threshold"; Pattern = '(?ms)^class\s+PokeBattle_Move_23A\b(?:(?!^class\s).)*?PBEffects::TalesEndBlades\]\+1,4(?:(?!^class\s).)*?totalhp\*blades/16\.0(?:(?!^class\s).)*?opponent\.hp<threshold(?:(?!^class\s).)*?pbReduceHP\(opponent\.hp\)' },
    @{ Name = "Lotus Bloom delayed slot-persistent strike"; Pattern = '(?ms)^class\s+PokeBattle_Move_21E\b(?:(?!^class\s).)*?@azure_lotus_bloom_strike(?:(?!^class\s).)*?PBEffects::LotusBloom\]=3(?:(?!^class\s).)*?PBEffects::LotusBloomPkmnIdx' },
    @{ Name = "Sunfury charge hazard clear and three damage ticks"; Pattern = '(?ms)^class\s+PokeBattle_Move_22F\b(?:(?!^class\s).)*?pbTwoTurnAttack(?:(?!^class\s).)*?PBWeather::SUNNYDAY(?:(?!^class\s).)*?PBEffects::StealthRock\]=false(?:(?!^class\s).)*?PBEffects::Sunfury\]=3' },
    @{ Name = "Red Sun star buildup gravity and third-star sacrifice"; Pattern = '(?ms)^class\s+PokeBattle_Move_23F\b(?:(?!^class\s).)*?stars\.length>=2(?:(?!^class\s).)*?basedmg\*3(?:(?!^class\s).)*?stars\.push\(6\)(?:(?!^class\s).)*?PBEffects::Gravity(?:(?!^class\s).)*?attacker\.pbReduceHP\(attacker\.hp\)' },
    @{ Name = "Blue Shift sacrifice and duration"; Pattern = '(?ms)^class\s+PokeBattle_Move_249\b(?:(?!^class\s).)*?PBEffects::BlueShift\]=2(?:(?!^class\s).)*?attacker\.pbReduceHP\(attacker\.hp\)' },
    @{ Name = "Circadian Rhythm sleep marking"; Pattern = '(?ms)^class\s+PokeBattle_Move_24B\b(?:(?!^class\s).)*?pbCanSleep\?\(true\)(?:(?!^class\s).)*?attacker\.pbSleep(?:(?!^class\s).)*?PBEffects::CircadianRhythm\]=true' },
    @{ Name = "Needle Blast hits and stored needles"; Pattern = '(?ms)^class\s+PokeBattle_Move_24D\b(?:(?!^class\s).)*?\[2,2,3,3,4,5\](?:(?!^class\s).)*?PBEffects::Needles\]\+=1' },
    @{ Name = "Needle contact consumption and Molten retaliation"; Pattern = '(?ms)^class\s+PokeBattle_Move\b(?:(?!^class\s).)*?isContactMove\?(?:(?!^class\s).)*?azureConsumeNeedle(?:(?!^class\s).)*?PBEffects::MoltenStance(?:(?!^class\s).)*?pbBurn' },
    @{ Name = "Molten Stance defensive setup"; Pattern = '(?ms)^class\s+PokeBattle_Move_24E\b(?:(?!^class\s).)*?PBStats::DEFENSE,PBStats::SPDEF(?:(?!^class\s).)*?pbIncreaseStat\(stat,1(?:(?!^class\s).)*?PBEffects::MoltenStance\]=true' }
  )
  foreach ($contract in $contracts) {
    if ($content -notmatch $contract.Pattern) {
      Add-AuditError "$($contract.Name) is missing or no longer matches its preservation contract in $relativePath."
    }
  }
  $orderEntries = @([System.IO.File]::ReadLines((Resolve-ProjectPath "Scripts\!script_order.csv")) | ForEach-Object { $_.Trim() })
  if ($orderEntries -notcontains "PokeBattle_MoveEffectCompatibility") {
    Add-AuditError "Move compatibility layer is absent from Scripts\!script_order.csv."
  }
  Add-AuditCheck "Move compatibility semantics: $($contracts.Count) adapters and behaviors were checked."
}

function Test-CompiledDataFreshness {
  $pairs = @(
    @{ Source = "PBS\moves.txt"; Output = "Data\moves.dat" },
    @{ Source = "PBS\pokemon.txt"; Output = "Data\dexdata.dat" },
    @{ Source = "PBS\pokemon.txt"; Output = "Data\evolutions.dat" },
    @{ Source = "PBS\pokemon.txt"; Output = "Data\eggEmerald.dat" },
    @{ Source = "PBS\pokemon.txt"; Output = "Data\attacksRS.rxdata" },
    @{ Source = "PBS\pokemon.txt"; Output = "Scripts\PBSpecies.rb" },
    @{ Source = "PBS\pokemon_metrics.txt"; Output = "Data\metrics.dat" },
    @{ Source = "PBS\regional_dexes.txt"; Output = "Data\regionals.dat" },
    @{ Source = "PBS\abilities.txt"; Output = "Scripts\PBAbilities.rb" },
    @{ Source = "PBS\items.txt"; Output = "Scripts\PBItems.rb" },
    @{ Source = "PBS\items.txt"; Output = "Data\pokmanitems.rxdata" },
    @{ Source = "PBS\trainer_types.txt"; Output = "Data\trainertypes.dat" },
    @{ Source = "PBS\trainers.txt"; Output = "Data\trainers.dat" },
    @{ Source = "PBS\townmap.txt"; Output = "Data\townmap.dat" },
    @{ Source = "PBS\connections.txt"; Output = "Data\connections.dat" },
    @{ Source = "PBS\phone.txt"; Output = "Data\phone.dat" },
    @{ Source = "PBS\trainerlists.txt"; Output = "Data\trainerlists.dat" },
    @{ Source = "PBS\encounters.txt"; Output = "Data\encounters.dat" },
    @{ Source = "PBS\shadowmoves.txt"; Output = "Data\shadowmoves.dat" },
    @{ Source = "PBS\tm.txt"; Output = "Data\tm.dat" }
  )
  foreach ($pair in $pairs) {
    $source = Get-Item -LiteralPath (Resolve-ProjectPath $pair.Source)
    $outputPath = Resolve-ProjectPath $pair.Output
    if (!(Test-Path -LiteralPath $outputPath -PathType Leaf)) {
      Add-AuditError "Compiled output $($pair.Output) is missing."
      continue
    }
    $output = Get-Item -LiteralPath $outputPath
    if ($source.LastWriteTimeUtc -gt $output.LastWriteTimeUtc) {
      Add-AuditWarning "$($pair.Output) is older than $($pair.Source); recompile before release testing."
    }
  }
  Add-AuditCheck "Compiled-data presence and timestamps were checked."
}

$requiredFiles = @(
  "Scripts\!script_order.csv",
  "Scripts\PBMoves.rb",
  "Scripts\PBSpecies.rb",
  "Scripts\PBItems.rb",
  "Scripts\PBAbilities.rb",
  "Scripts\PBTypes.rb",
  "Scripts\PBTrainers.rb",
  "PBS\moves.txt",
  "PBS\pokemon.txt",
  "PBS\items.txt",
  "PBS\abilities.txt",
  "PBS\types.txt",
  "PBS\trainer_types.txt",
  "PBS\trainers.txt",
  "PBS\townmap.txt",
  "PBS\connections.txt",
  "PBS\phone.txt",
  "PBS\trainerlists.txt",
  "PBS\encounters.txt",
  "PBS\shadowmoves.txt",
  "PBS\metadata.txt",
  "PBS\map_metadata.txt",
  "PBS\tm.txt"
)

foreach ($relativePath in $requiredFiles) {
  if (!(Test-Path -LiteralPath (Resolve-ProjectPath $relativePath) -PathType Leaf)) {
    Add-AuditError "Required file is missing: $relativePath."
  }
}

if ($script:Errors.Count -eq 0) {
  $moveConstants = Read-NumericConstants "Scripts\PBMoves.rb"
  $speciesConstants = Read-NumericConstants "Scripts\PBSpecies.rb"
  $itemConstants = Read-NumericConstants "Scripts\PBItems.rb"
  $abilityConstants = Read-NumericConstants "Scripts\PBAbilities.rb"
  $typeConstants = Read-NumericConstants "Scripts\PBTypes.rb"
  $trainerTypeConstants = Read-NumericConstants "Scripts\PBTrainers.rb"

  $moves = @(Read-SectionedPBS "PBS\moves.txt")
  $pokemon = @(Read-SectionedPBS "PBS\pokemon.txt")
  $abilities = @(Read-SectionedPBS "PBS\abilities.txt")
  $types = @(Read-SectionedPBS "PBS\types.txt")
  $trainerTypes = @(Read-SectionedPBS "PBS\trainer_types.txt")
  $items = @(Read-Items)

  Test-PokemonSchemas $pokemon
  Test-SectionedConstants "Moves" $moves "LegacyMoveID" $moveConstants
  Test-SectionedConstants "Pokémon" $pokemon "LegacySpeciesID" $speciesConstants
  Test-SectionedConstants "Abilities" $abilities "LegacyAbilityID" $abilityConstants
  Test-SectionedConstants "Trainer types" $trainerTypes "LegacyTrainerTypeID" $trainerTypeConstants
  Test-AbilitySchemas $abilities
  Test-TrainerTypeSchemas $trainerTypes
  $typeSymbols = Test-Types $types $typeConstants
  $moveSymbols = Test-Moves $moves $moveConstants $typeSymbols (Find-MoveExecutors)
  $itemSymbols = Test-Items $items $itemConstants $moveSymbols
  $speciesSymbols = @{}
  foreach ($mon in $pokemon) {
    $baseSpecies = ($mon.Id -split ',', 2)[0]
    $speciesSymbols[$baseSpecies] = $true
  }
  $abilitySymbols = @{}
  foreach ($ability in $abilities) { $abilitySymbols[$ability.Id] = $true }

  Test-PokemonReferences $pokemon $speciesSymbols $moveSymbols $abilitySymbols $typeSymbols
  Test-AbilityScriptReferences $abilityConstants
  Test-TypeScriptReferences $typeConstants
  Test-TrainerReferences $speciesSymbols $moveSymbols $itemSymbols
  Test-TownMapSources
  Test-ConnectionSources
  Test-PhoneSources
  Test-BattleFacilitySources
  Test-MetadataSources $trainerTypeConstants
  Test-EncounterReferences $speciesSymbols
  Test-ShadowMoveReferences $speciesSymbols $moveSymbols
  Test-TMReferences $speciesSymbols $moveSymbols $speciesConstants $moveConstants
  Test-LegacyDuplicatePolicy $moves $pokemon $abilities $trainerTypes $items
  Test-FeatureContracts
  Test-MoveCompatibilitySemantics
  Test-CompiledDataFreshness
}

Write-Host "Azure preservation audit"
Write-Host "Root: $Root"
foreach ($check in $script:Checks) { Write-Host "  PASS  $check" -ForegroundColor Green }
foreach ($warning in $script:Warnings) { Write-Host "  WARN  $warning" -ForegroundColor Yellow }
foreach ($failure in $script:Errors) { Write-Host "  FAIL  $failure" -ForegroundColor Red }
Write-Host "Summary: $($script:Checks.Count) checks, $($script:Warnings.Count) warnings, $($script:Errors.Count) failures."

if ($script:Errors.Count -gt 0 -or ($WarningsAsErrors -and $script:Warnings.Count -gt 0)) {
  exit 1
}
exit 0
