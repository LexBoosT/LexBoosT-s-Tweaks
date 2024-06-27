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

$keys = @(
    "EnhancedPowerManagementEnabled",
    "AllowIdleIrpInD3",
    "EnableSelectiveSuspend",
    "DeviceSelectiveSuspended",
    "SelectiveSuspendEnabled",
    "SelectiveSuspendOn",
    "EnumerationRetryCount",
    "ExtPropDescSemaphore",
    "WaitWakeEnabled",
    "D3ColdSupported",
    "WdfDirectedPowerTransitionEnable",
    "EnableIdlePowerManagement",
    "IdleInWorkingState",
    "IoLatencyCap",
    "DmaRemappingCompatible",
    "DmaRemappingCompatibleSelfhost"
)

foreach ($key in $keys) {
    $paths = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum" -Recurse | Get-ItemProperty -EA SilentlyContinue | Where-Object { $_.PSChildName -eq $key }
    foreach ($path in $paths) {
        Set-ItemProperty -Path $path.PSPath -Name $key -Value 1
    }
}
