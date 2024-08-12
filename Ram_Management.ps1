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
    Write-Host "============================================================="
    Write-Host "|          LexBoosT RAM Management Tweaks Menu              |"
    Write-Host "============================================================="
    Write-Host "| 1. Limits RAM to use certain tasks (IoPageLockLimit)      |" -ForegroundColor Blue
    Write-Host "| 2. Trim massive WorkingSet (CacheUnmapBehindLengthInMB)   |" -ForegroundColor Magenta
    Write-Host "| 3. Set ModifiedWriteMaximum (ModifiedWriteMaximum)        |" -ForegroundColor Green
    Write-Host "| 4. Configures all 3 options above at the same time        |" -ForegroundColor Yellow
    Write-Host "| 0. Exit                                                   |" -ForegroundColor Red
    Write-Host "============================================================="
}

function Get-RAMSizeInGB {
    $ramSizeBytes = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory
    $ramSizeGB = [math]::Round($ramSizeBytes / 1GB)
    return $ramSizeGB
}

function Set-IoPageLockLimit {
    param (
        [int]$ramGB
    )
    $value = $ramGB * 1024 * 1024 * 1024 / 512
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d $value /f
    Write-Host "IoPageLockLimit set to $value KB for $ramGB GB RAM"
    Start-Sleep -Seconds 2
}

function Set-CacheUnmapBehindLengthInMB {
    param (
        [int]$ramGB
    )
    if ($ramGB -le 4) { $value = 0x00000100 }
    elseif ($ramGB -le 8) { $value = 0x00000200 }
    elseif ($ramGB -le 12) { $value = 0x00000300 }
    elseif ($ramGB -le 16) { $value = 0x00000400 }
    elseif ($ramGB -le 32) { $value = 0x00000800 }
    elseif ($ramGB -le 64) { $value = 0x00001600 }
    elseif ($ramGB -le 128) { $value = 0x00003200 }
    elseif ($ramGB -le 256) { $value = 0x00006400 }
    else { $value = 0x0000C800 }
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "CacheUnmapBehindLengthInMB" /t REG_DWORD /d $value /f
    Write-Host "CacheUnmapBehindLengthInMB set to $value for $ramGB GB RAM"
    Start-Sleep -Seconds 2
}

function Set-ModifiedWriteMaximum {
    param (
        [int]$ramGB
    )
    if ($ramGB -le 4) { $value = 0x00000020 }
    elseif ($ramGB -le 8) { $value = 0x00000040 }
    elseif ($ramGB -le 12) { $value = 0x00000060 }
    elseif ($ramGB -le 16) { $value = 0x00000080 }
    elseif ($ramGB -le 32) { $value = 0x00000160 }
    elseif ($ramGB -le 64) { $value = 0x00000320 }
    elseif ($ramGB -le 128) { $value = 0x00000640 }
    elseif ($ramGB -le 256) { $value = 0x00000C80 }
    else { $value = 0x00001900 }
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ModifiedWriteMaximum" /t REG_DWORD /d $value /f
    Write-Host "ModifiedWriteMaximum set to $value for $ramGB GB RAM"
    Start-Sleep -Seconds 2
}

function Set-AllKeys {
    param (
        [int]$ramGB
    )
    Set-IoPageLockLimit -ramGB $ramGB
    Set-CacheUnmapBehindLengthInMB -ramGB $ramGB
    Set-ModifiedWriteMaximum -ramGB $ramGB
}

$ramGB = Get-RAMSizeInGB
Write-Host "Detected RAM size: $ramGB GB"

while ($true) {
    Show-Menu
    $choice = Read-Host "Choose an option"
    switch ($choice) {
        1 {
            Set-IoPageLockLimit -ramGB $ramGB
        }
        2 {
            Set-CacheUnmapBehindLengthInMB -ramGB $ramGB
        }
        3 {
            Set-ModifiedWriteMaximum -ramGB $ramGB
        }
        4 {
            Set-AllKeys -ramGB $ramGB
        }
        0 {
            Write-Host "Goodbye!"
            Start-Sleep -Seconds 2
            Exit
        }
        default {
            Write-Host "Invalid choice"
        }
    }
}

Write-Host "All registry keys have been set based on the detected RAM size."

