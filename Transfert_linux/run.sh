#!/bin/bash
# run.sh - Build et lance l'application Transfert TCP

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              🚀 Transfert TCP - Build & Run              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Aller dans le bon dossier
cd ~/Transfert_linux

# Vérifier si build.sh existe
if [ ! -f "build.sh" ]; then
    echo "❌ build.sh non trouvé !"
    exit 1
fi

# Exécuter le build
echo "📦 Lancement du build..."
./build.sh

# Vérifier que l'AppImage a été créée
if [ -f "Transfert_TCP-v1.0.0-x86_64.AppImage" ]; then
    echo ""
    echo "✅ Build terminé ! Lancement de l'application..."
    echo ""
    ./Transfert_TCP-v1.0.0-x86_64.AppImage
else
    echo ""
    echo "❌ AppImage non trouvée !"
    echo "   Vérifiez que le build s'est bien passé."
    exit 1
fi
