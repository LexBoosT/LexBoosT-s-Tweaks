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

$networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

$ipv4Dns = "1.1.1.1", "1.0.0.1"
$ipv6Dns = "2606:4700:4700::1111", "2606:4700:4700::1001"

foreach ($adapter in $networkAdapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $ipv4Dns
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $ipv6Dns
}
