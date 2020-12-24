# Install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Visual Studio
choco install visualstudio2019community -y
choco install visualstudio2019-workload-azure -y
choco install visualstudio2019-workload-manageddesktop -y
choco install visualstudio2019-workload-netcoretools -y
choco install visualstudio2019-workload-netcrossplat -y
choco install visualstudio2019-workload-netweb -y
choco install visualstudio2019-workload-xamarinbuildtools -y

#Dev tools
choco install resharper-ultimate-all /NoCpp /NoTeamCityAddin -y
choco install sql-server-management-studio -y
choco install microsoftazurestorageexplorer -y
choco install azure-functions-core-tools -y
choco install docker-cli -y
choco install nugetpackageexplorer -y

# Editors
choco install vscode -y
choco install notepadplusplus -y

# Web tools
choco install postman -y
choco install fiddler -y

# git
choco install git -y
refreshenv
./git-alias.ps1
choco install github-desktop -y
choco install sourcetree -y
choco install kdiff3 -y

# Web dev tools and frameworks
choco install nodejs -y
choco install yarn -y
choco install python -y

#ML
choco install anaconda3 -y --params /AddToPath
conda install -c pytorch -c fastai fastai

# Productivity
choco install microsoft-teams -y
choco install google-backup-and-sync -y
choco install googlechrome -y
choco install firefox -y
choco install adobereader -y
choco install irfanview -y

# Upgrade
choco upgrade all -y