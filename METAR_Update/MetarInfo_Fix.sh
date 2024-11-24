#!/bin/bash
#
# Script de Mise à Jour de la requête de l'annonce METAR pour l'application F4BPP HotSpot Remote
#


file='/etc/spotnik/svxlink.d/ModuleMetarInfo.conf' aeroport=`grep "STARTDEFAULT=" $file | sed s/STARTDEFAULT=//`

echo "Ecriture du fichier ModuleMetarInfo.conf pour l'aéroport $aeroport"

cat << EOF > $file
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

echo "Redémarrage du HotSpot"
/etc/spotnik/restart
sleep 2

echo
echo "Mise à jour terminée"
echo
