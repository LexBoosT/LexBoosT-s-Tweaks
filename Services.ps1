Add-Type -AssemblyName System.Windows.Forms
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

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

function gaming{
    $services_m = @(
        "BcastDVRUserService_48486de"
        "Browser"
        "BthAvctpSvc"
        "CaptureService_48486de"
        "edgeupdate"
        "edgeupdatem"
        "FontCache"
        "gupdate"
        "gupdatem"
        "lmhosts"
        "MicrosoftEdgeElevationService"
        "MSDTC"
        "NahimicService"
        "PerfHost"
        "QWAVE"
        "RtkBtManServ"
        "SharedAccess"
        "ssh-agent"
        "TrkWks"
        "WMPNetworkSvc"
        "WPDBusEnum"
        "WpnService"
        "WSearch"
        "XblAuthManager"
        "XblGameSave"
        "XboxNetApiSvc"
        "XboxGipSvc"
        "HPAppHelperCap"
        "HPDiagsCap"
        "HPNetworkCap"
        "HPSysInfoCap"
        "HpTouchpointAnalyticsService"
        "HvHost"
        "vmicguestinterface"
        "vmicheartbeat"
        "vmickvpexchange"
        "vmicrdv"
        "vmicshutdown"
        "vmictimesync"
        "vmicvmsession"
    )

    foreach ($service in $services_m) {
        Write-Host "Setting $service StartupType to Manual" -ForegroundColor Yellow
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -ErrorAction SilentlyContinue
    }

    $services_d = @(
        "ALG"
        "AJRouter"
        "tzautoupdate"
        "CertPropSvc"
        "DusmSvc"
        "DialogBlockingService"
        "DiagTrack"
        "diagnosticshub.standardcollector.service"
        "dmwappushservice"
        "DPS"
        "Fax"
        "fhsvc"
        "AppVClient"
        "MapsBroker"
        "MsKeyboardFilter"
        "uhssvc"
        "NcbService"
        "NetTcpPortSharing"
        "PcaSvc"
        "PhoneSvc"
        "PrintNotify"
        "RemoteRegistry"
        "RemoteAccess"
        "RetailDemo"
        "shpamsvc"
        "ScDeviceEnum"
        "SCPolicySvc"
        "SEMgrSvc"
        "seclogon"
        "stisvc"
        "Spooler"
        "SCardSvr"
        "SysMain"
        "UevAgentService"
        "lfsvc"
        "icssvc"
        "iphlpsvc"
        "WpcMonSvc"
        "WerSvc"
        "WbioSrvc"
        "wisvc"
    )

    foreach ($service in $services_d) {
        Write-Host "Setting $service StartupType to Disabled" -ForegroundColor Red
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Art -artN "
=======================================
----- Services set to Gaming Mode -----
=======================================
" -ch Cyan
Pause
}

function normal{
    cmd /c services.msc
Pause
}

function recommended{
    $services = @(
        "ALG"
        "BcastDVRUserService_48486de"
        "Browser"
        "BthAvctpSvc"
        "CaptureService_48486de"
        "cbdhsvc_48486de"
        "diagnosticshub.standardcollector.service"
        "DiagTrack"
        "dmwappushservice"
        "DPS"
        "edgeupdate"
        "edgeupdatem"
        "Fax"
        "fhsvc"
        "FontCache"
        "gupdate"
        "gupdatem"
        "lfsvc"
        "lmhosts"
        "MapsBroker"
        "MicrosoftEdgeElevationService"
        "MSDTC"
        "NahimicService"
        "NetTcpPortSharing"
        "PcaSvc"
        "PerfHost"
        "PhoneSvc"
        "PrintNotify"
        "QWAVE"
        "RemoteAccess"
        "RemoteRegistry"
        "RetailDemo"
        "RtkBtManServ"
        "SCardSvr"
        "seclogon"
        "SEMgrSvc"
        "SharedAccess"
        "ssh-agent"
        "stisvc"
        "SysMain"
        "TrkWks"
        "WerSvc"
        "wisvc"
        "WMPNetworkSvc"
        "WpcMonSvc"
        "WPDBusEnum"
        "WpnService"
        "WSearch"
        "XblAuthManager"
        "XblGameSave"
        "XboxNetApiSvc"
        "XboxGipSvc"
        "HPAppHelperCap"
        "HPDiagsCap"
        "HPNetworkCap"
        "HPSysInfoCap"
        "HpTouchpointAnalyticsService"
        "HvHost"
        "vmicguestinterface"
        "vmicheartbeat"
        "vmickvpexchange"
        "vmicrdv"
        "vmicshutdown"
        "vmictimesync"
        "vmicvmsession"
    )
    foreach ($service in $services) {
        Write-Host "Setting $service StartupType to Manual" -ForegroundColor Yellow
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -ErrorAction SilentlyContinue
    }
    Art -artN "
======================================
-- Services set to Recommended Mode --
======================================
" -ch Cyan
Pause
}

function Show-Menu
{
    Clear-Host
    Write-Host "============================================="
    Write-Host "|          LexBoosT Services Menu           |"
    Write-Host "============================================="
    Write-Host "| 1. Normal mode                            |" -ForegroundColor Blue
    Write-Host "| 2. Recommended mode                       |" -ForegroundColor Cyan
    Write-Host "| 3. Gaming mode                            |" -ForegroundColor Magenta
    Write-Host "| 4. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

# Boucle pour afficher le menu et gérer les choix de l'utilisateur
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2, 3 or 4 for Exit)"
    switch ($choice) {
        1 { normal }
        2 { recommended }
		3 { gaming }
        4 { Exit }
        default { Write-Host "Invalid choice. Please try again."; Pause }
    }
}