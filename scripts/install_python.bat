@echo off
REM scripts/install_python.bat - Installe Python portable (Windows)

set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..

echo 📦 Installation de Python portable...

REM Décompresser Python embed
mkdir "%PROJECT_DIR%\portable_python" 2>nul
powershell -command "Expand-Archive -Path '%PROJECT_DIR%\deps\windows\python-embed.zip' -DestinationPath '%PROJECT_DIR%\portable_python' -Force"

REM Installer PyInstaller depuis les wheels
"%PROJECT_DIR%\portable_python\python.exe" -m pip install --no-index --find-links="%PROJECT_DIR%\deps\wheels" pyinstaller

echo ✅ Python portable installé.
pause
