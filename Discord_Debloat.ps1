Add-Type -AssemblyName System.Windows.Forms
# LexBoosT Discord Debloater
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"

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

# Define the base directory for Discord
$baseDir = "$env:LOCALAPPDATA\Discord"

# Function to safely remove files and folders
function Remove-Files {
    param (
        [string]$path,
        [string[]]$fileNames
    )
    
    foreach ($fileName in $fileNames) {
        $filePath = Join-Path -Path $path -ChildPath $fileName
        if (Test-Path $filePath) {
            Remove-Item -Path $filePath -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
}

# Close Discord
Write-Host "Closing Discord!"
Stop-Process -Name discord -Force

# Define files to delete
$filesToDelete = @(
    "discord_game_sdk_x64.dll",
    "discord_game_sdk_x86.dll"
)

# Set Discord paths for updates file
$discordPath = "$env:USERPROFILE\AppData\Local\Discord"

Clear-Host

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

# Définir la taille de la fenêtre PowerShell
Set-WindowSize -width 510 -height 560
# Définir la taille du tampon de sortie pour éviter les barres de défilement
$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (510, 0)
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size (510, 0)

# Menu
function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|        Discord Script Options Menu        |"
    Write-Host "============================================="
    Write-Host "| 1. Disable Updates                        |" -ForegroundColor Blue
    Write-Host "| 2. Debloat Discord                        |" -ForegroundColor Magenta
    Write-Host "| 3. Remove Overlay                         |" -ForegroundColor Yellow
    Write-Host "| 4. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

do {
    Show-Menu
    $choice = Read-Host "Please select an option"

    switch ($choice) {
        '1' {
			# Directories to search in
            $directoriesToSearch = @(
                "$env:LOCALAPPDATA\Discord"
            )

            # Search for and delete the specified files in each directory
            foreach ($directory in $directoriesToSearch) {
                Write-Host "Searching in directory: $directory"
                
                foreach ($fileToDelete in $filesToDelete) {
                    $file = Get-ChildItem -Path $directory -Recurse -Filter $fileToDelete -File

                    if ($file -ne $null) {
                        Write-Host "File '$fileToDelete' found at: $($file.FullName)"
                        
                        # Delete the file
                        Remove-Item -Path $file.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        Write-Host "File deleted."
                    } else {
                        Write-Host "File '$fileToDelete' not found in $directory."
                    }
                }
            }
            # Delete update-related files
            $updatesToDelete = @(
                "Update.exe",
                "SquirrelSetup.log",
                "Squirrel.exe"
            )
            
            Remove-Files -Path $discordPath -FileNames $updatesToDelete
            Write-Host "Updates disabled!"
        }
        '2' {
            Write-Host "Removing bloat!"

            # Directories to search in
            $directoriesToSearch = @(
                "$env:LOCALAPPDATA\Discord"
            )

            # Search for and delete the specified files in each directory
            foreach ($directory in $directoriesToSearch) {
                Write-Host "Searching in directory: $directory"
                
                foreach ($fileToDelete in $filesToDelete) {
                    $file = Get-ChildItem -Path $directory -Recurse -Filter $fileToDelete -File

                    if ($file -ne $null) {
                        Write-Host "File '$fileToDelete' found at: $($file.FullName)"
                        
                        # Delete the file
                        Remove-Item -Path $file.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        Write-Host "File deleted."
                    } else {
                        Write-Host "File '$fileToDelete' not found in $directory."
                    }
                }
            }

            # List of directories to process
            $directoriesToProcess = Get-ChildItem -Path $baseDir -Directory -Filter "app-*" | ForEach-Object { $_.Name }


            $moduleFilesToRemove = @(
                "discord_cloudsync-1",
                "discord_dispatch-1",
                "discord_erlpack-1",
                "discord_game_utils-1",
                "discord_media-1",
                "discord_spellcheck-1",
                "discord_krisp-1",
                "discord_Spellcheck-1"
                # ... (add other module files)
            )

            foreach ($directory in $directoriesToProcess) {
                $modulePath = Join-Path -Path $baseDir -ChildPath "$directory\modules"
                Remove-Files -path $modulePath -fileNames $moduleFilesToRemove -Force -Recurse -ErrorAction SilentlyContinue
            }

            Write-Host "Bloat removed!"
        }
        '3' {
            Write-Host "Removing overlay!"
			# Directories to search in
            $directoriesToSearch = @(
                "$env:LOCALAPPDATA\Discord"
            )

            # Search for and delete the specified files in each directory
            foreach ($directory in $directoriesToSearch) {
                Write-Host "Searching in directory: $directory"
                
                foreach ($fileToDelete in $filesToDelete) {
                    $file = Get-ChildItem -Path $directory -Recurse -Filter $fileToDelete -File

                    if ($file -ne $null) {
                        Write-Host "File '$fileToDelete' found at: $($file.FullName)"
                        
                        # Delete the file
                        Remove-Item -Path $file.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        Write-Host "File deleted."
                    } else {
                        Write-Host "File '$fileToDelete' not found in $directory."
                    }
                }
            }

            # List of directories to process
            $directoriesToProcess = Get-ChildItem -Path $baseDir -Directory -Filter "app-*" | ForEach-Object { $_.Name }
			
			# Delete specified overlay files quietly
                $overlayFilesToRemove = @(
                    "discord_rpc-1",
                    "discord_overlay2-1"
                )
				
            foreach ($directory in $directoriesToProcess) {
				$modulePath = Join-Path -Path $baseDir -ChildPath "$directory\modules"
                Remove-Files -path $modulePath -fileNames $overlayFilesToRemove  -Force -Recurse -ErrorAction SilentlyContinue
            }

            Write-Host "Overlay removed!"
        }
        '4' {
            break
        }
    }
} while ($choice -ne '4')
function Create-Shortcut {
    param (
        [string]$targetPath,
        [string]$shortcutPath
    )

    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Save()
}

# Ouvrir l'emplacement de l'exécutable Discord dans Explorer
$directoriesToProcess | ForEach-Object {
    $discordExePath = Join-Path -Path (Join-Path -Path $baseDir -ChildPath $_) -ChildPath "Discord.exe"
    if (Test-Path $discordExePath) {
        # Créer un raccourci sur le bureau
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path -Path $desktopPath -ChildPath "Discord.lnk"
        Create-Shortcut -targetPath $discordExePath -shortcutPath $shortcutPath
    }
}
Pause

