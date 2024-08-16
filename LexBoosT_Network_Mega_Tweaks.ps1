Add-Type -AssemblyName System.Windows.Forms
# LexBoosT Network Mega Tweaks
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

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
function Set-WindowSize {
    param (
        [int]$width,
        [int]$height
    )
    $psWindow = Get-Process -Id $PID
    $hwnd = $psWindow.MainWindowHandle
    $user32 = Add-Type -MemberDefinition @"
        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
"@ -Name "User32" -Namespace "Win32Functions" -PassThru
    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
    $windowX = [math]::Round(($screenWidth - $width) / 2)
    $windowY = [math]::Round(($screenHeight - $height) / 2)
    $user32::MoveWindow($hwnd, $windowX, $windowY, $width, $height, $true)
}

# Définir la taille de la fenêtre PowerShell
Set-WindowSize -width 510 -height 560
# Définir la taille du tampon de sortie pour éviter les barres de défilement
$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (510, 0)
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size (510, 0)

function Show-Menu {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "|       LexBoosT Network Tweaks Menu         |"
    Write-Host "=============================================="
    Write-Host "1.  Disable Explicit Congestion Notification $ecn"
    Write-Host "2.  Enable Direct Cache Access $dca"
    Write-Host "3.  Enable Network Direct Memory Access $netdma"
    Write-Host "4.  Disable Recieve Side Coalescing $rsc"
    Write-Host "5.  Enable Recieve Side Scaling $rss"
    Write-Host "6.  Disable TCP Timestamps $timestamps"
    Write-Host "7.  Set Initial Retransmission Timer $initialrto"
    Write-Host "8.  Set MTU Size (1500) $mtu"
    Write-Host "9.  Disable Non Sack RTT Resiliency $nonsackrtt"
    Write-Host "10. Set Max Syn Retransmissions $maxsyn"
    Write-Host "11. Disable Memory Pressure Protection $mpp"
    Write-Host "12. Disable Security Profiles $profiles"
    Write-Host "13. Disable Windows Scaling Heuristics $heuristics"
    Write-Host "14. Increase ARP Cache Size (256 > 4096) $arp"
    Write-Host "15. Enable CTCP $ctcp"
    Write-Host "16. Disable Task Offloading $taskoffload"
    Write-Host "17. Disable IPv6 $ipv6"
    Write-Host "18. Disable ISATAP $isatap"
    Write-Host "19. Disable Teredo $teredo"
    Write-Host "=============================================="
    Write-Host "| 20. Select All                             |" -ForegroundColor Yellow
    Write-Host "| 21. Unselect All                           |" -ForegroundColor Cyan
    Write-Host "| 22. Apply Selected Tweaks                  |" -ForegroundColor Blue
    Write-Host "| 23. Restore Default Network Values         |" -ForegroundColor Magenta
    Write-Host "| 0.  Exit                                  |" -ForegroundColor Red
    Write-Host "=============================================="
}

function Invoke-Tweaks {
    if ($ecn -eq "*") {
        Write-Host "Disabling Explicit Congestion Notification"
        netsh int tcp set global ecncapability=disabled
    }
    if ($dca -eq "*") {
        Write-Host "Enabling Direct Cache Access"
        netsh int tcp set global dca=enabled
    }
    if ($netdma -eq "*") {
        Write-Host "Enabling Network Direct Memory Access"
        netsh int tcp set global netdma=enabled
    }
    if ($rsc -eq "*") {
        Write-Host "Disabling Recieve Side Coalescing"
        netsh int tcp set global rsc=disabled
    }
    if ($rss -eq "*") {
        Write-Host "Enabling Recieve Side Scaling"
        netsh int tcp set global rss=enabled
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Ndis\Parameters" /v "RssBaseCpu" /t REG_DWORD /d "1" /f >> APB_Log.txt
    }
    if ($timestamps -eq "*") {
        Write-Host "Disabling TCP Timestamps"
        netsh int tcp set global timestamps=disabled
    }
    if ($initialrto -eq "*") {
        Write-Host "Setting Initial Retransmission Timer"
        netsh int tcp set global initialRto=2000
    }
    $wifiConnection = Get-NetAdapter | Where-Object {$_.Name -like "*Wi-Fi*" -and $_.Status -eq "Up"}
    $ethernetConnection = Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*" -and $_.Status -eq "Up"}

	if ($wifiConnection) {
		if ($mtu -eq "*") {
			Write-Host "Setting MTU Size"
			netsh interface ipv4 set subinterface "Wi-Fi" mtu=1500 store=persistent
		}
	} elseif ($ethernetConnection) {
		if ($mtu -eq "*") {
			Write-Host "Setting MTU Size"
			netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
		}
	}
    if ($nonsackrtt -eq "*") {
        Write-Host "Disabling Non Sack RTT Resiliency"
        netsh int tcp set global nonsackrttresiliency=disabled
    }
    if ($maxsyn -eq "*") {
        Write-Host "Setting Max Syn Retransmissions"
        netsh int tcp set global maxsynretransmissions=2
    }
    if ($mpp -eq "*") {
        Write-Host "Disabling Memory Pressure Protection"
        netsh int tcp set security mpp=disabled
    }
    if ($profiles -eq "*") {
        Write-Host "Disabling Security Profiles"
        netsh int tcp set security profiles=disabled
    }
    if ($heuristics -eq "*") {
        Write-Host "Disabling Windows Scaling Heuristics"
        netsh int tcp set heuristics disabled
    }
    if ($arp -eq "*") {
        Write-Host "Increasing ARP Cache Size"
        netsh int ip set global neighborcachelimit=4096
    }
    if ($ctcp -eq "*") {
        Write-Host "Enabling CTCP"
        netsh int tcp set supplemental Internet congestionprovider=ctcp
    }
    if ($taskoffload -eq "*") {
        Write-Host "Disabling Task Offloading"
        netsh int ip set global taskoffload=disabled
    }
    if ($ipv6 -eq "*") {
        Write-Host "Disabling IPv6"
        netsh int ipv6 set state disabled
    }
    if ($isatap -eq "*") {
        Write-Host "Disabling ISATAP"
        netsh int isatap set state disabled
    }
    if ($teredo -eq "*") {
        Write-Host "Disabling Teredo"
        netsh int teredo set state disabled
    }
    Write-Host "Network tweaks applied."
    Pause
}

function Restore-Defaults {
    Write-Host "Restoring default network values"
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
			Write-Host "Setting MTU Size"
			netsh interface ipv4 set subinterface "Wi-Fi" mtu=1500 store=persistent
		}
	} elseif ($ethernetConnection) {
		if ($mtu -eq "*") {
			Write-Host "Setting MTU Size"
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
    Write-Host "Default network values restored."
    Pause
}

$autotuning = ""
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

while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-23) or 0 for Quit"
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
            Write-Host "Goodbye!"
            Exit
        }
        default {
            Write-Host "Invalid choice. Please try again."
            Pause
        }
    }
}
