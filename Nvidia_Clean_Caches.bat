@echo off
setlocal enabledelayedexpansion
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

echo ============================================
echo        LexBoosT Nvidia Caches Cleaner
echo ============================================
set "total_size=0"

echo Cleaning NVIDIA Corporation NV_Cache...
for %%F in ("%programdata%\NVIDIA Corporation\NV_Cache\*") do (
    set /a total_size+=%%~zF
    echo Deleting %%F
    takeown /f "%%F" >nul 2>&1
    icacls "%%F" /grant administrators:F >nul 2>&1
    del /q /f "%%F" >nul 2>&1
    if exist "%%F" (
        echo Failed to delete %%F
    )
)
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA GLCache...
for /d %%x in ("%localappdata%\NVIDIA\GLCache\*") do (
    for /r %%F in ("%%x\*") do (
        set /a total_size+=%%~zF
        echo Deleting %%F
        takeown /f "%%F" >nul 2>&1
        icacls "%%F" /grant administrators:F >nul 2>&1
        del /q /f "%%F" >nul 2>&1
        if exist "%%F" (
            echo Failed to delete %%F
        )
    )
    echo Deleting %%x
    rd /s /q "%%x"
)
for /d %%x in ("%AppData%\Local\NVIDIA\GLCache\*") do (
    for /r %%F in ("%%x\*") do (
        set /a total_size+=%%~zF
        echo Deleting %%F
        takeown /f "%%F" >nul 2>&1
        icacls "%%F" /grant administrators:F >nul 2>&1
        del /q /f "%%F" >nul 2>&1
        if exist "%%F" (
            echo Failed to delete %%F
        )
    )
    echo Deleting %%x
    rd /s /q "%%x"
)
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA D3DSCache...
for /d %%x in ("%localappdata%\low\D3DSCache\*") do (
    for /r %%F in ("%%x\*") do (
        set /a total_size+=%%~zF
        echo Deleting %%F
        takeown /f "%%F" >nul 2>&1
        icacls "%%F" /grant administrators:F >nul 2>&1
        del /q /f "%%F" >nul 2>&1
        if exist "%%F" (
            echo Failed to delete %%F
        )
    )
    echo Deleting %%x
    rd /s /q "%%x"
)
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA PerDriverVersion GLCache...
for /d %%x in ("%localappdata%\low\NVIDIA\PerDriverVersion\GLCache\*") do (
    for /r %%F in ("%%x\*") do (
        set /a total_size+=%%~zF
        echo Deleting %%F
        takeown /f "%%F" >nul 2>&1
        icacls "%%F" /grant administrators:F >nul 2>&1
        del /q /f "%%F" >nul 2>&1
        if exist "%%F" (
            echo Failed to delete %%F
        )
    )
    echo Deleting %%x
    rd /s /q "%%x"
)
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA PerDriverVersion DXCache...
for /d %%x in ("%localappdata%\low\NVIDIA\PerDriverVersion\DXCache\*") do (
    for /r %%F in ("%%x\*") do (
        set /a total_size+=%%~zF
        echo Deleting %%F
        takeown /f "%%F" >nul 2>&1
        icacls "%%F" /grant administrators:F >nul 2>&1
        del /q /f "%%F" >nul 2>&1
        if exist "%%F" (
            echo Failed to delete %%F
        )
    )
    echo Deleting %%x
    rd /s /q "%%x"
)
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA ComputeCache...
for /d %%x in ("%AppData%\NVIDIA\ComputeCache\*") do (
    for /r %%F in ("%%x\*") do (
        set /a total_size+=%%~zF
        echo Deleting %%F
        takeown /f "%%F" >nul 2>&1
        icacls "%%F" /grant administrators:F >nul 2>&1
        del /q /f "%%F" >nul 2>&1
        if exist "%%F" (
            echo Failed to delete %%F
        )
    )
    echo Deleting %%x
    rd /s /q "%%x"
)
timeout /t 3 /nobreak >nul

echo Cleaning DirectX ShaderCache...
for /d %%x in ("%localappdata%\Microsoft\DirectX\ShaderCache\*") do (
    for /r %%F in ("%%x\*") do (
        set /a total_size+=%%~zF
        echo Deleting %%F
        takeown /f "%%F" >nul 2>&1
        icacls "%%F" /grant administrators:F >nul 2>&1
        del /q /f "%%F" >nul 2>&1
        if exist "%%F" (
            echo Failed to delete %%F
        )
    )
    echo Deleting %%x
    rd /s /q "%%x"
)
timeout /t 3 /nobreak >nul

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
echo ============================================
echo Cleanup complete.
echo ============================================
timeout /t 3 /nobreak >nul
endlocal
exit
