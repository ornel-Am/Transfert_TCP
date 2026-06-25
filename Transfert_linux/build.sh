#!/bin/bash
# build.sh - Version ULTIME sans here-document
set -e

# Variables
APP_NAME="transfert-app"
APP_VERSION="1.0.0"
VENV_DIR="venv-build"
DIST_DIR="dist"

echo "🔨 Construction de Transfert TCP v${APP_VERSION}"

# Nettoyage
rm -rf "$DIST_DIR" build/ "$VENV_DIR" __pycache__/

# Environnement virtuel
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Installation
pip install --upgrade pip > /dev/null 2>&1
pip install pyinstaller > /dev/null 2>&1

# Build
pyinstaller --onefile --windowed --name "$APP_NAME" transfert.py

# AppImage
if [ -f "$DIST_DIR/$APP_NAME" ]; then
    echo "✅ Build réussi: $DIST_DIR/$APP_NAME"
    
    # Télécharger appimagetool
    wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x appimagetool-x86_64.AppImage
    
    # Créer AppDir
    mkdir -p AppDir/usr/bin
    cp "$DIST_DIR/$APP_NAME" AppDir/usr/bin/
    
    # Fichier .desktop
    echo "[Desktop Entry]" > AppDir/$APP_NAME.desktop
    echo "Name=Transfert TCP" >> AppDir/$APP_NAME.desktop
    echo "Exec=transfert-app" >> AppDir/$APP_NAME.desktop
    echo "Terminal=false" >> AppDir/$APP_NAME.desktop
    echo "Type=Application" >> AppDir/$APP_NAME.desktop
    echo "Categories=Network;" >> AppDir/$APP_NAME.desktop
    
    # AppRun
    echo "#!/bin/bash" > AppDir/AppRun
    echo 'exec "$(dirname "$(readlink -f "$0")")/usr/bin/transfert-app"' >> AppDir/AppRun
    chmod +x AppDir/AppRun
    
    # Construire
    ARCH=x86_64 ./appimagetool-x86_64.AppImage AppDir Transfert_TCP-v1.0.0-x86_64.AppImage
    
    echo "✅ AppImage créée"
fi

deactivate
