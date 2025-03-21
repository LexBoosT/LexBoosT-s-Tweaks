@echo off
setlocal enabledelayedexpansion

:: === Configuration ===
set "LOG_FILE=%TEMP%\CacheCleaner.log"

:: Liste des processus à tuer
set "PROCESSES=brave.exe msedge.exe opera.exe operagx.exe chrome.exe firefox.exe arc.exe vivaldi.exe"

:: Liste des caches à nettoyer (nom du navigateur = chemin du cache)
set "BRAVE_CACHE=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
set "EDGE_CACHE=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"
set "OPERA_CACHE=%APPDATA%\Opera Software\Opera Stable\Cache"
set "OPERAGX_CACHE=%APPDATA%\Opera Software\Opera GX Stable\Cache"
set "CHROME_CACHE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"
set "FIREFOX_CACHE=%APPDATA%\Mozilla\Firefox\Profiles"
set "ARC_CACHE=%LOCALAPPDATA%\Arc\User Data\Default\Cache"
set "VIVALDI_CACHE=%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache"

:: === Admin Check ===
net session >nul 2>&1 || (
    echo [INFO] Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c ""%~f0"" %*' -Verb RunAs"
    exit /b
)

:: === Main Script ===
echo ======================================================
echo  LexBoosT Browsers Caches Cleaner - Enterprise Edition
echo ======================================================

:: Kill browser processes
call :kill_processes

:: Clean browser caches
set "total_size_all=0"
call :clean_cache "Brave" "%BRAVE_CACHE%"
call :clean_cache "Edge" "%EDGE_CACHE%"
call :clean_cache "Opera" "%OPERA_CACHE%"
call :clean_cache "OperaGX" "%OPERAGX_CACHE%"
call :clean_cache "Chrome" "%CHROME_CACHE%"
call :clean_cache "Firefox" "%FIREFOX_CACHE%"
call :clean_cache "Arc" "%ARC_CACHE%"
call :clean_cache "Vivaldi" "%VIVALDI_CACHE%"

:: Display summary
call :log_message "INFO" "Total cleaned: %total_size_all% bytes"
echo ======================================================
echo [INFO] Total cleaned: %total_size_all% bytes
echo ======================================================

endlocal
pause
exit /b

:: === Functions ===

:kill_processes
    echo [INFO] Terminating browser processes...
    for %%P in (%PROCESSES%) do (
        taskkill /IM %%P >nul 2>&1 || (
            taskkill /F /IM %%P >nul 2>&1
            if !errorlevel! equ 0 (
                call :log_message "INFO" "Terminated process: %%P"
            ) else (
                call :log_message "WARNING" "Failed to terminate process: %%P"
            )
        )
    )
    exit /b

:clean_cache
    set "browser_name=%~1"
    set "cache_path=%~2"

    if not exist "!cache_path!\" (
        call :log_message "WARNING" "Cache path not found for !browser_name!: !cache_path!"
        exit /b
    )

    echo [INFO] Cleaning !browser_name! cache...
    call :log_message "INFO" "Cleaning !browser_name! cache: !cache_path!"

    :: Take ownership
    takeown /F "!cache_path!" /R /A >nul 2>&1
    if !errorlevel! neq 0 (
        call :log_message "ERROR" "Failed to take ownership of !cache_path!"
        exit /b
    )

    :: Grant permissions
    icacls "!cache_path!" /grant *S-1-5-32-544:F /T /C >nul 2>&1
    if !errorlevel! neq 0 (
        call :log_message "ERROR" "Failed to grant permissions for !cache_path!"
        exit /b
    )

    :: Calculate size and delete
    set "total_size=0"
    for /r "!cache_path!" %%f in (*) do (
        set /a total_size+=%%~zf
    )

    if !total_size! gtr 0 (
        rd /s /q "!cache_path!" >nul 2>&1
        if !errorlevel! equ 0 (
            set /a total_size_all+=!total_size!
            call :log_message "INFO" "Cleaned !browser_name! cache: !total_size! bytes"
        ) else (
            call :log_message "ERROR" "Failed to delete cache for !browser_name!"
        )
    ) else (
        call :log_message "INFO" "No cache found for !browser_name!"
    )
    exit /b

:log_message
    set "log_level=%~1"
    set "log_message=%~2"
    set "timestamp=%date% %time%"
    echo [!timestamp!] [!log_level!] !log_message! >> "%LOG_FILE%"
    exit /b
