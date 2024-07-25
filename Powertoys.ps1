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

# Télécharger la dernière version de PowerToys
$downloadUrl = "https://github.com/microsoft/PowerToys/releases/download/v0.82.1/PowerToysSetup-0.82.1-x64.exe" # Remplacez ceci par l'URL de la dernière version
$outputPath = "$env:TEMP\PowerToysSetup.exe"

Write-Host "Downloading PowerToys..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

# Installer PowerToys
Write-Host "Installing PowerToys..."
Start-Process -FilePath $outputPath -Wait
