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

function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|        LexBoosT Drivers Cleaner Menu      |"
    Write-Host "============================================="
    Write-Host "| 1. Apply Duplicate Drivers Cleaner        |" -ForegroundColor Blue
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

function Apply-Tweaks {
	$OriginalFileName = @{
		Name = "OriginalFileName"
		Expression = {$_.OriginalFileName | Split-Path -Leaf}
	}
	$Date = @{
		Name = "Date"
		Expression = {$_.Date.Tostring().Split("")[0]}
	}
	$AllDrivers = Get-WindowsDriver -Online -All | Where-Object -FilterScript {$_.Driver -like 'oem*inf'} | Select-Object -Property $OriginalFileName, Driver, ClassDescription, ProviderName, $Date, Version

	Write-Verbose "`nAll installed third-party drivers" -Verbose
	($AllDrivers | Sort-Object -Property ClassDescription | Format-Table -AutoSize -Wrap | Out-String).Trim()
	$DriverGroups = $AllDrivers | Group-Object -Property OriginalFileName | Where-Object -FilterScript {$_.Count -gt 1}

	Write-Verbose "`nDuplicate drivers" -Verbose
	($DriverGroups | ForEach-Object -Process {$_.Group | Sort-Object -Property Date -Descending | Select-Object -Skip 1} | Format-Table | Out-String).Trim()
	$DriversToRemove = $DriverGroups | ForEach-Object -Process {$_.Group | Sort-Object -Property Date -Descending | Select-Object -Skip 1}

	Write-Verbose "`nDrivers to remove" -Verbose
	($DriversToRemove | Sort-Object -Property ClassDescription | Format-Table | Out-String).Trim()

	foreach ($item in $DriversToRemove)
	{
		$Name = $($item.Driver).Trim()
		& pnputil.exe /delete-driver "$Name" /force
	}
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Enter 1 for Cleaning Drivers or 0 for Quit"
    switch ($choice) {
        1 { Apply-Tweaks }
        0 { Write-Host "Goodbye!"; Exit }
        default { Write-Host "Invalid choice. Please try again."; Pause }
    }
}