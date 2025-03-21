<#
.SYNOPSIS
LexBoosT Drivers Cleaner - Stable Final Version
.DESCRIPTION
Robust driver maintenance tool with ASCII-compatible interface
#>

#region Initialization
$EnableLogs = (Read-Host "Do you want to create a folder with Logs files at the program root? (Y/N)") -eq 'Y'
$EnableBackup = (Read-Host "Do you want to create a folder with Drivers backup at the program root? (Y/N)") -eq 'Y'

$LogPath = if ($EnableLogs) { "$PSScriptRoot\Logs" } else { $null }
$BackupPath = if ($EnableBackup) { "$PSScriptRoot\Backup" } else { $null }

# Créer les dossiers uniquement si activé
if ($LogPath) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

if ($BackupPath) {
    New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
}

$TranscriptFile = if ($EnableLogs -and $LogPath) {
    "$LogPath\DriverCleaner-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
} else {
    $null
}

$global:MenuConfig = @{
    Width       = 70
    LineChar    = '='
    SideBorder  = '|'
    CornerTL    = '+'
    CornerTR    = '+'
    CornerBL    = '+'
    CornerBR    = '+'
}
#endregion

#region UI Engine
function Show-Menu {
    param($ScanResult)
    Clear-Host

    # Header
    $headerLine = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"
    $headerText = "LexBoosT Drivers Cleaner".PadLeft(($global:MenuConfig.Width - "LexBoosT Drivers Cleaner".Length) / 2 + "LexBoosT Drivers Cleaner".Length).PadRight($global:MenuConfig.Width-1)
    $headerLine2 = "$($global:MenuConfig.CornerTL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerTR)"

    # Menu Items
    $menuItems = @(
        @{Text="1. Scan System"; Color="Yellow"; Enabled=$true},
        @{Text="2. Clean Drivers";
          Color=if ($ScanResult) {"Green"} else {"DarkGray"};
          Status=if ($ScanResult) {"($($ScanResult.DriverGroups.Count) duplicates)"} else {"[Needs Scan]"};
          Enabled=$ScanResult}
    )

    # Ajouter des options dynamiquement si activé
    if ($EnableBackup -and $BackupPath) {
        $menuItems += @{Text="3. Open Backup"; Color="Blue"; Enabled=$true}
    }
    if ($EnableLogs -and $LogPath) {
        $menuItems += @{Text="4. View Logs"; Color="Magenta"; Enabled=$true}
        $menuItems += @{Text="5. Delete Logs"; Color="DarkRed"; Enabled=$true}
    }

    $menuItems += @{Text="0. Exit"; Color="Red"; Enabled=$true}

    # Render
    Write-Host "$headerLine" -ForegroundColor Cyan
    Write-Host $headerText -ForegroundColor Cyan
    Write-Host "$headerLine2" -ForegroundColor Cyan

    foreach ($item in $menuItems) {
        $lineContent = if ($item.Status) {
            "$($item.Text.PadRight(40))$($item.Status)"
        } else {
            $item.Text
        }

        $padding = $global:MenuConfig.Width - $lineContent.Length - 4
        $displayLine = "$($global:MenuConfig.SideBorder) " +
                       $lineContent +
                       (" "*$padding) +
                       " $($global:MenuConfig.SideBorder)"

        Write-Host $displayLine -ForegroundColor $item.Color
    }

    Write-Host "$($global:MenuConfig.CornerBL)$($global:MenuConfig.LineChar*($global:MenuConfig.Width-2))$($global:MenuConfig.CornerBR)`n" -ForegroundColor Cyan
}
#endregion

#region Core Functions
function Get-DuplicateDrivers {
    try {
        $drivers = Get-WindowsDriver -Online -All -ErrorAction Stop |
            Where-Object { $_.Driver -like 'oem*inf' } |
            Select-Object @{n='OriginalFileName';e={Split-Path $_.OriginalFileName -Leaf}},
                          Driver,
                          ClassDescription,
                          ProviderName,
                          @{n='Date';e={$_.Date.ToString("yyyy-MM-dd")}},
                          Version

        $groups = $drivers | Group-Object OriginalFileName | Where-Object Count -GT 1
        return @{AllDrivers=$drivers; DriverGroups=$groups}
    }
    catch {
        Write-Host "`n[!] Scan Failed: $_" -ForegroundColor Red
        return $null
    }
}

function Invoke-Cleaner {
    param($DriverGroups)

    # Backup
    if ($EnableBackup -and $BackupPath) {
        Write-Host "`n[BACKUP]" -ForegroundColor Cyan
        $DriverGroups | ForEach-Object {
            $_.Group | Select-Object -Skip 1 | ForEach-Object {
                $source = Join-Path $env:SystemRoot\System32\DriverStore\FileRepository $_.Driver
                if (Test-Path $source) {
                    $dest = "$BackupPath\$($_.OriginalFileName)_$($_.Date).inf"
                    try {
                        Copy-Item $source $dest -Force
                        Write-Host "Backed up: $($_.Driver)" -ForegroundColor DarkGray
                    }
                    catch {
                        Write-Host "[!] Backup failed: $($_.Driver)" -ForegroundColor Red
                    }
                }
            }
        }
    }

    # Cleanup
    Write-Host "`n[CLEANING]" -ForegroundColor Red
    $total = ($DriverGroups | Measure-Object).Count
    $current = 0

    $DriverGroups | ForEach-Object {
        $current++
        $_.Group | Sort-Object @{e={[Version]$_.Version}; Descending=$true}, Date -Descending | Select-Object -Skip 1 | ForEach-Object {
            Write-Progress -Activity "Cleaning" -Status "$current/$total groups" -PercentComplete ($current/$total*100)
            try {
                $output = pnputil.exe /delete-driver $_.Driver /force 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[OK] Removed: $($_.Driver)" -ForegroundColor Green
                }
                else {
                    Write-Host "[X] Failed: $($output -join ' ')" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "[!] Error: $_" -ForegroundColor Red
            }
        }
    }
}

function DeleteLogs {
    try {
        # Arrêter la transcription si elle est en cours
        if ($EnableLogs -and $TranscriptFile -and (Test-Path $TranscriptFile)) {
            Stop-Transcript | Out-Null
        }

        # Supprimer les fichiers de logs
        if ($EnableLogs -and $LogPath -and (Test-Path $LogPath)) {
            Get-ChildItem -Path $LogPath -File | ForEach-Object {
                Remove-Item -Path $_.FullName -Force
                Write-Host "Deleted: $($_.FullName)" -ForegroundColor Green
            }
            Write-Host "`n[OK] All logs deleted." -ForegroundColor Cyan
        } else {
            Write-Host "`n[!] Log directory does not exist or logging is disabled." -ForegroundColor Yellow
        }

        # Redémarrer la transcription si les logs sont activés
        if ($EnableLogs -and $LogPath) {
            $TranscriptFile = "$LogPath\DriverCleaner-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
            Start-Transcript -Path $TranscriptFile -Append
            Write-Host "`n[OK] Logging restarted." -ForegroundColor Green
        }
    } catch {
        Write-Host "`n[ERROR] Failed to delete logs: $_" -ForegroundColor Red
    }
}
#endregion

#region Main Program
try {
    # Élever les privilèges si nécessaire
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "`n[!] Restarting as admin..." -ForegroundColor Yellow
        Start-Process pwsh "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }

    # Démarrer la transcription si les logs sont activés
    if ($EnableLogs -and $TranscriptFile) {
        Start-Transcript -Path $TranscriptFile -Append
    }

    $global:ScanResult = $null

    do {
        Show-Menu -ScanResult $global:ScanResult
        $choice = Read-Host "`n[INPUT] Select option (0-5)"

        switch ($choice) {
            '1' {
                # Scanner les drivers
                $global:ScanResult = Get-DuplicateDrivers
                if ($global:ScanResult) {
                    Write-Host "`n[OK] Found $($global:ScanResult.DriverGroups.Count) duplicate groups" -ForegroundColor Green
                }
                Read-Host "`n[CONTINUE] Press Enter..."
            }
            '2' {
                # Nettoyer les drivers
                if (-not $global:ScanResult) {
                    Write-Host "`n[!] Please scan first!" -ForegroundColor Red
                    Start-Sleep -Seconds 2
                    continue
                }

                $confirm = Read-Host "`n[CONFIRM] Proceed to clean? (Y/N)"
                if ($confirm -eq 'Y') {
                    Invoke-Cleaner -DriverGroups $global:ScanResult.DriverGroups
                    $global:ScanResult = $null
                }
                Read-Host "`n[CONTINUE] Press Enter..."
            }
            '3' {
                # Ouvrir le dossier Backup si activé
                if ($EnableBackup -and $BackupPath -and (Test-Path $BackupPath)) {
                    Invoke-Item $BackupPath
                } else {
                    Write-Host "`n[!] Backup is disabled or path does not exist." -ForegroundColor Yellow
                }
            }
            '4' {
                # Ouvrir le fichier de logs si activé
                if ($EnableLogs -and $TranscriptFile -and (Test-Path $TranscriptFile)) {
                    Invoke-Item $TranscriptFile
                } else {
                    Write-Host "`n[!] Logging is disabled or file does not exist." -ForegroundColor Yellow
                }
            }
            '5' {
                # Supprimer les logs si activé
                if ($EnableLogs -and $LogPath) {
                    $confirm = Read-Host "`n[CONFIRM] Delete all logs? (Y/N)"
                    if ($confirm -eq 'Y') {
                        DeleteLogs
                    }
                } else {
                    Write-Host "`n[!] Logging is disabled or path does not exist." -ForegroundColor Yellow
                }
                Read-Host "`n[CONTINUE] Press Enter..."
            }
            '0' {
                # Quitter le programme
                exit
            }
            default {
                Write-Host "`n[!] Invalid choice. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)

} catch {
    # Gestion des erreurs fatales
    Write-Host "`n[!!!] FATAL ERROR: $_" -ForegroundColor White -BackgroundColor Red
    $_.Exception.StackTrace -split "`r`n" | ForEach-Object { Write-Host "[STACK] $_" -ForegroundColor DarkGray }
} finally {
    # Arrêter la transcription si elle est activée
    if ($EnableLogs -and $TranscriptFile -and (Test-Path $TranscriptFile)) {
        Stop-Transcript | Out-Null
    }

    # Supprimer le dossier Backup s'il est vide
    if ($EnableBackup -and $BackupPath -and (Test-Path $BackupPath)) {
        $backupFiles = Get-ChildItem -Path $BackupPath
        if ($backupFiles.Count -eq 0) {
            Remove-Item -Path $BackupPath -Force
            Write-Host "`n[OK] Backup directory was empty and has been deleted." -ForegroundColor Green
        }
    }

    Read-Host "`n[EXIT] Press Enter to close..."
}
#endregion
