@echo off
echo ============================================
echo. Clearing browser caches
echo ============================================

REM Close all browsers to avoid issues during cache deletion
taskkill /IM brave.exe /F 2>nul
taskkill /IM msedge.exe /F 2>nul
taskkill /IM opera.exe /F 2>nul
taskkill /IM opera_gx.exe /F 2>nul
taskkill /IM chrome.exe /F 2>nul
taskkill /IM firefox.exe /F 2>nul
taskkill /IM arc.exe /F 2>nul
taskkill /IM vivaldi.exe /F 2>nul

REM Wait a few seconds to ensure all browsers are completely closed
timeout /t 5 /nobreak >nul

REM Set paths to browser caches
set "BRAVE_CACHE=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
set "EDGE_CACHE=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"
set "OPERA_ONE_CACHE=%APPDATA%\Opera Software\Opera Stable\Cache"
set "OPERAGX_CACHE=%APPDATA%\Opera Software\Opera GX Stable\Cache"
set "CHROME_CACHE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"
set "FIREFOX_CACHE=%APPDATA%\Mozilla\Firefox\Profiles"
set "ARC_CACHE=%LOCALAPPDATA%\Arc\User Data\Default\Cache"
set "VIVALDI_CACHE=%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache"

REM Variable to track if any cache folder was found
set "CACHE_FOUND=0"

REM Check and delete caches if directories exist, set CACHE_FOUND if any cache is found
if exist "%BRAVE_CACHE%" (
    echo Clearing Brave cache...
    rmdir /s /q "%BRAVE_CACHE%"
    set "CACHE_FOUND=1"
)

if exist "%EDGE_CACHE%" (
    echo Clearing Edge cache...
    rmdir /s /q "%EDGE_CACHE%"
    set "CACHE_FOUND=1"
)

if exist "%OPERA_ONE_CACHE%" (
    echo Clearing Opera One cache...
    rmdir /s /q "%OPERA_ONE_CACHE%"
    set "CACHE_FOUND=1"
)

if exist "%OPERAGX_CACHE%" (
    echo Clearing OperaGX cache...
    rmdir /s /q "%OPERAGX_CACHE%"
    set "CACHE_FOUND=1"
)

if exist "%CHROME_CACHE%" (
    echo Clearing Chrome cache...
    rmdir /s /q "%CHROME_CACHE%"
    set "CACHE_FOUND=1"
)

if exist "%FIREFOX_CACHE%" (
    echo Clearing Firefox cache...
    REM Delete cache subfolders in Firefox profiles
    for /d %%d in ("%FIREFOX_CACHE%\*") do (
        if exist "%%d\cache2" (
            echo Clearing cache in Firefox profile %%d...
            rmdir /s /q "%%d\cache2"
            set "CACHE_FOUND=1"
        )
    )
)

if exist "%ARC_CACHE%" (
    echo Clearing Arc cache...
    rmdir /s /q "%ARC_CACHE%"
    set "CACHE_FOUND=1"
)

if exist "%VIVALDI_CACHE%" (
    echo Clearing Vivaldi cache...
    rmdir /s /q "%VIVALDI_CACHE%"
    set "CACHE_FOUND=1"
)

REM Check if any cache was found and cleared
if "%CACHE_FOUND%"=="0" (
    echo No cache folders found to delete.
)

echo ============================================
echo. Process completed.
echo ============================================
pause

