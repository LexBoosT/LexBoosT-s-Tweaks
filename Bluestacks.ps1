# Vérification de l'installation de Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Loading installation..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iwr -useb https://aka.ms/winget/install | iex
}

winget install --id BlueStack.BlueStacks --exact --source winget --accept-source-agreements --version "5.20.0.1037" --silent --disable-interactivity --accept-package-agreements
