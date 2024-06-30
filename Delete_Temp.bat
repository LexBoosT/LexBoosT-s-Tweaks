@echo off
takeown /f "%temp%" /r /d y
RD /S /Q "%temp%"
MKDIR "%temp%"

takeown /f "%SystemRoot%\Temp" /r /d y
RD /S /Q "%SystemRoot%\Temp"
MKDIR "%SystemRoot%\Temp"
exit