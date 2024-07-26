# Vérification de l'installation de Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Loading installation..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iwr -useb https://aka.ms/winget/install | iex
}

Start-Process -Wait -FilePath "winget" -ArgumentList "install -e --id Microsoft.VisualStudioCode --silent --force"
Start-Process -FilePath "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalCache\Local\Microsoft\WinGet"