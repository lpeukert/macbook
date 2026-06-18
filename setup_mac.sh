#!/bin/bash

# ==========================================
# Konfiguration & Farben
# ==========================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[HINWEIS]${NC} $1"; }
error() { echo -e "${RED}[FEHLER]${NC} $1"; }

SUMMARY_LIST=()

echo -e "${BLUE}============================================"
echo -e "   🚀 MacBook Initial-Setup gestartet"
echo -e "============================================${NC}"

# ==========================================
# 0. Administrator-Rechte sichern
# ==========================================
log "Bitte gib dein Mac-Passwort ein (wird für Homebrew benötigt):"
# Sichert die sudo-Rechte vorab, damit die Installation später nicht blockiert
sudo -v || { error "Administrator-Rechte konnten nicht erlangt werden. Abbruch."; exit 1; }

# ==========================================
# 1. Architektur prüfen & Pfad setzen
# ==========================================
ARCH=$(uname -m)

if [ "$ARCH" == "arm64" ]; then
    log "Apple Silicon (ARM) Architektur erkannt."
    BREW_PATH="/opt/homebrew/bin/brew"
else
    log "Intel (x86_64) Architektur erkannt."
    BREW_PATH="/usr/local/bin/brew"
fi

# Prüfen, ob brew schon auf der Festplatte liegt, aber nur nicht im PATH ist
if [ -f "$BREW_PATH" ] && ! command -v brew &> /dev/null; then
    log "Homebrew gefunden, lade Umgebungsvariablen..."
    eval "$($BREW_PATH shellenv)"
fi

# ==========================================
# 2. Homebrew zwingend installieren
# ==========================================
if ! command -v brew &> /dev/null; then
    log "Homebrew ist nicht installiert. Installation startet jetzt..."
    # Installation starten (NONINTERACTIVE unterdrückt die "Press Return"-Abfrage)
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # NACHPRÜFUNG: Wurde Homebrew wirklich erfolgreich installiert?
    if [ -f "$BREW_PATH" ]; then
        eval "$($BREW_PATH shellenv)"
        success "Homebrew wurde erfolgreich installiert!"
    else
        error "Die Installation von Homebrew ist fehlgeschlagen! Das Setup wird abgebrochen."
        exit 1 # Skript bricht hier hart ab
    fi
else
    success "Homebrew ist bereits vorhanden und einsatzbereit."
fi

# ==========================================
# 3. Homebrew Update
# ==========================================
log "Homebrew-Repositories werden aktualisiert..."
brew update > /dev/null

# ==========================================
# 4. App-Installation & Versionsprüfung
# ==========================================
APPS=(
    firefox
    keybase
    google-chrome
    iterm2
    slack
    tunnelblick
    bitwarden
    pearcleaner
    bitwarden-cli
)

echo -e "\n${BLUE}Starte App-Installation & Versionsprüfung...${NC}"

for app in "${APPS[@]}"; do
    if brew list --cask "$app" &> /dev/null || brew list "$app" &> /dev/null; then
        
        INSTALLED_VERSION=$(brew list --versions "$app" | awk '{print $2}' | head -n 1)
        AVAILABLE_VERSION=$(brew info "$app" 2>/dev/null | head -n 1 | awk '{print $2}')
        
        if [ "$INSTALLED_VERSION" == "$AVAILABLE_VERSION" ]; then
            success ">>> '$app' ist auf dem neuesten Stand (Version $INSTALLED_VERSION). Überspringe..."
            SUMMARY_LIST+=("  ${GREEN}✔${NC} ${app}: ${YELLOW}${INSTALLED_VERSION}${NC} (Bereits aktuell)")
            continue
        fi
        
        IS_OUTDATED=$(brew outdated "$app" 2>/dev/null)
        
        if [ -z "$IS_OUTDATED" ]; then
            warn ">>> '$app' ist installiert ($INSTALLED_VERSION) und ist NEUER als Homebrew ($AVAILABLE_VERSION). Überspringe..."
            SUMMARY_LIST+=("  ${BLUE}ℹ${NC} ${app}: ${YELLOW}${INSTALLED_VERSION}${NC} (Neuer als Homebrew)")
            continue
        else
            log ">>> '$app' ist veraltet ($INSTALLED_VERSION -> $AVAILABLE_VERSION). Führe Update durch..."
            if brew upgrade "$app" --quiet 2>/dev/null || brew upgrade --cask "$app" --quiet; then
                FINAL_VERSION=$(brew list --versions "$app" | awk '{print $2}' | head -n 1)
                success "'$app' wurde erfolgreich auf Version $FINAL_VERSION aktualisiert."
                SUMMARY_LIST+=("  ${GREEN}↑${NC} ${app}: ${YELLOW}${FINAL_VERSION}${NC} (Aktualisiert von $INSTALLED_VERSION)")
            else
                error "Konnte '$app' nicht aktualisieren. Gehe zur nächsten App..."
                SUMMARY_LIST+=("  ${RED}✘${NC} ${app}: ${YELLOW}${INSTALLED_VERSION}${NC} (Update fehlgeschlagen)")
            fi
            continue
        fi
    fi

    log "Installiere '$app'..."
    
    if brew install --cask "$app" --quiet 2>/dev/null || brew install "$app" --quiet 2>/dev/null; then
        FINAL_VERSION=$(brew list --versions "$app" | awk '{print $2}' | head -n 1)
        success "'$app' wurde erfolgreich installiert."
        SUMMARY_LIST+=("  ${GREEN}★${NC} ${app}: ${YELLOW}${FINAL_VERSION}${NC} (Neu installiert)")
    else
        if brew list --versions "$app" &>/dev/null; then
            FINAL_VERSION=$(brew list --versions "$app" | awk '{print $2}' | head -n 1)
            warn ">>> '$app' warf einen Fehler, wurde aber in Homebrew registriert (Version $FINAL_VERSION)."
            SUMMARY_LIST+=("  ${YELLOW}⚠${NC} ${app}: ${YELLOW}${FINAL_VERSION}${NC} (Mit Warnung installiert)")
        else
            error "Konnte '$app' nicht über Homebrew installieren. Möglicherweise existiert die App bereits im Programme-Ordner."
            SUMMARY_LIST+=("  ${RED}✘${NC} ${app}: ${RED}Fehlgeschlagen (Oder bereits manuell installiert)${NC}")
        fi
    fi
done

# ==========================================
# 5. Finale Zusammenfassung
# ==========================================
echo -e "\n${BLUE}============================================"
echo -e "   📋 Zusammenfassung der Installation"
echo -e "============================================${NC}"

for entry in "${SUMMARY_LIST[@]}"; do
    echo -e "$entry"
done

echo -e "\n${GREEN}============================================"
echo -e "   ✅ Setup erfolgreich abgeschlossen!"
echo -e "============================================${NC}"
