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

# Vérification de l'installation de Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Loading installation..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iwr -useb https://aka.ms/winget/install | iex
}

while ($true) {
	Write-Host "Choose the package to install :"
	Write-Host "1. Corsair iCUE 3"
	Write-Host "2. Corsair iCUE 4"
	Write-Host "3. Corsair iCUE 5"
	Write-Host "4. Corsair iCUE GameBar Widgets"
	Write-Host "0. Exit"

	$choice = Read-Host "Enter your choice (1, 2, 3, 4 or 0 for Quit)"

	switch ($choice) {
		'1' { winget install -e --id "Corsair.iCUE.3" --accept-package-agreements --accept-source-agreements --disable-interactivity --force -h }
		'2' { winget install -e --id "Corsair.iCUE.4" --accept-package-agreements --accept-source-agreements --disable-interactivity --force -h }
		'3' { winget install -e --id "Corsair.iCUE.5" --accept-package-agreements --accept-source-agreements --disable-interactivity --force -h }
		'4' { winget install -e --id "9PG940D1ZDVP" --accept-package-agreements --accept-source-agreements --disable-interactivity --force -h }
		'0' { exit }
		default { Write-Host "Invalid choice. Please try again." }
	}
}
