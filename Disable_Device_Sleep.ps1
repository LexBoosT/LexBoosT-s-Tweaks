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
