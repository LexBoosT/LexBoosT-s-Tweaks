$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

# Vérifier les privilèges administratifs
function Test-Admin {
    Write-Host "Checking for Administrative Privileges..."
    Start-Sleep -Seconds 3

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Not running as administrator. Relaunching..."
        Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
    Write-Host "Running as administrator."
}
Test-Admin

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

function Refresh-Folder {
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
        Refresh-Folder -FolderPath $folder

        Write-Host "Compressing $folder with $Algorithm..."
        icacls $folder /save "$folder.acl" /t /c > $null 2>&1
        takeown /f $folder /r > $null 2>&1
        icacls $folder /grant "$env:userdomain\$env:username":'(F)' /t /c > $null 2>&1

        compact /c /s:$folder /a /i /f /exe:$Algorithm > $null 2>&1

        icacls $folder /restore "$folder.acl" /c > $null 2>&1
        Remove-Item "$folder.acl" > $null 2>&1

        Start-Sleep -Seconds 5  # Pause to ensure changes are applied
        Refresh-Folder -FolderPath $folder

        Write-Host "Compression complete for $folder!"
    }
    Pause
}

function Compress-Custom-Folder {
    param (
        [string]$Algorithm,
        [string]$FolderPath
    )

    Refresh-Folder -FolderPath $FolderPath

    Write-Host "Compressing $FolderPath with $Algorithm..."
    icacls $FolderPath /save "$FolderPath.acl" /t /c > $null 2>&1
    takeown /f $FolderPath /r > $null 2>&1
    icacls $FolderPath /grant "$env:userdomain\$env:username":'(F)' /t /c > $null 2>&1

    compact /c /s:$FolderPath /a /i /f /exe:$Algorithm > $null 2>&1

    icacls $FolderPath /restore "$FolderPath.acl" /c > $null 2>&1
    Remove-Item "$FolderPath.acl" > $null 2>&1

    Start-Sleep -Seconds 5  # Pause to ensure changes are applied
    Refresh-Folder -FolderPath $FolderPath

    Write-Host "Compression complete!"
    Pause
}

function Expand-Folders {
    param (
        [string]$FolderPath
    )

    Refresh-Folder -FolderPath $FolderPath

    Write-Host "Decompressing $FolderPath..."
    compact /u /s:$FolderPath /a /i /f > $null 2>&1

    Start-Sleep -Seconds 5  # Pause to ensure changes are applied
    Refresh-Folder -FolderPath $FolderPath

    Write-Host "Decompression complete for $FolderPath!"
    Pause
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2, 3, 4, 5 or 0 for Quit)"
    Write-Host "Choice entered: $choice"
    switch ($choice) {
        1 { $algorithm = "Xpress4K" }
        2 { $algorithm = "Xpress8K" }
        3 { $algorithm = "Xpress16K" }
        4 { $algorithm = "LZX" }
        5 { 
            do {
                Show-Decompression-Menu
                $decompressionChoice = Read-Host "Enter your choice (1, 2, 3, or 0 for Back)"
                switch ($decompressionChoice) {
                    1 { Expand-Folders -FolderPath "C:\Windows\winsxs" }
                    2 { Expand-Folders -FolderPath "C:\Windows\System32\DriverStore\FileRepository" }
                    3 { 
                        $customFolderPath = Read-Host "Enter the path of the custom folder to decompress"
                        Expand-Folders -FolderPath $customFolderPath
                    }
                }
            } while ($decompressionChoice -ne 0)
        }
    }
} while ($choice -ne 0)
