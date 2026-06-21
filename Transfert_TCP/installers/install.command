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

REPO_URL="https://raw.githubusercontent.com/ornel-Am/Transfert_TCP/main"
SCRIPT_URL="$REPO_URL/src/transfert_gui.py"
SCRIPT_NAME="transfert_gui.py"

echo -e "${YELLOW}📥 Téléchargement du script...${NC}"
curl -L -o "$SCRIPT_NAME" "$SCRIPT_URL"

if [ ! -f "$SCRIPT_NAME" ]; then
    echo -e "${RED}❌ Échec du téléchargement.${NC}"
    exit 1
fi

# Vérifier Python3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 non trouvé.${NC}"
    echo -e "${YELLOW}📦 Installez Python depuis https://python.org${NC}"
    exit 1
fi

# Installer
mkdir -p ~/Applications
cp "$SCRIPT_NAME" ~/Applications/transfert_gui.py
chmod +x ~/Applications/transfert_gui.py

echo -e "${GREEN}✅ Installation terminée !${NC}"
echo -e "${BLUE}📌 Lancez avec : python3 ~/Applications/transfert_gui.py${NC}"
