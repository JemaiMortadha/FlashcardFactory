# FlashCard Factory 🧠

Une application iOS collaborative pour créer et réviser des flashcards en groupe avec synchronisation Firebase.

![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-orange)
![Firebase](https://img.shields.io/badge/Firebase-yellow)
![Core%20Data](https://img.shields.io/badge/Core%20Data-green)

## 📱 Fonctionnalités

### ✅ 6 Interfaces Requises
1. **AuthenticationView** - Connexion/Inscription avec Firebase Auth
2. **GroupListView** - Liste des groupes d'étude collaboratifs
3. **CardCreationView** - Création de flashcards avec API REST
4. **StudySessionView** - Révision avec animations 3D et gestes
5. **HistoryView** - Historique des cartes révisées
6. **StatisticsView** - Statistiques de progression

### 🎨 Animations & Interactions
- **Animation 3D** : Retournement de carte avec `.rotation3DEffect`
- **Gestes** : Swipe gauche/droite avec `DragGesture`
- **Transitions** : Animations fluides avec `.withAnimation`

### ☁️ Technologies
- **SwiftUI** : Interface utilisateur moderne
- **Core Data** : Persistance locale
- **Firebase Auth** : Authentification
- **Firestore** : Synchronisation collaborative
- **API REST** : Free Dictionary API pour définitions

## 🛠️ Prérequis

- **Xcode 15+**
- **iOS 15.0+**
- **Compte Firebase** (gratuit)
- **CocoaPods** (pour dépendances)

## 🚀 Installation

### 1. Cloner le Repository

```bash
git clone https://github.com/VOTRE_COMPTE/FlashcardFactory.git
cd FlashcardFactory
```

### 2. Configurer Firebase

1. Créez un projet sur [Firebase Console](https://console.firebase.google.com/)
2. Ajoutez une application iOS avec Bundle ID: `com.student.flashcardfactory`
3. Téléchargez `GoogleService-Info.plist`
4. Placez-le dans `FlashcardFactory/`
5. Activez **Authentication** (Email/Password)
6. Créez une base **Firestore**

**Règles Firestore:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /groups/{groupId} {
      allow read, write: if request.auth != null;
    }
    match /flashcards/{cardId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Installer les Dépendances

```bash
pod install
```

### 4. Ouvrir le Projet

```bash
open Flashcard Factory.xcworkspace
```

⚠️ **IMPORTANT**: Utilisez toujours le fichier `.xcworkspace`, PAS le `.xcodeproj`!

## 🏗️ Structure du Projet

```
FlashcardFactory/
├── Models/
│   ├── FlashcardFactory.xcdatamodeld    # Core Data Model
│   ├── StudyGroupModel.swift            # Modèle Firestore
│   ├── FlashcardModel.swift             # Modèle Firestore
│   └── DictionaryAPIResponse.swift      # Modèle API (Decodable)
├── Managers/
│   ├── CoreDataManager.swift            # Persistance locale
│   ├── FirebaseManager.swift            # Auth + Firestore
│   └── APIService.swift                 # API REST
├── Views/
│   ├── AuthenticationView.swift         # 1️⃣ Login/Signup
│   ├── GroupListView.swift              # 2️⃣ Liste des groupes
│   ├── CardCreationView.swift           # 3️⃣ Création
│   ├── StudySessionView.swift           # 4️⃣ Révision (Animations!)
│   ├── HistoryView.swift                # 5️⃣ Historique
│   └── StatisticsView.swift             # 6️⃣ Stats
└── FlashcardFactoryApp.swift            # Point d'entrée
```

## 🎓 Syntaxe du Cours Utilisée

### Core Data
- **@FetchRequest** : Récupération automatique des données
- **NSPredicate** : Filtrage des données (ex: `status > 0`)
- **NSSortDescriptor** : Tri des données (ex: par date)

### SwiftUI
- **@State** : État local d'une vue
- **@Binding** : Partage d'état entre vues
- **if/else** : Affichage conditionnel
- **Form & TextField** : Formulaires
- **List & NavigationLink** : Navigation

### Animations
- **.rotation3DEffect** : Retournement 3D
- **DragGesture** : Gestes de swipe
- **.withAnimation** : Transitions fluides

### Networking
- **URLSession** : Requêtes réseau
- **Decodable** : Parsing JSON
- **Chaînage optionnel (`?.`)** : Sécurité des optionnels
- **Coalescence nulle (`??`)** : Valeurs par défaut

### POO
- **didSet** : Observer de propriété
- **Classes singleton** : `shared` instance
- **Propriétés calculées** : `var masteredCount: Int { ... }`

## 💻 Compilation via GitHub Actions

### Configuration du Secret Firebase

1. Convertir `GoogleService-Info.plist` en base64:
```bash
cat GoogleService-Info.plist | base64 -w 0
```

2. Dans GitHub:
   - Settings → Secrets and variables → Actions
   - New repository secret
   - Name: `GOOGLE_SERVICE_INFO_PLIST`
   - Value: [coller la chaîne base64]

### Workflow GitHub Actions

Le fichier `.github/workflows/ios.yml` compilera automatiquement:
- ✅ Installation de CocoaPods
- ✅ Restauration de GoogleService-Info.plist
- ✅ Build avec Xcode
- ✅ Tests (optionnel)

**Durée:** ~5-10 minutes

### Pousser sur GitHub

```bash
git add .
git commit -m "Initial commit: FlashcardFactory iOS app"
git push origin main
```

Le workflow s'exécutera automatiquement! Consultez l'onglet **Actions**.

## 📖 Utilisation

### 1. Créer un Compte
- Lancez l'app
- Cliquez sur "Pas de compte? S'inscrire"
- Entrez email et mot de passe (min 6 caractères)

### 2. Créer un Groupe
- Dans l'onglet "Groupes"
- Cliquez sur "+"
- Nommez votre groupe d'étude

### 3. Créer des Flashcards
- Sélectionnez un groupe
- Remplissez la question
- **API REST** : Entrez un mot anglais et cliquez sur 🔍 pour obtenir la définition
- Sauvegardez

### 4. Réviser
- Ouvrez une session d'étude
- **Tapez** pour retourner la carte
- **Swipez** gauche (❌) ou droite (✅)
- Les cartes sont mises à jour automatiquement!

### 5. Consulter les Stats
- Onglet "Stats"
- Voir la progression globale
- Cartes maîtrisées vs. en cours

## 🔥 Firebase - Synchronisation Collaborative

Les données sont automatiquement synchronisées:
- ✅ Création de groupes → Firestore
- ✅ Création de cartes → Firestore
- ✅ Statuts de révision → Firestore

**Mode hors-ligne:** Core Data conserve tout localement!

## 🌐 API REST Utilisée

**Free Dictionary API**: https://dictionaryapi.dev/

- Gratuite, sans clé API
- Définitions en anglais
- Exemples et synonymes

## 🐛 Dépannage

### Pod install échoue
```bash
sudo gem install cocoapods
pod repo update
pod install
```

### Firebase non configuré
- Vérifiez que `GoogleService-Info.plist` est dans le bon dossier
- Vérifiez le Bundle ID dans Xcode

### GitHub Actions échoue
- Vérifiez que le secret `GOOGLE_SERVICE_INFO_PLIST` est configuré
- Consultez les logs dans l'onglet Actions

## 📝 Licence

Ce projet est un projet académique pour démontrer l'utilisation de SwiftUI, Core Data, Firebase et des API REST.

## 👨‍💻 Auteur

Projet créé pour le cours iOS Development

---

**Happy Coding! 🚀**
