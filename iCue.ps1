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
	Write-Host "5. Quit"

	$choice = Read-Host "Enter your choice (1-5)"

	switch ($choice) {
		'1' { winget install -e --id Corsair.iCUE.3 }
		'2' { winget install -e --id Corsair.iCUE.4 }
		'3' { winget install -e --id Corsair.iCUE.5 }
		'4' { winget install -e --id 9PG940D1ZDVP }
		'5' { exit }
		default { Write-Host "Invalid choice. Please enter a number between 1 and 5." }
	}
}