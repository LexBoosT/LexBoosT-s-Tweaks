# LexBoosT_Network_Mega_Tweaks (Full Fixed Version)
Add-Type -AssemblyName System.Windows.Forms

$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

$global:MenuConfig = @{
    Width       = 70
    LineChar    = '='
    SideBorder  = '|'
    CornerTL    = '+'
    CornerTR    = '+'
    CornerBL    = '+'
    CornerBR    = '+'
}

function Test-Admin {
    Write-Host "Checking Administrative Privileges..."
    Start-Sleep -Seconds 2

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

Test-Admin

function Show-Menu {
    Clear-Host

    $headerLine = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"
    $headerText = "LexBoosT Network Tweaks Menu (v2.2)"
    $paddingLeft = [math]::Max(0, ($global:MenuConfig.Width - $headerText.Length) / 2)
    $headerText = $headerText.PadLeft($headerText.Length + $paddingLeft).PadRight($global:MenuConfig.Width - 1)

    $menuItems = @(
        @{Text="1.  Disable Explicit Congestion Notification $ecn"; Color="Blue"; Enabled=$true},
        @{Text="2.  Enable Direct Cache Access $dca"; Color="Blue"; Enabled=$true},
        @{Text="3.  Enable Network Direct Memory Access $netdma"; Color="Blue"; Enabled=$true},
        @{Text="4.  Disable Receive Side Coalescing $rsc"; Color="Blue"; Enabled=$true},
        @{Text="5.  Enable Receive Side Scaling $rss"; Color="Blue"; Enabled=$true},
        @{Text="6.  Disable TCP Timestamps $timestamps"; Color="Blue"; Enabled=$true},
        @{Text="7.  Set Initial Retransmission Timer $initialrto"; Color="Blue"; Enabled=$true},
        @{Text="8.  Set MTU Size (1500) $mtu"; Color="Blue"; Enabled=$true},
        @{Text="9.  Disable Non Sack RTT Resiliency $nonsackrtt"; Color="Blue"; Enabled=$true},
        @{Text="10. Set Max Syn Retransmissions $maxsyn"; Color="Blue"; Enabled=$true},
        @{Text="11. Disable Memory Pressure Protection $mpp"; Color="Blue"; Enabled=$true},
        @{Text="12. Disable Security Profiles $profiles"; Color="Blue"; Enabled=$true},
        @{Text="13. Disable Windows Scaling Heuristics $heuristics"; Color="Blue"; Enabled=$true},
        @{Text="14. Increase ARP Cache Size (256 > 4096) $arp"; Color="Blue"; Enabled=$true},
        @{Text="15. Enable CTCP $ctcp"; Color="Blue"; Enabled=$true},
        @{Text="16. Disable Task Offloading $taskoffload"; Color="Blue"; Enabled=$true},
        @{Text="17. Disable IPv6 Tunnels (SAFE) $ipv6tun"; Color="Blue"; Enabled=$true},
        @{Text="18. Disable IPv6 Completely (ADVANCED) $ipv6full"; Color="Blue"; Enabled=$true},
        @{Text="19. Select All Optimizations"; Color="Cyan"; Enabled=$true},
        @{Text="20. Unselect All"; Color="Cyan"; Enabled=$true},
        @{Text="21. Apply Selected Tweaks"; Color="Green"; Enabled=$true},
        @{Text="22. Restore Default Settings"; Color="Magenta"; Enabled=$true},
        @{Text="0.  Exit"; Color="Red"; Enabled=$true}
    )

    Write-Host $headerLine -ForegroundColor Cyan
    Write-Host $headerText -ForegroundColor Cyan
    Write-Host $headerLine -ForegroundColor Cyan

    foreach ($item in $menuItems) {
        $lineContent = $item.Text
        $padding = [math]::Max(0, $global:MenuConfig.Width - $lineContent.Length - 4)
        $displayLine = "$($global:MenuConfig.SideBorder) $lineContent$(' ' * $padding) $($global:MenuConfig.SideBorder)"
        Write-Host $displayLine -ForegroundColor $item.Color
    }

    Write-Host "$($global:MenuConfig.CornerBL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerBR)`n" -ForegroundColor Cyan
}

function Invoke-Tweaks {
    $logStamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logFile = "NetworkTweaks_$logStamp.log"
    "=== Network Tweaks Log ($logStamp) ===" | Out-File $logFile

    if ($ecn -eq "*") {
        Write-Host "Disabling ECN..." -ForegroundColor Gray
        netsh int tcp set global ecncapability=disabled | Out-File $logFile -Append
    }
    if ($dca -eq "*") {
        Write-Host "Enabling DCA..." -ForegroundColor Gray
        netsh int tcp set global dca=enabled | Out-File $logFile -Append
    }
    if ($netdma -eq "*") {
        Write-Host "Enabling NetDMA..." -ForegroundColor Gray
        netsh int tcp set global netdma=enabled | Out-File $logFile -Append
    }
    if ($rsc -eq "*") {
        Write-Host "Disabling RSC..." -ForegroundColor Gray
        netsh int tcp set global rsc=disabled | Out-File $logFile -Append
    }
    if ($rss -eq "*") {
        Write-Host "Enabling RSS..." -ForegroundColor Gray
        netsh int tcp set global rss=enabled | Out-File $logFile -Append
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Ndis\Parameters" /v "RssBaseCpu" /t REG_DWORD /d 1 /f | Out-File $logFile -Append
    }
    if ($timestamps -eq "*") {
        Write-Host "Disabling TCP Timestamps..." -ForegroundColor Gray
        netsh int tcp set global timestamps=disabled | Out-File $logFile -Append
    }
    if ($initialrto -eq "*") {
        Write-Host "Setting Initial RTO..." -ForegroundColor Gray
        netsh int tcp set global initialRto=2000 | Out-File $logFile -Append
    }
    if ($mtu -eq "*") {
        $adapter = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and ($_.Name -like "*Wi-Fi*" -or $_.Name -like "*Ethernet*") }).Name
        if ($adapter) {
            Write-Host "Setting MTU to 1500..." -ForegroundColor Gray
            netsh interface ipv4 set subinterface "`"$adapter`"" mtu=1500 store=persistent | Out-File $logFile -Append
        }
    }
    if ($nonsackrtt -eq "*") {
        Write-Host "Disabling Non-Sack RTT..." -ForegroundColor Gray
        netsh int tcp set global nonsackrttresiliency=disabled | Out-File $logFile -Append
    }
    if ($maxsyn -eq "*") {
        Write-Host "Setting Max Syn Retransmissions..." -ForegroundColor Gray
        netsh int tcp set global maxsynretransmissions=2 | Out-File $logFile -Append
    }
    if ($mpp -eq "*") {
        Write-Host "Disabling Memory Pressure Protection..." -ForegroundColor Gray
        netsh int tcp set security mpp=disabled | Out-File $logFile -Append
    }
    if ($profiles -eq "*") {
        Write-Host "Disabling Security Profiles..." -ForegroundColor Gray
        netsh int tcp set security profiles=disabled | Out-File $logFile -Append
    }
    if ($heuristics -eq "*") {
        Write-Host "Disabling Scaling Heuristics..." -ForegroundColor Gray
        netsh int tcp set heuristics disabled | Out-File $logFile -Append
    }
    if ($arp -eq "*") {
        Write-Host "Increasing ARP Cache..." -ForegroundColor Gray
        netsh int ip set global neighborcachelimit=4096 | Out-File $logFile -Append
    }
    if ($ctcp -eq "*") {
        Write-Host "Enabling CTCP..." -ForegroundColor Gray
        netsh int tcp set supplemental Internet congestionprovider=ctcp | Out-File $logFile -Append
    }
    if ($taskoffload -eq "*") {
        Write-Host "Disabling Task Offload..." -ForegroundColor Gray
        netsh int ip set global taskoffload=disabled | Out-File $logFile -Append
    }
    if ($ipv6tun -eq "*") {
        Write-Host "Disabling IPv6 Tunnels..." -ForegroundColor Yellow
        @('teredo', 'isatap', '6to4') | ForEach-Object {
            netsh interface $_ set state disabled | Out-File $logFile -Append
        }
    }
    if ($ipv6full -eq "*") {
        Write-Host "DISABLING IPv6 COMPLETELY..." -ForegroundColor Red
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 255 /f | Out-File $logFile -Append
        Write-Host "WARNING: System restart required for IPv6 changes!" -ForegroundColor Red
    }

    Write-Host "`nAll tweaks applied. Log saved to: $logFile" -ForegroundColor Green
    Pause
}

function Restore-Defaults {
    Write-Host "Restoring Defaults..." -ForegroundColor Magenta
    netsh int tcp reset | Out-Null
    netsh int ip reset | Out-Null
    netsh winsock reset | Out-Null

    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Ndis\Parameters" /v "RssBaseCpu" /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 0 /f | Out-Null

    Get-NetAdapter | ForEach-Object {
        netsh interface ipv4 set subinterface "`"$($_.Name)`"" mtu=1492 store=persistent | Out-Null
        Enable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6 | Out-Null
    }

    @('teredo', 'isatap', '6to4') | ForEach-Object {
        netsh interface $_ set state enabled | Out-Null
    }

    Write-Host "Defaults restored. Reboot recommended." -ForegroundColor Green
    Pause
}

$ecn = $dca = $netdma = $rsc = $rss = $timestamps = $initialrto = $mtu = $nonsackrtt = $maxsyn = $mpp = $profiles = $heuristics = $arp = $ctcp = $taskoffload = $ipv6tun = $ipv6full = ""

while ($true) {
    Show-Menu
    $choice = Read-Host "`n[INPUT] Select option (0-22)"

    switch ($choice) {
        1 { $ecn = if ($ecn -eq "*") { "" } else { "*" } }
        2 { $dca = if ($dca -eq "*") { "" } else { "*" } }
        3 { $netdma = if ($netdma -eq "*") { "" } else { "*" } }
        4 { $rsc = if ($rsc -eq "*") { "" } else { "*" } }
        5 { $rss = if ($rss -eq "*") { "" } else { "*" } }
        6 { $timestamps = if ($timestamps -eq "*") { "" } else { "*" } }
        7 { $initialrto = if ($initialrto -eq "*") { "" } else { "*" } }
        8 { $mtu = if ($mtu -eq "*") { "" } else { "*" } }
        9 { $nonsackrtt = if ($nonsackrtt -eq "*") { "" } else { "*" } }
        10 { $maxsyn = if ($maxsyn -eq "*") { "" } else { "*" } }
        11 { $mpp = if ($mpp -eq "*") { "" } else { "*" } }
        12 { $profiles = if ($profiles -eq "*") { "" } else { "*" } }
        13 { $heuristics = if ($heuristics -eq "*") { "" } else { "*" } }
        14 { $arp = if ($arp -eq "*") { "" } else { "*" } }
        15 { $ctcp = if ($ctcp -eq "*") { "" } else { "*" } }
        16 { $taskoffload = if ($taskoffload -eq "*") { "" } else { "*" } }
        17 { $ipv6tun = if ($ipv6tun -eq "*") { "" } else { "*" } }
        18 {
            $confirm = Read-Host "WARNING: This may break modern apps! Confirm? (Y/N)"
            if ($confirm -eq 'Y') { $ipv6full = "*" }
        }
        19 {
            $ecn = $dca = $netdma = $rsc = $rss = $timestamps = $initialrto = $mtu = $nonsackrtt = $maxsyn = $mpp = $profiles = $heuristics = $arp = $ctcp = $taskoffload = $ipv6tun = "*"
            $ipv6full = ""
        }
        20 {
            $ecn = $dca = $netdma = $rsc = $rss = $timestamps = $initialrto = $mtu = $nonsackrtt = $maxsyn = $mpp = $profiles = $heuristics = $arp = $ctcp = $taskoffload = $ipv6tun = $ipv6full = ""
        }
        21 { Invoke-Tweaks }
        22 { Restore-Defaults }
        0 {
            Write-Host "Goodbye!" -ForegroundColor Cyan
            Exit
        }
        default {
            Write-Host "Invalid choice. Try again." -ForegroundColor Red
            Pause
        }
    }
}
