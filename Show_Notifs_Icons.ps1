Add-Type -AssemblyName System.Windows.Forms
# LexBoosT BCD Tweaks for Better performances
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

function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|     LexBoosT Notification Icons Menu      |"
    Write-Host "============================================="
    Write-Host "| 1. Show All Notification Icons            |" -ForegroundColor Blue
    Write-Host "| 2. Hide All Notification Icons            |" -ForegroundColor Magenta
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

function Show-AllNotificationIcons {
    $baseKeyPath = "HKCU:\Control Panel\NotifyIconSettings"
    $baseKey = Get-Item -Path $baseKeyPath

    foreach ($subKey in $baseKey.GetSubKeyNames()) {
        $subKeyPath = "$baseKeyPath\$subKey"
        Set-ItemProperty -Path $subKeyPath -Name "IsPromoted" -Value 1 -Force -ErrorAction SilentlyContinue
    }
}

function Hide-AllNotificationIcons {
    $baseKeyPath = "HKCU:\Control Panel\NotifyIconSettings"
    $baseKey = Get-Item -Path $baseKeyPath

    foreach ($subKey in $baseKey.GetSubKeyNames()) {
        $subKeyPath = "$baseKeyPath\$subKey"
        Set-ItemProperty -Path $subKeyPath -Name "IsPromoted" -Value 0 -Force -ErrorAction SilentlyContinue
    }
}

function Restart-Explorer {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer -ErrorAction SilentlyContinue
}

# Menu interactif
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 {
            Show-AllNotificationIcons
            Restart-Explorer
            Write-Host "All notification icons are now visible."
            Show-Menu
        }
        2 {
            Hide-AllNotificationIcons
            Restart-Explorer
            Write-Host "All notification icons are now hidden."
			Start-Sleep -Seconds 2
            Show-Menu
        }
        0 {
            Write-Host "Goodbye!"
			Start-Sleep -Seconds 2
			Exit
			
        }
        default {
            Write-Host "Invalid choice. Please try again."
			Start-Sleep -Seconds 2
            Show-Menu
        }
    }
}