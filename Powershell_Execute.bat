@echo off
reg query "HKCU\Console" /v "DelegationConsole" 2>nul
if %errorlevel% neq 0 (
    reg add "HKCU\Console" /v "DelegationConsole" /t REG_SZ /d "{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" /f
)
reg query "HKCU\Console" /v "DelegationTerminal" 2>nul
if %errorlevel% neq 0 (
    reg add "HKCU\Console" /v "DelegationTerminal" /t REG_SZ /d "{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" /f
)
exit