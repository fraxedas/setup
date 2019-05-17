#!/bin/bash

function installBrew() {
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.bash_profile
}

function binstall() {
    echo Checking $1
    brew list $1 >> /dev/null || brew install $1
}

function cinstall() {
    echo Checking $1
    brew cask list $1 >> /dev/null || brew cask install $1
}

# Install homebrew and cask
brew doctor || installBrew

#Visual Studio and dev tools
cinstall visual-studio
cinstall microsoft-azure-storage-explorer
cinstall visual-studio-code
brew tap azure/functions
binstall azure-functions-core-tools

# Web tools
cinstall postman

# git
cinstall github
source git-alias.ps1
cinstall sourcetree

# Web dev tools and frameworks
binstall nodejs
binstall yarn
binstall python

#ML
cinstall anaconda
echo 'export PATH="/usr/local/anaconda3/bin:$PATH"' >> ~/.bash_profile

# Productivity
cinstall microsoft-teams
cinstall google-backup-and-sync
cinstall google-chrome
cinstall firefox

# Upgrade
brew update
brew upgrade
brew cask upgrade