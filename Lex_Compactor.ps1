$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host

# Créer et exécuter un script batch temporaire
function Invoke-TemporaryBatchScript {
    param (
        [string]$batchCommands
    )
    $tempBatchFile = [System.IO.Path]::GetTempFileName() + ".bat"
    Set-Content -Path $tempBatchFile -Value $batchCommands
    Write-Host "Running temporary batch script..."
    Start-Process -FilePath $tempBatchFile -NoNewWindow -Wait
    Remove-Item -Path $tempBatchFile
}

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
    Write-Host "| 2. Compress a folder by drag and drop     |" -ForegroundColor Magenta
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
    Write-Host "| 2. Decompress a folder by path            |" -ForegroundColor Magenta
    Write-Host "| 0. Back                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

function Get-FolderSize {
    param (
        [string]$FolderPath
    )
    $size = (Get-ChildItem -Path $FolderPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    return [math]::Round($size / 1KB, 2)
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

    $totalSizeBefore = 0
    $totalSizeAfter = 0

    foreach ($folder in $folders) {
        $sizeBefore = Get-FolderSize -FolderPath $folder
        $totalSizeBefore += $sizeBefore

        Write-Host "Compressing $folder with $Algorithm..."
        icacls $folder /save "$folder.acl" /t /c > $null 2>&1
        takeown /f $folder /r > $null 2>&1
        icacls $folder /grant "$env:userdomain\$env:username":'(F)' /t /c > $null 2>&1

        $files = Get-ChildItem -Path $folder -Recurse -File
        $totalFiles = $files.Count
        $processedFiles = 0

        foreach ($file in $files) {
            compact /c /s:$file.FullName /a /i /f /exe:$Algorithm > $null 2>&1
            $processedFiles++
            $progress = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
            Write-Progress -Activity "Compressing $folder" -Status "$progress% Complete" -PercentComplete $progress
        }

        icacls $folder /restore "$folder.acl" /c > $null 2>&1
        Remove-Item "$folder.acl" > $null 2>&1

        $sizeAfter = Get-FolderSize -FolderPath $folder
        $totalSizeAfter += $sizeAfter
    }

    $sizeReduction = $totalSizeBefore - $totalSizeAfter
    if ($totalSizeBefore -ne 0) {
        $percentageReduction = [math]::Round(($sizeReduction / $totalSizeBefore) * 100, 2)
    } else {
        $percentageReduction = 0
    }

    Write-Host "Compression complete!"
    Write-Host "Total size before compression: $totalSizeBefore KB"
    Write-Host "Total size after compression: $totalSizeAfter KB"
    Write-Host "Total size reduction: $sizeReduction KB ($percentageReduction%)"
    Pause
}

function Compress-Custom-Folder {
    param (
        [string]$Algorithm,
        [string]$FolderPath
    )

    $sizeBefore = Get-FolderSize -FolderPath $FolderPath

    Write-Host "Compressing $FolderPath with $Algorithm..."
    icacls $FolderPath /save "$FolderPath.acl" /t /c > $null 2>&1
    takeown /f $FolderPath /r > $null 2>&1
    icacls $FolderPath /grant "$env:userdomain\$env:username":'(F)' /t /c > $null 2>&1

    $files = Get-ChildItem -Path $FolderPath -Recurse -File
    $totalFiles = $files.Count
    $processedFiles = 0

    foreach ($file in $files) {
        compact /c /s:$file.FullName /a /i /f /exe:$Algorithm > $null 2>&1
        $processedFiles++
        $progress = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
        Write-Progress -Activity "Compressing $FolderPath" -Status "$progress% Complete" -PercentComplete $progress
    }

    icacls $FolderPath /restore "$FolderPath.acl" /c > $null 2>&1
    Remove-Item "$FolderPath.acl" > $null 2>&1

    $sizeAfter = Get-FolderSize -FolderPath $FolderPath
    $sizeReduction = $sizeBefore - $sizeAfter
    if ($sizeBefore -ne 0) {
        $percentageReduction = [math]::Round(($sizeReduction / $sizeBefore) * 100, 2)
    } else {
        $percentageReduction = 0
    }

    Write-Host "Compression complete!"
    Write-Host "Size before compression: $sizeBefore KB"
    Write-Host "Size after compression: $sizeAfter KB"
    Write-Host "Size reduction: $sizeReduction KB ($percentageReduction%)"
    Pause
}

function Expand-Folders {
    $folders = @(
        "$env:windir\winsxs",
        "$env:windir\System32\DriverStore\FileRepository",
        "C:\Program Files\WindowsApps",
        "$env:windir\InfusedApps",
        "$env:windir\installer"
    )

    $totalSizeBefore = 0
    $totalSizeAfter = 0

    foreach ($folder in $folders) {
        $sizeBefore = Get-FolderSize -FolderPath $folder
        $totalSizeBefore += $sizeBefore

        Write-Host "Decompressing $folder..."
        $files = Get-ChildItem -Path $folder -Recurse -File
        $totalFiles = $files.Count
        $processedFiles = 0

        foreach ($file in $files) {
            compact /u /s:$file.FullName /a /i /f > $null 2>&1
            $processedFiles++
            $progress = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
            Write-Progress -Activity "Decompressing $folder" -Status "$progress% Complete" -PercentComplete $progress
        }

        $sizeAfter = Get-FolderSize -FolderPath $folder
        $totalSizeAfter += $sizeAfter
    }

    $sizeReduction = $totalSizeBefore - $totalSizeAfter
    if ($totalSizeBefore -ne 0) {
        $percentageReduction = [math]::Round(($sizeReduction / $totalSizeBefore) * 100, 2)
    } else {
        $percentageReduction = 0
    }

    Write-Host "Decompression complete!"
    Write-Host "Total size before decompression: $totalSizeBefore KB"
    Write-Host "Total size after decompression: $totalSizeAfter KB"
    Write-Host "Total size reduction: $sizeReduction KB ($percentageReduction%)"
    Pause
}
function Expand-Custom-Folder {
    param (
        [string]$FolderPath
    )

    $sizeBefore = Get-FolderSize -FolderPath $FolderPath

    Write-Host "Decompressing $FolderPath..."
    $files = Get-ChildItem -Path $FolderPath -Recurse -File
    $totalFiles = $files.Count
    $processedFiles = 0

    foreach ($file in $files) {
        compact /u /s:$file.FullName /a /i /f > $null 2>&1
        $processedFiles++
        $progress = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
        Write-Progress -Activity "Decompressing $FolderPath" -Status "$progress% Complete" -PercentComplete $progress
    }

    $sizeAfter = Get-FolderSize -FolderPath $FolderPath
    $sizeReduction = $sizeBefore - $sizeAfter
    if ($sizeBefore -ne 0) {
        $percentageReduction = [math]::Round(($sizeReduction / $sizeBefore) * 100, 2)
    } else {
        $percentageReduction = 0
    }

    Write-Host "Decompression complete!"
    Write-Host "Size before decompression: $sizeBefore KB"
    Write-Host "Size after decompression: $sizeAfter KB"
    Write-Host "Size reduction: $sizeReduction KB ($percentageReduction%)"
    Pause
}

# Menu principal
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 { Compress-Folders -Algorithm "Xpress4K" }
        2 { Compress-Folders -Algorithm "Xpress8K" }
        3 { Compress-Folders -Algorithm "Xpress16K" }
        4 { Compress-Folders -Algorithm "LZX" }
        5 { Show-Decompression-Menu
                $decompressChoice = Read-Host "Enter your choice"
                switch ($decompressChoice) {
                    1 { Expand-Folders }
                    2 {
                        $folderPath = Read-Host "Enter the path of the folder to decompress"
                        Expand-Custom-Folder -FolderPath $folderPath
                    }
                    0 { Show-Menu }
                    default { Write-Host "Invalid choice. Please try again." }
                }
            }
        0 { exit }
        default { Write-Host "Invalid choice. Please try again." }
    }
}
