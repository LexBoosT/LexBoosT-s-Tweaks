Add-Type -AssemblyName System.Windows.Forms
# LexBoosT BCD Tweaks for Better performances
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

function Art {
    param (
        [string]$artN,
        [string]$ch = "White"
    )

    $artN | ForEach-Object {
        Write-Host $_ -NoNewline -ForegroundColor $ch
    }

    Write-Host "`n"
}

function Invoke-FixesUpdate{
    Write-Host "1. Stopping Windows Update Services..."
    Stop-Service -Name BITS
    Stop-Service -Name wuauserv
    Stop-Service -Name appidsvc
    Stop-Service -Name cryptsvc
    Write-Host "2. Remove QMGR Data file..."
        Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue

    Write-Host "3. Renaming the Software Distribution and CatRoot Folder..."
        Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -ErrorAction SilentlyContinue
        Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue

    Write-Host "4. Removing old Windows Update log..."
        Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue

    Write-Host "5. Resetting the Windows Update Services to default settings..."
        Start-Process -NoNewWindow -FilePath "sc.exe" -ArgumentList "sdset", "bits", "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
        Start-Process -NoNewWindow -FilePath "sc.exe" -ArgumentList "sdset", "wuauserv", "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
        Set-Location $env:systemroot\system32

    Write-Host "6. Registering some DLLs..."
    $DLLs = @(
        "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll",
        "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll",
        "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll",
        "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll",
        "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll", "wuapi.dll",
        "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll",
        "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll"
    )
    foreach ($dll in $DLLs) {
        Start-Process -NoNewWindow -FilePath "regsvr32.exe" -ArgumentList "/s", $dll
    }

    Write-Host "7) Removing WSUS client settings..."
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate") {
        Start-Process -NoNewWindow -FilePath "REG" -ArgumentList "DELETE", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate", "/v", "AccountDomainSid", "/f"
        Start-Process -NoNewWindow -FilePath "REG" -ArgumentList "DELETE", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate", "/v", "PingID", "/f"
        Start-Process -NoNewWindow -FilePath "REG" -ArgumentList "DELETE", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate", "/v", "SusClientId", "/f"
    }

    Write-Host "8) Resetting the WinSock..."
        Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "winsock", "reset"
        Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "winhttp", "reset", "proxy"
        Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "int", "ip", "reset"

    Write-Host "9) Delete all BITS jobs..."
        Get-BitsTransfer | Remove-BitsTransfer

    Write-Host "10) Attempting to install the Windows Update Agent..."
    If ([System.Environment]::Is64BitOperatingSystem) {
        Start-Process -NoNewWindow -FilePath "wusa" -ArgumentList "Windows8-RT-KB2937636-x64", "/quiet"
    }
    else {
        Start-Process -NoNewWindow -FilePath "wusa" -ArgumentList "Windows8-RT-KB2937636-x86", "/quiet"
    }

    Write-Host "11) Starting Windows Update Services..."
        Start-Service -Name BITS
        Start-Service -Name wuauserv
        Start-Service -Name appidsvc
        Start-Service -Name cryptsvc

    Write-Host "12) Forcing discovery..."
    Start-Process -NoNewWindow -FilePath "wuauclt" -ArgumentList "/resetauthorization", "/detectnow"


    Write-Host "Process complete. Please reboot your computer."

    Art -artN "
    ===============================================
-- Reset All Windows Update Settings to Stock --
===============================================
" -ch DarkGreen
    Invoke-MessageBox -msg "updateFix"
}

function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|        LexBoosT Win Update Fix Menu       |"
    Write-Host "============================================="
    Write-Host "| 1. Fix Windows Update                     |" -ForegroundColor Blue
    Write-Host "| 2. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1 or 2 for Exit)"
    switch ($choice) {
        1 { Invoke-FixesUpdate }
        2 { Write-Host "Goodbye!"; Exit }
        default { Write-Host "Invalid choice. Please try again."; Pause }
    }
}

