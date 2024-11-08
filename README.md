# F4BPP HotSpot Remote Android Application

## 1. Presentation de l'application
![HotSpot Remote Preview](https://github.com/f4bpp/HotSpot-Remote/blob/main/Images/HotSpot_Remote_Preview.png)

Hotspot Remote est une application pour Smartphone sous Android qui permet de piloter les HotSpots de type "Spotnik" de F5NLG prévus pour fonctionner sur les réseaux numériques radioamateurs suivants:

 - Réseau des Répéteurs Francophones
 - Réseau interconnecté multiprotocoles du 49.

L'application permet d'effectuer les actions suivantes :

 - Changer de réflecteur.
 - Activer le mode "Perroquet".
 - Redémarrer le HotSpot.
 - Éteindre le HotSpot.
 - Contrôler la température du HotSpot.
 - Afficher un mémento de toutes les tonalités DTMF qui permettent de contrôler le HotSpot sans l'application.


## 2. Installation de l'application

 1. Copier le fichier **HotSPotRemote.js** dans le répertoire "root" du
    HotSpot. Pour se faire, connectez-vous au HotSpot via ssh sous Linux (ssh root@adresse_IP_du_HotSpot) ou via Putty sous Windows puis entrer la commande suivante :
 >      wget -O /root/HotSpotRemote.js https://github.com/f4bpp/HotSpot-Remote/releases/download/v1.0/HotSpotRemote.js
 3. Éditer le fichier **rc.local** et ajouter les lignes suivantes :

>     #Lancement du HotSpot Remote au démarrage
>     nohup node /root/HotSpotRemote.js

 3. Sauvegarder le fichier.
 4. Redémarrer le HotSpot.
 5. Télécharger le fichier APK sur votre smartphone via ce lien : [HotSpot_Remote_APK](https://github.com/f4bpp/HotSpot-Remote/releases/tag/v1.0) ou bien en scannant le QR Code ci dessous avec votre smartphone et lancez l'installation.

![APK_QR-CODE](https://github.com/f4bpp/Icom_IC-PCR100_Remote_Software/blob/main/Images/HotSpot_Remote_APK_QR-Code.png)

## 3. Réglages

Lors de la première utilisation, vous devez accéder aux paramètres de l’application (Bouton avec un engrenage) pour effectuer les réglages nécessaires à l’utilisation de l’application.

La première étape consiste à choisir la version du Spotnik qui correspond à votre HotSpot. Ce réglage permet à l’application de récupérer l’adresse IP du HotSpot qui sera ensuite utilisée pour envoyer les requêtes http qui permettent de contrôler et monitorer le HotSpot. Si la version sélectionnée ne correspond pas à votre Spotnik, l’application sera incapable de se connecter à votre HotSpot.

Dans les paramètres, vous pouvez forcer l’écran à rester allumé tant que l’application est en cours d’utilisation et en premier plan.

Vous pouvez également afficher la console permet de visualiser les réponses données par le HotSpot aux requêtes de l’application. Ce paramètre est désactivé par défaut car la console n’est utile qu’au développeur pour contrôler la bonne exécution des requêtes mais elle peut être aussi intéressante pour les utilisateurs curieux.

## 4. Note du développeur

Cette application utilise une version modifiée du code Open Source développé par Armel (F4HWN) en Java Script pour l'application RRF Remote pour plateformes M5 Stack que je remercie chaleureusement pour l'ensemble de son oeuvre pour la communauté radioamateur ainsi que son soutien.

73, David (F4BPP).
