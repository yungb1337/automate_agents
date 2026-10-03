<#
.SYNOPSIS
    Install the autonomous agent workflow into a target project.
.DESCRIPTION
    Copies agent definitions, commands, project memory templates, and
    creates the checkpoint directory structure in the target project.
.PARAMETER Target
    Path to the target project directory. Defaults to current directory.
.PARAMETER Force
    Overwrite existing files.
.EXAMPLE
    .\install.ps1 -Target C:\Users\Me\Projects\my-app
    .\install.ps1  # installs into current directory (with confirmation)
#>
param(
    [string]$Target = ".",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Target -eq ".") {
    $Target = Get-Location
    $confirm = Read-Host "Install into current directory ($Target)? [y/N]"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Cancelled."
        exit 1
    }
}

$Target = Resolve-Path $Target

function Copy-IfNotExists {
    param([string]$Src, [string]$Dest)
    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    if ((Test-Path $Dest) -and -not $Force) {
        Write-Host "  SKIP (exists): $Dest"
    } else {
        Copy-Item $Src $Dest -Force
        Write-Host "  COPY: $Dest"
    }
}

Write-Host "Installing autonomous agent workflow into: $Target"

# Copy .claude/agents
Write-Host ""
Write-Host "Copying agent definitions..."
Get-ChildItem "$ScriptDir\.claude\agents\*.md" | ForEach-Object {
    Copy-IfNotExists $_.FullName "$Target\.claude\agents\$($_.Name)"
}

# Copy .claude/commands
Write-Host ""
Write-Host "Copying commands..."
Get-ChildItem "$ScriptDir\.claude\commands\*.md" | ForEach-Object {
    Copy-IfNotExists $_.FullName "$Target\.claude\commands\$($_.Name)"
}

# Copy .claude/skills (if any)
if (Test-Path "$ScriptDir\.claude\skills\*.md") {
    Write-Host ""
    Write-Host "Copying skills..."
    Get-ChildItem "$ScriptDir\.claude\skills\*.md" | ForEach-Object {
        Copy-IfNotExists $_.FullName "$Target\.claude\skills\$($_.Name)"
    }
}

# Create project_memory structure
Write-Host ""
Write-Host "Creating project memory structure..."
@(
    "$Target\project_memory\architecture",
    "$Target\project_memory\adrs",
    "$Target\project_memory\contracts",
    "$Target\project_memory\schemas",
    "$Target\project_memory\known_issues"
) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

Copy-IfNotExists "$ScriptDir\project_memory\active_objective.md" "$Target\project_memory\active_objective.md"
Copy-IfNotExists "$ScriptDir\project_memory\module_status.md" "$Target\project_memory\module_status.md"

# Create checkpoints directory
Write-Host ""
Write-Host "Creating checkpoints directory..."
if (-not (Test-Path "$Target\checkpoints\run")) {
    New-Item -ItemType Directory -Path "$Target\checkpoints\run" -Force | Out-Null
}
if (-not (Test-Path "$Target\checkpoints\.gitkeep")) {
    New-Item -ItemType File -Path "$Target\checkpoints\.gitkeep" -Force | Out-Null
}

# Copy CLAUDE.md
if (-not (Test-Path "$Target\CLAUDE.md")) {
    Copy-IfNotExists "$ScriptDir\CLAUDE.md" "$Target\CLAUDE.md"
} else {
    Write-Host ""
    Write-Host "  NOTE: $Target\CLAUDE.md already exists."
    Write-Host "  You may want to manually add the /dev-team documentation from this template's CLAUDE.md."
}

# Update .gitignore
$gitignorePath = "$Target\.gitignore"
if (Test-Path $gitignorePath) {
    $content = Get-Content $gitignorePath -Raw
    if ($content -notmatch "checkpoints/") {
        Add-Content $gitignorePath "`n# Autonomous agent run checkpoints (optional - remove to track run history)`ncheckpoints/"
        Write-Host "  UPDATED: .gitignore (added checkpoints/)"
    }
} else {
    Set-Content $gitignorePath "# Autonomous agent run checkpoints (optional - remove to track run history)`ncheckpoints/"
    Write-Host "  CREATED: .gitignore"
}

Write-Host ""
Write-Host "Done! The autonomous agent workflow is installed."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit project_memory\active_objective.md with your goal"
Write-Host "  2. Run /dev-team in Claude Code to start"
Write-Host "  3. Or: /dev-team Build a REST API with authentication"
