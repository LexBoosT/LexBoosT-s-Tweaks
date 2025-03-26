<#
.SYNOPSIS
    Script PowerShell avec menu ASCII pour installer Amazon Corretto via Winget
.DESCRIPTION
    Ce script offre une interface utilisateur stylisée permettant d'installer
    les versions Amazon Corretto de Java 8 à la dernière version disponible.
.NOTES
    Version: 1.4
    Auteur: VotreNom
    Date: $(Get-Date -Format "yyyy-MM-dd")
#>

# Configuration de la console
$Host.UI.RawUI.WindowTitle = "Amazon Corretto Installer via Winget"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Vérification de Winget
function Test-Winget {
    try {
        $wingetVersion = winget --version
        return $true
    } catch {
        return $false
    }
}

<#
.SYNOPSIS
    Script PowerShell avec menu ASCII coloré pour installer Amazon Corretto via Winget
.DESCRIPTION
    Ce script offre une interface utilisateur colorée permettant d'installer
    les versions Amazon Corretto de Java 8 à la dernière version disponible.
.NOTES
    Version: 1.5
    Auteur: VotreNom
    Date: $(Get-Date -Format "yyyy-MM-dd")
#>

# Configuration de la console
$Host.UI.RawUI.WindowTitle = "Amazon Corretto Installer via Winget"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Vérification de Winget
function Test-Winget {
    try {
        $wingetVersion = winget --version
        return $true
    } catch {
        return $false
    }
}

# Affichage du menu ASCII coloré
function Show-Menu {
    Clear-Host
    # Ligne 1 - Titre
    Write-Host "  _______________________________________________________" -ForegroundColor DarkCyan
    # Ligne 2 - Titre
    Write-Host " /                                                       \" -ForegroundColor DarkCyan
    # Ligne 3 - Titre principal
    Write-Host "|                    LexBoosT Java Menu                   |" -ForegroundColor Magenta
    # Ligne 4 - Fin titre
    Write-Host " \_______________________________________________________/" -ForegroundColor DarkCyan
    # Ligne 5 - Séparateur
    Write-Host " /                                                       \" -ForegroundColor DarkCyan
    # Ligne 6 - Vide
    Write-Host "|                                                         |" -ForegroundColor DarkCyan
    
    # Options du menu avec couleurs différentes
    Write-Host "|   [1] Install Amazon Corretto 8                         |" -ForegroundColor Green
    Write-Host "|   [2] Install Amazon Corretto 11                        |" -ForegroundColor Yellow
    Write-Host "|   [3] Install Amazon Corretto 17                        |" -ForegroundColor Cyan
    Write-Host "|   [4] Install Amazon Corretto 21                        |" -ForegroundColor Blue
    Write-Host "|   [5] Install Amazon Corretto 22                        |" -ForegroundColor Red
    Write-Host "|   [6] Install Amazon Corretto 23                        |" -ForegroundColor DarkYellow
    Write-Host "|   [7] Install Amazon Corretto 24                        |" -ForegroundColor DarkMagenta
    Write-Host "|   [8] Update all Corretto packages                      |" -ForegroundColor White
    Write-Host "|   [0] Quit                                              |" -ForegroundColor Gray
    
    # Ligne finale
    Write-Host " \_______________________________________________________/" -ForegroundColor DarkCyan
    Write-Host ""
    
    Write-Host "Select an option (0-8) : " -ForegroundColor Yellow -NoNewline
}

# Installation de Corretto via Winget
function Install-Corretto {
    param (
        [string]$packageId,
        [string]$version
    )
    
    $packageName = "Amazon Corretto $version"
    Write-Host "`nStart of the installation of $packageName..." -ForegroundColor Green
    Write-Host "Execution of: winget install --id $packageId -e" -ForegroundColor Gray
    
    try {
        winget install --id $packageId -e --accept-package-agreements --accept-source-agreements
        Write-Host "`nInstallation of $packageName successfully completed!" -ForegroundColor Green
    } catch {
        Write-Host "`nError when installing $packageName : $_" -ForegroundColor Red
    }
    
    Pause
}

# Mise à jour de tous les paquets Corretto
function Update-AllCorretto {
    Write-Host "`nSearch for updates for Amazon Corretto..." -ForegroundColor Green
    
    try {
        winget upgrade --name "Corretto"
        Write-Host "`nUpdate of Corretto packages finished!" -ForegroundColor Green
    } catch {
        Write-Host "`nError when updating Corretto packages : $_" -ForegroundColor Red
    }
    
    Pause
}

# Fonction pause
function Pause {
    Write-Host "`nPress a key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main
if (-not (Test-Winget)) {
    Write-Host "`nWinget is not installed or is not in the path." -ForegroundColor Red
    Write-Host "Please install Winget before using this script." -ForegroundColor Yellow
    Write-Host "More information: https://aka.ms/winget" -ForegroundColor Cyan
    Pause
    exit
}

# Boucle principale
do {
    Show-Menu
    $choice = Read-Host
    
    switch ($choice) {
        '1' { Install-Corretto "Amazon.Corretto.8.JDK" "8" }
        '2' { Install-Corretto "Amazon.Corretto.11.JDK" "11" }
        '3' { Install-Corretto "Amazon.Corretto.17.JDK" "17" }
        '4' { Install-Corretto "Amazon.Corretto.21.JDK" "21" }
        '5' { Install-Corretto "Amazon.Corretto.22.JDK" "22" }
        '6' { Install-Corretto "Amazon.Corretto.23.JDK" "23" }
        '7' { Install-Corretto "Amazon.Corretto.24.JDK" "24" }
        '8' { Update-AllCorretto }
        '0' { 
            Write-Host "`nThank you for using the Amazon Corretto installer. Bye!`n" -ForegroundColor Cyan
            exit 
        }
        default {
            Write-Host "`nInvalid option. Please choose a number between 0 and 8." -ForegroundColor Red
            Pause
        }
    }
} while ($true)