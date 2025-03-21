Add-Type -AssemblyName System.Windows.Forms

# LexBoosT Network Mega Tweaks
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

# Configuration du menu
$global:MenuConfig = @{
    Width       = 70
    LineChar    = '='
    SideBorder  = '|'
    CornerTL    = '+'
    CornerTR    = '+'
    CornerBL    = '+'
    CornerBR    = '+'
}

# Vérifier les privilèges administratifs
function Test-Admin {
    Write-Host "Checking for Administrative Privileges..."
    Start-Sleep -Seconds 3

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

Test-Admin

# Fonction pour afficher le menu
function Show-Menu {
    Clear-Host

    # Header
    $headerLine = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"
    $headerText = "LexBoosT Network Tweaks Menu"
    $paddingLeft = [math]::Max(0, ($global:MenuConfig.Width - $headerText.Length) / 2)
    $headerText = $headerText.PadLeft($headerText.Length + $paddingLeft).PadRight($global:MenuConfig.Width - 1)
    $headerLine2 = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"

    # Menu Items
    $menuItems = @(
        @{Text="1.  Disable Explicit Congestion Notification $ecn"; Color="Blue"; Enabled=$true},
        @{Text="2.  Enable Direct Cache Access $dca"; Color="Blue"; Enabled=$true},
        @{Text="3.  Enable Network Direct Memory Access $netdma"; Color="Blue"; Enabled=$true},
        @{Text="4.  Disable Recieve Side Coalescing $rsc"; Color="Blue"; Enabled=$true},
        @{Text="5.  Enable Recieve Side Scaling $rss"; Color="Blue"; Enabled=$true},
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
        @{Text="17. Disable IPv6 $ipv6"; Color="Blue"; Enabled=$true},
        @{Text="18. Disable ISATAP $isatap"; Color="Blue"; Enabled=$true},
        @{Text="19. Disable Teredo $teredo"; Color="Blue"; Enabled=$true},
        @{Text="20. Select All"; Color="Yellow"; Enabled=$true},
        @{Text="21. Unselect All"; Color="Cyan"; Enabled=$true},
        @{Text="22. Apply Selected Tweaks"; Color="Green"; Enabled=$true},
        @{Text="23. Restore Default Network Values"; Color="Magenta"; Enabled=$true},
        @{Text="0.  Exit"; Color="Red"; Enabled=$true}
    )

    # Render
    Write-Host "$headerLine" -ForegroundColor Cyan
    Write-Host $headerText -ForegroundColor Cyan
    Write-Host "$headerLine2" -ForegroundColor Cyan

    foreach ($item in $menuItems) {
        $lineContent = $item.Text
        $padding = [math]::Max(0, $global:MenuConfig.Width - $lineContent.Length - 4)
        $displayLine = "$($global:MenuConfig.SideBorder) " +
                       $lineContent +
                       (" "*$padding) +
                       " $($global:MenuConfig.SideBorder)"

        Write-Host $displayLine -ForegroundColor $item.Color
    }

    Write-Host "$($global:MenuConfig.CornerBL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerBR)`n" -ForegroundColor Cyan
}

# Fonction pour appliquer les tweaks
function Invoke-Tweaks {
    if ($ecn -eq "*") {
        Write-Host "Disabling Explicit Congestion Notification" -ForegroundColor Green
        netsh int tcp set global ecncapability=disabled
    }
    if ($dca -eq "*") {
        Write-Host "Enabling Direct Cache Access" -ForegroundColor Green
        netsh int tcp set global dca=enabled
    }
    if ($netdma -eq "*") {
        Write-Host "Enabling Network Direct Memory Access" -ForegroundColor Green
        netsh int tcp set global netdma=enabled
    }
    if ($rsc -eq "*") {
        Write-Host "Disabling Recieve Side Coalescing" -ForegroundColor Green
        netsh int tcp set global rsc=disabled
    }
    if ($rss -eq "*") {
        Write-Host "Enabling Recieve Side Scaling" -ForegroundColor Green
        netsh int tcp set global rss=enabled
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Ndis\Parameters" /v "RssBaseCpu" /t REG_DWORD /d "1" /f >> APB_Log.txt
    }
    if ($timestamps -eq "*") {
        Write-Host "Disabling TCP Timestamps" -ForegroundColor Green
        netsh int tcp set global timestamps=disabled
    }
    if ($initialrto -eq "*") {
        Write-Host "Setting Initial Retransmission Timer" -ForegroundColor Green
        netsh int tcp set global initialRto=2000
    }
    $wifiConnection = Get-NetAdapter | Where-Object {$_.Name -like "*Wi-Fi*" -and $_.Status -eq "Up"}
    $ethernetConnection = Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*" -and $_.Status -eq "Up"}

    if ($wifiConnection) {
        if ($mtu -eq "*") {
            Write-Host "Setting MTU Size" -ForegroundColor Green
            netsh interface ipv4 set subinterface "Wi-Fi" mtu=1500 store=persistent
        }
    } elseif ($ethernetConnection) {
        if ($mtu -eq "*") {
            Write-Host "Setting MTU Size" -ForegroundColor Green
            netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
        }
    }
    if ($nonsackrtt -eq "*") {
        Write-Host "Disabling Non Sack RTT Resiliency" -ForegroundColor Green
        netsh int tcp set global nonsackrttresiliency=disabled
    }
    if ($maxsyn -eq "*") {
        Write-Host "Setting Max Syn Retransmissions" -ForegroundColor Green
        netsh int tcp set global maxsynretransmissions=2
    }
    if ($mpp -eq "*") {
        Write-Host "Disabling Memory Pressure Protection" -ForegroundColor Green
        netsh int tcp set security mpp=disabled
    }
    if ($profiles -eq "*") {
        Write-Host "Disabling Security Profiles" -ForegroundColor Green
        netsh int tcp set security profiles=disabled
    }
    if ($heuristics -eq "*") {
        Write-Host "Disabling Windows Scaling Heuristics" -ForegroundColor Green
        netsh int tcp set heuristics disabled
    }
    if ($arp -eq "*") {
        Write-Host "Increasing ARP Cache Size" -ForegroundColor Green
        netsh int ip set global neighborcachelimit=4096
    }
    if ($ctcp -eq "*") {
        Write-Host "Enabling CTCP" -ForegroundColor Green
        netsh int tcp set supplemental Internet congestionprovider=ctcp
    }
    if ($taskoffload -eq "*") {
        Write-Host "Disabling Task Offloading" -ForegroundColor Green
        netsh int ip set global taskoffload=disabled
    }
    if ($ipv6 -eq "*") {
        Write-Host "Disabling IPv6" -ForegroundColor Green
        netsh int ipv6 set state disabled
    }
    if ($isatap -eq "*") {
        Write-Host "Disabling ISATAP" -ForegroundColor Green
        netsh int isatap set state disabled
    }
    if ($teredo -eq "*") {
        Write-Host "Disabling Teredo" -ForegroundColor Green
        netsh int teredo set state disabled
    }
    Write-Host "Network tweaks applied." -ForegroundColor Green
    Pause
}

# Fonction pour restaurer les valeurs par défaut
function Restore-Defaults {
    Write-Host "Restoring default network values" -ForegroundColor Green
    netsh int tcp set global ecncapability=default
    netsh int tcp set global dca=disabled
    netsh int tcp set global netdma=disabled
    netsh int tcp set global rsc=enabled
    netsh int tcp set global rss=disabled
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Ndis\Parameters" /v "RssBaseCpu" /f >> APB_Log.txt
    netsh int tcp set global timestamps=enabled
    netsh int tcp set global initialRto=3000
    netsh interface ipv4 set subinterface "Ethernet" mtu=1492 store=persistent
    $wifiConnection = Get-NetAdapter | Where-Object {$_.Name -like "*Wi-Fi*" -and $_.Status -eq "Up"}
    $ethernetConnection = Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*" -and $_.Status -eq "Up"}

    if ($wifiConnection) {
        if ($mtu -eq "*") {
            Write-Host "Setting MTU Size" -ForegroundColor Green
            netsh interface ipv4 set subinterface "Wi-Fi" mtu=1500 store=persistent
        }
    } elseif ($ethernetConnection) {
        if ($mtu -eq "*") {
            Write-Host "Setting MTU Size" -ForegroundColor Green
            netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
        }
    }
    netsh int tcp set global nonsackrttresiliency=enabled
    netsh int tcp set global maxsynretransmissions=2
    netsh int tcp set security mpp=enabled
    netsh int tcp set security profiles=enabled
    netsh int tcp set heuristics enabled
    netsh int ip set global neighborcachelimit=256
    netsh int tcp set supplemental Internet congestionprovider=none
    netsh int ip set global taskoffload=enabled
    netsh int ipv6 set state enabled
    netsh int isatap set state enabled
    netsh int teredo set state enabled
    Write-Host "Default network values restored." -ForegroundColor Green
    Pause
}

# Variables pour suivre les options sélectionnées
$ecn = ""
$dca = ""
$netdma = ""
$rsc = ""
$rss = ""
$timestamps = ""
$initialrto = ""
$mtu = ""
$nonsackrtt = ""
$maxsyn = ""
$mpp = ""
$profiles = ""
$heuristics = ""
$arp = ""
$ctcp = ""
$taskoffload = ""
$ipv6 = ""
$isatap = ""
$teredo = ""

# Boucle principale
while ($true) {
    Show-Menu
    $choice = Read-Host "`n[INPUT] Select option (0-23)"
    switch ($choice) {
        1 {
            if ($ecn -eq "*") {
                $ecn = ""
            } else {
                $ecn = "*"
            }
        }
        2 {
            if ($dca -eq "*") {
                $dca = ""
            } else {
                $dca = "*"
            }
        }
        3 {
            if ($netdma -eq "*") {
                $netdma = ""
            } else {
                $netdma = "*"
            }
        }
        4 {
            if ($rsc -eq "*") {
                $rsc = ""
            } else {
                $rsc = "*"
            }
        }
        5 {
            if ($rss -eq "*") {
                $rss = ""
            } else {
                $rss = "*"
            }
        }
        6 {
            if ($timestamps -eq "*") {
                $timestamps = ""
            } else {
                $timestamps = "*"
            }
        }
        7 {
            if ($initialrto -eq "*") {
                $initialrto = ""
            } else {
                $initialrto = "*"
            }
        }
        8 {
            if ($mtu -eq "*") {
                $mtu = ""
            } else {
                $mtu = "*"
            }
        }
        9 {
            if ($nonsackrtt -eq "*") {
                $nonsackrtt = ""
            } else {
                $nonsackrtt = "*"
            }
        }
        10 {
            if ($maxsyn -eq "*") {
                $maxsyn = ""
            } else {
                $maxsyn = "*"
            }
        }
        11 {
            if ($mpp -eq "*") {
                $mpp = ""
            } else {
                $mpp = "*"
            }
        }
        12 {
            if ($profiles -eq "*") {
                $profiles = ""
            } else {
                $profiles = "*"
            }
        }
        13 {
            if ($heuristics -eq "*") {
                $heuristics = ""
            } else {
                $heuristics = "*"
            }
        }
        14 {
            if ($arp -eq "*") {
                $arp = ""
            } else {
                $arp = "*"
            }
        }
        15 {
            if ($ctcp -eq "*") {
                $ctcp = ""
            } else {
                $ctcp = "*"
            }
        }
        16 {
            if ($taskoffload -eq "*") {
                $taskoffload = ""
            } else {
                $taskoffload = "*"
            }
        }
        17 {
            if ($ipv6 -eq "*") {
                $ipv6 = ""
            } else {
                $ipv6 = "*"
            }
        }
        18 {
            if ($isatap -eq "*") {
                $isatap = ""
            } else {
                $isatap = "*"
            }
        }
        19 {
            if ($teredo -eq "*") {
                $teredo = ""
            } else {
                $teredo = "*"
            }
        }
        20 {
            $ecn = "*"
            $dca = "*"
            $netdma = "*"
            $rsc = "*"
            $rss = "*"
            $timestamps = "*"
            $initialrto = "*"
            $mtu = "*"
            $nonsackrtt = "*"
            $maxsyn = "*"
            $mpp = "*"
            $profiles = "*"
            $heuristics = "*"
            $arp = "*"
            $ctcp = "*"
            $taskoffload = "*"
            $ipv6 = "*"
            $isatap = "*"
            $teredo = "*"
        }
        21 {
            $ecn = ""
            $dca = ""
            $netdma = ""
            $rsc = ""
            $rss = ""
            $timestamps = ""
            $initialrto = ""
            $mtu = ""
            $nonsackrtt = ""
            $maxsyn = ""
            $mpp = ""
            $profiles = ""
            $heuristics = ""
            $arp = ""
            $ctcp = ""
            $taskoffload = ""
            $ipv6 = ""
            $isatap = ""
            $teredo = ""
        }
        22 {
            Invoke-Tweaks
        }
        23 {
            Restore-Defaults
        }
        0 {
            Write-Host "Goodbye!" -ForegroundColor Cyan
            Exit
        }
        default {
            Write-Host "`n[!] Invalid choice. Please try again." -ForegroundColor Red
            Pause
        }
    }
}