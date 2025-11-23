# 🏗️ GÉNÉRATION DU PROJET XCODE

## ⚠️ Important: Besoin d'un projet Xcode

Le projet nécessite un fichier `.xcodeproj` pour compiler. Voici 3 méthodes:

---

## Méthode 1: Utiliser GitHub Actions (RECOMMANDÉ sans Mac)

**Avantage**: Pas besoin de Mac local!

### Configuration Spéciale GitHub Actions

Modifiez `.github/workflows/ios.yml` pour ajouter une étape de création du projet:

```yaml
# Ajoutez cette étape AVANT "Install CocoaPods"
- name: Generate Xcode Project
  run: |
    brew install xcodegen
    cd FlashcardFactory
    xcodegen generate
```

Puis créez `project.yml` à la racine:

```yaml
name: FlashcardFactory
options:
  bundleIdPrefix: com.student
  deploymentTarget:
    iOS: "15.0"
targets:
  FlashcardFactory:
    type: application
    platform: iOS
    deploymentTarget: "15.0"
    sources:
      - FlashcardFactory
    settings:
      base:
        PRODUCT_NAME: FlashcardFactory
        PRODUCT_BUNDLE_IDENTIFIER: com.student.flashcardfactory
        INFOPLIST_FILE: FlashcardFactory/Info.plist
        SWIFT_VERSION: "5.0"
        TARGETED_DEVICE_FAMILY: "1,2"
        IPHONEOS_DEPLOYMENT_TARGET: "15.0"
        CODE_SIGN_IDENTITY: ""
        CODE_SIGNING_ALLOWED: NO
    preBuildScripts:
      - script: |
          if [ "${CONFIGURATION}" = "Debug" ]; then
            echo "Debug build"
          fi
        name: Pre-build Script
    scheme:
      testTargets: []
      gatherCoverageData: false
```

**Résultat**: GitHub Actions génèrera automatiquement le `.xcodeproj`!

---

## Méthode 2: Sur macOS avec Xcode (Manuel)

### A. Créer le Projet

1. **Ouvrez Xcode**
2. **File** → **New** → **Project**
3. Choisissez **iOS** → **App**
4. **Product Name**: `FlashcardFactory`
5. **Team**: Aucun (ou votre compte)
6. **Organization Identifier**: `student`
7. **Bundle Identifier**: `com.student.flashcardfactory`
8. **Interface**: **SwiftUI**
9. **Language**: **Swift**
10. **✅ Cochez "Use Core Data"**
11. **Storage**: ❌ Décochez (on a déjà notre modèle)
12. Cliquez **Next** et sauvegardez dans le dossier projet

### B. Nettoyer et Organiser

1. **Supprimez** les fichiers auto-générés:
   - `ContentView.swift`
   - `FlashcardFactoryApp.swift` (on a le nôtre)
   - Le modèle Core Data auto-généré

### C. Ajouter nos Fichiers

1. **Drag & drop** tout le contenu du dossier `FlashcardFactory/` dans Xcode
2. Cochez **"Copy items if needed"**
3. Vérifiez que tous les fichiers sont dans le target

### D. Configurer Core Data

1. Sélectionnez `FlashcardFactory.xcdatamodeld`
2. Vérifiez les entités `StudyGroup` et `Flashcard`
3. Vérifiez les relations

### E. Installer CocoaPods

```bash
pod install
```

### F. Ouvrir le Workspace

```bash
open FlashcardFactory.xcworkspace
```

---

## Méthode 3: Avec xcodegen (Sur macOS)

### A. Installer xcodegen

```bash
brew install xcodegen
```

### B. Créer project.yml

(Utilisez le fichier de la Méthode 1)

### C. Générer le Projet

```bash
xcodegen generate
```

### D. Installer CocoaPods

```bash
pod install
```

### E. Ouvrir

```bash
open FlashcardFactory.xcworkspace
```

---

## 🎯 Structure Attendue Après Génération

```
FlashcardFactory/
├── FlashcardFactory.xcodeproj/        # ✅ Généré
├── FlashcardFactory.xcworkspace/      # ✅ Après pod install
├── Pods/                               # ✅ Dépendances
├── Podfile
├── Podfile.lock                        # ✅ Après pod install
├── FlashcardFactory/
│   ├── ... (tous nos fichiers Swift)
│   └── GoogleService-Info.plist       # ⚠️ À ajouter
└── .github/workflows/ios.yml
```

---

## ✅ Vérification

Après génération, vous devriez pouvoir:

```bash
# Build
xcodebuild -workspace FlashcardFactory.xcworkspace \
  -scheme FlashcardFactory \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  CODE_SIGNING_ALLOWED=NO \
  clean build
```

Si ça compile ✅ → Parfait!
Si ça échoue ❌ → Vérifiez les logs

---

## 📝 Pour GitHub Actions

Si vous utilisez GitHub Actions sans Mac local:

1. Ajoutez `project.yml` (de la Méthode 1)
2. Modifiez `.github/workflows/ios.yml` pour inclure xcodegen
3. Push sur GitHub
4. Laissez GitHub Actions faire le travail!

---

**Note**: Ce projet a été structuré pour fonctionner avec GitHub Actions même sans projet Xcode pré-généré. Le workflow installera xcodegen et générera le projet automatiquement.
