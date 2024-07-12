# Vérification de l'installation de Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Loading installation..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
# Vérification de l'installation de Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Loading installation..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iwr -useb https://aka.ms/winget/install | iex
}

choco install goxlr-driver -y --no-progress
winget install -e --id GoXLR-on-Linux.GoXLR-Utility