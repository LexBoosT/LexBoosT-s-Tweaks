# Elevate to run as administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Set PowerShell window background to black and text to white
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|         LexBoosT Drive Compactor          |"
    Write-Host "============================================="
    Write-Host "| 1. Compress with   Xpress4K   (20-30%)    |" -ForegroundColor Blue
    Write-Host "| 2. Compress with   Xpress8K   (30-40%)    |" -ForegroundColor Magenta
    Write-Host "| 3. Compress with   Xpress16K  (40-50%)    |" -ForegroundColor Cyan
    Write-Host "| 4. Compress with   LZX        (50-60%)    |" -ForegroundColor Green
    Write-Host "| 5. Decompress                             |" -ForegroundColor Yellow
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

function Show-Compression-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|         Compression Options               |"
    Write-Host "============================================="
    Write-Host "| 1. Compress specific folders              |" -ForegroundColor Blue
    Write-Host "|    (C:\Windows\winsxs,                    |"
    Write-Host "|     C:\Windows\System32\DriverStore,      |"
    Write-Host "|     C:\Program Files\WindowsApps,         |"
    Write-Host "|     C:\Windows\InfusedApps,               |"
    Write-Host "|     C:\Windows\installer)                 |"
    Write-Host "| 2. Compress a custom folder               |" -ForegroundColor Magenta
    Write-Host "| 0. Back                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

function Show-Decompression-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|         Decompression Options             |"
    Write-Host "============================================="
    Write-Host "| 1. Decompress specific folders            |" -ForegroundColor Blue
    Write-Host "|    (C:\Windows\winsxs,                    |"
    Write-Host "|     C:\Windows\System32\DriverStore,      |"
    Write-Host "|     C:\Program Files\WindowsApps,         |"
    Write-Host "|     C:\Windows\InfusedApps,               |"
    Write-Host "|     C:\Windows\installer)                 |"
    Write-Host "| 2. Decompress a custom folder             |" -ForegroundColor Magenta
    Write-Host "| 0. Back                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

function Update-Folder {
    param (
        [string]$FolderPath
    )
    [System.IO.Directory]::GetFiles($FolderPath, '*', 'AllDirectories') | Out-Null
}

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

        Write-Host "Compressing $folder with $Algorithm..."
        icacls "$folder" /save "$folder.acl" /t /c > $null 2>&1
        takeown /f "$folder" /r 2>&1
        icacls "$folder" /grant "`"$env:userdomain\$env:username`:(F)'" /t /c > $null 2>&1

        compact /c /s:"$folder" /a /i /f /exe:$Algorithm 2>&1

        icacls "$folder" /restore "$folder.acl" /c > $null 2>&1
        Remove-Item "$folder.acl"

        Start-Sleep -Seconds 5  # Pause to ensure changes are applied
        Update-Folder -FolderPath "$folder"

        Write-Host "Compression complete for $folder!"
    }
}

function Compress-Custom-Folder {
    param (
        [string]$Algorithm,
        [string]$FolderPath
    )

    Update-Folder -FolderPath $FolderPath

    Write-Host "Compressing $FolderPath with $Algorithm..."
    icacls "$FolderPath" /save "$FolderPath.acl" /t /c > $null 2>&1
    takeown /f "$FolderPath" /r 2>&1
    icacls "$FolderPath" /grant "$env:userdomain\$env:username":'(F)' /t /c > $null 2>&1
    compact /c /s:"$FolderPath" /a /i /f /exe:$Algorithm 2>&1

    icacls "$FolderPath" /restore "$FolderPath.acl" /c > $null 2>&1
    Remove-Item "$FolderPath.acl"

    Start-Sleep -Seconds 5  # Pause to ensure changes are applied
    Update-Folder -FolderPath $FolderPath

    Write-Host "Compression complete!"
}

function Expand-Folders {
    param (
        [string]$FolderPath
    )

    Update-Folder -FolderPath $FolderPath

    Write-Host "Decompressing $FolderPath..."

    compact /u /s:"$FolderPath" /a /i /f 2>&1

    Start-Sleep -Seconds 5  # Pause to ensure changes are applied
    Update-Folder -FolderPath $FolderPath

    Write-Host "Decompression complete for $FolderPath!"
}

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

        Write-Host "Decompressing $folder..."

        compact /u /s:"$folder" /a /i /f 2>&1

        Start-Sleep -Seconds 5  # Pause to ensure changes are applied
        Update-Folder -FolderPath $folder

        Write-Host "Decompression complete for $folder!"
    }
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2, 3, 4, 5 or 0 for Quit)"
    Write-Host "Choice entered: $choice"
    switch ($choice) {
        1 {
            $algorithm = "Xpress4K"
            Show-Compression-Menu
            $compressionChoice = Read-Host "Enter your choice (1, 2, or 0 for Back)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $algorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $algorithm -FolderPath $customFolderPath
                }
            }
        }
        2 {
            $algorithm = "Xpress8K"
            Show-Compression-Menu
            $compressionChoice = Read-Host "Enter your choice (1, 2, or 0 for Back)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $algorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $algorithm -FolderPath $customFolderPath
                }
            }
        }
        3 {
            $algorithm = "Xpress16K"
            Show-Compression-Menu
            $compressionChoice = Read-Host "Enter your choice (1, 2, or 0 for Back)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $algorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $algorithm -FolderPath $customFolderPath
                }
            }
        }
        4 {
            $algorithm = "LZX"
            Show-Compression-Menu
            $compressionChoice = Read-Host "Enter your choice (1, 2, or 0 for Back)"
            switch ($compressionChoice) {
                1 { Compress-Folders -Algorithm $algorithm }
                2 {
                    $customFolderPath = Read-Host "Enter the path of the custom folder to compress"
                    Compress-Custom-Folder -Algorithm $algorithm -FolderPath $customFolderPath
                }
            }
        }
        5 {
            do {
                Show-Decompression-Menu
                $decompressionChoice = Read-Host "Enter your choice (1, 2, or 0 for Back)"
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
    }
} while ($choice -ne 0)
