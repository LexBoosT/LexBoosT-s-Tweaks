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
set "BRAVE_CACHE=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
set "EDGE_CACHE=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"
set "OPERA_ONE_CACHE=%APPDATA%\Opera Software\Opera Stable\Cache"
set "OPERAGX_CACHE=%APPDATA%\Opera Software\Opera GX Stable\Cache"
set "CHROME_CACHE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"
set "FIREFOX_CACHE=%APPDATA%\Mozilla\Firefox\Profiles"
set "ARC_CACHE=%LOCALAPPDATA%\Arc\User Data\Default\Cache"
set "VIVALDI_CACHE=%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache"
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
REM Convertir la taille totale en Mo avec deux chiffres après la virgule
set /a total_size_mb=total_size / 1024 / 1024
set /a total_size_kb=(total_size / 1024) %% 1024
set /a total_size_bytes=total_size %% 1024
set "total_size_formatted=!total_size_mb!.!total_size_kb:~0,2!"
echo.
echo ============================================
echo Total deleted files : !total_size_formatted! Mo
echo ============================================
echo.
endlocal
echo ============================================
echo. Process completed.
echo ============================================
pause
exit /b
:clean_cache
set "cache_key=%~1"
set "cache_path=%~2"
if exist "!cache_path!" (
echo Nettoyage du cache : !cache_path!
for /r "!cache_path!" %%F in (*) do (
set /a total_size+=%%~zF
del /q "%%F" >nul 2>&1
if !errorlevel! neq 0 (
echo Failed to delete file: %%F
)
)
REM Supprimer les sous-répertoires vides
for /d /r "!cache_path!" %%D in (*) do (
rmdir /s /q "%%D" >nul 2>&1
if !errorlevel! neq 0 (
echo Failed to delete directory: %%D
)
)
)
exit /b
