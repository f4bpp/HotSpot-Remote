# F4BPP HotSpot Remote Android Application

## 1. Presentation de l'application :
![HotSpot Remote Preview](https://github.com/f4bpp/HotSpot-Remote/blob/main/Preview/Preview_V3.0.png)

Hotspot Remote est une application pour Smartphone sous Android qui permet de piloter les HotSpots prévus pour fonctionner sur les réseaux numériques radioamateurs suivants:

 - Réseau des Répéteurs Francophones.
 - Réseau interconnecté multiprotocoles du 49.

L'application permet d'effectuer les actions suivantes :

 - Changer de réflecteur.
 - Activer le mode "Perroquet".
 - Lancer la lecture du bulletin météo METAR via une synthèse vocale.
 - Redémarrer le HotSpot.
 - Éteindre le HotSpot.
 - Contrôler la température du HotSpot.
 - Afficher un mémento de toutes les tonalités DTMF qui permettent de contrôler le HotSpot sans l'application.
 - Ecouter les réflecteurs via Internet.


## 2. Installation de l'application :

 1. Connectez-vous au HotSpot via ssh sous Linux (ssh root@adresse_IP_du_HotSpot) ou via Putty sous Windows puis entrer la commande suivante :
 >      curl -fsSL https://raw.githubusercontent.com/f4bpp/HotSpot-Remote/main/Install/Install_HotSpotRemote.sh | bash

 2. Télécharger le fichier APK sur votre smartphone en scannant le QR Code ci dessous avec votre smartphone et lancez l'installation.

![HotSpot Remote QR Code](https://github.com/f4bpp/HotSpot-Remote/blob/main/Install/QRCode_Setup_APK_V3.png)

Les utilisateurs de la version 2.0 peuvent passer directement à l'étape 2 car seule la partie Android a été mise à jour dans la version 3. Cependant, le nouveau script d'installation de la version 3.0 installe la dernière version du fichier "HotSpotRemote.js" puis il contrôle et corrige le cas échéant, deux fichiers sur le HotSpot afin de pouvoir effectuer la lecture du bulletin METAR avec une annonce correcte de l'heure du bulletin. De plus, si l'accès au RI49 France Multiprotocoles n'est pas activé, le script propose à l'utilisateur d'installer ce réflecteur afin de profiter pleinement de toutes les fonctionnalités de l'application.

## 3. Réglages :

Lors de la première utilisation, vous devez accéder aux paramètres de l’application (Bouton avec un engrenage) pour effectuer les réglages nécessaires à l’utilisation de l’application.

La première étape consiste à choisir la version du Spotnik qui correspond à votre HotSpot. Ce réglage permet à l’application de récupérer l’adresse IP du HotSpot qui sera ensuite utilisée pour envoyer les requêtes http qui permettent de contrôler et monitorer le HotSpot. Si la version sélectionnée ne correspond pas à votre Spotnik, l’application sera incapable de se connecter à votre HotSpot.

Dans les paramètres, vous pouvez forcer l’écran à rester allumé tant que l’application est en cours d’utilisation et en premier plan.

Vous pouvez également afficher la console permet de visualiser les réponses données par le HotSpot aux requêtes de l’application. Ce paramètre est désactivé par défaut car la console n’est utile qu’au développeur pour contrôler la bonne exécution des requêtes mais elle peut être aussi intéressante pour les utilisateurs curieux.

## 4. Note du développeur :

Cette application utilise une version modifiée du code Open Source développé par Armel (F4HWN) en Java Script pour l'application RRF Remote pour plateformes M5 Stack que je remercie chaleureusement pour l'ensemble de son oeuvre pour la communauté radioamateur ainsi que son soutien.

## 5. Remerciements :

Je tiens à remercier chaleureusement les personnes suivantes pour leur soutien, leurs encouragements, leurs suggestions et leur contribution pour le développement de cette application :

- Rémy (F4JAJ)
- Guillaume (F4IPA)
- Maxime (F4HWD)
- Yannick (F4JFO)
- Hervé (F4ELD)
- Eric (F4IGG)
- François (F4ICM)
- Yannick (F5NKP)

73, David (F4BPP).
