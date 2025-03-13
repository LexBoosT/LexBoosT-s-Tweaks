function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Clear-Devices {
    Write-Host ""
    Write-Host "============================================="
    Write-Host "|         Starting Devices Cleanup          |" -ForegroundColor Red
    Write-Host "============================================="
    $devices = Get-PnpDevice | Where-Object { $_.Status -ne "OK" -and $_.Status -ne "Running" -and $_.Status -ne "Starting" -and $_.Status -ne "Stopping" }
    $currentDevice = 0
    $removedDevices = 0
    foreach ($device in $devices) {
        $currentDevice++
        $escapedInstanceId = [regex]::Escape($device.InstanceId)
        $driverPackage = pnputil /enum-drivers | Select-String -Pattern $escapedInstanceId
        if ($driverPackage) {
            Write-Host "Removing device: $($device.Name)" -ForegroundColor Blue
            try {
                if (Get-Command -Name "Remove-PnpDevice" -ErrorAction SilentlyContinue) {
                    Remove-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -Force
                } else {
                    $driverPackageId = $driverPackage.ToString().Split(' ')[1]
                    pnputil /delete-driver $driverPackageId /force
                }
                $removedDevices++
            } catch {
                Write-Host "Error removing device: $($device.Name)" -ForegroundColor Red
                Write-Host "Error details: $_" -ForegroundColor Red
            }
        }
    }
    Write-Host ""
    Write-Host "Cleanup complete! $removedDevices devices removed." -ForegroundColor Blue
    Write-Host ""
    Start-Sleep -Seconds 3
    Show-Menu
}

function Clear-Logs {
    Write-Host ""
    Write-Host "============================================="
    Write-Host "|         Starting Logs Cleanup             |" -ForegroundColor Red
    Write-Host "============================================="
    $logs = Get-EventLog -LogName System | Where-Object { $_.Source -eq "PnP" }
    $currentLog = 0
    $removedLogs = 0
    foreach ($log in $logs) {
        $currentLog++
        Write-Host "Removing log entry: $($log.Message)" -ForegroundColor Blue
        try {
            Remove-EventLog -LogName System -EntryType $log.EntryType -Index $log.Index -Confirm:$false
            $removedLogs++
        } catch {
            Write-Host "Error removing log entry: $($log.Message)" -ForegroundColor Red
            Write-Host "Error details: $_" -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "Logs cleanup complete! $removedLogs log entries removed." -ForegroundColor Blue
    Write-Host ""
    Start-Sleep -Seconds 3
    Show-Menu
}

function Clear-OldDevices {
    Write-Host ""
    Write-Host "============================================="
    Write-Host "|      Starting Old Devices Cleanup         |" -ForegroundColor Red
    Write-Host "============================================="
    Write-Host "Please wait, this may take a while.." -ForegroundColor Yellow
    Write-Host ""
    $oldDevices = Get-PnpDevice | Where-Object { $_.LastArrival -lt (Get-Date).AddDays(-10) }
    $currentDevice = 0
    $removedDevices = 0
    foreach ($device in $oldDevices) {
        $currentDevice++
        $escapedInstanceId = [regex]::Escape($device.InstanceId)
        $driverPackage = pnputil /enum-drivers | Select-String -Pattern $escapedInstanceId
        if ($driverPackage) {
            Write-Host "Removing old device: $($device.Name)" -ForegroundColor Blue
            try {
                if (Get-Command -Name "Remove-PnpDevice" -ErrorAction SilentlyContinue) {
                    Remove-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -Force
                } else {
                    $driverPackageId = $driverPackage.ToString().Split(' ')[1]
                    pnputil /delete-driver $driverPackageId /force
                }
                $removedDevices++
            } catch {
                Write-Host "Error removing old device: $($device.Name)" -ForegroundColor Red
                Write-Host "Error details: $_" -ForegroundColor Red
            }
        }
    }
    Write-Host ""
    Write-Host "Old devices cleanup complete! $removedDevices old devices removed." -ForegroundColor Blue
    Write-Host ""
    Start-Sleep -Seconds 3
    Show-Menu
}

function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|      LexBoosT Devices Cleanup Script      |" -ForegroundColor Red
    Write-Host "============================================="
    Write-Host "| 1. Start devices cleanup                  |"
    Write-Host "| 2. Start logs cleanup                     |"
    Write-Host "| 3. Start old devices cleanup              |"
    Write-Host "| 0. Exit                                   |"
    Write-Host "============================================="
    $choice = Read-Host "Please enter your choice. (1, 2, 3, or 0 for Quit)"
    switch ($choice) {
        1 { Clear-Devices }
        2 { Clear-Logs }
        3 { Clear-OldDevices }
        0 {
            Write-Host "Thank you for using the device cleanup script. Have a great day!" -ForegroundColor Yellow
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

if (Test-Admin) {
    Show-Menu
} else {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
