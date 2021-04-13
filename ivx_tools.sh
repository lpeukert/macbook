#!/usr/bin/env bash
# Autor: Lutz Peukert - IVX - Campus-Ops 22/Mar/2021 v0.97 - Update 13/Apr/2021 Thx to K.Forsthövel
ARCH=$(uname -m)

if [[ "$ARCH" == "arm64" ]]; then
  HOMEBREW_BIN=/opt/homebrew/bin/brew
else
  HOMEBREW_BIN=/usr/local/bin/brew
fi

echo  -e "\x1B[1;47m Installing Xcode CLI tools now (please wait) ... \x1B[0m"
xcode-select --install
read -rp "Have you completed the Xcode CLI tools install (y/n)? " xcode_response
if [[ "$xcode_response" != "y" ]]; then
  printf "ERROR: Xcode CLI tools must be installed before proceeding. Please restart the script.\n"
  exit 1
fi
if [[ "$ARCH" == "arm64" ]]; then
  echo  -e "\x1B[1;47m Installing Rosetta 2 Framework now (please wait) ...\x1B[0m"
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  read -rp "Have you completed the Rosetta install (y/n)? " rosetta_response
  if [[ "$rosetta_response" != "y" ]]; then
    printf "ERROR: Rosetta must be installed before proceeding. Please restart the script.\n"
    exit 1
  fi
fi
if ! command -v brew > /dev/null; then
  echo  -e "\x1B[1;47m Installing Homebrew now (please wait) ... \x1B[0m"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "$(eval "$($HOMEBREW_BIN shellenv)")" >> "$HOME/.zprofile"
fi

echo -e "\x1B[1;47m Upgrading homebrew now (please wait) ... \x1B[0m"
$HOMEBREW_BIN update && $HOMEBREW_BIN upgrade && $HOMEBREW_BIN cleanup
echo -e "\x1B[1;47m Install packages now (please wait) ... \x1B[0m"
for package in git mpv wget ; do
  $HOMEBREW_BIN install "$package"
done

$HOMEBREW_BIN tap homebrew/cask
for package in firefox keybase google-chrome iterm2 slack tunnelblick bitwarden authy; do
  $HOMEBREW_BIN install --cask "$package"
done

echo "What was installed:"
echo "- Google Chrome - Browser"
echo "- FireFox - Browser"
echo "- Keybase - Secure File & Chat"
echo "- iTerm2 - Terminal"
echo "- slack - Main Communication Tool"
echo "- Tunnelblick - VPN Client"
echo "- Bitwarden - Password Manager"
echo "- Authy - 2FA Two-factor authentication"
echo "All done. You can find the installed programs under Applications"
echo "Have a nice day!"
