
# Projet Flutter - Gestion des Idées

Ce projet est une application Flutter qui permet de récupérer et afficher une liste d'idées provenant d'une base de données Strapi. L'utilisateur peut visualiser les idées sous forme de liste dynamique, chaque idée affichant un titre et une description.

## Objectif du Projet

L'objectif de ce projet est de créer une application mobile permettant de consulter une liste d'idées depuis une base de données Strapi. Cette application pourrait être utilisée, par exemple, pour afficher des propositions d'améliorations, des suggestions d'innovation ou d'autres types d'idées générées par une équipe.

## Fonctionnalités Principales

- Récupérer les idées depuis une API Strapi.
- Récupérer les moods depuis une API Strapi
- Enregistrer son mood depuis l'application
- Visualiser l'état global pour les managers de l'équipe
- Afficher les idées sous forme de `ListView`.
- Gérer les états de chargement lors de la récupération des données.

## Installation du Projet

### Prérequis

Assurez-vous d'avoir les éléments suivants installés sur votre machine :
- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) ou [Visual Studio Code](https://code.visualstudio.com/) avec les extensions Flutter.

### Étapes d'installation

1. Clonez ce dépôt dans votre environnement local :
 

2. Naviguez dans le dossier du projet :
   ```bash
   cd projet-flutter-idees
   ```

3. Installez les dépendances Flutter :
   ```bash
   flutter pub get
   ```

4. Configurez votre URL Strapi dans le code. Mettez à jour l'URL de base de votre API Strapi :
   ```dart
   final String baseUrl = 'http://localhost://1337/'; // Remplacez par votre URL
   ```

5. Lancez l'application sur un simulateur ou un appareil physique :
   ```bash
   flutter run
   ```

## Librairies Utilisées

Ce projet utilise les librairies suivantes :

- **[http](https://pub.dev/packages/http)** : Utilisé pour effectuer les requêtes HTTP afin de récupérer les données de l'API Strapi.
  ```yaml
  dependencies:
    http: ^0.13.5
  ```



### Améliorations futures

- 
