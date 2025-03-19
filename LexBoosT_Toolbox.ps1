$OutputEncoding = [System.Text.Encoding]::UTF8

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|       LexBoosT Context Menu Toolbox       |"
    Write-Host "============================================="
    Write-Host "| 1. Manage Toolbox Options in context menu |" -ForegroundColor Blue
    Write-Host "| 2. Remove all Toolbox Options             |" -ForegroundColor Yellow
    Write-Host "| 0. Exit                                   |" -ForegroundColor Red
    Write-Host "============================================="
}

function Show-Options-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host "|      Select Options to Add or Remove      |"
    Write-Host "============================================="
    Write-Host "| 1. Add/Remove Disk Cleanup Option         |" -ForegroundColor Yellow
    Write-Host "| 2. Add/Remove MSConfig Option             |" -ForegroundColor Magenta
    Write-Host "| 3. Add/Remove Registry Editor Option      |" -ForegroundColor Blue
    Write-Host "| 4. Add/Remove CPU Idle Options            |" -ForegroundColor DarkGreen
    Write-Host "| 5. Add/Remove Power Menu Options          |" -ForegroundColor DarkMagenta
    Write-Host "| 0. Return to Main Menu                    |" -ForegroundColor Red
    Write-Host "============================================="
}

function Get-LocalizedOptions {
    $language = (Get-Culture).TwoLetterISOLanguageName
    $localOptions = @{}

    Switch ($language) {
        "fr" {
            $localOptions["menuName"] = "LexBoosT ToolBox"
            $localOptions["shutdown"] = "Arr$([char]0xEA)ter l'ordinateur"
            $localOptions["restart"] = "Red$([char]0xE9)marrer l'ordinateur"
            $localOptions["restartBios"] = "Red$([char]0xE9)marrer l'ordinateur sur le Bios"
            $localOptions["cleanup"] = "Nettoyage disque"
            $localOptions["msconfig"] = "Configuration syst$([char]0xE8)me (msconfig)"
            $localOptions["regedit"] = "$([char]0xC9)diteur de registre (regedit)"
            $localOptions["cpuIdleOn"] = "Activer CPU Idle"
            $localOptions["cpuIdleOff"] = "D$([char]0xE9)sactiver CPU Idle"
            $localOptions["cpuIdleMenu"] = "CPU Idle"
            $localOptions["powerMenu"] = "Alimentation"
        }
        "en" {
            $localOptions["menuName"] = "LexBoosT ToolBox"
            $localOptions["shutdown"] = "Shut Down Computer"
            $localOptions["restart"] = "Restart Computer"
            $localOptions["restartBios"] = "Restart Computer to BIOS"
            $localOptions["cleanup"] = "Disk Cleanup"
            $localOptions["msconfig"] = "System Configuration (msconfig)"
            $localOptions["regedit"] = "Registry Editor (regedit)"
            $localOptions["cpuIdleOn"] = "Enable CPU Idle"
            $localOptions["cpuIdleOff"] = "Disable CPU Idle"
            $localOptions["cpuIdleMenu"] = "CPU Idle"
            $localOptions["powerMenu"] = "Power"
        }
        "es" {
            $localOptions["menuName"] = "LexBoosT ToolBox"
            $localOptions["shutdown"] = "Apagar el ordenador"
            $localOptions["restart"] = "Reiniciar el ordenador"
            $localOptions["restartBios"] = "Reiniciar el ordenador al BIOS"
            $localOptions["cleanup"] = "Limpieza de disco"
            $localOptions["msconfig"] = "Configuraci$([char]0xF3)n del sistema (msconfig)"
            $localOptions["regedit"] = "Editor del registro (regedit)"
            $localOptions["cpuIdleOn"] = "Activar CPU Idle"
            $localOptions["cpuIdleOff"] = "Desactivar CPU Idle"
            $localOptions["cpuIdleMenu"] = "CPU Idle"
            $localOptions["powerMenu"] = "Energ$([char]0xED)a"
        }
        "de" {
            $localOptions["menuName"] = "LexBoosT ToolBox"
            $localOptions["shutdown"] = "Computer herunterfahren"
            $localOptions["restart"] = "Computer neu starten"
            $localOptions["restartBios"] = "Computer im BIOS neu starten"
            $localOptions["cleanup"] = "Datentr$([char]0xE4)gerbereinigung"
            $localOptions["msconfig"] = "Systemkonfiguration (msconfig)"
            $localOptions["regedit"] = "Registrierungs-Editor (regedit)"
            $localOptions["cpuIdleOn"] = "CPU Idle aktivieren"
            $localOptions["cpuIdleOff"] = "CPU Idle deaktivieren"
            $localOptions["cpuIdleMenu"] = "CPU Idle"
            $localOptions["powerMenu"] = "Energie"
        }
            Default {
            $localOptions["menuName"] = "LexBoosT ToolBox"
            $localOptions["shutdown"] = "Shut Down Computer"
            $localOptions["restart"] = "Restart Computer"
            $localOptions["restartBios"] = "Restart Computer to BIOS"
            $localOptions["cleanup"] = "Disk Cleanup"
            $localOptions["msconfig"] = "System Configuration (msconfig)"
            $localOptions["regedit"] = "Registry Editor (regedit)"
            $localOptions["cpuIdleOn"] = "Enable CPU Idle"
            $localOptions["cpuIdleOff"] = "Disable CPU Idle"
            $localOptions["cpuIdleMenu"] = "CPU Idle"
            $localOptions["powerMenu"] = "Power"
            }
        }
    return $localOptions
}

function ContextMenuOption {
    param (
        [string]$optionName,
        [string]$commandKey,
        [string]$defaultCommand,
        [string]$iconPath,
        [string]$parentMenuKey = $null
    )
    $baseKey = if ($parentMenuKey) {
        Join-Path "HKCU:\Software\Classes\Directory\Background\shell\SystemOptions\shell" $parentMenuKey
    } else {
        "HKCU:\Software\Classes\Directory\Background\shell\SystemOptions"
    }

    if (!(Test-Path $baseKey)) {
        New-Item -Path $baseKey -Force | Out-Null
        if (-not $parentMenuKey) {
            Set-ItemProperty -Path $baseKey -Name "MUIVerb" -Value $localizedOptions["menuName"]
            Set-ItemProperty -Path $baseKey -Name "SubCommands" -Value ""
            Set-ItemProperty -Path $baseKey -Name "Icon" -Value "C:\Windows\System32\shell32.dll,-28"
            Set-ItemProperty -Path $baseKey -Name "Position" -Value "Bottom"
        }
    }

    $subKey = Join-Path $baseKey "shell\$commandKey"
    if (Test-Path $subKey) {
        Remove-Item -Path $subKey -Recurse -Force
        Write-Host "$optionName has been removed!"
        Start-Sleep -Seconds 1
    } else {
        New-Item -Path $subKey -Force | Out-Null
        Set-ItemProperty -Path $subKey -Name "MUIVerb" -Value $optionName
        Set-ItemProperty -Path $subKey -Name "Icon" -Value $iconPath

        if ($defaultCommand) {
            New-Item -Path "$subKey\command" -Force | Out-Null
            Set-ItemProperty -Path "$subKey\command" -Name "(default)" -Value $defaultCommand
        }
        Write-Host "$optionName has been added!"
        Start-Sleep -Seconds 1
    }
}

function Add-CPUIdle-Options {
    $localizedOptions = Get-LocalizedOptions

    $systemOptionsKey = "HKCU:\Software\Classes\Directory\Background\shell\SystemOptions"
    if (!(Test-Path $systemOptionsKey)) {
        New-Item -Path $systemOptionsKey -Force | Out-Null
        Set-ItemProperty -Path $systemOptionsKey -Name "MUIVerb" -Value $localizedOptions["menuName"]
        Set-ItemProperty -Path $systemOptionsKey -Name "SubCommands" -Value ""
        Set-ItemProperty -Path $systemOptionsKey -Name "Icon" -Value "C:\Windows\System32\shell32.dll,-28"
        Set-ItemProperty -Path $systemOptionsKey -Name "Position" -Value "Bottom"
    }

    $cpuIdleMenuKey = Join-Path $systemOptionsKey "shell\CPUIdle"
    if (!(Test-Path $cpuIdleMenuKey)) {
        New-Item -Path $cpuIdleMenuKey -Force | Out-Null
        Set-ItemProperty -Path $cpuIdleMenuKey -Name "MUIVerb" -Value $localizedOptions["cpuIdleMenu"]
        Set-ItemProperty -Path $cpuIdleMenuKey -Name "SubCommands" -Value ""
        Set-ItemProperty -Path $cpuIdleMenuKey -Name "Icon" -Value "powercpl.dll"
    }

    $cpuIdleOnCommand ="cmd.exe /c `"powercfg /setacvalueindex scheme_current sub_processor 5d76a2ca-e8c0-402f-a133-2158492d58ad 0 && powercfg /setactive scheme_current`""
    $cpuIdleOffCommand ="cmd.exe /c `"powercfg /setacvalueindex scheme_current sub_processor 5d76a2ca-e8c0-402f-a133-2158492d58ad 1 && powercfg /setactive scheme_current`""

    ContextMenuOption $localizedOptions["cpuIdleOn"] "CPUIdleOn" $cpuIdleOnCommand "powercpl.dll" "CPUIdle"
    ContextMenuOption $localizedOptions["cpuIdleOff"] "CPUIdleOff" $cpuIdleOffCommand "powercpl.dll" "CPUIdle"

}

function Add-Power-Menu-Options {
    $localizedOptions = Get-LocalizedOptions

    $systemOptionsKey = "HKCU:\Software\Classes\Directory\Background\shell\SystemOptions"
    if (!(Test-Path $systemOptionsKey)) {
        New-Item -Path $systemOptionsKey -Force | Out-Null
        Set-ItemProperty -Path $systemOptionsKey -Name "MUIVerb" -Value $localizedOptions["menuName"]
        Set-ItemProperty -Path $systemOptionsKey -Name "SubCommands" -Value ""
        Set-ItemProperty -Path $systemOptionsKey -Name "Icon" -Value "C:\Windows\System32\shell32.dll,-28"
        Set-ItemProperty -Path $systemOptionsKey -Name "Position" -Value "Bottom"
    }

    $powerMenuKey = Join-Path $systemOptionsKey "shell\PowerMenu"
    if (!(Test-Path $powerMenuKey)) {
        New-Item -Path $powerMenuKey -Force | Out-Null
        Set-ItemProperty -Path $powerMenuKey -Name "MUIVerb" -Value $localizedOptions["powerMenu"]
        Set-ItemProperty -Path $powerMenuKey -Name "SubCommands" -Value ""
        Set-ItemProperty -Path $powerMenuKey -Name "Icon" -Value "powercpl.dll"
    }

    ContextMenuOption $localizedOptions["shutdown"] "Shutdown" "shutdown.exe /s /t 0" "C:\Windows\System32\shell32.dll,-329" "PowerMenu"
    ContextMenuOption $localizedOptions["restart"] "Restart" "shutdown.exe /r /t 0" "C:\Windows\System32\shell32.dll,-331" "PowerMenu"
    ContextMenuOption $localizedOptions["restartBios"] "Restart (BIOS)" "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `"Start-Process shutdown.exe -ArgumentList '/r /fw /t 1' -Verb RunAs`"" "C:\Windows\System32\shell32.dll,24" "PowerMenu"
}

function ContextMenuOptions {
    $localizedOptions = Get-LocalizedOptions
    do {
        Show-Options-Menu
        $choice = Read-Host "Select an option to add/remove"
        Switch ($choice) {
            "1" { ContextMenuOption $localizedOptions["cleanup"] "Cleanup" "cleanmgr.exe /sagerun:1337" "cleanmgr.exe" }
            "2" { ContextMenuOption $localizedOptions["msconfig"] "Msconfig" "msconfig.exe" "msconfig.exe" }
            "3" { ContextMenuOption $localizedOptions["regedit"] "Regedit" "regedit.exe" "C:\Windows\regedit.exe" }
            "4" { Add-CPUIdle-Options }
            "5" { Add-Power-Menu-Options }
            "0" { break }
            Default { Write-Host "Invalid option. Please try again."; Start-Sleep -Seconds 2 }
        }
    } while ($choice -ne "0")
}

function Remove-ContextMenu {
    try {
        $baseKey = "HKCU:\Software\Classes\Directory\Background\shell\SystemOptions"
        If (Test-Path $baseKey) {
            Remove-Item -Path $baseKey -Recurse -Force
            Write-Host "The context menu has been removed successfully!"
            Start-Sleep -Seconds 2
        } else {
            Write-Host "No context menu to remove."
            Start-Sleep -Seconds 2
        }
    } catch {
        Write-Host "Error removing context menu: $_"
        Start-Sleep -Seconds 2
    }
}

function Main {
    Do {
        Show-Menu
        $choice = Read-Host "Please select an option"
        Switch ($choice) {
            "1" {
                ContextMenuOptions
            }
            "2" {
                Remove-ContextMenu
            }
            "0" {
                Write-Host "Closing the script. Goodbye!"
                Start-Sleep -Seconds 2
                Exit
            }
            Default {
                Write-Host "Invalid option. Please try again."
                Start-Sleep -Seconds 2
            }
        }
    } While ($choice -ne "0")
}
Main
