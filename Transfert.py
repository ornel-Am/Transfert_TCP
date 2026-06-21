#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Transfert de fichiers TCP - Interface graphique Tkinter
Version 1.0.0 - Thème noir intégral
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import socket
import os
import threading
import time
from pathlib import Path

# ============================================================================
# CONSTANTES
# ============================================================================
BUFFER_SIZE = 8192          # 8 Ko par paquet
DEFAULT_PORT = 5000
DEFAULT_IP = "127.0.0.1"

# ============================================================================
# THÈME NOIR - Couleurs
# ============================================================================
COLORS = {
    "bg": "#0a0a0a",           # Fond principal - Noir profond
    "bg_sec": "#141414",       # Fond secondaire - Noir légèrement plus clair
    "bg_third": "#1a1a1a",     # Fond tertiaire
    "bg_frame": "#0a0a0a",     # Fond des frames
    "fg": "#e8e8e8",           # Texte principal - Blanc
    "fg_sec": "#888888",       # Texte secondaire - Gris
    "accent": "#666666",       # Accent - Gris
    "accent_hover": "#888888", # Accent hover - Gris plus clair
    "success": "#4caf50",      # Vert succès
    "error": "#f44336",        # Rouge erreur
    "warning": "#ff9800",      # Orange warning
    "border": "#2a2a2a",       # Bordures - Gris foncé
    "log_bg": "#050505",       # Fond des logs - Noir profond
    "log_fg": "#c0c0c0",       # Texte des logs - Gris clair
}

# ============================================================================
# CLASSE SERVEUR
# ============================================================================

class ServeurTCP:
    """Serveur TCP pour recevoir et envoyer des fichiers"""
    
    def __init__(self, log_callback):
        self.log = log_callback
        self.socket_ecoute = None
        self.en_cours = False
        self.dossier_reception = "recus"
        self.port = DEFAULT_PORT

    def demarrer(self, port, dossier):
        if self.en_cours:
            self.log("⚠️ Serveur déjà en cours.")
            return
        
        self.port = port
        self.dossier_reception = dossier
        
        try:
            Path(self.dossier_reception).mkdir(exist_ok=True)
        except Exception as e:
            self.log(f"❌ Erreur création dossier: {e}")
            return

        try:
            self.socket_ecoute = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket_ecoute.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.socket_ecoute.bind(('0.0.0.0', self.port))
            self.socket_ecoute.listen(5)
        except Exception as e:
            self.log(f"❌ Erreur bind: {e}")
            return

        self.en_cours = True
        self.log(f"✅ Serveur démarré sur le port {self.port}")
        self.log(f"📁 Dossier: {os.path.abspath(self.dossier_reception)}")
        
        thread_accept = threading.Thread(target=self._accepter_connexions, daemon=True)
        thread_accept.start()

    def _accepter_connexions(self):
        while self.en_cours:
            try:
                client_socket, addr = self.socket_ecoute.accept()
                self.log(f"📡 Client connecté: {addr[0]}:{addr[1]}")
                thread_client = threading.Thread(
                    target=self._gerer_client, 
                    args=(client_socket, addr), 
                    daemon=True
                )
                thread_client.start()
            except Exception as e:
                if self.en_cours:
                    self.log(f"Erreur accept: {e}")

    def _gerer_client(self, client_socket, addr):
        try:
            while True:
                commande_bytes = client_socket.recv(4)
                if not commande_bytes:
                    break
                commande = commande_bytes.decode('utf-8')
                
                if commande == 'SEND':
                    self._recevoir_fichier(client_socket, addr)
                elif commande == 'RECV':
                    self._envoyer_fichier(client_socket, addr)
                elif commande == 'QUIT':
                    break
                else:
                    client_socket.send(b'ERROR')
        except Exception as e:
            self.log(f"Erreur client {addr}: {e}")
        finally:
            client_socket.close()
            self.log(f"👋 Client déconnecté: {addr[0]}:{addr[1]}")

    def _recevoir_fichier(self, client_socket, addr):
        try:
            nom_len_bytes = client_socket.recv(4)
            if not nom_len_bytes:
                return
            nom_len = int.from_bytes(nom_len_bytes, 'big')
            
            nom_fichier = client_socket.recv(nom_len).decode('utf-8')
            
            taille_bytes = client_socket.recv(8)
            if not taille_bytes:
                return
            taille_fichier = int.from_bytes(taille_bytes, 'big')
            
            chemin = os.path.join(self.dossier_reception, nom_fichier)
            with open(chemin, 'wb') as f:
                recu = 0
                while recu < taille_fichier:
                    a_lire = min(BUFFER_SIZE, taille_fichier - recu)
                    donnees = client_socket.recv(a_lire)
                    if not donnees:
                        break
                    f.write(donnees)
                    recu += len(donnees)
            
            client_socket.send(b'OK')
            self.log(f"✅ Fichier reçu: {nom_fichier} ({taille_fichier} octets)")
            
        except Exception as e:
            self.log(f"❌ Erreur réception: {e}")
            client_socket.send(b'ERROR')

    def _envoyer_fichier(self, client_socket, addr):
        try:
            nom_len_bytes = client_socket.recv(4)
            if not nom_len_bytes:
                return
            nom_len = int.from_bytes(nom_len_bytes, 'big')
            
            nom_fichier = client_socket.recv(nom_len).decode('utf-8')
            
            chemin = os.path.join(self.dossier_reception, nom_fichier)
            if not os.path.isfile(chemin):
                client_socket.send(b'ERROR')
                self.log(f"❌ Fichier non trouvé: {nom_fichier}")
                return
            
            taille_fichier = os.path.getsize(chemin)
            client_socket.send(taille_fichier.to_bytes(8, 'big'))
            
            with open(chemin, 'rb') as f:
                while True:
                    donnees = f.read(BUFFER_SIZE)
                    if not donnees:
                        break
                    client_socket.send(donnees)
            
            reponse = client_socket.recv(2)
            if reponse == b'OK':
                self.log(f"✅ Fichier envoyé: {nom_fichier}")
            else:
                self.log(f"⚠️ Pas d'accusé pour {nom_fichier}")
                
        except Exception as e:
            self.log(f"❌ Erreur envoi: {e}")

    def arreter(self):
        self.en_cours = False
        if self.socket_ecoute:
            try:
                self.socket_ecoute.close()
            except:
                pass
        self.log("🛑 Serveur arrêté.")

# ============================================================================
# CLASSE CLIENT
# ============================================================================

class ClientTCP:
    """Client TCP pour envoyer et recevoir des fichiers"""
    
    def __init__(self, log_callback):
        self.log = log_callback
        self.socket = None
        self.connecte = False

    def connecter(self, ip, port):
        if self.connecte:
            self.log("⚠️ Déjà connecté.")
            return

        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((ip, port))
            self.connecte = True
            self.log(f"✅ Connecté à {ip}:{port}")
        except Exception as e:
            self.log(f"❌ Connexion échouée: {e}")
            self.socket = None

    def deconnecter(self):
        if self.connecte:
            try:
                self.socket.send(b'QUIT')
            except:
                pass
            try:
                self.socket.close()
            except:
                pass
            self.socket = None
            self.connecte = False
            self.log("✅ Déconnecté.")

    def envoyer_fichier(self, chemin_fichier):
        if not self.connecte:
            self.log("⚠️ Pas connecté.")
            return

        if not os.path.isfile(chemin_fichier):
            self.log(f"❌ Fichier introuvable: {chemin_fichier}")
            return

        nom_fichier = os.path.basename(chemin_fichier)
        taille_fichier = os.path.getsize(chemin_fichier)

        try:
            self.socket.send(b'SEND')
            self.socket.send(len(nom_fichier).to_bytes(4, 'big'))
            self.socket.send(nom_fichier.encode('utf-8'))
            self.socket.send(taille_fichier.to_bytes(8, 'big'))
            
            with open(chemin_fichier, 'rb') as f:
                while True:
                    donnees = f.read(BUFFER_SIZE)
                    if not donnees:
                        break
                    self.socket.send(donnees)
            
            reponse = self.socket.recv(2)
            if reponse == b'OK':
                self.log(f"✅ Fichier envoyé: {nom_fichier} ({taille_fichier} octets)")
            else:
                self.log(f"❌ Erreur d'envoi: réponse {reponse}")
                
        except Exception as e:
            self.log(f"❌ Erreur: {e}")
            self.deconnecter()

    def recevoir_fichier(self, nom_fichier):
        if not self.connecte:
            self.log("⚠️ Pas connecté.")
            return

        try:
            self.socket.send(b'RECV')
            self.socket.send(len(nom_fichier).to_bytes(4, 'big'))
            self.socket.send(nom_fichier.encode('utf-8'))
            
            reponse = self.socket.recv(8)
            if reponse == b'ERROR':
                self.log("❌ Fichier non trouvé sur le serveur.")
                return
            
            taille_fichier = int.from_bytes(reponse, 'big')
            
            dossier_client = "recus_client"
            Path(dossier_client).mkdir(exist_ok=True)
            chemin = os.path.join(dossier_client, nom_fichier)
            
            with open(chemin, 'wb') as f:
                recu = 0
                while recu < taille_fichier:
                    a_lire = min(BUFFER_SIZE, taille_fichier - recu)
                    donnees = self.socket.recv(a_lire)
                    if not donnees:
                        break
                    f.write(donnees)
                    recu += len(donnees)
            
            self.socket.send(b'OK')
            self.log(f"✅ Fichier reçu: {nom_fichier} ({taille_fichier} octets)")
            
        except Exception as e:
            self.log(f"❌ Erreur: {e}")
            self.deconnecter()

# ============================================================================
# INTERFACE GRAPHIQUE - THÈME NOIR
# ============================================================================

class TransfertApp:
    """Application principale avec interface Tkinter - Thème noir"""
    
    def __init__(self, root):
        self.root = root
        
        # Configuration de la fenêtre
        self.root.title("Transfert de fichiers TCP")
        self.root.geometry("750x650")
        self.root.resizable(True, True)
        
        # Configuration du thème noir (ttk)
        self._configurer_theme()
        
        # Variables
        self.mode_var = tk.StringVar(value="client")
        self.ip_var = tk.StringVar(value=DEFAULT_IP)
        self.port_var = tk.StringVar(value=str(DEFAULT_PORT))
        self.dossier_var = tk.StringVar(value="recus")
        self.fichier_envoyer_var = tk.StringVar()
        self.fichier_recevoir_var = tk.StringVar()
        
        # Composants réseau
        self.serveur = None
        self.client = None
        
        # Construire l'interface
        self._creer_widgets()
        self.log("✅ Application démarrée")

    def _configurer_theme(self):
        """Configure le thème noir pour ttk"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configuration des couleurs - Noir intégral
        style.configure('TFrame', background=COLORS['bg'])
        style.configure('TLabel', background=COLORS['bg'], foreground=COLORS['fg'])
        style.configure('TLabelframe', background=COLORS['bg_sec'], foreground=COLORS['fg'])
        style.configure('TLabelframe.Label', background=COLORS['bg_sec'], foreground=COLORS['fg'])
        style.configure('TButton', background=COLORS['bg_third'], foreground=COLORS['fg'], 
                       borderwidth=1, focusthickness=3, focuscolor=COLORS['accent'])
        style.map('TButton', 
                  background=[('active', COLORS['accent_hover']), ('pressed', COLORS['accent'])])
        style.configure('TEntry', fieldbackground=COLORS['bg_sec'], foreground=COLORS['fg'],
                       insertcolor=COLORS['fg'], borderwidth=1)
        style.configure('TRadiobutton', background=COLORS['bg'], foreground=COLORS['fg'])
        style.map('TRadiobutton', 
                  background=[('active', COLORS['bg'])])
        
        # Couleur de fond de la fenêtre principale
        self.root.configure(bg=COLORS['bg'])

    def _creer_widgets(self):
        """Construit tous les widgets avec le thème noir"""
        # Frame principal avec padding
        main_frame = ttk.Frame(self.root, padding="15")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # --- Mode (Serveur / Client) ---
        mode_frame = ttk.LabelFrame(main_frame, text="Mode", padding="10")
        mode_frame.pack(fill=tk.X, pady=5)
        
        ttk.Radiobutton(mode_frame, text="🖥️ Client", 
                       variable=self.mode_var, value="client",
                       command=self._changer_mode).pack(side=tk.LEFT, padx=15)
        ttk.Radiobutton(mode_frame, text="📡 Serveur", 
                       variable=self.mode_var, value="serveur",
                       command=self._changer_mode).pack(side=tk.LEFT, padx=15)
        
        # --- Configuration ---
        config_frame = ttk.LabelFrame(main_frame, text="Configuration", padding="10")
        config_frame.pack(fill=tk.X, pady=5)
        
        # IP
        ttk.Label(config_frame, text="IP:").grid(row=0, column=0, sticky=tk.W, padx=5, pady=2)
        self.entry_ip = ttk.Entry(config_frame, textvariable=self.ip_var, width=20)
        self.entry_ip.grid(row=0, column=1, padx=5, pady=2)
        
        # Port
        ttk.Label(config_frame, text="Port:").grid(row=0, column=2, sticky=tk.W, padx=5, pady=2)
        self.entry_port = ttk.Entry(config_frame, textvariable=self.port_var, width=10)
        self.entry_port.grid(row=0, column=3, padx=5, pady=2)
        
        # Dossier
        ttk.Label(config_frame, text="Dossier:").grid(row=1, column=0, sticky=tk.W, padx=5, pady=2)
        self.entry_dossier = ttk.Entry(config_frame, textvariable=self.dossier_var, width=30)
        self.entry_dossier.grid(row=1, column=1, columnspan=3, padx=5, pady=2, sticky=tk.W)
        
        # --- Actions ---
        action_frame = ttk.LabelFrame(main_frame, text="Actions", padding="10")
        action_frame.pack(fill=tk.X, pady=5)
        
        self.btn_connect = ttk.Button(action_frame, text="Connecter / Démarrer", 
                                     command=self._action_connect)
        self.btn_connect.pack(side=tk.LEFT, padx=5)
        
        self.btn_stop = ttk.Button(action_frame, text="Arrêter / Déconnecter",
                                  command=self._action_stop, state=tk.DISABLED)
        self.btn_stop.pack(side=tk.LEFT, padx=5)
        
        # --- Envoi ---
        send_frame = ttk.LabelFrame(main_frame, text="📤 Envoyer un fichier", padding="10")
        send_frame.pack(fill=tk.X, pady=5)
        
        self.entry_envoyer = ttk.Entry(send_frame, textvariable=self.fichier_envoyer_var, width=50)
        self.entry_envoyer.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        
        self.btn_parcourir = ttk.Button(send_frame, text="Parcourir...", 
                                       command=self._choisir_fichier_envoyer)
        self.btn_parcourir.pack(side=tk.LEFT, padx=5)
        
        self.btn_envoyer = ttk.Button(send_frame, text="Envoyer", 
                                     command=self._action_envoyer, state=tk.DISABLED)
        self.btn_envoyer.pack(side=tk.LEFT, padx=5)
        
        # --- Réception ---
        recv_frame = ttk.LabelFrame(main_frame, text="📥 Recevoir un fichier", padding="10")
        recv_frame.pack(fill=tk.X, pady=5)
        
        self.entry_recevoir = ttk.Entry(recv_frame, textvariable=self.fichier_recevoir_var, width=40)
        self.entry_recevoir.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        
        self.btn_recevoir = ttk.Button(recv_frame, text="Recevoir", 
                                      command=self._action_recevoir, state=tk.DISABLED)
        self.btn_recevoir.pack(side=tk.LEFT, padx=5)
        
        # --- Logs ---
        log_frame = ttk.LabelFrame(main_frame, text="📋 Logs", padding="10")
        log_frame.pack(fill=tk.BOTH, expand=True, pady=5)
        
        # Zone de logs avec fond noir
        self.log_text = scrolledtext.ScrolledText(
            log_frame, 
            height=15, 
            font=("Courier", 9),
            bg=COLORS['log_bg'],
            fg=COLORS['log_fg'],
            insertbackground=COLORS['fg'],
            borderwidth=0,
            highlightthickness=0,
            relief=tk.FLAT
        )
        self.log_text.pack(fill=tk.BOTH, expand=True)
        
        # Configurer les tags pour les couleurs dans les logs
        self.log_text.tag_configure("success", foreground=COLORS['success'])
        self.log_text.tag_configure("error", foreground=COLORS['error'])
        self.log_text.tag_configure("warning", foreground=COLORS['warning'])
        self.log_text.tag_configure("info", foreground=COLORS['fg_sec'])
    
    def _changer_mode(self):
        """Change le mode Client/Serveur"""
        mode = self.mode_var.get()
        if mode == "client":
            self.btn_connect.config(text="Connecter")
            self.ip_var.set(DEFAULT_IP)
            self.dossier_var.set("recus_client")
            self.entry_ip.config(state=tk.NORMAL)
        else:
            self.btn_connect.config(text="Démarrer")
            self.ip_var.set("0.0.0.0")
            self.dossier_var.set("recus")
            self.entry_ip.config(state=tk.DISABLED)
    
    def log(self, message, tag=None):
        """Ajoute un message dans les logs avec couleur"""
        import datetime
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        full_msg = f"[{timestamp}] {message}\n"
        
        if tag:
            self.log_text.insert(tk.END, full_msg, tag)
        else:
            self.log_text.insert(tk.END, full_msg)
        self.log_text.see(tk.END)
    
    def log_success(self, message):
        self.log(f"✅ {message}", "success")
    
    def log_error(self, message):
        self.log(f"❌ {message}", "error")
    
    def log_warning(self, message):
        self.log(f"⚠️ {message}", "warning")
    
    def log_info(self, message):
        self.log(f"ℹ️ {message}", "info")
    
    # ========================================================================
    # ACTIONS
    # ========================================================================
    
    def _action_connect(self):
        """Connecte en mode client ou démarre en mode serveur"""
        mode = self.mode_var.get()
        port = int(self.port_var.get())
        dossier = self.dossier_var.get()
        
        if mode == "client":
            ip = self.ip_var.get()
            self.client = ClientTCP(self.log)
            self.client.connecter(ip, port)
            if self.client.connecte:
                self._set_connected(True)
        else:
            self.serveur = ServeurTCP(self.log)
            self.serveur.demarrer(port, dossier)
            if self.serveur.en_cours:
                self._set_connected(True, server=True)
    
    def _action_stop(self):
        """Déconnecte le client ou arrête le serveur"""
        mode = self.mode_var.get()
        if mode == "client" and self.client:
            self.client.deconnecter()
        elif mode == "serveur" and self.serveur:
            self.serveur.arreter()
        self._set_connected(False)
    
    def _set_connected(self, connected, server=False):
        """Active/désactive les boutons selon l'état de connexion"""
        if connected:
            self.btn_connect.config(state=tk.DISABLED)
            self.btn_stop.config(state=tk.NORMAL)
            self.btn_envoyer.config(state=tk.NORMAL)
            self.btn_recevoir.config(state=tk.NORMAL)
            if server:
                self.btn_parcourir.config(state=tk.DISABLED)
                self.entry_envoyer.config(state=tk.DISABLED)
            else:
                self.btn_parcourir.config(state=tk.NORMAL)
                self.entry_envoyer.config(state=tk.NORMAL)
        else:
            self.btn_connect.config(state=tk.NORMAL)
            self.btn_stop.config(state=tk.DISABLED)
            self.btn_envoyer.config(state=tk.DISABLED)
            self.btn_recevoir.config(state=tk.DISABLED)
            self.btn_parcourir.config(state=tk.NORMAL)
            self.entry_envoyer.config(state=tk.NORMAL)
    
    def _choisir_fichier_envoyer(self):
        """Ouvre une boîte de dialogue pour choisir un fichier"""
        fichier = filedialog.askopenfilename(
            title="Choisir un fichier à envoyer",
            filetypes=[("Tous les fichiers", "*.*")]
        )
        if fichier:
            self.fichier_envoyer_var.set(fichier)
    
    def _action_envoyer(self):
        """Envoie le fichier sélectionné"""
        if not self.client or not self.client.connecte:
            self.log_warning("Client non connecté.")
            return
        fichier = self.fichier_envoyer_var.get()
        if fichier:
            self.client.envoyer_fichier(fichier)
        else:
            self.log_warning("Sélectionnez un fichier.")
    
    def _action_recevoir(self):
        """Demande un fichier au serveur"""
        if not self.client or not self.client.connecte:
            self.log_warning("Client non connecté.")
            return
        nom = self.fichier_recevoir_var.get()
        if nom:
            self.client.recevoir_fichier(nom)
        else:
            self.log_warning("Entrez un nom de fichier.")

# ============================================================================
# MAIN
# ============================================================================

def main():
    """Point d'entrée de l'application"""
    root = tk.Tk()
    
    # Opacité de 95% (légère transparence)
    try:
        root.attributes('-alpha', 0.95)
    except:
        pass
    
    app = TransfertApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
