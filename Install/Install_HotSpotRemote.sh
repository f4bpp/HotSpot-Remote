#!/bin/bash

# Script d'installation et de mise à jour de F4BPP HotSpot Remote

echo "Début de l'installation/mise à jour de F4BPP HotSpot Remote..."

# -----------------------------
# 1. Téléchargement du fichier HotSpotRemote.js
# -----------------------------
HOTSPOT_REMOTE_FILE="/root/HotSpotRemote.js"
HOTSPOT_REMOTE_URL="https://raw.githubusercontent.com/f4bpp/HotSpot-Remote/main/Script/HotSpotRemote.js"

echo "Téléchargement du fichier HotSpotRemote.js..."
curl -fsSL "$HOTSPOT_REMOTE_URL" -o "$HOTSPOT_REMOTE_FILE"
if [ $? -eq 0 ]; then
    echo "Fichier HotSpotRemote.js téléchargé et copié dans /root."
else
    echo "Échec du téléchargement de HotSpotRemote.js."
    exit 1
fi

# -----------------------------
# 2. Modification du fichier /etc/rc.local
# -----------------------------
RC_LOCAL_FILE="/etc/rc.local"
HOTSPOT_REMOTE_LINES=(
"# Lancement du HotSpot Remote au démarrage"
"nohup node /root/HotSpotRemote.js"
)

echo "Vérification et modification de $RC_LOCAL_FILE si nécessaire..."
for line in "${HOTSPOT_REMOTE_LINES[@]}"; do
    if ! grep -Fxq "$line" "$RC_LOCAL_FILE"; then
        echo "Ajout de la ligne : $line"
        sed -i "/^exit 0/i $line" "$RC_LOCAL_FILE"
    fi
done
echo "Mise à jour de $RC_LOCAL_FILE terminée."

# -----------------------------
# 3. Vérification et installation du RI49
# -----------------------------
RI49_FILE="/etc/spotnik/restart.ri49"
if [ -f "$RI49_FILE" ]; then
    echo "Le réflecteur RI49 est déjà installé."
else
    echo "Le réflecteur RI49 n'est pas installé."
    echo "Souhaitez-vous l'installer ? (o/n)"
    read -r choix
    if [ "$choix" = "o" ]; then
        echo "Installation du réflecteur RI49..."
        curl -fs http://49.f4ipa.fr/extra/ri49.sh | bash
        if [ $? -eq 0 ]; then
            echo "Réflecteur RI49 installé avec succès."
        else
            echo "Échec de l'installation du réflecteur RI49."
        fi
    else
        echo "Installation du réflecteur RI49 annulée."
    fi
fi

# -----------------------------
# 4. Vérification et mise à jour du fichier ModuleMetarInfo.conf
# -----------------------------
METAR_INFO_FILE="/etc/spotnik/svxlink.d/ModuleMetarInfo.conf"
OLD_LINK="/cgi-bin/data/dataserver.php?requestType=retrieve&dataSource=metars&hoursBeforeNow=3&format=xml&mostRecent=true&stationString="
NEW_LINK="/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&hoursBeforeNow=3&mostRecent=true&stationString="

echo "Vérification des modifications nécessaires dans $METAR_INFO_FILE..."
if [ -f "$METAR_INFO_FILE" ]; then
    if grep -q "$OLD_LINK" "$METAR_INFO_FILE"; then
        echo "Ancien lien détecté. Remplacement par le nouveau lien..."
        sed -i "s|$OLD_LINK|$NEW_LINK|" "$METAR_INFO_FILE"
        echo "Lien mis à jour dans $METAR_INFO_FILE."
    else
        echo "Le lien dans $METAR_INFO_FILE est déjà à jour."
    fi

    if grep -q "STARTDEFAULT=LFOH" "$METAR_INFO_FILE"; then
        echo "Modification de STARTDEFAULT et AIRPORTS pour LFRO..."
        sed -i "s|STARTDEFAULT=LFOH|STARTDEFAULT=LFRO|" "$METAR_INFO_FILE"
        sed -i "s|AIRPORTS=LFOH|AIRPORTS=LFRO|" "$METAR_INFO_FILE"
    else
        echo "Les paramètres STARTDEFAULT et AIRPORTS sont déjà à jour."
    fi
else
    echo "Fichier $METAR_INFO_FILE introuvable."
fi

# -----------------------------
# 5. Vérification et mise à jour du fichier MetarInfo.tcl
# -----------------------------
METAR_INFO_TCL_FILE="/usr/share/svxlink/events.d/local/MetarInfo.tcl"
MODIFICATION_START_LINE=128

echo "Vérification et modification de $METAR_INFO_TCL_FILE si nécessaire..."
if [ -f "$METAR_INFO_TCL_FILE" ]; then
    if ! grep -q "set heure \[string range \$item 0 1\]" "$METAR_INFO_TCL_FILE"; then
        echo "Modification requise pour la fonction metreport_time..."
        sed -i "${MODIFICATION_START_LINE},$((${MODIFICATION_START_LINE}+5))c\\
# MET-report TIME\\
proc metreport_time item {\\
   playMsg \"metreport_time\";\\
   set heure [string range \$item 0 1]\\
   set minute [string range \$item 2 3]\\
   playTime \"\$heure\" \"\$minute\";\\
   playSilence 200;\\
}" "$METAR_INFO_TCL_FILE"
        echo "Modifications apportées à $METAR_INFO_TCL_FILE."
    else
        echo "Les modifications dans $METAR_INFO_TCL_FILE sont déjà effectuées."
    fi
else
    echo "Fichier $METAR_INFO_TCL_FILE introuvable."
fi

# -----------------------------
# 6. Affichage du message final
# -----------------------------
echo "Installation de F4BPP HotSpot Remote terminée."
