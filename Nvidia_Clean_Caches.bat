@echo off

if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

echo Cleaning NVIDIA Corporation NV_Cache...
del /q "%programdata%\NVIDIA Corporation\NV_Cache\*"
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA GLCache...
for /d %%x in ("%localappdata%\NVIDIA\GLCache\*") do @rd /s /q "%%x"
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA D3DSCache...
for /d %%x in ("%localappdata%\low\D3DSCache\*") do @rd /s /q "%%x"
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA PerDriverVersion GLCache...
for /d %%x in ("%localappdata%\low\NVIDIA\PerDriverVersion\GLCache\*") do @rd /s /q "%%x"
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA PerDriverVersion DXCache...
for /d %%x in ("%localappdata%\low\NVIDIA\PerDriverVersion\DXCache\*") do @rd /s /q "%%x"
timeout /t 1 /nobreak >nul

echo Cleaning NVIDIA ComputeCache...
for /d %%x in ("%AppData%\NVIDIA\ComputeCache\*") do @rd /s /q "%%x"
timeout /t 3 /nobreak >nul

echo Cleaning DirectX ShaderCache...
for /d %%x in ("%localappdata%\Microsoft\DirectX\ShaderCache\*") do @rd /s /q "%%x"
timeout /t 3 /nobreak >nul

echo Cleanup complete.
pause
exit
