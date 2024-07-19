$networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

$ipv4Dns = "1.1.1.1", "1.0.0.1"
$ipv6Dns = "2606:4700:4700::1111", "2606:4700:4700::1001"

foreach ($adapter in $networkAdapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $ipv4Dns
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $ipv6Dns
}
