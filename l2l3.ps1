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

# LexBoosT Script for Configure L2 and L3 Caches
# Get processor information
$Processor = Get-WmiObject -Class Win32_Processor

# Get cache sizes in KB
$L2Cache = $Processor.L2CacheSize
$L3Cache = $Processor.L3CacheSize

# Check if cache sizes are in MB and convert to KB if necessary
if ($L2Cache -lt 1024) {
    $L2Cache = $L2Cache * 1024
}
if ($L3Cache -lt 1024) {
    $L3Cache = $L3Cache * 1024
}

# Set registry keys
$Path = "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management"
if ((Get-ItemProperty -Path $Path).PSObject.Properties.Name -contains "SecondLevelDataCache") {
    Remove-ItemProperty -Path $Path -Name "SecondLevelDataCache"
}
New-ItemProperty -Path $Path -Name "SecondLevelDataCache" -Value $L2Cache -PropertyType DWORD

if ((Get-ItemProperty -Path $Path).PSObject.Properties.Name -contains "ThirdLevelDataCache") {
    Remove-ItemProperty -Path $Path -Name "ThirdLevelDataCache"
}
New-ItemProperty -Path $Path -Name "ThirdLevelDataCache" -Value $L3Cache -PropertyType DWORD




