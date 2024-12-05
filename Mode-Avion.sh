#!/bin/bash

# Vérifier les permissions root
if [ "$EUID" -ne 0 ]; then
    echo "Veuillez exécuter ce script avec sudo."
    exit 1
fi

# 1. Mettre à jour le système et installer Zenity
echo "Mise à jour du système et installation des dépendances..."
sudo apt update && sudo apt install -y zenity

# 2. Créer le script `mode_avion.sh`
echo "Création du script mode_avion.sh..."
SCRIPT_PATH="/usr/local/bin/mode_avion.sh"
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash
# Script Mode Avion par Wharkly47 (GitHub: nearoofly)

# Fonction pour basculer le mode avion
toggle_mode_avion() {
    STATUS=$(rfkill list | grep -i "soft blocked: no" | wc -l)

    if [ "$STATUS" -gt 0 ]; then
        # Activer le mode avion
        nmcli radio wifi off
        rfkill block bluetooth
        zenity --info --text="✈️ Mode avion activé"
    else
        # Désactiver le mode avion
        nmcli radio wifi on
        rfkill unblock bluetooth
        zenity --info --text="📶 Mode avion désactivé"
    fi
}

# Affichage de l'interface
zenity --question --title="Mode Avion" --text="Voulez-vous activer ou désactiver le mode avion ?" --ok-label="Basculer" --cancel-label="Annuler"

if [ $? -eq 0 ]; then
    toggle_mode_avion
else
    zenity --info --text="Action annulée."
fi
EOF

# Rendre le script exécutable
chmod +x "$SCRIPT_PATH"

# 3. Ajouter une icône personnalisée
echo "Ajout d'une icône personnalisée..."
ICON_PATH="/usr/share/icons/mode_avion.png"
cat << 'EOF' > "$ICON_PATH"
<contenu_base64_image>
EOF
chmod 644 "$ICON_PATH"

# 4. Créer un raccourci sur le bureau
echo "Création du raccourci sur le bureau..."
DESKTOP_FILE="$HOME/Bureau/mode_avion.desktop"
cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Name=Mode Avion
Comment=Activer/Désactiver le mode avion
Exec=$SCRIPT_PATH
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$DESKTOP_FILE"

# 5. Ajouter le script au démarrage
echo "Ajout du script au démarrage..."
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cp "$DESKTOP_FILE" "$AUTOSTART_DIR"

# 6. Fin
echo "Installation terminée ! Le raccourci est sur le bureau et prêt à être utilisé."
echo "Pour désinstaller, utilisez la commande suivante :"
echo "sudo ./install_mode_avion.sh --uninstall"

# 7. Gestion de la désinstallation
if [ "$1" == "--uninstall" ]; then
    echo "Désinstallation en cours..."
    # Supprimer le script
    rm -f "$SCRIPT_PATH"
    # Supprimer l'icône
    rm -f "$ICON_PATH"
    # Supprimer le raccourci du bureau
    rm -f "$DESKTOP_FILE"
    # Supprimer le raccourci du démarrage automatique
    rm -f "$AUTOSTART_DIR/mode_avion.desktop"
    echo "Désinstallation terminée. Merci d'avoir utilisé ce script !"
    exit 0
fi
