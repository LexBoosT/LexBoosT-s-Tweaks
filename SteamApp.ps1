# Vérification de l'installation de Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Loading installation..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iwr -useb https://aka.ms/winget/install | iex
}

$package = winget list --id=Valve.Steam -e
if ($package) {
    Write-Host "Steam is already installed. Checking for updates..."
    winget upgrade --id=Valve.Steam -e --force
} else {
    Write-Host "Install Steam..."
    winget install --id=Valve.Steam -e --force
}
