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
HOTSPOT_REMOTE_LINE="nohup node /root/HotSpotRemote.js &"

echo "Vérification de $RC_LOCAL_FILE..."
if ! grep -Fq "$HOTSPOT_REMOTE_LINE" "$RC_LOCAL_FILE"; then
    echo "Ajout de la ligne de démarrage à $RC_LOCAL_FILE..."
    sed -i "/^exit 0/i # Lancement du HotSpot Remote\n$HOTSPOT_REMOTE_LINE" "$RC_LOCAL_FILE"
else
    echo "La ligne de démarrage est déjà présente."
fi

# -----------------------------
# 3. Vérification et installation du RI49 France Multiprotocoles
# -----------------------------
RI49_FILE="/etc/spotnik/restart.ri49"
if [ -f "$RI49_FILE" ]; then
    echo "Le réflecteur RI49 France Multiprotocoles est déjà installé."
else
    echo "Le réflecteur RI49 n'est pas installé."
    echo "Installation du réflecteur RI49 France Multiprotocoles..."
    curl -fs http://49.f4ipa.fr/extra/ri49.sh | bash
    if [ $? -eq 0 ]; then
        echo "Réflecteur RI49 France Multiprotocoles installé avec succès."
    else
        echo "Échec de l'installation du réflecteur RI49 France Multiprotocoles."
    fi
fi

# -----------------------------
# 4. Vérification et mise à jour du fichier ModuleMetarInfo.conf
# -----------------------------

# Fichier de configuration
METAR_INFO_FILE="/etc/spotnik/svxlink.d/ModuleMetarInfo.conf"

# Lien attendu pour la ligne LINK=
EXPECTED_LINK="/cgi-bin/data/dataserver.php?requestType=retrieve&dataSource=metars&hoursBeforeNow=3&format=xml&mostRecent=true&stationString="

# Lignes supplémentaires attendues
EXPECTED_STARTDEFAULT="STARTDEFAULT=LFRO"
EXPECTED_AIRPORTS="AIRPORTS=LFRO"

echo "Vérification des modifications nécessaires dans $METAR_INFO_FILE..."

# Vérifier si le fichier existe
if [ -f "$METAR_INFO_FILE" ]; then
    # Comparer la ligne LINK= et la remplacer si elle est incorrecte
    CURRENT_LINK=$(grep "^LINK=" "$METAR_INFO_FILE")
    if [ "$CURRENT_LINK" != "LINK=\"$EXPECTED_LINK\"" ]; then
        echo "La ligne LINK= est incorrecte, remplacement..."
        sed -i "s|^LINK=.*|LINK=\"$EXPECTED_LINK\"|" "$METAR_INFO_FILE"
    else
        echo "La ligne LINK= est déjà correcte."
    fi

    # Vérifier et corriger STARTDEFAULT
    if ! grep -q "^$EXPECTED_STARTDEFAULT" "$METAR_INFO_FILE"; then
        echo "Mise à jour de STARTDEFAULT..."
        sed -i "s|^STARTDEFAULT=.*|$EXPECTED_STARTDEFAULT|" "$METAR_INFO_FILE"
    else
        echo "STARTDEFAULT est déjà correct."
    fi

    # Vérifier et corriger AIRPORTS
    if ! grep -q "^$EXPECTED_AIRPORTS" "$METAR_INFO_FILE"; then
        echo "Mise à jour de AIRPORTS..."
        sed -i "s|^AIRPORTS=.*|$EXPECTED_AIRPORTS|" "$METAR_INFO_FILE"
    else
        echo "AIRPORTS est déjà correct."
    fi
else
    echo "Fichier $METAR_INFO_FILE introuvable."
    exit 1
fi

echo "Vérification et mise à jour du fichier ModuleMetarInfo.conf terminée."

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
# 6. Redémarrage du Raspberry Pi
# -----------------------------
echo "Installation terminée. Le Raspberry Pi va redémarrer dans 10 secondes..."
sleep 10
sudo reboot
