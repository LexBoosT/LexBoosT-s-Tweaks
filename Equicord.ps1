# Vérifiez si le script est en cours d'exécution en tant qu'administrateur
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Relancez le script en tant qu'administrateur
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Installer Winget dans sa dernière version
Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle" -OutFile "Winget.appxbundle"
Add-AppxPackage -Path .\Winget.appxbundle

# Installer Git
winget install --id Git.Git -e --source winget

# Installer NodeJS
winget install --id OpenJS.NodeJS.LTS -e --source winget

# Installer pnpm
npm i -g pnpm

# Cloner Equicord
git clone https://github.com/Equicord/Equicord
cd Equicord

# Installer les dépendances
pnpm install --frozen-lockfile

# Construire Equicord
pnpm build

# Injecter Equicord dans votre client
pnpm inject

# Boucle pour relancer 'pnpm inject'
do {
    Write-Host "Choose 1 to Inject or 2 to Exit Powershell"
    $choice = Read-Host "Entrez votre choix"
    if ($choice -eq '1') {
        pnpm inject
    } elseif ($choice -eq '2') {
        exit
    } else {
        Write-Host "Invalid choice. Please choose 1 to Inject or 2 to exit Powershell"
    }
} while ($true)




