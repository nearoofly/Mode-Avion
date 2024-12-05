#!/bin/bash

# Vérification des permissions root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté avec les privilèges root (sudo)."
    exit 1
fi

# Variables
APP_NAME="Mode-Avion"
INSTALL_DIR="/opt/Mode-Avion"
SCRIPT_PATH="$INSTALL_DIR/mode_avion.sh"
ICON_PATH="/usr/share/icons/mode_avion_icon.png"
DESKTOP_FILE="/usr/share/applications/mode_avion.desktop"
AUTOSTART_DIR="$HOME/.config/autostart"

# Création du répertoire d'installation
echo "Création du répertoire : $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Génération du script principal
echo "Création du script principal..."
cat <<'EOF' > "$SCRIPT_PATH"
#!/bin/bash

toggle_airplane_mode() {
    if nmcli radio all | grep -q "enabled"; then
        nmcli radio all off
        zenity --info --title="Mode-Avion" --text="Mode avion activé ✈️"
    else
        nmcli radio all on
        zenity --info --title="Mode-Avion" --text="Mode avion désactivé 🌐"
    fi
}

while true; do
    option=$(zenity --list --title="Mode-Avion" \
        --text="Choisissez une action :" \
        --radiolist \
        --column=" " --column="Action" \
        TRUE "Activer/Désactiver le Mode Avion" \
        FALSE "Quitter")

    case $option in
        "Activer/Désactiver le Mode Avion") toggle_airplane_mode ;;
        "Quitter") exit ;;
    esac
done
EOF

# Rendre le script exécutable
chmod +x "$SCRIPT_PATH"

# Génération automatique de l'icône
echo "Génération de l'icône..."
convert -size 256x256 xc:white -fill black -gravity center \
    -pointsize 100 -annotate 0 "✈️" "$ICON_PATH"

# Création du fichier .desktop pour le menu des applications
echo "Création du fichier .desktop..."
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$APP_NAME
Comment=Activer ou désactiver le mode avion
Exec=$SCRIPT_PATH
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;Network;
StartupNotify=true
EOF

# Ajout au démarrage
echo "Ajout au démarrage..."
mkdir -p "$AUTOSTART_DIR"
cp "$DESKTOP_FILE" "$AUTOSTART_DIR/"

# Création du raccourci sur le bureau
echo "Création du raccourci sur le bureau..."
cp "$DESKTOP_FILE" "$HOME/Bureau/"
chmod +x "$HOME/Bureau/$(basename "$DESKTOP_FILE")"

# Installation des dépendances nécessaires
echo "Installation des dépendances..."
apt update
apt install -y zenity imagemagick

# Fin de l'installation
echo "Installation terminée ! Vous pouvez lancer $APP_NAME depuis :"
echo "1. Le menu des applications."
echo "2. Le raccourci sur le bureau."
echo "3. La barre des tâches."
