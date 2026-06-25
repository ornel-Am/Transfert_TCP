#!/bin/bash
# build-appimage.sh - Création de l'AppImage pour Transfert TCP

set -e

APP_NAME="transfert-app"
APP_VERSION="1.0.0"

echo "🔨 Création de l'AppImage pour Transfert TCP v${APP_VERSION}"

# Vérifier que l'exécutable existe
if [ ! -f "dist/$APP_NAME" ]; then
    echo "❌ Exécutable non trouvé: dist/$APP_NAME"
    exit 1
fi

# Créer la structure AppDir
echo "📁 Création de la structure AppDir..."
mkdir -p AppDir/usr/bin
cp "dist/$APP_NAME" AppDir/usr/bin/

# Créer le fichier .desktop
echo "📝 Création du fichier .desktop..."
cat > AppDir/$APP_NAME.desktop << 'DESKTOP'
[Desktop Entry]
Name=Transfert TCP
Comment=Application de transfert de fichiers TCP
Exec=transfert-app
Icon=transfert-app
Terminal=false
Type=Application
Categories=Network;FileTransfer;
StartupNotify=true
DESKTOP

# Créer AppRun
echo "📝 Création de AppRun..."
cat > AppDir/AppRun << 'APPRUN'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/transfert-app" "$@"
APPRUN
chmod +x AppDir/AppRun

# Copier l'icône si disponible
if [ -f "icon.png" ]; then
    echo "🖼️  Copie de l'icône..."
    cp icon.png AppDir/transfert-app.png
fi

# Télécharger appimagetool
echo "📦 Téléchargement de appimagetool..."
if [ ! -f "appimagetool-x86_64.AppImage" ]; then
    wget -q --show-progress https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x appimagetool-x86_64.AppImage
fi

# Créer l'AppImage
echo "🔨 Construction de l'AppImage..."
./appimagetool-x86_64.AppImage AppDir "Transfert_TCP-v${APP_VERSION}-x86_64.AppImage"

# Vérifier
if [ -f "Transfert_TCP-v${APP_VERSION}-x86_64.AppImage" ]; then
    echo "✅ AppImage créée avec succès !"
    echo "📦 Fichier: Transfert_TCP-v${APP_VERSION}-x86_64.AppImage"
    echo "📏 Taille: $(du -h Transfert_TCP-v${APP_VERSION}-x86_64.AppImage | cut -f1)"
else
    echo "❌ Échec de la création de l'AppImage"
    exit 1
fi
