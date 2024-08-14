
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

function Compress-Drive {
    param (
        [string]$Algorithm,
        [string]$DriveLetter
    )

    $batchCommands = @"
@echo off
echo Starting compression...
setlocal enabledelayedexpansion
set totalFiles=0
for /r ${DriveLetter}:\ %%i in (*.*) do (
    set /a totalFiles+=1
)

set processedFiles=0
for /r ${DriveLetter}:\ %%i in (*.*) do (
    set exclude=0
    if "%%i"=="${DriveLetter}:\Windows" set exclude=1
    if "%%i"=="${DriveLetter}:\System Volume Information" set exclude=1
    if "%%i"=="${DriveLetter}:\$*" set exclude=1
    for %%j in (7z aac avi ba bik bk2 bnk pc_binkvid br bz2 cab dl_ docx flac flv gif gz jpeg jpg log lz4 lzma lzx m2v m4v m4a mkv mp2 mp3 mp4 mpeg mpg ogg onepkg png pptx rar upk vob vss vstx wem webm wma wmv xap xnb xlsx xz zst zstd) do (
        if /i "%%~xi"==".%%j" set exclude=1
    )
    if !exclude!==0 (
        compact /c /q "%%i" | find "%%i" | find /i "compressed" >nul
        if errorlevel 1 (
            compact /c /a /i /f /EXE:$Algorithm "%%i"
        )
    )
)
echo Compression complete!
pause
"@
    $batchFile = [System.IO.Path]::GetTempFileName() + ".bat"
    Set-Content -Path $batchFile -Value $batchCommands

    Start-Process cmd -ArgumentList "/c $batchFile" -NoNewWindow -Wait

    Remove-Item -Path $batchFile
}

function Expand-Drive {
    param (
        [string]$DriveLetter
    )

    $batchCommands = @"
@echo off
echo Starting decompression...
setlocal enabledelayedexpansion
set totalFiles=0
for /r ${DriveLetter}:\ %%i in (*.*) do (
    set /a totalFiles+=1
)

set processedFiles=0
for /r ${DriveLetter}:\ %%i in (*.*) do (
    set exclude=0
    if "%%i"=="${DriveLetter}:\Windows" set exclude=1
    if "%%i"=="${DriveLetter}:\System Volume Information" set exclude=1
    if "%%i"=="${DriveLetter}:\$*" set exclude=1
    for %%j in (7z aac avi ba bik bk2 bnk pc_binkvid br bz2 cab dl_ docx flac flv gif gz jpeg jpg log lz4 lzma lzx m2v m4v m4a mkv mp2 mp3 mp4 mpeg mpg ogg onepkg png pptx rar upk vob vss vstx wem webm wma wmv xap xnb xlsx xz zst zstd) do (
        if /i "%%~xi"==".%%j" set exclude=1
    )
    if !exclude!==0 (
        compact /c /q "%%i" | find "%%i" | find /i "compressed" >nul
        if errorlevel 0 (
            compact /u /a /i /f "%%i"
        )
    )
)
echo Decompression complete!
pause
"@
    $batchFile = [System.IO.Path]::GetTempFileName() + ".bat"
    Set-Content -Path $batchFile -Value $batchCommands

    Start-Process cmd -ArgumentList "/c $batchFile" -NoNewWindow -Wait

    Remove-Item -Path $batchFile
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1, 2, 3, 4, 5 or 6 for Quit)"
    Write-Host "Choice entered: $choice"
    switch ($choice) {
        1 {
            $algorithm = "Xpress4K"
        }
        2 {
            $algorithm = "Xpress8K"
        }
        3 {
            $algorithm = "Xpress16K"
        }
        4 {
            $algorithm = "LZX"
        }
        5 {
            $algorithm = "Decompress"
        }
        0 {
            Write-Host "Goodbye!..." -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "Invalid option, please try again." -ForegroundColor Red
            continue
        }
    }

    if ($choice -ne 6) {
        $driveLetter = Read-Host "Enter the drive letter to compress (ex: C)"
        Write-Host "Drive letter entered: $driveLetter"
        if ($algorithm -eq "Decompress") {
            Expand-Drive -DriveLetter $driveLetter
        } else {
            Compress-Drive -Algorithm $algorithm -DriveLetter $driveLetter
        }
        Read-Host "Press Enter to continue..."
    }
} while ($choice -ne 6)
