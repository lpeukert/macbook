#!/usr/bin/env bash

# Autor: Lutz Peukert - IVX - Campus-Ops (Original)
# Optimierte Version: Modernized & Robust
# ---------------------------------------------------------

# Farben für bessere Lesbarkeit
GREEN='\033[0;32m'
BLUE='\033[1;34m'
BOLD_WHITE='\x1B[1;47m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== macOS Setup Script v1.0 ===${NC}\n"

# 1. Architektur-Erkennung
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    HOMEBREW_PATH="/opt/homebrew"
else
    HOMEBREW_PATH="/usr/local"
fi
HOMEBREW_BIN="$HOMEBREW_PATH/bin/brew"

# 2. Xcode CLI Tools (Prüfung statt nur Aufforderung)
echo -e "${BOLD_WHITE} Checking Xcode CLI tools... ${NC}"
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode CLI tools..."
    xcode-select --install
    echo -e "${GREEN}Bitte beende die Installation im Pop-up-Fenster und starte das Skript erneut.${NC}"
    exit 0
else
    echo "Xcode CLI tools bereits installiert."
fi

# 3. Rosetta 2 (Nur für Apple Silicon)
if [[ "$ARCH" == "arm64" ]]; then
    # Prüfen, ob Rosetta bereits läuft (oahd = Rosetta background daemon)
    if ! pgrep -q "oahd"; then
        echo -e "${BOLD_WHITE} Installing Rosetta 2... ${NC}"
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    else
        echo "Rosetta 2 bereits installiert."
    fi
fi

# 4. Homebrew Installation & Environment
if [[ ! -f "$HOMEBREW_BIN" ]]; then
    echo -e "${BOLD_WHITE} Installing Homebrew... ${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Shell-Umgebung konfigurieren (ohne Duplikate in .zprofile)
if ! grep -q "$HOMEBREW_PATH/bin/shellenv" "$HOME/.zprofile" 2>/dev/null; then
    echo "Adding Homebrew to .zprofile..."
    echo "eval \"\$($HOMEBREW_BIN shellenv)\"" >> "$HOME/.zprofile"
fi
# Aktiviere Homebrew sofort für die laufende Session
eval "$($HOMEBREW_BIN shellenv)"

# 5. Update & Upgrade
echo -e "${BOLD_WHITE} Updating Homebrew... ${NC}"
brew update && brew upgrade

# 6. Pakete installieren (CLI & Cask getrennt)
echo -e "${BOLD_WHITE} Installing Packages... ${NC}"
CLI_TOOLS=(git mpv wget)
CASKS=(firefox keybase google-chrome iterm2 slack tunnelblick bitwarden authy)

for pkg in "${CLI_TOOLS[@]}"; do
    if ! brew list "$pkg" &>/dev/null; then
        brew install "$pkg"
    fi
done

for cask in "${CASKS[@]}"; do
    if ! brew list --cask "$cask" &>/dev/null; then
        brew install --cask "$cask"
    fi
done

# 7. Cleanup
brew cleanup

echo -e "\n${GREEN}Setup erfolgreich abgeschlossen!${NC}"
echo "Bitte starte dein Terminal neu, damit alle Änderungen aktiv werden."