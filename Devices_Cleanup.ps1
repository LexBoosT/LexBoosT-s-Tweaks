# Vérifie si le script est exécuté en tant qu'administrateur
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relance le script en tant qu'administrateur si nécessaire
if (-not (Test-Admin)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Fonction pour nettoyer les périphériques
function Cleanup-Devices {
    # Message d'accueil
    Write-Host ""
    Write-Host "============================================="
    Write-Host "|          Starting Devices Cleanup         |" -ForegroundColor Red
    Write-Host "============================================="

    # Obtenir tous les périphériques PnP qui ne sont pas actuellement présents
    $devices = Get-PnpDevice -Status "Error" | Where-Object { $_.Present -eq $false }
    $totalDevices = $devices.Count
    $currentDevice = 0
    $removedDevices = 0

    # Boucle à travers chaque périphérique et le supprime
    foreach ($device in $devices) {
        $currentDevice++
        Write-Host "Removing device: $($device.Name)" -ForegroundColor Blue
        try {
            Remove-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
            $removedDevices++
        } catch {
            Write-Host "Error removing device: $($device.Name)" -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "Cleanup complete! $removedDevices devices removed." -ForegroundColor Blue
    Write-Host ""
	Start-Sleep -Seconds 3
	Show-Menu
}

# Menu principal
function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|      LexBoosT  Devices Cleanup Script     |" -ForegroundColor Red
    Write-Host "============================================="
    Write-Host "| 1. Start devices cleanup                  |"
    Write-Host "| 0. Exit                                   |"
    Write-Host "============================================="
    $choice = Read-Host "Please enter your choice. (1 to Start or 0 for Quit)"
    switch ($choice) {
        1 { Cleanup-Devices }
        0 { Write-Host "Thank you for using the device cleanup script. Have a great day!" -ForegroundColor Yellow
		    Start-Sleep -Seconds 3
			exit 
		  }
        default {
            Write-Host "Invalid choice, please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-Menu
        }
    }
}

Test-Admin
# Afficher le menu
Show-Menu

