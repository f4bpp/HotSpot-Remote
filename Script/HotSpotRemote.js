// Copyright (c) F4HWN Armel. All rights reserved.
// Forked RRFRemote.js by F4BPP for HotSpot Remote Application on Android
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

const http = require('http');
const port = 3000;
const version = 0.5;

const requestHandler = (request, response) => {
   console.log(request.url);
   const { exec } = require('child_process');
   const input = new URL('https://localhost/' + request.url);
   const cmd = parseInt(input.searchParams.get('cmd'));

   var room = {
     "default": "95,PERROQUET",
     "rrf": "96,RRF",
     "fon": "97,FON",
     "tec": "98,TECHNIQUE",
     "bav": "100,BAVARDAGE",
     "loc": "101,LOCAL",
     "ri49": "49,RI49",
   };

   var qsy = {
     95: "/etc/spotnik/restart.default",
     96: "/etc/spotnik/restart.rrf",
     97: "/etc/spotnik/restart.fon",
     98: "/etc/spotnik/restart.tec",
     100: "/etc/spotnik/restart.bav",
     101: "/etc/spotnik/restart.loc",
     49: "/etc/spotnik/restart.ri49",
   };

   // Commande 1003 : Lecture météo METAR
   if (cmd === 1003) {
     console.log("Command 1003 received: Playing METAR weather.");
     exec('echo "*51#" > /tmp/dtmf_uhf', (error, stdout, stderr) => {
       if (error || stderr) {
         console.log("Error playing METAR weather:", error || stderr);
         response.writeHead(500);
         response.end('Échec lecture météo METAR');
       } else {
         response.writeHead(200);
         response.end('Lecture météo METAR effectuée');
       }
     });

   // Commande 1002 : Récupérer uniquement l'adresse IP
   } else if (cmd === 1002) {
     console.log("Command 1002 received: Sending IP address.");
     exec('hostname -I', (error, stdout, stderr) => {
       if (error || stderr) {
         console.log("Error getting IP address:", error || stderr);
         response.writeHead(500);
         response.end('Échec identification adresse IP');
       } else {
         const ipList = stdout.trim().split(' ');  // Séparer les adresses IP
         const ipv4 = ipList.find(ip => ip.includes('.')); // Trouver l'adresse IPv4
         console.log("IPv4 address:", ipv4); // Log de l'adresse IPv4
         response.writeHead(200, { 'Content-Type': 'text/plain' });
         response.end(ipv4); // Envoi de l'adresse IPv4
       }
     });

 // Commande 1004 : Récupérer la valeur de AIRPORT dans un fichier
} else if (cmd === 1004) {
  console.log("Command 1004 received: Fetching AIRPORTS value.");
  const fs = require('fs'); // Module pour lire les fichiers

  const filePath = '/etc/spotnik/svxlink.d/ModuleMetarInfo.conf'; // Chemin réel du fichier

  fs.readFile(filePath, 'utf8', (error, data) => {
    if (error) {
      console.log("Error reading file:", error);
      response.writeHead(500);
      response.end('Erreur de lecture du fichier');
    } else {
      const match = data.match(/AIRPORTS=([^\s]+)/); // Regex pour extraire la valeur
      if (match && match[1]) {
        const airport = match[1]; // Un seul code d'aéroport
        if (airport.length === 4 && /^[A-Z]+$/.test(airport)) {
          console.log("AIRPORTS value:", airport);
          response.writeHead(200, { 'Content-Type': 'text/plain' });
          response.end(airport); // Renvoie la valeur si elle est valide
        } else {
          console.log("Invalid airport code.");
          response.writeHead(400, { 'Content-Type': 'text/plain' });
          response.end('Identifiant aéroport incorrect');
        }
      } else {
        console.log("AIRPORTS value not found in file.");
        response.writeHead(404);
        response.end('Valeur AIRPORTS introuvable');
      }
    }
  });

   // Commande 1000 : Redémarrage
   } else if (cmd == 1000) {
     exec('reboot', (error, stdout, stderr) => {
       if (error || stderr) {
         response.writeHead(500);
       } else {
         response.writeHead(200);
         response.end('Redémarrage effectué');
       }
     });

   // Commande 1001 : Arrêt
   } else if (cmd == 1001) {
     exec('poweroff', (error, stdout, stderr) => {
       if (error || stderr) {
         response.writeHead(500);
       } else {
         response.writeHead(200);
         response.end('Arrêt effectué');
       }
     });

   // Gestion des QSY
   } else if (cmd > 0 && cmd < 1000) {
     var action = "";
     if (cmd in qsy) {
       action = qsy[cmd];
     } else {
       action = 'echo "' + cmd + '#" > /tmp/dtmf_uhf';
     }
     exec(action);
     response.writeHead(200);
     response.end('QSY effectué');

   // Lecture des informations système
   } else {
     var temp = "";

     exec('cat /sys/class/thermal/thermal_zone0/temp', (error, stdout, stderr) => {
       if (error || stderr) {
         temp = "0";
       } else {
         temp = stdout.trim();
       }
     });

     exec('cat /etc/spotnik/network', (error, stdout, stderr) => {
       if (error || stderr) {
         response.writeHead(500);
       } else {
         response.writeHead(200);
         if (stdout.trim() in room) {
           response.end(room[stdout.trim()] + "," + temp);
         } else {
           response.end("0,UNDEFINED" + "," + temp);
         }
       }
     });
   }
};

const server = http.createServer(requestHandler);

server.listen(port, (error) => {
   if (error) {
     return console.log('ERROR', error);
   }
   console.log(`server is listening on ${port}`);
});
