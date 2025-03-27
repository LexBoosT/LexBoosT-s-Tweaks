Add-Type -AssemblyName System.Windows.Forms

# LexBoosT BCD Tweaks for Better performances
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

# Configuration du menu
$global:MenuConfig = @{
    Width       = 50
    LineChar    = '='
    SideBorder  = '|'
    CornerTL    = '+'
    CornerTR    = '+'
    CornerBL    = '+'
    CornerBR    = '+'
}

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

# Fonction pour définir la taille de la fenêtre
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

    # Header
    $headerLine = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"
    $headerText = "LexBoosT BCD Tweaks Menu"
    $paddingLeft = [math]::Max(0, ($global:MenuConfig.Width - $headerText.Length) / 2)
    $headerText = $headerText.PadLeft($headerText.Length + $paddingLeft).PadRight($global:MenuConfig.Width - 1)
    $headerLine2 = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"

    # Menu Items
    $menuItems = @(
        @{Text="1. Apply BCD tweaks"; Color="Blue"; Enabled=$true},
        @{Text="2. Restore default BCD values"; Color="Magenta"; Enabled=$true},
        @{Text="0. Exit"; Color="Red"; Enabled=$true}
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
function Apply-Tweaks {
    bcdedit /set tscsyncpolicy Enhanced
    bcdedit /timeout 0
    bcdedit /set bootux disabled
    bcdedit /set bootmenupolicy Legacy
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
    bcdedit /set lastknowngood yes
    if ((Get-WmiObject Win32_Processor).Name -like '*Intel*') {
        bcdedit /set nx optout
    } else {
        bcdedit /set nx alwaysoff
    }
    Write-Host "Tweaks applied." -ForegroundColor Green
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
    Write-Host "Default values restored." -ForegroundColor Green
    Pause
}

# Boucle pour afficher le menu et gérer les choix de l'utilisateur
while ($true) {
    Show-Menu
    $choice = Read-Host "`n[INPUT] Select option (0-2)"
    switch ($choice) {
        '1' { Apply-Tweaks }
        '2' { Restore-Defaults }
        '0' { Write-Host "Goodbye!" -ForegroundColor Cyan; Exit }
        default { Write-Host "`n[!] Invalid choice. Please try again." -ForegroundColor Red; Pause }
    }
}
