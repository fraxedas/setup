# Install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Visual Studio
choco install visualstudio-installer -y

#resharper
choco install resharper-platform -y

# Install vscode
choco install vscode -y

# Notepadd++
choco install notepadplusplus -y

# postman
choco install postman -y

# fiddler
choco install fiddler -y

# git
choco install git -y

# kdiff3
choco install kdiff3 -y

# teams
choco install microsoft-teams -y

# node
choco install nodejs -y

# yarn
choco install yarn -y

# google-backup-and-sync
choco install google-backup-and-sync -y

# googlechrome
choco install googlechrome -y

# firefox
choco install firefox -y

# Upgrade
choco upgrade all -y