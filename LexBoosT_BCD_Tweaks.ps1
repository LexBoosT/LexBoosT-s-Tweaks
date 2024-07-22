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
    Write-Host "| 3. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

# Fonction pour appliquer les tweaks
function Apply-Tweaks {
    bcdedit /set tscsyncpolicy Enhanced
    bcdedit /set firstmegabytepolicy UseAll
    bcdedit /set avoidlowmemory 0x8000000
    bcdedit /set nolowmem Yes
    bcdedit /set allowedinmemorysettings 0x0
    bcdedit /set isolatedcontext No
    bcdedit /set vsmlaunchtype Off
    bcdedit /set vm No
    bcdedit /set x2apicpolicy Enable
    bcdedit /set configaccesspolicy Default
    bcdedit /set MSI Default
    bcdedit /set usephysicaldestination No
    bcdedit /set usefirmwarepcisettings No
    bcdedit /set disableelamdrivers Yes
    bcdedit /set pae ForceEnable
    bcdedit /set nx optout
    bcdedit /set highestmode Yes
    bcdedit /set forcefipscrypto No
    bcdedit /set noumex Yes
    bcdedit /set uselegacyapicmode No
    bcdedit /set ems No
    bcdedit /set extendedinput Yes
    bcdedit /set hypervisorlaunchtype Off
    Write-Host "Tweaks applied."
    Pause
}

# Fonction pour restaurer les valeurs par défaut
function Restore-Defaults {
    bcdedit /set tscsyncpolicy Default
    bcdedit /set firstmegabytepolicy Default
    bcdedit /set avoidlowmemory 0x0
    bcdedit /set nolowmem No
    bcdedit /set allowedinmemorysettings 0x1
    bcdedit /set isolatedcontext Yes
    bcdedit /set vsmlaunchtype Auto
    bcdedit /set vm Yes
    bcdedit /set x2apicpolicy Default
    bcdedit /set configaccesspolicy Default
    bcdedit /set MSI Default
    bcdedit /set usephysicaldestination Yes
    bcdedit /set usefirmwarepcisettings Yes
    bcdedit /set disableelamdrivers No
    bcdedit /set pae Default
    bcdedit /set nx OptIn
    bcdedit /set highestmode No
    bcdedit /set forcefipscrypto Yes
    bcdedit /set noumex No
    bcdedit /set uselegacyapicmode Yes
    bcdedit /set ems Yes
    bcdedit /set extendedinput No
    bcdedit /set hypervisorlaunchtype Auto
    Write-Host "Default values restored."
    Pause
}

# Boucle pour afficher le menu et gérer les choix de l'utilisateur
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2 or 3)"
    switch ($choice) {
        1 { Apply-Tweaks }
        2 { Restore-Defaults }
        3 { Write-Host "Goodbye!"; Exit }
        default { Write-Host "Invalid choice. Please try again."; Pause }
    }
}