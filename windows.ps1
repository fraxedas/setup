# Install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

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

# Upgrade
choco upgrade all -y