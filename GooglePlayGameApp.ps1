# Vérification de l'installation de Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Loading installation..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iwr -useb https://aka.ms/winget/install | iex
}

winget.exe install --id Google.PlayGames.Beta --exact --source winget --accept-source-agreements --version "24.5.760.6" --silent --disable-interactivity --accept-package-agreements
