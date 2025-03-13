@echo off
setlocal enabledelayedexpansion
set "___args="%~f0" %*"
fltmc > nul 2>&1 || (
echo Administrator privileges are required.
powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList """/c $env:___args"""" 2> nul || (
echo You must run this script as admin.
if "%*"=="" pause
exit /b 1
)
exit /b
)
echo ============================================
echo. Clearing browser caches
echo ============================================
REM Liste des processus à tuer
set "PROCESSES=brave.exe msedge.exe opera.exe opera_gx.exe chrome.exe firefox.exe arc.exe vivaldi.exe"
REM Chemins des caches des navigateurs
set "BRAVE_CACHE="%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache""
set "EDGE_CACHE="%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache""
set "OPERA_ONE_CACHE="%APPDATA%\Opera Software\Opera Stable\Cache""
set "OPERAGX_CACHE="%APPDATA%\Opera Software\Opera GX Stable\Cache""
set "CHROME_CACHE="%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache""
set "FIREFOX_CACHE="%APPDATA%\Mozilla\Firefox\Profiles""
set "ARC_CACHE="%LOCALAPPDATA%\Arc\User Data\Default\Cache""
set "VIVALDI_CACHE="%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache""
REM Tuer les processus
for %%P in (%PROCESSES%) do (
taskkill /F /IM %%P >nul 2>&1
if !errorlevel! equ 0 (
echo Process %%P stopped successfully.
)
)
REM Nettoyer les caches
set "total_size=0"
call :clean_cache BRAVE_CACHE !BRAVE_CACHE!
call :clean_cache EDGE_CACHE !EDGE_CACHE!
call :clean_cache OPERA_ONE_CACHE !OPERA_ONE_CACHE!
call :clean_cache OPERAGX_CACHE !OPERAGX_CACHE!
call :clean_cache CHROME_CACHE !CHROME_CACHE!
call :clean_cache FIREFOX_CACHE !FIREFOX_CACHE!
call :clean_cache ARC_CACHE !ARC_CACHE!
call :clean_cache VIVALDI_CACHE !VIVALDI_CACHE!
endlocal
echo ============================================
echo. Process completed.
echo ============================================
pause
exit /b
:clean_cache
set "cache_path=%~2"
if exist "!cache_path!" (
    echo Clean Cache : "!cache_path!"
    powershell -Command "Start-Process cmd -ArgumentList '/c takeown /F ""!cache_path!"" /R /A' -Verb RunAs" >nul 2>&1
    powershell -Command "Start-Process cmd -ArgumentList '/c icacls ""!cache_path!"" /grant *S-1-5-32-544:F /T' -Verb RunAs" >nul 2>&1
    dir "!cache_path!"
    for /r "!cache_path!" %%f in (*) do (
        echo Files size %%f: %%~zf
        set /a total_size+=%%~zf
    )
    rd /s /q "!cache_path!"
)
exit /b
