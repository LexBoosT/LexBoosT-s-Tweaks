# Elevate to run as administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Set PowerShell window background to black and text to white
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

# Configuration du menu
$global:MenuConfig = @{
    Width       = 70
    LineChar    = '='
    SideBorder  = '|'
    CornerTL    = '+'
    CornerTR    = '+'
    CornerBL    = '+'
    CornerBR    = '+'
}

# Variable to store the chosen algorithm
$global:chosenAlgorithm = "None"

# Fonction pour afficher le menu principal
function Show-Menu {
    Clear-Host

    # Header
    $headerLine = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"
    $headerText = "LexBoosT Drive Compactor"
    $paddingLeft = [math]::Max(0, ($global:MenuConfig.Width - $headerText.Length) / 2)
    $headerText = $headerText.PadLeft($headerText.Length + $paddingLeft).PadRight($global:MenuConfig.Width - 1)
    $headerLine2 = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"

    # Menu Items
    $menuItems = @(
        @{Text="1. Compress with   Xpress4K   (20-30%)"; Color="Blue"; Enabled=$true},
        @{Text="2. Compress with   Xpress8K   (30-40%)"; Color="Magenta"; Enabled=$true},
        @{Text="3. Compress with   Xpress16K  (40-50%)"; Color="Cyan"; Enabled=$true},
        @{Text="4. Compress with   LZX        (50-60%)"; Color="Green"; Enabled=$true},
        @{Text="5. Decompress"; Color="Yellow"; Enabled=$true},
        @{Text="0. Exit"; Color="Red"; Enabled=$true}
    )

    # Render
    Write-Host "$headerLine" -ForegroundColor Cyan
    Write-Host $headerText -ForegroundColor Cyan
    Write-Host "$headerLine2" -ForegroundColor Cyan

    foreach ($item in $menuItems) {
        $lineContent = $item.Text
        $padding = [math]::Max(0, $global:MenuConfig.Width - $lineContent.Length - 4)
        $displayLine = "$($global:MenuConfig.SideBorder) " +
                       $lineContent +
                       (" "*$padding) +
                       " $($global:MenuConfig.SideBorder)"

        Write-Host $displayLine -ForegroundColor $item.Color
    }

    Write-Host "$($global:MenuConfig.CornerBL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerBR)`n" -ForegroundColor Cyan
}

# Fonction pour afficher le menu de compression
function Show-Compression-Menu {
    Clear-Host

    # Header
    $headerLine = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"
    $headerText = "Compression Options"
    $paddingLeft = [math]::Max(0, ($global:MenuConfig.Width - $headerText.Length) / 2)
    $headerText = $headerText.PadLeft($headerText.Length + $paddingLeft).PadRight($global:MenuConfig.Width - 1)
    $headerLine2 = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"

    # Menu Items
    $menuItems = @(
        @{Text="1. Compress specific folders"; Color="Blue"; Enabled=$true},
        @{Text="    (C:\Windows\winsxs, C:\Windows\System32\DriverStore, C:\Program Files\WindowsApps, C:\Windows\InfusedApps, C:\Windows\installer)"; Color="Gray"; Enabled=$true},
        @{Text="2. Compress a custom folder"; Color="Magenta"; Enabled=$true},
        @{Text="0. Back"; Color="Red"; Enabled=$true}
    )

    # Render
    Write-Host "$headerLine" -ForegroundColor Cyan
    Write-Host $headerText -ForegroundColor Cyan
    Write-Host "$headerLine2" -ForegroundColor Cyan

    foreach ($item in $menuItems) {
        $lineContent = $item.Text
        $padding = [math]::Max(0, $global:MenuConfig.Width - $lineContent.Length - 4)
        $displayLine = "$($global:MenuConfig.SideBorder) " +
                       $lineContent +
                       (" "*$padding) +
                       " $($global:MenuConfig.SideBorder)"

        Write-Host $displayLine -ForegroundColor $item.Color
    }

    Write-Host "$($global:MenuConfig.CornerBL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerBR)`n" -ForegroundColor Cyan
    Write-Host "Chosen Algorithm: $global:chosenAlgorithm" -ForegroundColor White
}

# Fonction pour afficher le menu de décompression
function Show-Decompression-Menu {
    Clear-Host

    # Header
    $headerLine = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"
    $headerText = "Decompression Options"
    $paddingLeft = [math]::Max(0, ($global:MenuConfig.Width - $headerText.Length) / 2)
    $headerText = $headerText.PadLeft($headerText.Length + $paddingLeft).PadRight($global:MenuConfig.Width - 1)
    $headerLine2 = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"

    # Menu Items
    $menuItems = @(
        @{Text="1. Decompress specific folders"; Color="Blue"; Enabled=$true},
        @{Text="    (C:\Windows\winsxs, C:\Windows\System32\DriverStore, C:\Program Files\WindowsApps, C:\Windows\InfusedApps, C:\Windows\installer)"; Color="Gray"; Enabled=$true},
        @{Text="2. Decompress a custom folder"; Color="Magenta"; Enabled=$true},
        @{Text="0. Back"; Color="Red"; Enabled=$true}
    )

    # Render
    Write-Host "$headerLine" -ForegroundColor Cyan
    Write-Host $headerText -ForegroundColor Cyan
    Write-Host "$headerLine2" -ForegroundColor Cyan

    foreach ($item in $menuItems) {
        $lineContent = $item.Text
        $padding = [math]::Max(0, $global:MenuConfig.Width - $lineContent.Length - 4)
        $displayLine = "$($global:MenuConfig.SideBorder) " +
                       $lineContent +
                       (" "*$padding) +
                       " $($global:MenuConfig.SideBorder)"

        Write-Host $displayLine -ForegroundColor $item.Color
    }

    Write-Host "$($global:MenuConfig.CornerBL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerBR)`n" -ForegroundColor Cyan
}

# Fonction pour mettre à jour les dossiers
function Update-Folder {
    param (
        [string]$FolderPath
    )
    [System.IO.Directory]::GetFiles($FolderPath, '*', 'AllDirectories') | Out-Null
}

# Fonction pour compresser des dossiers spécifiques
function Compress-Folders {
    param (
        [string]$Algorithm
    )

    $folders = @(
        "$env:windir\winsxs",
        "$env:windir\System32\DriverStore\FileRepository",
        "C:\Program Files\WindowsApps",
        "$env:windir\InfusedApps",
        "$env:windir\installer"
    )

    foreach ($folder in $folders) {
        Update-Folder -FolderPath $folder

        Write-Host "Compressing $folder with $Algorithm..." -ForegroundColor Green
        icacls "$folder" /save "$folder.acl" /t /c > $null 2>&1
        takeown /f "$folder" /r 2>&1
        icacls "$folder" /grant "`"$env:userdomain\$env:username`:(F)'" /t /c > $null 2>&1

        compact /c /s:"$folder" /a /i /f /exe:$Algorithm 2>&1

        icacls "$folder" /restore "$folder.acl" /c > $null 2>&1
        Remove-Item "$folder.acl"

        Start-Sleep -Seconds 5  # Pause to ensure changes are applied
        Update-Folder -FolderPath "$folder"

        Write-Host "Compression complete for $folder!" -ForegroundColor Green
    }
}

# Fonction pour compresser un dossier personnalisé
function Compress-Custom-Folder {
    param (
        [string]$Algorithm,
        [string]$FolderPath
    )

    Update-Folder -FolderPath $FolderPath

    Write-Host "Compressing $FolderPath with $Algorithm..." -ForegroundColor Green
    icacls "$FolderPath" /save "$FolderPath.acl" /t /c > $null 2>&1
    takeown /f "$FolderPath" /r 2>&1
    icacls "$FolderPath" /grant "$env:userdomain\$env:username":'(F)' /t /c > $null 2>&1
    compact /c /s:"$FolderPath" /a /i /f /exe:$Algorithm 2>&1

    icacls "$FolderPath" /restore "$FolderPath.acl" /c > $null 2>&1
    Remove-Item "$FolderPath.acl"

    Start-Sleep -Seconds 5  # Pause to ensure changes are applied
    Update-Folder -FolderPath $FolderPath

    Write-Host "Compression complete!" -ForegroundColor Green
}

# Fonction pour décompresser un dossier
function Expand-Folders {
    param (
        [string]$FolderPath
    )

    Update-Folder -FolderPath $FolderPath

    Write-Host "Decompressing $FolderPath..." -ForegroundColor Green
    compact /u /s:"$FolderPath" /a /i /f 2>&1

    Start-Sleep -Seconds 5  # Pause to ensure changes are applied
    Update-Folder -FolderPath $FolderPath

    Write-Host "Decompression complete for $FolderPath!" -ForegroundColor Green
}

# Fonction pour décompresser des dossiers spécifiques
function Expand-Specific-Folders {
    $folders = @(
        "$env:windir\winsxs",
        "$env:windir\System32\DriverStore",
        "C:\Program Files\WindowsApps",
        "$env:windir\InfusedApps",
        "$env:windir\installer"
    )

    foreach ($folder in $folders) {
        Update-Folder -FolderPath $folder

        Write-Host "Decompressing $folder..." -ForegroundColor Green
        compact /u /s:"$folder" /a /i /f 2>&1

        Start-Sleep -Seconds 5  # Pause to ensure changes are applied
        Update-Folder -FolderPath $folder

        Write-Host "Decompression complete for $folder!" -ForegroundColor Green
    }
}

# Boucle principale
do {
    Show-Menu
    $choice = Read-Host "`n[INPUT] Select option (0-5)"
    switch ($choice) {
        1 {
            $global:chosenAlgorithm = "Xpress4K"
            Show-Compression-Menu
            $compressionChoice = Read-Host "`n[INPUT] Select option (0-2)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $global:chosenAlgorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $global:chosenAlgorithm -FolderPath $customFolderPath
                }
            }
        }
        2 {
            $global:chosenAlgorithm = "Xpress8K"
            Show-Compression-Menu
            $compressionChoice = Read-Host "`n[INPUT] Select option (0-2)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $global:chosenAlgorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $global:chosenAlgorithm -FolderPath $customFolderPath
                }
            }
        }
        3 {
            $global:chosenAlgorithm = "Xpress16K"
            Show-Compression-Menu
            $compressionChoice = Read-Host "`n[INPUT] Select option (0-2)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $global:chosenAlgorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $global:chosenAlgorithm -FolderPath $customFolderPath
                }
            }
        }
        4 {
            $global:chosenAlgorithm = "LZX"
            Show-Compression-Menu
            $compressionChoice = Read-Host "`n[INPUT] Select option (0-2)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $global:chosenAlgorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $global:chosenAlgorithm -FolderPath $customFolderPath
                }
            }
        }
        5 {
            do {
                Show-Decompression-Menu
                $decompressionChoice = Read-Host "`n[INPUT] Select option (0-2)"
                switch ($decompressionChoice) {
                    1 { Expand-Specific-Folders }
                    2 {
                        $customFolderPath = Read-Host "Enter the path of the custom folder to decompress"
                        Expand-Folders -FolderPath $customFolderPath
                    }
                    0 { Show-Menu }
                }
            } while ($decompressionChoice -ne 0)
        }
        0 {
            Write-Host "Goodbye!" -ForegroundColor Cyan
            Exit
        }
        default {
            Write-Host "`n[!] Invalid choice. Please try again." -ForegroundColor Red
            Pause
        }
    }
} while ($choice -ne 0)