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

# Script to free up RAM at specified intervals
param(
    [ValidateSet("2", "5", "10", "15", "uninstall", "status")]
    [string]$option
)

# Script to free up RAM at specified intervals
param(
    [ValidateSet("2", "5", "10", "15", "uninstall", "status")]
    [string]$option
)

# Function to free up RAM
function Free-RAM {
    Write-Host "Freeing up RAM..."
    # Exclude critical processes
    $excludedProcesses = @("explorer.exe", "csrss.exe", "winlogon.exe", "services.exe", "svchost.exe")
    Get-Process | Where-Object { $_.ProcessName -notin $excludedProcesses } | ForEach-Object { 
        $_.MinWorkingSet = [System.IntPtr]::Zero
        $_.MaxWorkingSet = [System.IntPtr]::Zero
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()
}

# Function to create the scheduled task
function Create-ScheduledTask {
    param (
        [int]$minutes
    )
    $taskName = "FreeRAM"
    $taskAction = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -WindowStyle Hidden -File `"$PSScriptRoot\FreeRAM.ps1`" -option $minutes"
    $taskTrigger = New-ScheduledTaskTrigger -AtStartup
    $taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
    Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal
    Write-Host "Scheduled task created to free RAM every $minutes minutes."
}

# Function to uninstall the scheduled task
function Uninstall-ScheduledTask {
    $taskName = "FreeRAM"
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Scheduled task '$taskName' has been uninstalled."
    } else {
        Write-Host "No scheduled task named '$taskName' found."
    }
}

# Function to show the status of the scheduled task
function Show-Status {
    $taskName = "FreeRAM"
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "Scheduled task '$taskName' is installed and configured."
    } else {
        Write-Host "Scheduled task '$taskName' is not found."
    }
}

# Display the menu
function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|    LexBoosT Free RAM Management           |"
    Write-Host "============================================="
    Write-Host "| 1. Set interval to 2 minutes              |" -ForegroundColor Blue
    Write-Host "| 2. Set interval to 5 minutes              |" -ForegroundColor Blue
    Write-Host "| 3. Set interval to 10 minutes             |" -ForegroundColor Blue
    Write-Host "| 4. Set interval to 15 minutes             |" -ForegroundColor Blue
    Write-Host "| 5. Uninstall scheduled task               |" -ForegroundColor Magenta
    Write-Host "| 6. Show status                            |" -ForegroundColor Yellow
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 { Create-ScheduledTask -minutes 2; Start-Sleep -Seconds 3; Clear-Host; Show-Menu }
        2 { Create-ScheduledTask -minutes 5; Start-Sleep -Seconds 3; Clear-Host; Show-Menu }
        3 { Create-ScheduledTask -minutes 10; Start-Sleep -Seconds 3; Clear-Host; Show-Menu }
        4 { Create-ScheduledTask -minutes 15; Start-Sleep -Seconds 3; Clear-Host; Show-Menu }
        5 { Uninstall-ScheduledTask; Start-Sleep -Seconds 3; Clear-Host; Show-Menu }
        6 { Show-Status; Start-Sleep -Seconds 3; Clear-Host; Show-Menu }
        0 { Write-Host "Goodbye!"; Start-Sleep -Seconds 3; Exit }
        default { Write-Host "Invalid choice. Please select an option from 0 to 6."; Start-Sleep -Seconds 3; Clear-Host; Show-Menu }
    }
}

# Run the menu if no option is passed
if (-not $option) {
    Show-Menu
} else {
    switch ($option) {
        "uninstall" { Uninstall-ScheduledTask; exit }
        "status" { Show-Status; exit }
        default {
            $minutes = [int]$option
            $seconds = $minutes * 60
            while ($true) {
                Free-RAM
                Start-Sleep -Seconds $seconds
            }
        }
    }
}
