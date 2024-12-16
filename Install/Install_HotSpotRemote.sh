#!/bin/bash

# Chemins des fichiers
RI49_FILE="/etc/spotnik/restart.ri49"
RC_LOCAL_FILE="/etc/rc.local"
HOTSPOT_REMOTE_FILE="/root/HotSpotRemote.js"
HOTSPOT_REMOTE_URL="https://raw.githubusercontent.com/f4bpp/HotSpot-Remote/main/Script/HotSpotRemote.js"
METAR_INFO_FILE="/etc/spotnik/svxlink.d/ModuleMetarInfo.conf"
METAR_TCL_FILE="/usr/share/svxlink/events.d/local/MetarInfo.tcl"
METAR_TCL_URL="https://raw.githubusercontent.com/f4bpp/HotSpot-Remote/main/METAR_Update/MetarInfo.tcl"

# Lignes à ajouter à rc.local
HOTSPOT_REMOTE_LINES=(
"# Lancement du HotSpot Remote au démarrage"
"nohup node /root/HotSpotRemote.js &"
)

# Vérifie la présence du fichier restart.ri49
if [ -f "$RI49_FILE" ]; then
    echo "Votre HotSpot est déjà paramétré pour accéder au réflecteur RI49 France Multiprotocoles."
else
    echo "Votre HotSpot n’est pas paramétré pour accéder au réflecteur RI49 France Multiprotocoles."
    echo "Souhaitez-vous activer l’accès à ce réflecteur ? (o/n)"
    read -r choix

    if [ "$choix" = "o" ]; then
        echo "Installation du réflecteur RI49 France Multiprotocoles..."
        curl -fs http://49.f4ipa.fr/extra/ri49.sh | bash
        if [ $? -eq 0 ]; then
            echo "Le réflecteur RI49 France Multiprotocoles a été installé avec succès."
        else
            echo "Une erreur est survenue lors de l'installation."
        fi
    else
        echo "Installation annulée par l'utilisateur."
    fi
fi

# Téléchargement et écrasement de HotSpotRemote.js
echo "Téléchargement de la dernière version de HotSpotRemote.js..."
curl -fsSL "$HOTSPOT_REMOTE_URL" -o "$HOTSPOT_REMOTE_FILE"
if [ $? -eq 0 ]; then
    echo "Le fichier HotSpotRemote.js a été téléchargé et enregistré dans /root."
else
    echo "Une erreur est survenue lors du téléchargement de HotSpotRemote.js."
fi

# Vérifie et ajoute les lignes dans rc.local
echo "Vérification des lignes de configuration dans $RC_LOCAL_FILE..."
for line in "${HOTSPOT_REMOTE_LINES[@]}"; do
    if ! grep -Fxq "$line" "$RC_LOCAL_FILE"; then
        echo "Ajout de la ligne : $line"
        echo "$line" >> "$RC_LOCAL_FILE"
    fi
done
echo "Mise à jour du fichier /etc/rc.local pour exécuter le script au démarrage."

# Mise à jour du fichier ModuleMetarInfo.conf
if [ -f "$METAR_INFO_FILE" ]; then
    aeroport=$(grep "STARTDEFAULT=" "$METAR_INFO_FILE" | sed 's/STARTDEFAULT=//')
else
    echo "Fichier $METAR_INFO_FILE introuvable. Création avec un aéroport par défaut."
    aeroport="LFPG"  # Aéroport par défaut si le fichier n'existe pas
fi

echo "Ecriture du fichier ModuleMetarInfo.conf pour l'aéroport $aeroport"

cat << EOF > "$METAR_INFO_FILE"
[ModuleMetarInfo]
NAME=MetarInfo
ID=5
TIMEOUT=120
TYPE=XML
SERVER=https://aviationweather.gov
LINK="/cgi-bin/data/dataserver.php?requestType=retrieve&dataSource=metars&hoursBeforeNow=3&format=xml&mostRecent=true&stationString="
STARTDEFAULT=$aeroport
AIRPORTS=$aeroport
EOF

# Téléchargement et remplacement du fichier MetarInfo.tcl
echo "Téléchargement et mise à jour du fichier MetarInfo.tcl..."
curl -fsSL "$METAR_TCL_URL" -o "$METAR_TCL_FILE"
if [ $? -eq 0 ]; then
    echo "Le fichier MetarInfo.tcl a été téléchargé et remplacé dans $METAR_TCL_FILE."
else
    echo "Une erreur est survenue lors du téléchargement de MetarInfo.tcl."
fi

# Redémarrage du HotSpot
echo "Redémarrage du HotSpot"
/etc/spotnik/restart
sleep 2

# Message final
echo
echo "Installation de F4BPP HotSpot Remote terminée."
