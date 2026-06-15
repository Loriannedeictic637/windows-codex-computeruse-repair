[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$Destination = (Join-Path $HOME ".codex\skills\repair-codex-computer-use")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "repair-codex-computer-use"
if (-not (Test-Path -LiteralPath (Join-Path $source "SKILL.md"))) {
  throw "Could not find skill source folder: $source"
}

$parent = Split-Path -Parent $Destination
if (-not (Test-Path -LiteralPath $parent)) {
  if ($PSCmdlet.ShouldProcess($parent, "Create Codex skills directory")) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
}

if (Test-Path -LiteralPath $Destination) {
  $backup = "$Destination.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
  if ($PSCmdlet.ShouldProcess($Destination, "Back up existing skill to $backup")) {
    Move-Item -LiteralPath $Destination -Destination $backup
    Write-Host "Backed up existing skill to: $backup"
  }
}

if ($PSCmdlet.ShouldProcess($Destination, "Install repair-codex-computer-use skill")) {
  Copy-Item -LiteralPath $source -Destination $Destination -Recurse
  Write-Host ""
  Write-Host "Installed repair-codex-computer-use skill to:"
  Write-Host "  $Destination"
  Write-Host ""
  Write-Host "Next steps:"
  Write-Host "  1. Restart Codex Desktop, or open a new Codex chat."
  Write-Host "  2. Ask: Use repair-codex-computer-use to diagnose my Windows Computer Use plugin."
}

