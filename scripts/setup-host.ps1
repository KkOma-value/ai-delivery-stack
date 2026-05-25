[CmdletBinding()]
param(
    [Alias("Host")]
    [ValidateSet("codex", "claude", "both")]
    [string]$TargetHost = "both",

    [ValidateSet("copy", "link")]
    [string]$Mode = "copy",

    [switch]$DryRun,
    [switch]$Apply,
    [switch]$Force,
    [string]$SkillPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-HomeDirectory {
    if ($env:USERPROFILE) { return $env:USERPROFILE }
    if ($HOME) { return $HOME }
    throw "Unable to determine the user home directory."
}

function Get-TargetRoots {
    param([string]$RequestedHost)

    $homeDir = Get-HomeDirectory
    $targets = @()

    if ($RequestedHost -in @("codex", "both")) {
        $targets += [pscustomobject]@{
            host = "codex"
            root = Join-Path $homeDir ".codex\skills"
        }
    }

    if ($RequestedHost -in @("claude", "both")) {
        $targets += [pscustomobject]@{
            host = "claude"
            root = Join-Path $homeDir ".claude\skills"
        }
    }

    return $targets
}

function Remove-ExistingDestination {
    param(
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$TargetRoot
    )

    $resolvedRoot = Resolve-Path -LiteralPath $TargetRoot
    $resolvedDestination = Resolve-Path -LiteralPath $Destination

    if (-not $resolvedDestination.Path.StartsWith($resolvedRoot.Path, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove destination outside target root: $($resolvedDestination.Path)"
    }

    Remove-Item -LiteralPath $resolvedDestination.Path -Recurse -Force
}

function Install-Skill {
    param(
        [Parameter(Mandatory = $true)][string]$TargetHost,
        [Parameter(Mandatory = $true)][string]$TargetRoot,
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$InstallMode,
        [Parameter(Mandatory = $true)][bool]$ShouldApply,
        [Parameter(Mandatory = $true)][bool]$Overwrite
    )

    $destination = Join-Path $TargetRoot "ai-delivery-stack"
    $actionPrefix = if ($ShouldApply) { "Applying" } else { "Dry run" }

    Write-Host "$actionPrefix for $TargetHost -> $destination"

    if (-not $ShouldApply) {
        if (-not (Test-Path -LiteralPath $TargetRoot -PathType Container)) {
            Write-Host "  Would create directory: $TargetRoot"
        }
        if (Test-Path -LiteralPath $destination) {
            $message = if ($Overwrite) { "Would replace existing destination" } else { "Destination exists; would skip without -Force" }
            Write-Host "  $message"
        }
        if ($InstallMode -eq "link") {
            Write-Host "  Would link $SourcePath"
        } else {
            Write-Host "  Would copy $SourcePath"
        }
        return
    }

    New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null

    if (Test-Path -LiteralPath $destination) {
        if (-not $Overwrite) {
            Write-Host "  Destination exists; skipping. Re-run with -Force to replace."
            return
        }
        Remove-ExistingDestination -Destination $destination -TargetRoot $TargetRoot
    }

    if ($InstallMode -eq "link") {
        if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) {
            New-Item -ItemType Junction -Path $destination -Target $SourcePath | Out-Null
        } else {
            New-Item -ItemType SymbolicLink -Path $destination -Target $SourcePath | Out-Null
        }
    } else {
        Copy-Item -LiteralPath $SourcePath -Destination $destination -Recurse -Force
    }

    Write-Host "  Installed."
}

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $SkillPath) {
    $SkillPath = (Resolve-Path -LiteralPath (Join-Path $scriptRoot "..")).Path
}

$source = Resolve-Path -LiteralPath $SkillPath
$shouldApply = [bool]$Apply
if ($DryRun -and $Apply) {
    throw "Use either -DryRun or -Apply, not both."
}

Write-Host "AI Delivery Stack host setup"
Write-Host "Source: $($source.Path)"
Write-Host "Mode: $Mode"
Write-Host ("Operation: {0}" -f $(if ($shouldApply) { "apply" } else { "dry-run" }))
Write-Host ""

foreach ($target in Get-TargetRoots -RequestedHost $TargetHost) {
    Install-Skill `
        -TargetHost $target.host `
        -TargetRoot $target.root `
        -SourcePath $source.Path `
        -InstallMode $Mode `
        -ShouldApply $shouldApply `
        -Overwrite ([bool]$Force)
}
