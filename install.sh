#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   📦 TransfertTCP - Installation${NC}"
echo -e "${BLUE}========================================${NC}"

# URLs
REPO_URL="https://raw.githubusercontent.com/ornel-Am/Transfert_TCP/main"
SCRIPT_URL="$REPO_URL/src/transfert_gui.py"
SCRIPT_NAME="transfert_gui.py"

echo -e "${YELLOW}📥 Téléchargement du script depuis GitHub...${NC}"
curl -L -o "$SCRIPT_NAME" "$SCRIPT_URL"

if [ ! -f "$SCRIPT_NAME" ]; then
    echo -e "${RED}❌ Échec du téléchargement.${NC}"
    exit 1
fi

# Détection de l'OS
OS="$(uname -s)"
ARCH="$(uname -m)"
echo -e "${YELLOW}🔍 Système : $OS ($ARCH)${NC}"

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 non trouvé.${NC}"
    echo -e "${YELLOW}📦 Installation de Python...${NC}"
    sudo apt update && sudo apt install -y python3 python3-tk
fi

# Installation
mkdir -p ~/.local/bin
cp "$SCRIPT_NAME" ~/.local/bin/transfert_gui
chmod +x ~/.local/bin/transfert_gui

# Lanceur
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/transfert.desktop << 'DESKTOP'
[Desktop Entry]
Name=TransfertTCP
Comment=Transfert de fichiers TCP
Exec=$HOME/.local/bin/transfert_gui
Icon=applications-other
Terminal=false
Type=Application
Categories=Network;
DESKTOP

echo -e "${GREEN}✅ Installation terminée !${NC}"
echo -e "${BLUE}📌 Lancez avec : transfert_gui${NC}"
