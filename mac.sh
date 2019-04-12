#!/bin/bash

# Install homebrew and cask
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew install caskroom/cask/brew-cask

#Visual Studio and dev tools
brew cask install visual-studio
brew cask install microsoft-azure-storage-explorer
brew cask install visual-studio-code

# Web tools
brew cask install postman

# git
brew cask install github
source git-alias.ps1

# Web dev tools and frameworks
brew install nodejs
brew install yarn

# Productivity
brew cask install microsoft-teams
brew cask install google-backup-and-sync
brew cask install google-chrome
brew cask install firefox

# Upgrade
brew update
brew upgrade
brew cask upgrade