# Projet DuoScribo - Documentation de Développement

## 📝 Concept
DuoScribo est une application iOS native (SwiftUI) de gamification de l'écriture quotidienne. Inspirée par DuoLingo, elle encourage la régularité via un système de séries (streaks), de points et de défis sociaux (actuellement masqués pour le focus Solo).

## 🛠 Stack Technique
- **Langage** : Swift 5.9 / SwiftUI
- **Gestion de projet** : XcodeGen (`project.yml`) avec `Sources/DuoScribo-Info.plist` manuel.
- **Persistance** : SwiftData (iOS 17+)
- **Synchronisation** : CloudKit (Conteneur : `iCloud.ch.yannickmauray.DuoScribo`) activé via `ModelConfiguration`.
- **Déploiement** : `devicectl` sur iPhone 16 et iPad (7th Gen)
- **Identifiants** : Team ID `WFMP87LTRX` / Prefix `ch.yannickmauray`
- **Localisation** : Configurée pour `fr` et `en` (système gère clavier/menus).

## 💎 Fonctionnalités Implémentées

### 1. Éditeur de Texte "Zen"
- **Sauvegarde automatique** du brouillon via `@AppStorage`.
- **Compteur de mots animé** avec barre de progression (Cap à 250 mots).
- **Coaching contextuel** : Objectifs affichés (150, 200, 250 mots) pour les paliers de points.
- **Feedback haptique** tous les 10 mots et lors de la publication.
- **Son de succès** : Petit "ding" (son système 1407) à la publication.

### 2. Système de Points (Scribo-XP)
- **Logique de Cumul** : Le score du jour est calculé sur le total des mots de tous les textes écrits.
- **Paliers de base** : 1-149 mots = 10 pts, 150-199 = 15 pts, 200-249 = 20 pts, 250+ = 25 pts.
- **Cap Quotidien** : Limité à **25 points bruts** par jour.
- **Multiplicateur de Carrière** : `XP Totale = Points de Base * (1.0 + Série / 100)`.
- **Certification** : Logique validée par `Tests/PointsLogicTests.swift`.

### 3. Interface et Gamification
- **Dashboard Unifié** : Flamme, stats et bouton d'action regroupés pour un alignement parfait.
- **La Flamme** : Grise si inactif, Orange animée si le texte du jour est publié.
- **Effets Visuels** : Effet "Burst" (jaillissement) et confettis lors de la première publication du jour.
- **Historique** : Groupé par jour avec **cumul des mots par date** visible dans les en-têtes.
- **Actions** : Swipe-to-Delete (textes du jour uniquement), Swipe-to-Copy (tous les textes), Tap-to-Edit (aujourd'hui).

### 4. Notifications et Sécurité
- **Rappel quotidien** : Notification locale à **21h00** si aucune saisie n'a été faite.
- **Synchronisation Push** : Support des notifications à distance (Background Modes) pour CloudKit.
- **Sécurité Deletion** : Le rappel est re-programmé si le dernier texte du jour est supprimé.
- **Backdoor Debug** : **7 taps rapides** sur la flamme pour réinitialiser toutes les données.

## 🚀 Commandes de Déploiement

### Régénérer le projet
```bash
xcodegen generate
```

### Build et Déploiement (Automatisé)
- **iPhone** : 
  `xcodebuild build -project DuoScribo.xcodeproj -scheme DuoScribo -destination 'id=AE196C15-8591-55A9-A87B-A7C49FDD02C0' -derivedDataPath ./build-output-iphone && xcrun devicectl device install app --device AE196C15-8591-55A9-A87B-A7C49FDD02C0 build-output-iphone/Build/Products/Debug-iphoneos/DuoScribo.app`
- **iPad** : 
  `xcodebuild build -project DuoScribo.xcodeproj -scheme DuoScribo -destination 'id=D4418FD6-A284-5C4A-8B68-E26A58B5D467' -derivedDataPath ./build-output-ipad && xcrun devicectl device install app --device D4418FD6-A284-5C4A-8B68-E26A58B5D467 build-output-ipad/Build/Products/Debug-iphoneos/DuoScribo.app`

## 📅 Prochaines Étapes
1. **TestFlight** : L'app est prête pour une première soumission (orientations et localisation OK).
2. **Défis Sociaux** : Réactiver `SocialView.swift` et implémenter le partage CloudKit.
3. **Widgets** : Utiliser l'App Group déjà configuré pour afficher la flamme sur le Springboard.
