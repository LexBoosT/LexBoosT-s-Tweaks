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

# Fonction pour afficher le menu
function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|        LexBoosT BCD Tweaks Menu           |"
    Write-Host "============================================="
    Write-Host "| 1. Apply BCD tweaks                       |" -ForegroundColor Blue
    Write-Host "| 2. Restore default BCD values             |" -ForegroundColor Magenta
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

# Fonction pour appliquer les tweaks
function Apply-Tweaks {
    bcdedit /set tscsyncpolicy Enhanced
	bcdedit /timeout 0
	bcdedit /set bootux disabled
	bcdedit /set bootmenupolicy standard
	bcdedit /set quietboot yes
	bcdedit /set allowedinmemorysettings 0x0
	bcdedit /set vsmlaunchtype Off
  	bcdedit /deletevalue nx
 	bcdedit /set vm No
	bcdedit /set x2apicpolicy Enable
	bcdedit /set uselegacyapicmode No
	bcdedit /set configaccesspolicy Default
	bcdedit /set usephysicaldestination No
	bcdedit /set usefirmwarepcisettings No
if ((Get-WmiObject Win32_Processor).Name -like '*Intel*') {

  bcdedit /set nx optout

} else {

  bcdedit /set nx alwaysoff

}
    Write-Host "Tweaks applied."
    Pause
}

# Fonction pour restaurer les valeurs par défaut
function Restore-Defaults {
    bcdedit /deletevalue tscsyncpolicy
    bcdedit /timeout 3
    bcdedit /deletevalue bootux
    bcdedit /set bootmenupolicy standard
    bcdedit /set hypervisorlaunchtype Auto
	bcdedit /deletevalue tpmbootentropy
	bcdedit /deletevalue quietboot
	bcdedit /set nx optin
	bcdedit /set allowedinmemorysettings 0x17000077
    bcdedit /set isolatedcontext Yes
    bcdedit /deletevalue vsmlaunchtype
    bcdedit /deletevalue vm
    bcdedit /deletevalue firstmegabytepolicy
    bcdedit /deletevalue avoidlowmemory
    bcdedit /deletevalue nolowmem
    bcdedit /deletevalue configaccesspolicy
    bcdedit /deletevalue x2apicpolicy
    bcdedit /deletevalue usephysicaldestination
    bcdedit /deletevalue usefirmwarepcisettings

    Write-Host "Default values restored."
    Pause
}

# Boucle pour afficher le menu et gérer les choix de l'utilisateur
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2 or 0 for Quit)"
    switch ($choice) {
        1 { Apply-Tweaks }
        2 { Restore-Defaults }
        0 { Write-Host "Goodbye!"; Exit }
        default { Write-Host "Invalid choice. Please try again."; Pause }
    }
}
