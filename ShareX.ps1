# Vérification de l'installation de Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Loading installation..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iwr -useb https://aka.ms/winget/install | iex
}

$package = winget list --id=ShareX.ShareX -e
if ($package) {
    Write-Host "ShareX is already installed. Checking for updates..."
    winget upgrade --id=ShareX.ShareX -e --force
} else {
    Write-Host "Install ShareX..."
    winget install --id=ShareX.ShareX -e --force
}
