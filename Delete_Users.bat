@echo 
setlocal enabledelayedexpansion
rem # Delete Windows Defender user account
net user WDAGUtilityAccount /active:no
net user "WDAGUtilityAccount" /delete

rem # Delete web sign-in user account
net user WsiAccount /active:no
net user "WsiAccount" /delete

rem # Delete "defaultuser100000" account
net user defaultuser100000 /active:no
net user "defaultuser100000" /delete

rem # Delete "DefaultAccount" account
net user DefaultAccount /active:no
net user "DefaultAccount" /delete

rem # Delete Guest account
net user Guest /active:no
net user "Guest" /delete

rem # Delete controversial default0 user
net user defaultuser0 /active:no
net user defaultuser0 /delete
exit
