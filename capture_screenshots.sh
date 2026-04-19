#!/bin/bash

# Configuration
BUNDLE_ID="ch.yannickmauray.DuoScribo"
#DEVICE_NAME="iPhone 17 Pro"
DEVICE_NAME="iPad Pro 13-inch"
SCREENSHOT_DIR="$(pwd)/screenshots" # Utilisation d'un chemin absolu

# Récupération de l'ID du device
DEVICE_ID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -v "unavailable" | head -1 | sed -E 's/.*\(([-0-9A-F]+)\).*/\1/')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Erreur : Impossible de trouver le simulateur '$DEVICE_NAME'"
    exit 1
fi

echo "🚀 Préparation du simulateur : $DEVICE_NAME ($DEVICE_ID)"
mkdir -p "$SCREENSHOT_DIR"

# 1. Démarrer le simulateur
xcrun simctl boot "$DEVICE_ID" 2>/dev/null
open -a Simulator

# 2. Régénérer le projet
echo "🛠 Régénération du projet..."
xcodegen generate

# 3. Compiler pour le simulateur
echo "🏗 Compilation de l'application..."
xcodebuild build \
    -project DuoScribo.xcodeproj \
    -scheme DuoScribo \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -derivedDataPath ./build-output-sim \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO > /dev/null

if [ $? -ne 0 ]; then
    echo "❌ Erreur : La compilation a échoué"
    exit 1
fi

# 4. Installer et Lancer
echo "📲 Installation et lancement..."
APP_PATH=$(find ./build-output-sim -name "DuoScribo.app" | head -1)
xcrun simctl install "$DEVICE_ID" "$APP_PATH"
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"

# 5. Attendre les animations
echo "⏳ Attente de 5 secondes pour les animations..."
sleep 5

# 6. Prendre la capture d'écran
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="$SCREENSHOT_DIR/screenshot_$TIMESTAMP.png"
echo "📸 Prise de la capture d'écran (chemin absolu) : $FILENAME"
xcrun simctl io "$DEVICE_ID" screenshot "$FILENAME"

if [ $? -eq 0 ]; then
    echo "✅ Terminé ! Votre capture est disponible dans : $FILENAME"
else
    echo "❌ Erreur lors de la prise de vue."
fi
