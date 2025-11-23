#!/bin/bash

# setup_xcode_project.sh
# Script pour créer automatiquement le projet Xcode FlashcardFactory

set -e

echo "🚀 Configuration du projet Xcode FlashcardFactory..."

# Vérifier si Xcode est installé
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Erreur: Xcode n'est pas installé"
    echo "📝 Ce script doit être exécuté sur macOS avec Xcode installé"
    echo "💡 Alternative: Utilisez GitHub Actions pour compiler sans macOS local"
    exit 1
fi

# Définir le nom du projet
PROJECT_NAME="FlashcardFactory"
BUNDLE_ID="com.student.flashcardfactory"

echo "📦 Nom du projet: $PROJECT_NAME"
echo "🆔 Bundle ID: $BUNDLE_ID"

# Créer le projet Xcode via swift package init (ne fonctionne que sur macOS)
cd "$PROJECT_NAME"

# Alternative: Utiliser xcodegen (si installé)
if command -v xcodegen &> /dev/null; then
    echo "✅ xcodegen détecté, génération du projet..."
    
    # Créer project.yml pour xcodegen
    cat > project.yml <<EOF
name: FlashcardFactory
options:
  bundleIdPrefix: com.student
targets:
  FlashcardFactory:
    type: application
    platform: iOS
    deploymentTarget: "15.0"
    sources:
      - FlashcardFactory
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: $BUNDLE_ID
        INFOPLIST_FILE: FlashcardFactory/Info.plist
        DEVELOPMENT_TEAM: ""
    dependencies:
      - framework: CoreData.framework
        sdk: iOS
      - sdk: UIKit.framework
      - sdk: SwiftUI.framework
EOF
    
    xcodegen generate
    echo "✅ Projet Xcode généré avec xcodegen"
else
    echo "⚠️  xcodegen n'est pas installé"
    echo ""
    echo "📝 Instructions manuelles:"
    echo "1. Ouvrez Xcode"
    echo "2. File > New > Project"
    echo "3. Choisissez 'iOS' > 'App'"
    echo "4. Interface: SwiftUI"
    echo "5. Language: Swift"
    echo "6. Product Name: FlashcardFactory"
    echo "7. Bundle Identifier: $BUNDLE_ID"
    echo "8. Core Data: ✅ COCHÉ"
    echo "9. Utilisez l'organisation: Student"
    echo ""
    echo "Puis:"
    echo "1. Supprimez les fichiers auto-générés (ContentView.swift, etc.)"
    echo "2. Ajoutez tous les fichiers du dossier FlashcardFactory/"
    echo "3. Ajoutez le modèle Core Data (*.xcdatamodeld)"
    echo ""
    echo "🔧 Pour installer xcodegen:"
    echo "   brew install xcodegen"
    echo ""
    exit 0
fi

# Installer les pods
echo "📦 Installation des dépendances CocoaPods..."
if command -v pod &> /dev/null; then
    pod install
    echo "✅ Pods installés"
    echo ""
    echo "⚠️  RAPPEL: Utilisez FlashcardFactory.xcworkspace, PAS .xcodeproj"
else
    echo "⚠️  CocoaPods n'est pas installé"
    echo "🔧 Installez-le avec:"
    echo "   sudo gem install cocoapods"
fi

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Ajoutez GoogleService-Info.plist dans FlashcardFactory/"
echo "2. Ouvrez FlashcardFactory.xcworkspace (après pod install)"
echo "3. Compilez et testez!"
echo ""
echo "🎉 Bonne chance!"
