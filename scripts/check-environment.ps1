[CmdletBinding()]
param(
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-HomeDirectory {
    if ($env:USERPROFILE) { return $env:USERPROFILE }
    if ($HOME) { return $HOME }
    throw "Unable to determine the user home directory."
}

function Test-CommandState {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string[]]$VersionArgs = @("--version")
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    $version = $null

    if ($command) {
        try {
            $versionOutput = & $Name @VersionArgs 2>$null | Select-Object -First 1
            if ($versionOutput) {
                $version = [string]$versionOutput
            }
        } catch {
            $version = $null
        }
    }

    [pscustomobject]@{
        name      = $Name
        available = [bool]$command
        path      = if ($command) { $command.Source } else { $null }
        version   = $version
    }
}

function Test-DirectoryState {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Path
    )

    [pscustomobject]@{
        name    = $Name
        exists  = Test-Path -LiteralPath $Path -PathType Container
        path    = $Path
    }
}

$homeDir = Get-HomeDirectory
$skillRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")

$commands = @(
    (Test-CommandState -Name "git")
    (Test-CommandState -Name "openspec")
    (Test-CommandState -Name "gstack")
    (Test-CommandState -Name "node")
    (Test-CommandState -Name "bun")
)

$directories = @(
    (Test-DirectoryState -Name "codexSkills" -Path (Join-Path $homeDir ".codex\skills"))
    (Test-DirectoryState -Name "codexSuperpowers" -Path (Join-Path $homeDir ".codex\superpowers\skills"))
    (Test-DirectoryState -Name "agentsSkills" -Path (Join-Path $homeDir ".agents\skills"))
    (Test-DirectoryState -Name "claudeSkills" -Path (Join-Path $homeDir ".claude\skills"))
    (Test-DirectoryState -Name "codexGstack" -Path (Join-Path $homeDir ".codex\skills\gstack"))
    (Test-DirectoryState -Name "claudeGstack" -Path (Join-Path $homeDir ".claude\skills\gstack"))
    (Test-DirectoryState -Name "currentSkill" -Path $skillRoot.Path)
)

$superpowersPresent = [bool](
    ($directories | Where-Object { $_.name -eq "codexSuperpowers" -and $_.exists }) -or
    (Test-Path -LiteralPath (Join-Path $homeDir ".codex\skills\using-superpowers") -PathType Container) -or
    (Test-Path -LiteralPath (Join-Path $homeDir ".agents\skills\using-superpowers") -PathType Container)
)

$gstackPresent = [bool](
    ($directories | Where-Object { $_.name -in @("codexGstack", "claudeGstack") -and $_.exists }) -or
    (($commands | Where-Object { $_.name -eq "gstack" }).available)
)

$result = [pscustomobject]@{
    checkedAt          = (Get-Date).ToString("o")
    skillRoot          = $skillRoot.Path
    commands           = $commands
    directories        = $directories
    superpowersPresent = $superpowersPresent
    gstackPresent      = $gstackPresent
}

if ($Json) {
    $result | ConvertTo-Json -Depth 5
    exit 0
}

Write-Host "AI Delivery Stack environment check"
Write-Host "Skill root: $($result.skillRoot)"
Write-Host ""
Write-Host "Commands:"
foreach ($command in $commands) {
    $status = if ($command.available) { "[OK]" } else { "[MISSING]" }
    $detail = if ($command.available) { " - $($command.path)" } else { "" }
    Write-Host ("  {0} {1}{2}" -f $status, $command.name, $detail)
    if ($command.version) {
        Write-Host ("      {0}" -f $command.version)
    }
}

Write-Host ""
Write-Host "Directories:"
foreach ($directory in $directories) {
    $status = if ($directory.exists) { "[OK]" } else { "[MISSING]" }
    Write-Host ("  {0} {1}: {2}" -f $status, $directory.name, $directory.path)
}

Write-Host ""
Write-Host ("Superpowers skills: {0}" -f $(if ($superpowersPresent) { "present" } else { "missing" }))
Write-Host ("gstack skills/command: {0}" -f $(if ($gstackPresent) { "present" } else { "missing" }))

exit 0
