#!/bin/bash
# ============================================================
# run.sh - Lancement automatique de TransfertTCP
# Version corrigée avec téléchargement depuis la release
# ============================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   🚀 TransfertTCP - Lancement auto${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================
# 1. Vérification du code source
# ============================================================
if [ ! -f "src/transfert_gui.py" ]; then
	echo -e "${RED}❌ Code source manquant : src/transfert_gui.py${NC}"
	exit 1
	fi
	echo -e "${GREEN}✅ Code source trouvé.${NC}"
	
	# ============================================================
	# 2. Vérification / Téléchargement de Python portable
	# ============================================================
	if [ ! -f "portable_python/bin/python3" ]; then
		echo -e "${YELLOW}📦 Python portable non trouvé. Téléchargement...${NC}"
		
		# Créer le dossier de destination
		mkdir -p deps/linux portable_python
		
		# URL de la release (à adapter selon votre tag)
		RELEASE_URL="https://github.com/ornel-Am/Transfert_TCP/releases/download/v1.0.0/python-3.11.9.tgz"
		LOCAL_FILE="deps/linux/python-3.11.9.tgz"
		
		# Télécharger depuis la release
		echo -e "${YELLOW}📥 Téléchargement de Python depuis la release...${NC}"
		if command -v wget &> /dev/null; then
			wget -O "$LOCAL_FILE" "$RELEASE_URL"
			elif command -v curl &> /dev/null; then
			curl -L -o "$LOCAL_FILE" "$RELEASE_URL"
			else
				echo -e "${RED}❌ Ni wget ni curl trouvé.${NC}"
				exit 1
				fi
				
				# Vérifier l'intégrité
				if [ ! -f "$LOCAL_FILE" ] || [ ! -s "$LOCAL_FILE" ]; then
					echo -e "${RED}❌ Échec du téléchargement.${NC}"
					exit 1
					fi
					echo -e "${GREEN}✅ Téléchargement réussi.${NC}"
					
					# Décompresser Python
					echo -e "${YELLOW}📦 Décompression de Python...${NC}"
					tar -xzf "$LOCAL_FILE" -C portable_python --strip-components=1
					
					if [ ! -f "portable_python/bin/python3" ]; then
						echo -e "${RED}❌ Échec de la décompression.${NC}"
						exit 1
						fi
						echo -e "${GREEN}✅ Python portable installé.${NC}"
						else
							echo -e "${GREEN}✅ Python portable déjà présent.${NC}"
							fi
							
							# ============================================================
							# 3. Installation de PyInstaller
							# ============================================================
							echo -e "${YELLOW}📦 Installation de PyInstaller...${NC}"
							portable_python/bin/python3 -m pip install --upgrade pip --quiet
							portable_python/bin/python3 -m pip install pyinstaller --quiet
							
							# ============================================================
							# 4. Compilation de l'application
							# ============================================================
							if [ ! -f "dist/transfert_gui" ]; then
								echo -e "${YELLOW}🔧 Compilation de l'application...${NC}"
								portable_python/bin/python3 -m PyInstaller \
								--onefile \
								--name transfert_gui \
								src/transfert_gui.py
								
								# Nettoyer les fichiers temporaires
								rm -rf build/ transfert_gui.spec 2>/dev/null || true
								
								if [ ! -f "dist/transfert_gui" ]; then
									echo -e "${RED}❌ Échec de la compilation.${NC}"
									echo -e "${YELLOW}💡 Lancement direct du script Python...${NC}"
									portable_python/bin/python3 src/transfert_gui.py
									exit 0
									fi
									echo -e "${GREEN}✅ Compilation réussie !${NC}"
									else
										echo -e "${GREEN}✅ Exécutable déjà présent.${NC}"
										fi
										
										# ============================================================
										# 5. Lancement de l'application
										# ============================================================
										echo -e "${BLUE}========================================${NC}"
										echo -e "${GREEN}🚀 Lancement de TransfertTCP...${NC}"
										echo -e "${BLUE}========================================${NC}"
										
										chmod +x dist/transfert_gui
										./dist/transfert_gui
										
										echo -e "${BLUE}========================================${NC}"
										echo -e "${GREEN}✅ Application fermée.${NC}"
