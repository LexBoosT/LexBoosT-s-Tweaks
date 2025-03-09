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

function Disable-Sleep {
    $power_device_enable = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
    $usb_devices = @("Win32_USBController", "Win32_USBControllerDevice", "Win32_USBHub")
    foreach ($power_device in $power_device_enable) {
        $instance_name = $power_device.InstanceName.ToUpper()
        foreach ($device in $usb_devices) {
            foreach ($hub in Get-WmiObject $device) {
                $pnp_id = $hub.PNPDeviceID
                if ($instance_name -like "*$pnp_id*"){
                    $power_device.enable = $False
                    $power_device.psbase.put()
                }
            }
        }
    }
    Write-Host "Sleep mode disabled for USB devices."
}

function Enable-Sleep {
    $power_device_enable = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
    $usb_devices = @("Win32_USBController", "Win32_USBControllerDevice", "Win32_USBHub")
    foreach ($power_device in $power_device_enable) {
        $instance_name = $power_device.InstanceName.ToUpper()
        foreach ($device in $usb_devices) {
            foreach ($hub in Get-WmiObject $device) {
                $pnp_id = $hub.PNPDeviceID
                if ($instance_name -like "*$pnp_id*"){
                    $power_device.enable = $True
                    $power_device.psbase.put()
                }
            }
        }
    }
    Write-Host "Sleep mode enabled for USB devices."
}

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "=============================================" -ForegroundColor White
        Write-Host "|        Power Management Menu             |" -ForegroundColor White
        Write-Host "=============================================" -ForegroundColor White
        Write-Host "| 1. Disable Sleep for USB Devices         |" -ForegroundColor Blue
        Write-Host "| 2. Enable Sleep for USB Devices          |" -ForegroundColor Magenta
        Write-Host "| 0. Exit                                  |" -ForegroundColor Red
        Write-Host "=============================================" -ForegroundColor White
        $choice = Read-Host "Enter your choice"

        switch ($choice) {
            1 { Disable-Sleep
                Show-Menu
                }
            2 { Enable-Sleep
                Show-Menu
                }
            0 { exit }
            default { Write-Host "Invalid choice. Please try again." -ForegroundColor Yellow }
        }
        Read-Host "Press Enter to continue..."
    }
}

Show-Menu
