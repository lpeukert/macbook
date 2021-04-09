#!/usr/bin/env bash
# Autor: Lutz Peukert - IVX - Campus-Ops 22/Mar/2021 v0.92 - Update 09/Apr/2021
ARCH=$(uname -m)
echo  "Installing Xcode CLI tools now (please wait) ..."
xcode-select --install
read -rp "Have you completed the Xcode CLI tools install (y/n)? " xcode_response
if [[ "$xcode_response" != "y" ]]; then
  printf "ERROR: Xcode CLI tools must be installed before proceeding. Please restart the script.\n"
  exit 1
fi
if [[ "$ARCH" == "arm64" ]]; then
  echo  "Installing Rosetta 2 Framework now (please wait) ..."
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  read -rp "Have you completed the Rosetta install (y/n)? " rosetta_response
  if [[ "$rosetta_response" != "y" ]]; then
    printf "ERROR: Rosetta must be installed before proceeding. Please restart the script.\n"
    exit 1
  fi
fi
if ! command -v brew > /dev/null; then
  echo  "Installing Homebrew now (please wait) ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile
fi
echo "Upgrading homebrew now (please wait) ..."
brew update && brew upgrade && brew cleanup
echo "Install packages now (please wait) ..."
for package in git mpv wget ; do
  brew install "$package"
done
brew tap homebrew/cask
for package in firefox keybase google-chrome iterm2 slack tunnelblick bitwarden; do
  brew install --cask "$package"
done
echo "All done. Have a nice day! You can find the installed programs under Applications"
