@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Vérifie si le script a les droits d'administrateur
    net session >nul 2>&1
    if %errorLevel% == 0 (
        goto gotAdmin 
    ) else (
        echo Demande des droits d'administrateur...
    )

    goto UACPrompt

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
:: Votre script PowerShell commence ici
    PowerShell -Command "& {Set-ExecutionPolicy Bypass -Scope CurrentUser -Force}"
    PowerShell -Command "& {Set-ExecutionPolicy Bypass -Scope LocalMachine -Force}"
    PowerShell -Command "& {Set-ExecutionPolicy Bypass -Scope Process -Force}"
:: Votre script PowerShell se termine ici
:--------------------------------------