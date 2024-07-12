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

while ($true) {
	Write-Host "Choose the package to install:"
	Write-Host "1. Razer Synapse 2"
	Write-Host "2. Razer Synapse 3"
	Write-Host "3. Quit"

	$choice = Read-Host "Enter your choice (1-3)"

	switch ($choice) {
		'1' { choco install razer-synapse-2 -y --no-progress }
		'2' { winget install -e --id RazerInc.RazerInstaller }
		'3' { exit }
		default { Write-Host "Invalid choice. Please enter a number between 1 and 3." }
	}
}