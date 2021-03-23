# Autor: Lutz Peukert - IVX - Campus-Ops 22/Mar/2021 v0.9
#!/bin/bash
echo "What kind of MacBook do you have:"
PS3='Choose your processor architecture: '
procs=("Intel" "Apple" "Quit")
select fav in "${procs[@]}"; do
    case $fav in
        "Intel")
            echo "Starting installation for $fav based device!"
	    # optionally call a function or run some code here
		if test ! $(which brew); then
		    echo "Installing homebrew..."
		    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		fi

		# Update homebrew recipes
		brew update
		# Upgrade any already installed formulae
		brew upgrade
		# Install my brew packages
		brew install wget
		brew install mpv

		# Install cask
		brew tap homebrew/cask

		# Install desired cask packages
		# brew install --cask 1password
		brew install --cask firefox
		brew install --cask keybase
		brew install --cask google-chrome
		brew install --cask iterm2
		# brew install --cask adobe-acrobat-reader
		brew install --cask slack 
		brew install --cask tunnelblick
		brew install --cask bitwarden 

		# Remove brew cruft
		brew cleanup

		# Final line....
		echo "Macbook setup completed!"
		
		break
            ;;
        "Apple")
            echo "Starting installation for $fav based device!"
	    # optionally call a function or run some code here
		#!/usr/bin/env bash

		echo "Starting setup"

		# install xcode CLI
		xcode-select --install
		echo "Please wait till the installation of XCODE is finished"
		read -rsp $'Press any key to continue...\n' -n1 key

		/usr/sbin/softwareupdate --install-rosetta --agree-to-license
		echo "Please wait till the installation of ROSETTA is finished"
		read -rsp $'Press any key to continue...\n' -n1 key

		# Check for Homebrew ; install if not ; update 

		#if test ! $(which brew); then
		#    echo "Installing homebrew..."
		#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /tmp/homebrew-install.log
		#fi

		echo "Installing homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/infra/.zprofile
		    eval "$(/opt/homebrew/bin/brew shellenv)"

		# Update homebrew recipes
		brew update

		# Upgrade any already installed formulae
		brew upgrade

		# Install my brew packages
		brew install wget
		brew install mpv

		# Install cask
		brew tap homebrew/cask

		# Install desired cask packages
		# brew install --cask 1password
		brew install --cask firefox
		brew install --cask keybase
		brew install --cask google-chrome
		brew install --cask iterm2
		# brew install --cask adobe-acrobat-reader
		brew install --cask slack 
		brew install --cask tunnelblick
		brew install --cask bitwarden 

		# Remove brew cruft
		brew cleanup

		# Final line....
		echo "Macbook setup completed!"
		
		break
            ;;
	"Quit")
	    echo "User requested exit"
	    exit
	    ;;
        *) echo "invalid option $REPLY";;
    esac
done