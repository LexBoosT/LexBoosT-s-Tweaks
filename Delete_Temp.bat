@echo off
takeown /f "%temp%" /r /d y
RD /S /Q "%temp%"
MKDIR "%temp%"

takeown /f "%SystemRoot%\Temp" /r /d y
RD /S /Q "%SystemRoot%\Temp"
MKDIR "%SystemRoot%\Temp"

RD /S /Q "%SystemDrive%\$GetCurrent"
RD /S /Q "%SystemDrive%\$SysReset"
RD /S /Q "%SystemDrive%\$Windows.~BT"
RD /S /Q "%SystemDrive%\$Windows.~WS"
RD /S /Q "%SystemDrive%\$WinREAgent"
RD /S /Q "%SystemDrive%\OneDriveTemp"
del /S /Q /F "%WINDIR%\Logs"
del /S /Q /F "%WINDIR%\Installer\$PatchCache$"

exit
