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
$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (560, 560)
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size (560, 0)

# Fonction pour afficher le menu
function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|        LexBoosT Restart to Bios           |"
    Write-Host "============================================="
    Write-Host "| 1. Add Restart to Bios on Contexte Menu   |" -ForegroundColor Blue
    Write-Host "| 2. Delete Restart to Bios on Contexte Menu|" -ForegroundColor Magenta
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

# Chemin de l'icône
$iconPath = "C:\Windows\System32\shell32.dll,24"

# Clé de registre pour le menu contextuel
$regPath = "HKCU:\Software\Classes\DesktopBackground\Shell\RestartToBIOS"

function Add-RestartToBIOS {
    # Créer la clé de registre
    New-Item -Path $regPath -Force

    # Définir les valeurs de la clé de registre
    Set-ItemProperty -Path $regPath -Name "(Default)" -Value "Restart to BIOS"
    Set-ItemProperty -Path $regPath -Name "Icon" -Value $iconPath
    New-Item -Path "$regPath\command" -Force

    # Définir la commande pour exécuter avec des privilèges administratifs
    $command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `"Start-Process shutdown.exe -ArgumentList '/r /fw /t 1' -Verb RunAs`""
    Set-ItemProperty -Path "$regPath\command" -Name "(Default)" -Value $command

    Write-Output "Success!"
}

function Remove-RestartToBIOS {
    # Supprimer la clé de registre
    Remove-Item -Path $regPath -Recurse -Force
    Write-Output "Success!"
}

# Afficher le menu et gérer les choix de l'utilisateur
do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 { Add-RestartToBIOS }
        2 { Remove-RestartToBIOS }
        0 { Write-Host "Bye!"; break }
        default { Write-Host "Invalid choice, please try again." }
    }
    Start-Sleep -Seconds 2
} while ($choice -ne 0)

