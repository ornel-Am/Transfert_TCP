@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ========================================
echo    🚀 TransfertTCP - Lancement auto
echo ========================================

:: Détection du dossier du script
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: ============================================================
:: 1. Vérification du code source
:: ============================================================
if not exist "src\transfert_gui.py" (
	echo ❌ Code source manquant : src\transfert_gui.py
	pause
	exit /b 1
)
	echo ✅ Code source trouvé.
	
	:: ============================================================
	:: 2. Vérification / Installation de Python portable
	:: ============================================================
	if not exist "portable_python\python.exe" (
		echo 📦 Python portable non trouvé. Installation...
		
		if not exist "deps\windows\python-embed.zip" (
			echo ❌ Fichier python-embed.zip manquant dans deps\windows\
			pause
			exit /b 1
		)
			
			mkdir portable_python 2>nul
			powershell -command "Expand-Archive -Path 'deps\windows\python-embed.zip' -DestinationPath 'portable_python' -Force"
			
			if not exist "portable_python\python.exe" (
				echo ❌ Échec de l'installation de Python portable.
				pause
				exit /b 1
			)
				echo ✅ Python portable installé.
	) else (
		echo ✅ Python portable déjà présent.
	)
	
	:: ============================================================
	:: 3. Installation de PyInstaller (si les wheels sont présentes)
	:: ============================================================
	if exist "deps\wheels" (
		echo 📦 Installation de PyInstaller depuis les wheels locales...
		portable_python\python.exe -m pip install --no-index --find-links=deps\wheels pyinstaller --quiet 2>nul
		if errorlevel 1 (
			echo ⚠️ Échec de l'installation des wheels. Tentative avec pip en ligne...
			portable_python\python.exe -m pip install pyinstaller --quiet
		)
			echo ✅ PyInstaller prêt.
	)
		
		:: ============================================================
		:: 4. Compilation de l'application (si nécessaire)
		:: ============================================================
		if not exist "dist\transfert_gui.exe" (
			echo 🔧 Compilation de l'application...
			portable_python\python.exe -m PyInstaller --onefile --name transfert_gui src\transfert_gui.py
			
			if not exist "dist\transfert_gui.exe" (
				echo ❌ Échec de la compilation.
				echo 💡 Lancement direct du script Python...
				portable_python\python.exe src\transfert_gui.py
				pause
				exit /b 0
			)
				echo ✅ Compilation réussie !
		) else (
			echo ✅ Exécutable déjà présent.
		)
		
		:: ============================================================
		:: 5. Lancement de l'application
		:: ============================================================
		echo ========================================
		echo 🚀 Lancement de TransfertTCP...
		echo ========================================
		dist\transfert_gui.exe
		
		:: ============================================================
		:: 6. Fin
		:: ============================================================
		echo ========================================
		echo ✅ Application fermée.
		pause
