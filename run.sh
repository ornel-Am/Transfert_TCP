#!/bin/bash
# ============================================================
# run.sh - Lancement automatique de TransfertTCP
# Usage : ./run.sh  (ou double-clic)
# ============================================================

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Détection du dossier du script
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
	# 2. Vérification / Installation de Python portable
	# ============================================================
	if [ ! -f "portable_python/bin/python3" ]; then
		echo -e "${YELLOW}📦 Python portable non trouvé. Installation...${NC}"
		
		# Vérifier que le fichier compressé existe
		if [ ! -f "deps/linux/python-portable.tar.gz" ]; then
			echo -e "${RED}❌ Fichier python-portable.tar.gz manquant dans deps/linux/${NC}"
			exit 1
			fi
			
			# Décompresser Python
			mkdir -p portable_python
			tar -xzf "deps/linux/python-portable.tar.gz" \
			-C "portable_python" \
			--strip-components=1
			
			# Vérifier que l'installation a réussi
			if [ ! -f "portable_python/bin/python3" ]; then
				echo -e "${RED}❌ Échec de l'installation de Python portable.${NC}"
				exit 1
				fi
				echo -e "${GREEN}✅ Python portable installé.${NC}"
				else
					echo -e "${GREEN}✅ Python portable déjà présent.${NC}"
					fi
					
					# ============================================================
					# 3. Installation de PyInstaller (si les wheels sont présentes)
					# ============================================================
					if [ -d "deps/wheels" ] && [ "$(ls -A deps/wheels)" ]; then
						echo -e "${YELLOW}📦 Installation de PyInstaller depuis les wheels locales...${NC}"
						portable_python/bin/python3 -m pip install \
						--no-index \
						--find-links=deps/wheels \
						pyinstaller \
						--quiet 2>/dev/null || {
							echo -e "${YELLOW}⚠️ Échec de l'installation des wheels. Tentative avec pip en ligne...${NC}"
							portable_python/bin/python3 -m pip install pyinstaller --quiet
						}
						echo -e "${GREEN}✅ PyInstaller prêt.${NC}"
						fi
						
						# ============================================================
						# 4. Compilation de l'application (si nécessaire)
						# ============================================================
						if [ ! -f "dist/transfert_gui" ]; then
							echo -e "${YELLOW}🔧 Compilation de l'application...${NC}"
							portable_python/bin/python3 -m PyInstaller \
							--onefile \
							--name transfert_gui \
							src/transfert_gui.py \
							--distpath ./dist \
							--workpath ./build \
							--specpath ./tmp
							
							# Nettoyer les fichiers temporaires de compilation
							rm -rf build/ tmp/ transfert_gui.spec 2>/dev/null || true
							
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
									
									# Rendre l'exécutable... exécutable
									chmod +x dist/transfert_gui
									
									# Lancer l'application
									./dist/transfert_gui
									
									# ============================================================
									# 6. Fin
									# ============================================================
									echo -e "${BLUE}========================================${NC}"
									echo -e "${GREEN}✅ Application fermée.${NC}"
