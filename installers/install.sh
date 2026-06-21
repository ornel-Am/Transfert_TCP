#!/bin/bash
echo "📦 Installation de TransfertTCP"
mkdir -p ~/.local/bin
cp dist/transfert_gui ~/.local/bin/
chmod +x ~/.local/bin/transfert_gui
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
echo "✅ Installation terminée ! Lancez : transfert_gui"
