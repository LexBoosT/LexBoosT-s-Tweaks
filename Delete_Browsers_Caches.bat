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
set "PROCESSES=brave.exe msedge.exe opera.exe opera_gx.exe chrome.exe arc.exe vivaldi.exe firefox.exe"
set "BRAVE_CACHE="%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache""
set "EDGE_CACHE="%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache""
set "OPERA_ONE_CACHE="%APPDATA%\Opera Software\Opera Stable\Cache""
set "OPERAGX_CACHE="%APPDATA%\Opera Software\Opera GX Stable\Cache""
set "CHROME_CACHE="%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache""
set "ARC_CACHE="%LOCALAPPDATA%\Arc\User Data\Default\Cache""
set "VIVALDI_CACHE="%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache""
set "FIREFOX_PROFILE_PATH=C:\Users\%USERNAME%\AppData\Local\Mozilla\Firefox\Profiles"
for /f "tokens=*" %%a in ('"dir /b "%FIREFOX_PROFILE_PATH%" 2>nul | findstr ".*\.default-release""') do set "FIREFOX_CACHE_PATH=%FIREFOX_PROFILE_PATH%\%%a"
for %%P in (%PROCESSES%) do (
    taskkill /F /IM %%P >nul 2>&1
    if !errorlevel! equ 0 (
        echo ============================================
        echo Process %%P stopped successfully.
        echo ============================================
        echo.
    )
)

set total_size_all=0

call :clean_cache BRAVE_CACHE %BRAVE_CACHE%
call :clean_cache EDGE_CACHE %EDGE_CACHE%
call :clean_cache OPERA_ONE_CACHE %OPERA_ONE_CACHE%
call :clean_cache OPERAGX_CACHE %OPERAGX_CACHE%
call :clean_cache CHROME_CACHE %CHROME_CACHE%
call :clean_cache ARC_CACHE %ARC_CACHE%
call :clean_cache VIVALDI_CACHE %VIVALDI_CACHE%
call :clean_firefox_cache FIREFOX_CACHE %FIREFOX_CACHE_PATH%

set /a total_size_all_kb=!total_size_all!/1024
echo ============================================
echo. Process Success.
echo ============================================
echo ============================================
echo Total caches cleaned: !total_size_all_kb! Ko
echo ============================================

endlocal
pause
exit /b

:clean_cache
set "cache_path=%~2"
if exist "%CACHE_PATH%" (
    set total_size=0
    for /r "%CACHE_PATH%" %%f in (*) do (
        set /a total_size+=%%~zf
    )
    if !total_size! gtr 0 (
        echo Cache cleaning: "%CACHE_PATH%"
        powershell -Command "Start-Process cmd -ArgumentList '/c takeown /F "%CACHE_PATH%" /R /A' -Verb RunAs"
        powershell -Command "Start-Process cmd -ArgumentList '/c icacls "%CACHE_PATH%" /grant *S-1-5-32-544:F /T' -Verb RunAs"
        echo Taille totale en octets: !total_size!
        set /a total_size_kb=!total_size!/1024
        echo Total Ko size: !total_size_kb!
        rd /s /q "%CACHE_PATH%"
        set /a total_size_all+=!total_size!
    )
)
exit /b

:clean_firefox_cache
set "cache_path=%~2"
if exist "%cache_path%" (
    set total_size=0
    for %%f in ("%cache_path%\cache2\entries\*" "%cache_path%\startupCache\*.bin" "%cache_path%\startupCache\*.lz*" "%cache_path%\cache2\index*.*" "%cache_path%\startupCache\*.little" "%cache_path%\cache2\*.log") do (
        if exist "%%f" (
            for /r "%%f" %%g in (*) do (
                set /a total_size+=%%~zg
            )
        )
    )
    echo ============================================
    echo Taille totale des fichiers Firefox nettoyés: !total_size! octets
    set /a total_size_all+=total_size
    set /a total_size_kb=total_size/1024
    echo Total Firefox Ko size: !total_size_kb!
    echo ============================================
    del /q "%cache_path%\cache2\entries\*." 2>nul
    del /q "%cache_path%\startupCache\*.bin" 2>nul
    del /q "%cache_path%\startupCache\*.lz*" 2>nul
    del /q "%cache_path%\cache2\index*.*" 2>nul
    del /q "%cache_path%\startupCache\*.little" 2>nul
    del /q "%cache_path%\cache2\*.log" 2>nul
)
exit /b
