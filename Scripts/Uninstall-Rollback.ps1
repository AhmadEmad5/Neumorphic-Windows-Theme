<#
.SYNOPSIS
    Uninstall-Rollback.ps1 - Complete Reversible Uninstaller & Theme Rollback
.DESCRIPTION
    Restores factory default Windows Aero/Mica system themes, restores default registry colors,
    and removes custom Neumorphic OS visual style assets.
.AUTHOR
    Principal Systems Software Engineer & OS Theming Architect
#>

[CmdletBinding()]
param (
    [switch]$SkipExplorerRestart,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

Write-Host '============================================================' -ForegroundColor Yellow
Write-Host ' NEUMORPHIC DARK OS - RESTORATION & ROLLBACK ENGINE        ' -ForegroundColor White
Write-Host '============================================================' -ForegroundColor Yellow

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

$ScriptRoot = Split-Path -Parent $PSScriptRoot
$RegistrySource = Join-Path $ScriptRoot 'Registry'
$TargetThemesDir = Join-Path $env:SystemRoot 'Resources\Themes'

# 2. Restore Default Windows Registry Values
$RollbackReg = Join-Path $RegistrySource 'Rollback-Default-Colors.reg'
if (Test-Path $RollbackReg) {
    Write-Host '[*] Restoring default Windows palette and DWM registry values...' -ForegroundColor Yellow
    if (-not $DryRun) {
        Start-Process reg.exe -ArgumentList "import `"$RollbackReg`"" -Wait -NoNewWindow
    }
    Write-Host '[✓] Default registry palette restored.' -ForegroundColor Green
}

# 3. Apply Default Windows Aero Theme
$DefaultTheme = Join-Path $TargetThemesDir 'aero.theme'
if (Test-Path $DefaultTheme) {
    Write-Host '[*] Applying default Windows Aero theme...' -ForegroundColor Yellow
    if (-not $DryRun) {
        Start-Process 'rundll32.exe' -ArgumentList "themecui.dll,ThemeRundll `"$DefaultTheme`""
        Start-Sleep -Seconds 2
    }
    Write-Host '[✓] Default Aero theme applied.' -ForegroundColor Green
}

# 4. Remove Custom Neumorphic Assets from %SystemRoot%\Resources\Themes
Write-Host '[*] Cleaning up installed Neumorphic theme files...' -ForegroundColor Yellow
$InstalledTheme = Join-Path $TargetThemesDir 'Neumorphic.theme'
$InstalledFolder = Join-Path $TargetThemesDir 'Neumorphic'

if (-not $DryRun) {
    if (Test-Path $InstalledTheme) {
        Remove-Item -Path $InstalledTheme -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $InstalledFolder) {
        Remove-Item -Path $InstalledFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host '[✓] Custom theme assets removed.' -ForegroundColor Green

# 5. Restart Explorer
if (-not $SkipExplorerRestart -and -not $DryRun) {
    Write-Host '[*] Restarting Windows Explorer to reload original shell metrics...' -ForegroundColor Yellow
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Start-Process explorer.exe
    Write-Host '[✓] Windows Explorer restarted successfully.' -ForegroundColor Green
}

Write-Host '============================================================' -ForegroundColor Green
Write-Host ' [✓] SYSTEM SUCCESSFULLY RESTORED TO DEFAULT WINDOWS STATE! ' -ForegroundColor White
Write-Host '============================================================' -ForegroundColor Green
