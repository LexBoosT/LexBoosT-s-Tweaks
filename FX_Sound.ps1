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

# Télécharger la dernière version de FxSound
$downloadUrl = "https://github.com/fxsound2/fxsound-app/raw/latest/release/fxsound_setup.exe" # Lien direct vers la dernière version
$outputPath = "$env:TEMP\FxSoundSetup.exe"

Write-Host "Downloading FxSound..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

# Installer FxSound
Write-Host "Installing FxSound..."
Start-Process -FilePath $outputPath -Wait
