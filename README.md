# DuoScribo ✍️🔥

[![iOS CI](https://github.com/ymauray/DuoScribo/actions/workflows/ios.yml/badge.svg)](https://github.com/ymauray/DuoScribo/actions/workflows/ios.yml) [![Licence : MIT](https://img.shields.io/github/license/ymauray/DuoScribo)](LICENSE) [![repocheck](https://img.shields.io/badge/repocheck%201.3.0-100%2F100-brightgreen)](https://github.com/ymauray/repocheck)

**Transformez votre discipline d'écriture en un rituel addictif !**

DuoScribo est une application iOS native qui utilise la puissance de la **gamification** pour vous encourager à écrire un peu chaque jour. Inspirée par les meilleures mécaniques de DuoLingo, elle fait de chaque mot une étape vers votre succès.

---

## ✨ Fonctionnalités qui font pétiller la plume

### 🔥 Entretenez la Flamme !
Votre série (streak) est au cœur de l'expérience. Écrivez chaque jour pour allumer votre flamme orange vibrante. Mais attention... ne sautez pas un jour, ou la flamme redeviendra grise !

### 💎 Gagnez de la Scribo-XP
Plus vous écrivez, plus vous cumulez de points !
*   **10 pts** : Juste pour avoir ouvert l'app et écrit.
*   **15, 20 ou 25 pts** : Des paliers de motivation à 150, 200 et 250 mots.
*   **🚀 Multiplicateur** : Gagnez **+1% de bonus** par jour de série consécutif !

### 🧘 Éditeur Zen & Moderne
Un espace pur, sans distraction, conçu pour le flow :
*   ☁️ **Synchronisation iCloud** : Vos textes sont partout (iPhone & iPad).
*   📳 **Feedback Haptique** : Ressentez votre progression tous les 10 mots.
*   🖋️ **Police Georgia** : Pour un confort de lecture digne des plus grands romans.
*   📊 **Historique Intelligent** : Vos récits groupés par jour avec cumul automatique.

### 🔔 Le Coach Personnel
DuoScribo veille sur vous. Si vous n'avez pas encore écrit à **21h**, un petit rappel vous invite à sauver votre flamme avant la fin de la journée.

---

## 🛠 Sous le capot (Stack Technique)

DuoScribo est un pur produit de l'écosystème Apple moderne :
*   **Langage** : Swift 5.9+
*   **Interface** : SwiftUI
*   **Données** : SwiftData & CloudKit
*   **Architecture** : MVVM (Model-View-ViewModel)
*   **Projet** : Géré par XcodeGen 🛠

---

## 🚀 Installation pour les développeurs

1. Clonez le dépôt.
2. Installez `xcodegen` si vous ne l'avez pas déjà : `brew install xcodegen`.
3. Lancez la génération du projet :
   ```bash
   xcodegen generate
   ```
4. Ouvrez `DuoScribo.xcodeproj` et lancez l'aventure sur votre iPhone !

---

## 🔄 Intégration continue et release

### GitHub Actions — la qualité

Les workflows GitHub **ne font pas la release**. Le workflow [`iOS CI`](.github/workflows/ios.yml)
régénère le projet avec XcodeGen, compile l'app et exécute les tests (`DuoScriboTests`) sur
simulateur, à chaque push et pull request sur `main`.

La page [`docs/`](docs/) est publiée par GitHub Pages (workflow intégré
« pages-build-deployment », donc absent du dépôt) → https://ymauray.github.io/DuoScribo/

### Xcode Cloud — la livraison

La **livraison sur TestFlight et l'App Store est assurée par Xcode Cloud** (workflow « Default »,
configuré côté App Store Connect, pas dans le dépôt) : il archive l'app à chaque commit sur
`main`. La version marketing (`MARKETING_VERSION`) se maintient dans `project.yml`.

---

**Fait avec ❤️ pour les amoureux des mots.** 
*Propulsez votre écriture vers de nouveaux sommets !* 🚀🖋️
