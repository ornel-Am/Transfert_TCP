# -*- mode: python ; coding: utf-8 -*-
"""
Fichier de configuration PyInstaller pour Transfert TCP
Version 1.0.0
"""

import sys
import os
from PyInstaller.utils.hooks import collect_data_files, collect_submodules

block_cipher = None

# Analyse du code source
a = Analysis(
    ['transfert.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[
        'tkinter',
        'tkinter.ttk',
        'tkinter.filedialog',
        'tkinter.messagebox',
        'tkinter.scrolledtext',
        'socket',
        'threading',
        'pathlib',
        'datetime',
        'os',
        'time'
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

# Création du bundle PYZ (fichiers Python compilés)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

# Création de l'exécutable UNIQUE (--onefile)
exe = EXE(
    pyz,                      # Fichiers Python compilés
    a.scripts,                # Scripts principaux
    a.binaries,               # Bibliothèques binaires
    a.zipfiles,               # Fichiers zip
    a.datas,                  # Données
    [],
    name='transfert-app',     # Nom de l'exécutable
    debug=False,              # Pas de mode debug
    bootloader_ignore_signals=False,
    strip=False,              # Ne pas stripper (pour compatibilité)
    upx=True,                 # Compression UPX (si disponible)
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,            # Pas de fenêtre console (GUI)
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,                # Mettez 'icon.ico' pour Windows
)

# NOTE: On utilise EXE seul pour créer un fichier unique
# PAS de COLLECT car on veut un seul fichier
