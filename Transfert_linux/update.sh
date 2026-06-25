#!/bin/bash
# update.sh - Script de mise à jour automatique

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}              🔄 Mise à jour de Transfert TCP              ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Lire la version actuelle
if [ -f "build.sh" ]; then
    CURRENT_VERSION=$(grep "APP_VERSION=" build.sh | cut -d'"' -f2)
    echo -e "📌 Version actuelle: ${GREEN}$CURRENT_VERSION${NC}"
fi

# Demander la nouvelle version
echo ""
read -p "📝 Nouvelle version (ex: 1.0.1) : " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo -e "${RED}❌ Version non spécifiée !${NC}"
    exit 1
fi

# Demander la description
read -p "📝 Description des changements : " DESCRIPTION

if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION="Mise à jour vers v$NEW_VERSION"
fi

echo ""
echo -e "${BLUE}▶ Étape 1/6 : Mise à jour du code${NC}"
echo "   Modifiez transfert.py si nécessaire"
read -p "   Appuyez sur Entrée quand c'est fait..."

echo -e "${BLUE}▶ Étape 2/6 : Mise à jour des versions${NC}"
sed -i "s/APP_VERSION=\"[0-9.]*\"/APP_VERSION=\"$NEW_VERSION\"/g" build.sh
echo -e "   ✅ build.sh mis à jour (v$NEW_VERSION)"

echo -e "${BLUE}▶ Étape 3/6 : Nettoyage et rebuild${NC}"
rm -rf build dist AppDir __pycache__
./build.sh

echo -e "${BLUE}▶ Étape 4/6 : Test de l'application${NC}"
APPIMAGE="Transfert_TCP-v${NEW_VERSION}-x86_64.AppImage"
if [ -f "$APPIMAGE" ]; then
    echo -e "   ✅ AppImage créée: $APPIMAGE"
    echo -e "   🚀 Lancement pour test..."
    ./"$APPIMAGE" &
    sleep 2
    echo -e "   ✅ Application lancée (fermez-la pour continuer)"
    read -p "   Appuyez sur Entrée quand le test est terminé..."
else
    echo -e "${RED}   ❌ AppImage non créée !${NC}"
    exit 1
fi

echo -e "${BLUE}▶ Étape 5/6 : Commit et push${NC}"
git add transfert.py build.sh
git commit -m "Version $NEW_VERSION - $DESCRIPTION"
git push origin main

echo -e "${BLUE}▶ Étape 6/6 : Création du tag${NC}"
git tag -a "v$NEW_VERSION" -m "Version $NEW_VERSION - $DESCRIPTION"
git push origin "v$NEW_VERSION"

echo ""
echo -e "${GREEN}✅ Mise à jour terminée avec succès !${NC}"
echo -e "📦 Nouvelle version: ${GREEN}v$NEW_VERSION${NC}"
echo -e "🔗 GitHub: https://github.com/ornel-Am/Transfert_TCP/releases"
echo ""
echo -e "🚀 Les builds seront automatiquement créés par GitHub Actions."
echo -e "   Attendez 5-10 minutes puis téléchargez-les depuis les Releases."
