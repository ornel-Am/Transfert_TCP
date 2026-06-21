@echo off
chcp 65001 > nul
echo ========================================
echo    📦 TransfertTCP - Installation
echo ========================================
echo.

set "REPO_URL=https://raw.githubusercontent.com/ornel-Am/Transfert_TCP/main"
set "SCRIPT_URL=%REPO_URL%/src/transfert_gui.py"
set "SCRIPT_NAME=transfert_gui.py"

echo 📥 Téléchargement du script depuis GitHub...
curl -L -o "%SCRIPT_NAME%" "%SCRIPT_URL%"

if not exist "%SCRIPT_NAME%" (
    echo ❌ Échec du téléchargement.
    pause
    exit /b 1
)

echo 🔍 Vérification de Python...
python --version > nul 2>&1
if errorlevel 1 (
    echo ❌ Python non trouvé.
    echo 📦 Téléchargez Python depuis https://python.org
    pause
    exit /b 1
)

echo ✅ Script téléchargé.
echo 📌 Pour lancer : python "%SCRIPT_NAME%"
pause
