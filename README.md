# Démo Devoxx

Le code utilisé pour cette démo : https://youtu.be/JQ7TmM0pego à Devoxx France 2017.

Il y a eu pas mal d'actions manuelles pour mettre en musique la démonstration, mais tous le code utilisé est là.

Le code est réparti de la façon suivante :
 - `ci` : le code d'infrastructure qui a permis de construire la plateforme
    - `terraform` : le code de création des VMs de la plateforme
    - `ansible` : le code de déploiement de la plateforme
    - `kubernetes` : le code de création des Runners
 - `klar` : code de construction de l'image klar utilisée pour les scans de vulnerabilités
 - `metrics-app` : application Go de démonstration
 - `spring-petclinic` : application Java de démonstration
 - `alpine` : code de l'image alpine
 - `nginx` : code de l'image nginx
 - `manifests` : le dépôt de manifestes
 - `promoter` : le code du pipeline de promotion
 - `metrics-app` : le dépôt contenant les informations de signature du promoter
