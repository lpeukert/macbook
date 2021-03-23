#!/usr/bin/env bash
# Autor: Lutz Peukert - IVX - Campus-Ops 22/Mar/2021 v0.9
ARCH=$(uname -m)
xcode-select --install
read -rp "Have you completed the Xcode CLI tools install (y/n)? " xcode_response
if [[ "$xcode_response" != "y" ]]; then
  printf "ERROR: Xcode CLI tools must be installed before proceeding.\n"
  exit 1
fi
if [[ "$ARCH" == "arm64" ]]; then
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  read -rp "Have you completed the Rosetta install (y/n)? " rosetta_response
  if [[ "$rosetta_response" != "y" ]]; then
    printf "ERROR: Rosetta must be installed before proceeding.\n"
    exit 1
  fi
fi
if ! command -v brew > /dev/null; then
  echo  "Installing Homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
echo "Upgrading homebrew ..."
brew update && brew upgrade && brew cleanup
echo "Install packages ..."
for package in git mpv wget ; do
  brew install "$package"
done
brew tap homebrew/cask
for package in firefox keybase google-chrome iterm2 slack tunnelblick bitwarden; do
  brew install --cask "$package"
done
echo "All done. Have a nice day!"