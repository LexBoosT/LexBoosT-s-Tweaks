@echo 
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

setlocal enabledelayedexpansion
REM Obtenez le nom de l'utilisateur actuellement connecté
for /f "tokens=2 delims==" %%i in ('wmic ComputerSystem get UserName /value') do set "currentuser=%%i"
set "currentuser=%currentuser:~9%"
echo Utilisateur actuel : %currentuser%

REM Parcourez tous les utilisateurs du système
for /f "tokens=*" %%a in ('net user') do (
    for %%b in (%%a) do (
        REM Ignorez les lignes qui ne sont pas des noms d'utilisateur
        if not "%%b"=="Comptes" if not "%%b"=="-------" if not "%%b"=="commande" (
            REM Ignorez l'utilisateur actuellement connecté et l'administrateur
            if not "%%b"=="%currentuser%" if not "%%b"=="Administrator" (
                echo Suppression de l'utilisateur : %%b
                REM Supprimez l'utilisateur
                net user %%b /delete
            )
        )
    )
)

exit
