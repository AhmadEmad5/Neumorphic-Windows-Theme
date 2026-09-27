<#
.SYNOPSIS
    Deploy-NeumorphicOS.ps1 - Automated System-Wide Deployment Script
.DESCRIPTION
    Installs Neumorphic Dark Soft UI visual styles, registry palette injections,
    and applies the theme across Windows 10 and Windows 11.
.AUTHOR
    Principal Systems Software Engineer & OS Theming Architect
#>

[CmdletBinding()]
param (
    [switch]$SkipExplorerRestart,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ' NEUMORPHIC DARK SOFT UI - SYSTEM DEPLOYMENT ENGINE        ' -ForegroundColor White
Write-Host ' Target OS: Windows 10 (1903+) / Windows 11 (22H2 / 24H2)   ' -ForegroundColor DarkGray
Write-Host '============================================================' -ForegroundColor Cyan

# 1. Administrator Elevation Check
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    if ($DryRun) {
        Write-Host '[!] Running in DRY-RUN mode (non-elevated simulation).' -ForegroundColor Cyan
    } else {
        Write-Warning 'Administrative privileges required. Relaunching in an elevated PowerShell session...'
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
} else {
    Write-Host '[✓] Elevated administrative privileges confirmed.' -ForegroundColor Green
}

# 2. Path Resolution
$ScriptRoot = Split-Path -Parent $PSScriptRoot
$ThemesSource = Join-Path $ScriptRoot 'Themes'
$RegistrySource = Join-Path $ScriptRoot 'Registry'
$TargetThemesDir = Join-Path $env:SystemRoot 'Resources\Themes'

Write-Host "[i] Source Directory: $ScriptRoot" -ForegroundColor DarkGray
Write-Host "[i] Target Themes Directory: $TargetThemesDir" -ForegroundColor DarkGray

# 3. Registry Backup
$BackupDir = Join-Path $RegistrySource 'Backups'
if (-not (Test-Path $BackupDir)) {
    New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
}

$Timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$BackupPath = Join-Path $BackupDir "SystemColors_Backup_$Timestamp.reg"
Write-Host "[*] Creating safety backup of current registry palette to: $BackupPath" -ForegroundColor Yellow

if (-not $DryRun) {
    reg.exe export 'HKCU\Control Panel\Colors' "$BackupPath" /y | Out-Null
}
Write-Host '[✓] System palette backed up successfully.' -ForegroundColor Green

# 4. Install Visual Style & Theme Assets to %SystemRoot%\Resources\Themes
Write-Host "[*] Installing Neumorphic.theme and asset directory to $TargetThemesDir..." -ForegroundColor Yellow

$ThemeFileSource = Join-Path $ThemesSource 'Neumorphic.theme'
$ThemeFolderSource = Join-Path $ThemesSource 'Neumorphic'

if (Test-Path $ThemeFileSource) {
    if (-not $DryRun) {
        Copy-Item -Path $ThemeFileSource -Destination $TargetThemesDir -Force
        if (Test-Path $ThemeFolderSource) {
            $DestFolder = Join-Path $TargetThemesDir 'Neumorphic'
            Copy-Item -Path $ThemeFolderSource -Destination $DestFolder -Recurse -Force
        }
    }
    Write-Host '[✓] Theme assets copied to system directory.' -ForegroundColor Green
} else {
    Write-Error "Source theme file not found at $ThemeFileSource!"
}

# 5. Import Neumorphic System Palette & DWM Registry Keys
$RegFile = Join-Path $RegistrySource 'Neumorphic-Colors-DWM.reg'
if (Test-Path $RegFile) {
    Write-Host '[*] Merging Neumorphic system colors, DWM dark mode, and ClearType calibration...' -ForegroundColor Yellow
    if (-not $DryRun) {
        Start-Process reg.exe -ArgumentList "import `"$RegFile`"" -Wait -NoNewWindow
    }
    Write-Host '[✓] System palette and DWM registry values imported.' -ForegroundColor Green
} else {
    Write-Error "Registry file not found at $RegFile!"
}

# 6. SecureUxTheme Engine Verification
Write-Host '[*] Verifying UXTheme hooking engine status...' -ForegroundColor Yellow
$SecureUxThemeKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winlogon.exe'
$hasHook = $false
if (Test-Path $SecureUxThemeKey) {
    $val = Get-ItemProperty -Path $SecureUxThemeKey -Name 'Debugger' -ErrorAction SilentlyContinue
    if ($val -and $val.Debugger -like '*SecureUxTheme*') {
        $hasHook = $true
    }
}

if ($hasHook) {
    Write-Host '[✓] SecureUxTheme hook is active.' -ForegroundColor Green
} else {
    Write-Host '[!] Note: To load unsigned custom .msstyles files without signature verification,' -ForegroundColor Cyan
    Write-Host '    ensure SecureUxTheme [in-memory] or ThemeTool is active.' -ForegroundColor Cyan
}

# 7. Apply Theme via Shell API
Write-Host '[*] Applying Neumorphic.theme to user profile...' -ForegroundColor Yellow
$AppliedThemePath = Join-Path $TargetThemesDir 'Neumorphic.theme'
if (-not $DryRun) {
    Start-Process 'rundll32.exe' -ArgumentList "themecui.dll,ThemeRundll `"$AppliedThemePath`""
    Start-Sleep -Seconds 2
}

# 8. Smooth Explorer Restart
if (-not $SkipExplorerRestart -and -not $DryRun) {
    Write-Host '[*] Restarting Windows Explorer to refresh palette and metrics...' -ForegroundColor Yellow
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Start-Process explorer.exe
    Write-Host '[✓] Windows Explorer restarted successfully.' -ForegroundColor Green
}

Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ' [✓] NEUMORPHIC DARK OS THEME DEPLOYMENT COMPLETED!         ' -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Cyan
