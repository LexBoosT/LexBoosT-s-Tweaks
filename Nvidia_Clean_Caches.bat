@echo off
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b
del /q "%programdata%\NVIDIA Corporation\NV_Cache\*"
for /d %%x in ("%localappdata%\NVIDIA\GLCache\*") do @rd /s /q "%%x"
for /d %%x in ("%localappdata%low\D3DSCache\*") do @rd /s /q "%%x"
for /d %%x in ("%localappdata%low\NVIDIA\PerDriverVersion\GLCache\*") do @rd /s /q "%%x"
for /d %%x in ("%localappdata%low\NVIDIA\PerDriverVersion\DXCache") do @rd /s /q "%%x"
for /d %%x in ("%AppData%\NVIDIA\ComputeCache\*") do @rd /s /q "%%x"
exit
