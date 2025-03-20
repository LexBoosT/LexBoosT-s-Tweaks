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
        Write-Warning "This script requires administrative privileges. Restarting with elevated privileges..."
        Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}
Check-Admin

# LexBoosT Script for Configure L2 and L3 Caches
# Get processor information
$Processor = Get-WmiObject -Class Win32_Processor

# Get cache sizes in KB
$L2Cache = ($Processor | Measure-Object -Property L2CacheSize -Maximum).Maximum
$L3Cache = ($Processor | Measure-Object -Property L3CacheSize -Maximum).Maximum

if ($L2Cache -lt 256 -or $L2Cache -gt 32768) {
    Write-Warning "Invalid L2 Cache Size: $L2Cache KB. The size must be between 256 KB and 32768 KB. Skipping registry update."
    exit
}
if ($L3Cache -lt 1024) {
    Write-Warning "Invalid L3 Cache Size: $L3Cache KB. The size must be at least 1024 KB. Skipping registry update."
    exit
}

# Set registry keys
$Path = "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management"
$SecondLevelCache = Get-ItemProperty -Path $Path -Name "SecondLevelDataCache" -ErrorAction SilentlyContinue
$ThirdLevelCache = Get-ItemProperty -Path $Path -Name "ThirdLevelDataCache" -ErrorAction SilentlyContinue

if ($SecondLevelCache -and $SecondLevelCache.SecondLevelDataCache -ne $L2Cache) {
    Remove-ItemProperty -Path $Path -Name "SecondLevelDataCache"
}
New-ItemProperty -Path $Path -Name "SecondLevelDataCache" -Value $L2Cache -PropertyType DWORD -Force

if ($ThirdLevelCache -and $ThirdLevelCache.ThirdLevelDataCache -ne $L3Cache) {
    Remove-ItemProperty -Path $Path -Name "ThirdLevelDataCache"
}
New-ItemProperty -Path $Path -Name "ThirdLevelDataCache" -Value $L3Cache -PropertyType DWORD -Force

Write-Host "L2 and L3 cache sizes have been updated successfully."




