# LexBoosT NTFS Tweaks for Better Performances

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
    Write-Host "|        LexBoosT NTFS Tweaks Menu          |"
    Write-Host "============================================="
    Write-Host "| 1. Apply NTFS tweaks                      |" -ForegroundColor Blue
    Write-Host "| 2. Restore default NTFS values            |" -ForegroundColor Magenta
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}


# Fonction pour appliquer les tweaks NTFS
function Apply-Tweaks {
    Write-Host "Applying NTFS Tweaks..."
    fsutil behavior set memoryusage 2 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set mftzone 4 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set disablelastaccess 1 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set disabledeletenotify 0 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set encryptpagingfile 0 | Out-File -Append -FilePath "APB_Log.txt"
    Write-Host "NTFS tweaks applied."
    Pause
}

# Fonction pour restaurer les valeurs par défaut NTFS
function Restore-Defaults {
    Write-Host "Restoring default NTFS values..."
    fsutil behavior set memoryusage 1 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set mftzone 1 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set disablelastaccess 0 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set disabledeletenotify 1 | Out-File -Append -FilePath "APB_Log.txt"
    fsutil behavior set encryptpagingfile 1 | Out-File -Append -FilePath "APB_Log.txt"
    Write-Host "Default NTFS values restored."
    Pause
}

# Boucle pour afficher le menu et gérer les choix de l'utilisateur
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2) or 0 for Quit"
    switch ($choice) {
        1 { Apply-Tweaks }
        2 { Restore-Defaults }
        0 { Write-Host "Goodbye!"; Exit }
        default { Write-Host "Invalid choice. Please try again."; Pause }
    }
}

