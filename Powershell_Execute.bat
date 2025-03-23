@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject("Shell.Application") > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:: Check for WinGet installation
powershell -ExecutionPolicy Bypass -Command "if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { Write-Host 'Winget is not installed. Loading installation...'; Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/download/v1.10.340/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile '$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'; Add-AppxPackage -Path '$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' }"

if %errorlevel% neq 0 (
    start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'"
    exit /b
)

:: Check and add registry values if not exist
echo Checking and adding registry values...
reg query "HKCU\Console" /v "DelegationConsole" 2>nul
if %errorlevel% neq 0 (
    reg add "HKCU\Console" /v "DelegationConsole" /t REG_SZ /d "{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" /f
)

reg query "HKCU\Console" /v "DelegationTerminal" 2>nul
if %errorlevel% neq 0 (
    reg add "HKCU\Console" /v "DelegationTerminal" /t REG_SZ /d "{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" /f
)
exit
