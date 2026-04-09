# Projet DuoScribo - Documentation de Développement

## 📝 Concept
DuoScribo est une application iOS native (SwiftUI) de gamification de l'écriture quotidienne. Inspirée par DuoLingo, elle encourage la régularité via un système de séries (streaks), de points et de défis sociaux.

## 🛠 Stack Technique
- **Langage** : Swift 5.9 / SwiftUI
- **Gestion de projet** : XcodeGen (`project.yml`)
- **Persistance** : SwiftData (iOS 17+)
- **Synchronisation** : CloudKit (Conteneur : `iCloud.ch.yannickmauray.DuoScribo`)
- **Déploiement** : `devicectl` sur iPhone 16 et iPad (7th Gen)
- **Identifiants** : Team ID `WFMP87LTRX` / Prefix `ch.yannickmauray`

## 💎 Fonctionnalités Implémentées

### 1. Éditeur de Texte "Zen"
- **Sauvegarde automatique** du brouillon via `@AppStorage`.
- **Compteur de mots animé** avec barre de progression (Cap à 250 mots).
- **Feedback haptique** tous les 10 mots et lors de la publication.
- **Police Georgia** pour un confort de lecture optimal.

### 2. Système de Points (Scribo-XP)
- **Base** : 0.1 pt par mot, arrondi au multiple de 5 inférieur.
- **Limites** : Minimum 10 pts, Maximum 25 pts par texte.
- **Multiplicateur de Carrière** : `XP Totale = Points de Base * (1.0 + Série / 100)`.
- **Validation** : Logique couverte par des tests unitaires (`DuoScriboTests.swift`).

### 3. Gamification Visuelle
- **La Flamme** : Grise si inactif, Orange animée si le texte du jour est publié.
- **Chiffre de Série** : Bleu nuit pour un contraste maximal sur l'orange.
- **Notifications** : Rappel local à 22h00 si aucune saisie n'a été faite.

### 4. Gestion des Données
- **Historique** : Affichage sous forme de liste avec "Swipe to Delete".
- **Suppression sécurisée** : Uniquement autorisée pour les textes du jour (retire les points et éteint la flamme).
- **Backdoor Debug** : **7 taps rapides** sur la flamme pour réinitialiser toutes les données.

## 🚀 Commandes Utiles

### Régénérer le projet
```bash
xcodegen generate
```

### Déploiement iPhone
```bash
xcodebuild build -project DuoScribo.xcodeproj -scheme DuoScribo -destination 'id=AE196C15-8591-55A9-A87B-A7C49FDD02C0' -derivedDataPath ./build-output-iphone && xcrun devicectl device install app --device AE196C15-8591-55A9-A87B-A7C49FDD02C0 build-output-iphone/Build/Products/Debug-iphoneos/DuoScribo.app && xcrun devicectl device process launch --device AE196C15-8591-55A9-A87B-A7C49FDD02C0 ch.yannickmauray.DuoScribo
```

### Déploiement iPad
```bash
xcodebuild build -project DuoScribo.xcodeproj -scheme DuoScribo -destination 'id=D4418FD6-A284-5C4A-8B68-E26A58B5D467' -derivedDataPath ./build-output-ipad && xcrun devicectl device install app --device D4418FD6-A284-5C4A-8B68-E26A58B5D467 build-output-ipad/Build/Products/Debug-iphoneos/DuoScribo.app && xcrun devicectl device process launch --device D4418FD6-A284-5C4A-8B68-E26A58B5D467 ch.yannickmauray.DuoScribo
```

## 📅 Prochaines Étapes
1. **Défis Sociaux** : Implémenter le partage de défis via CloudKit Public Database.
2. **Synchronisation** : Monitorer la stabilité de SwiftData/CloudKit entre iPhone et iPad.
3. **Poli de l'Historique** : Ajouter des graphiques de progression hebdomadaire.
