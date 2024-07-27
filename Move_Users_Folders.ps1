Add-Type -AssemblyName System.Windows.Forms
# Set PowerShell window background color to black
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
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
cls

# Detect current locations of user folders
#function Update-CurrentPaths {
#    $global:currentDocumentsPath = [Environment]::GetFolderPath("MyDocuments")
#    $global:currentPicturesPath = [Environment]::GetFolderPath("MyPictures")
#    $global:currentMusicPath = [Environment]::GetFolderPath("MyMusic")
#    $global:currentVideosPath = [Environment]::GetFolderPath("MyVideos")
#    $global:currentDownloadsPath = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}")."{374DE290-123F-4565-9164-39C4925E467B}"
#    $global:currentFavoritesPath = [Environment]::GetFolderPath("Favorites")
#    $global:currentDesktopPath = [Environment]::GetFolderPath("Desktop")
#}
function Update-CurrentPaths {
    $global:currentDocumentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
    $global:currentPicturesPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyPictures)
    $global:currentMusicPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyMusic)
    $global:currentVideosPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyVideos)
    $global:currentDownloadsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\Downloads"
#    $global:currentDownloadsPath = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}")."{374DE290-123F-4565-9164-39C4925E467B}"
    $global:currentFavoritesPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::Favorites)
    $global:currentDesktopPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
}


Update-CurrentPaths

# Fonction pour vérifier si la lettre est en majuscule
function Is-UpperCase {
	param (
		[string]$char
	)
	return $char -cmatch '^[A-Z]$'
}
		
function Set-WindowSize {
    param (
        [int]$width,
        [int]$height
    )
    $psWindow = Get-Process -Id $PID
    $hwnd = $psWindow.MainWindowHandle
    $user32 = Add-Type -MemberDefinition @"
        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
"@ -Name "User32" -Namespace "Win32Functions" -PassThru
    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
    $windowX = [math]::Round(($screenWidth - $width) / 2)
    $windowY = [math]::Round(($screenHeight - $height) / 2)
    $user32::MoveWindow($hwnd, $windowX, $windowY, $width, $height, $true)
}

# Définir la taille de la mémoire tampon d'écran et de la fenêtre PowerShell
$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (120, 200)
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size (120, 40)
Set-WindowSize -width 510 -height 530

cls

# Function to move a user folder
function Move-UserFolder {
    param (
        [string]$folderName,
        [string]$registryName,
        [string]$currentPath,
        [string]$driveLetter,
        [string]$specificFolder
    )

    $folderName = Split-Path -Leaf $currentPath
    if ([string]::IsNullOrEmpty($specificFolder)) {
        $newPath = "$driveLetter`:\$folderName"
    } else {
        $newPath = "$driveLetter`:\$specificFolder\$folderName"
    }

    # Check if the current path is not empty
    if ([string]::IsNullOrEmpty($currentPath)) {
        Write-Output "Error: The current path for $folderName is empty. Please check if the folder exists."
        return
    }

    # Adjust permissions for the current folder
    icacls $currentPath /grant "$($env:USERNAME):F" /T

    # Move the folder and overwrite existing files
    $items = Get-ChildItem -Path $currentPath -Recurse -ErrorAction SilentlyContinue
    $totalItems = $items.Count
    $counter = 0

    foreach ($item in $items) {
        $destination = $item.FullName -replace [regex]::Escape($currentPath), $newPath
        Move-Item -Path $item.FullName -Destination $destination -Force -ErrorAction SilentlyContinue > $null
        $counter++
        $progress = [math]::Round(($counter / $totalItems) * 100)
        Write-Progress -Activity "Moving $folderName" -Status "$progress% Complete" -PercentComplete $progress
    }

    # Update the registry to point to the new location
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $registryName -Value $newPath
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name $registryName -Value $newPath

    Write-Output "$folderName successfully moved to $newPath"

    # Clean up memory
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

# Display current locations of user folders in a styled table
	Write-Host "=============================================="
	Write-Host "|        Current Locations of User Folders   |" -ForegroundColor Red
	Write-Host "=============================================="
	Write-Host " Documents:  $currentDocumentsPath" -ForegroundColor Yellow
	Write-Host " Pictures:   $currentPicturesPath" -ForegroundColor Yellow
	Write-Host " Music:      $currentMusicPath" -ForegroundColor Yellow
	Write-Host " Videos:     $currentVideosPath" -ForegroundColor Yellow
	Write-Host " Downloads:  $currentDownloadsPath" -ForegroundColor Yellow
	Write-Host " Favorites:  $currentFavoritesPath" -ForegroundColor Yellow
	Write-Host " Desktop:    $currentDesktopPath" -ForegroundColor Yellow
	Write-Host "=============================================="
	Write-Host "|                                            |"
	Write-Host "=============================================="

# Function to display the menu
function Show-Menu {
	Write-Host "=============================================="
	Write-Host "|       LexBoosT Easy Move User Folders      |" -ForegroundColor Red
    Write-Host "=============================================="
    Write-Host "|        Choose the User Folder to Move      |" 
    Write-Host "=============================================="
	Write-Host "| 1. Documents                               |" -ForegroundColor Cyan
	Write-Host "| 2. Pictures                                |" -ForegroundColor Green
	Write-Host "| 3. Music                                   |" -ForegroundColor Magenta
	Write-Host "| 4. Videos                                  |" -ForegroundColor Blue
	Write-Host "| 5. Downloads                               |" -ForegroundColor White
	Write-Host "| 6. Favorites                               |" -ForegroundColor Gray
	Write-Host "| 7. Desktop                                 |" -ForegroundColor Yellow
	Write-Host "| 0. Quit                                    |" -ForegroundColor Red
	Write-Host "=============================================="

}

# Main script
$selectedFolders = @()

do {
    Show-Menu
    $choice = Read-Host "Enter the folder numbers separated by commas`n (e.g., 1,3,5) or 0 to quit"

    if ($choice -eq "0") {
        Write-Host "Goodbye!" -ForegroundColor Green
        exit
    }

    $choices = $choice -split ","
    foreach ($c in $choices) {
        switch ($c.Trim()) {
            1 { $selectedFolders += @{"Name"="Documents"; "Registry"="Personal"; "Path"=$currentDocumentsPath} }
            2 { $selectedFolders += @{"Name"="Pictures"; "Registry"="My Pictures"; "Path"=$currentPicturesPath} }
            3 { $selectedFolders += @{"Name"="Music"; "Registry"="My Music"; "Path"=$currentMusicPath} }
            4 { $selectedFolders += @{"Name"="Videos"; "Registry"="My Video"; "Path"=$currentVideosPath} }
            5 { $selectedFolders += @{"Name"="Downloads"; "Registry"="{374DE290-123F-4565-9164-39C4925E467B}"; "Path"=$currentDownloadsPath} }
            6 { $selectedFolders += @{"Name"="Favorites"; "Registry"="Favorites"; "Path"=$currentFavoritesPath} }
            7 { $selectedFolders += @{"Name"="Desktop"; "Registry"="Desktop"; "Path"=$currentDesktopPath} }
            default { Write-Host "Invalid choice: $c. Please try again." -ForegroundColor Red }
        }
    }

    if ($selectedFolders.Count -gt 0) {
        do {
			$driveLetter = Read-Host "Enter the drive letter for the selected folders (e.g., E)"
			if (-not (Is-UpperCase $driveLetter)) {
				Write-Host "Please enter an uppercase letter." -ForegroundColor Red
			}
		} while (-not (Is-UpperCase $driveLetter))
        Write-Host "If no specific folder path is provided, the folders will be moved to the root of the drive." -ForegroundColor Red
        $specificFolder = Read-Host "Enter the specific folder path for the selected folders (or leave blank to move to the root of the drive)"
		foreach ($folder in $selectedFolders) {
        Move-UserFolder -folderName $folder.Name -registryName $folder.Registry -currentPath $folder.Path -driveLetter $driveLetter -specificFolder $specificFolder
    }

		# Restart explorer.exe
		Stop-Process -Name explorer -Force
		Start-Sleep -Seconds 3
		Start-Process explorer
		cls
		# Supprimer les anciens dossiers vides
		foreach ($folder in $selectedFolders) {
			if (Test-Path $folder.Path) {
				Remove-Item -Path $folder.Path -Recurse -Force
				Write-Output "$($folder.Name) folder at $($folder.Path) has been removed."
			}
		}
		Start-Sleep -Seconds 1
		# Redémarrer le script
		Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
		exit
	}
} while ($choice -ne 0)

