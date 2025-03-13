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
echo. Clearing Nvidia caches
echo ============================================

set "NV_Cache="%programdata%\NVIDIA Corporation\NV_Cache\""
set "GLCache="%localappdata%\NVIDIA\GLCache\""
set "GLCache2="%AppData%\Local\NVIDIA\GLCache\""
set "D3DSCache="%localappdata%\low\D3DSCache\""
set "GLCache3="%localappdata%\low\NVIDIA\PerDriverVersion\GLCache\""
set "DXCache="%localappdata%\low\NVIDIA\PerDriverVersion\DXCache\""
set "ComputeCache="%AppData%\NVIDIA\ComputeCache\""
set "ShaderCache="%localappdata%\Microsoft\DirectX\ShaderCache\""


REM Initialise total size for all caches
set total_size_all=0

REM Nettoyer le cache
call :clean_cache NV_Cache %NV_Cache%
call :clean_cache GLCache %GLCache%
call :clean_cache GLCache2 %GLCache2%
call :clean_cache D3DSCache %D3DSCache%
call :clean_cache GLCache3 %GLCache3%
call :clean_cache DXCache %DXCache%
call :clean_cache ComputeCache %ComputeCache%
call :clean_cache ShaderCache %ShaderCache%

REM Display total size for all caches
set /a total_size_all_kb=!total_size_all!/1024
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
        REM echo Fichier trouvé : %%f, taille : %%~zf octets
        set /a total_size+=%%~zf
    )
    if !total_size! gtr 0 (
        echo Cache cleaning: "%CACHE_PATH%"
        powershell -Command "Start-Process cmd -ArgumentList '/c takeown /F "%CACHE_PATH%" /R /A' -Verb RunAs"
        powershell -Command "Start-Process cmd -ArgumentList '/c icacls "%CACHE_PATH%" /grant *S-1-5-32-544:F /T' -Verb RunAs"
        echo Taille totale en octets: !total_size!
        set /a total_size_kb=!total_size!/1024
        echo Total Ko size: !total_size_kb!
        echo ============================================
        echo. Process Success.
        echo ============================================
        rd /s /q "%CACHE_PATH%"
        set /a total_size_all+=!total_size!
    )
)
exit /b
