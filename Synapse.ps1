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

# Vérification de l'installation de Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Loading installation..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

while ($true) {
	Write-Host "Choose the package to install:"
	Write-Host "1. Razer Synapse 2"
	Write-Host "2. Razer Synapse 3"
	Write-Host "3. Razer Synapse 4"
	Write-Host "0. Exit"

	$choice = Read-Host "Enter your choice (1, 2, 3 or 0 for Quit)"

	switch ($choice) {
		'1' { choco install razer-synapse-2 -y --no-progress --force }
		'2' { winget install -e --id "RazerInc.RazerInstaller.Synapse3" --accept-package-agreements --accept-source-agreements --force }
		'3' { winget install -e --id "RazerInc.RazerInstaller.Synapse4" --accept-package-agreements --accept-source-agreements --force }
		'0' { exit }
		default { Write-Host "Invalid choice. Please try again." }
	}
}

