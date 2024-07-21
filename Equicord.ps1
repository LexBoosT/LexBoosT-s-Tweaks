# Vérifiez si le script est en cours d'exécution en tant qu'administrateur
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Relancez le script en tant qu'administrateur
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$DOWNLOAD_GUI = "https://github.com/Equicord/Equilotl/releases/latest/download/Equilotl.exe"

$link = $DOWNLOAD_GUI

$outfile = "$env:TEMP\$(([uri]$link).Segments[-1])"

Write-Output "Downloading installer to $outfile"

Invoke-WebRequest -Uri "$link" -OutFile "$outfile"

Write-Output ""

Start-Process -Wait -NoNewWindow -FilePath "$outfile"

# Cleanup
Remove-Item -Force "$outfile"



