$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

# Vérifier les privilèges administratifs
function Check-Admin {
    Write-Host "Checking for Administrative Privileges..."
    Start-Sleep -Seconds 3

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}
Check-Admin
Clear-Host

function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|     LexBoosT Disk Optimizations Menu      |"
	Write-Host "============================================="
    Write-Host "|          Choose your Main Disk            |"
    Write-Host "============================================="
    Write-Host "| 1. SSD                                    |" -ForegroundColor Blue
    Write-Host "| 2. HDD                                    |" -ForegroundColor Magenta
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

# Commande pour définir IoLatencyCap à 0
$cmd1 = @"
FOR /F "eol=E" %a in ('REG QUERY "HKLM\SYSTEM\CurrentControlSet\Services" /S /F "IoLatencyCap"^| FINDSTR /V "IoLatencyCap"') DO (
    REG ADD "%a" /F /V "IoLatencyCap" /T REG_DWORD /d 0 >NUL 2>&1

    FOR /F "tokens=*" %z IN ("%a") DO (
        SET STR=%z
        SET STR=!STR:HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\=!
        SET STR=!STR:\Parameters=!
        ECHO Setting IoLatencyCap to 0 in !STR!
    )
)
"@

# Commande pour désactiver HIPM et DIPM
$cmd2 = @"
FOR /F "eol=E" %a in ('REG QUERY "HKLM\SYSTEM\CurrentControlSet\Services" /S /F "EnableHIPM"^| FINDSTR /V "EnableHIPM"') DO (
    REG ADD "%a" /F /V "EnableHIPM" /T REG_DWORD /d 0 >NUL 2>&1
    REG ADD "%a" /F /V "EnableDIPM" /T REG_DWORD /d 0 >NUL 2>&1
    REG ADD "%a" /F /V "EnableHDDParking" /T REG_DWORD /d 0 >NUL 2>&1

    FOR /F "tokens=*" %z IN ("%a") DO (
        SET STR=%z
        SET STR=!STR:HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\=!
        ECHO Disabling HIPM and DIPM in !STR!
    )
)
"@

function Execute-Choice {
    param (
        [string]$choice
    )

    switch ($choice) {
        "1" {
            Write-Host "You selected SSD. Applying SSD optimizations..." -ForegroundColor Blue
            cmd.exe /c "fsutil behavior set disableLastAccess 0"
            cmd.exe /c "fsutil behavior set disable8dot3 1"
            cmd.exe /c $cmd1
            Write-Host "IoLatencyCap has been set to 0 successfully." -ForegroundColor Green
            Start-Sleep -Seconds 3
            cmd.exe /c $cmd2
            Write-Host "HIPM and DIPM have been disabled successfully." -ForegroundColor Green
            Start-Sleep -Seconds 3
        }
        "2" {
            Write-Host "You selected HDD. Applying HDD optimizations..." -ForegroundColor Blue
            cmd.exe /c "fsutil behavior set disableLastAccess 1"
            cmd.exe /c "fsutil behavior set disable8dot3 1"
            cmd.exe /c $cmd1
            Write-Host "IoLatencyCap has been set to 0 successfully." -ForegroundColor Green
            Start-Sleep -Seconds 3
            cmd.exe /c $cmd2
            Write-Host "HIPM and DIPM have been disabled successfully." -ForegroundColor Green
            Start-Sleep -Seconds 3
        }
        "0" {
            Write-Host "Bye!" -ForegroundColor Red
            Start-Sleep -Seconds 3
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 3
        }
    }
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2, or 0)"
    Execute-Choice -choice $choice
}
