# 🚀 GUIDE DE DÉMARRAGE RAPIDE

## Vous êtes sur Linux/Windows sans macOS?

**Parfait!** Ce projet est conçu pour être compilé via **GitHub Actions** sans avoir besoin d'un Mac local.

## 📋 Étapes de Configuration

### 1. ✅ Configuration Firebase (À faire MAINTENANT)

#### A. Créer le Projet Firebase
1. Allez sur https://console.firebase.google.com/
2. Cliquez "Ajouter un projet"
3. Nom: `flashcard-factory`
4. Désactivez Google Analytics (optionnel)
5. Cliquez "Créer le projet"

#### B. Ajouter l'application iOS
1. Dans votre projet Firebase, cliquez sur l'icône **iOS**
2. **Bundle ID**: `com.student.flashcardfactory`
3. **Surnom**: FlashcardFactory
4. Cliquez "Enregistrer l'app"
5. **TÉLÉCHARGEZ** le fichier `GoogleService-Info.plist`

#### C. Activer Authentication
1. Menu gauche → **Authentication**
2. Cliquez "Commencer"
3. Onglet "Sign-in method"
4. Activez **"Adresse e-mail/Mot de passe"**
5. Cliquez "Enregistrer"

#### D. Créer Firestore Database
1. Menu gauche → **Firestore Database**
2. Cliquez "Créer une base de données"
3.  Mode: **Production**
4. Région: `europe-west1` (ou proche de vous)
5. Cliquez "Activer"

#### E. Configurer les Règles Firestore
1. Onglet **"Règles"**
2. Remplacez par:
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
3. Cliquez **"Publier"**

---

### 2. 🔐 Ajouter le Secret GitHub

#### A. Convertir GoogleService-Info.plist en Base64

**Sur Linux:**
```bash
cd ~/Downloads
cat GoogleService-Info.plist | base64 -w 0
```

**Sur macOS:**
```bash
cd ~/Downloads
base64 -i GoogleService-Info.plist | tr -d '\n'
```

**Sur Windows (PowerShell):**
```powershell
cd C:\Users\VOTRE_NOM\Downloads
[Convert]::ToBase64String([IO.File]::ReadAllBytes("GoogleService-Info.plist"))
```

➡️ **Copiez TOUTE la chaîne** (très longue, ~2000+ caractères)

#### B. Ajouter dans GitHub

1. Allez sur votre repo: `https://github.com/VOTRE_COMPTE/FlashcardFactory`
2. **Settings** → **Secrets and variables** → **Actions**
3. Cliquez **"New repository secret"**
4. **Name**: `GOOGLE_SERVICE_INFO_PLIST` (exactement ce nom!)
5. **Secret**: Collez la chaîne base64
6. Cliquez **"Add secret"**

✅ Vérifié quand vous voyez: `GOOGLE_SERVICE_INFO_PLIST` dans la liste

---

### 3. 📤 Pusher sur GitHub

```bash
# Dans le dossier FlashcardFactory
git status                                    # Vérifier les fichiers
git add .                                     # Ajouter tous les fichiers
git commit -m "Initial commit: Complete iOS FlashcardFactory app"
git push origin main                          # Pousser sur GitHub
```

---

### 4. ⚙️ Vérifier le Build GitHub Actions

1. Allez sur votre repo GitHub
2. Cliquez sur l'onglet **"Actions"**
3. Vous devriez voir un workflow en cours: `iOS Build and Test`
4. Cliquez dessus pour voir les logs
5. ⏱️ Attendez ~5-10 minutes

#### ✅ Build Réussi
Si tout est vert:
- ✅ Le code compile!
- ✅ Firebase est bien configuré
- ✅ Toutes les dépendances sont installées

#### ❌ Build Échoue
Vérifiez:
- Le secret `GOOGLE_SERVICE_INFO_PLIST` est bien configuré
- La chaîne base64 est complète (pas d'espaces, pas de retours ligne)
- Les logs d'erreur dans GitHub Actions

---

## 📱 Structure du Projet

```
FlashcardFactory/
├── .github/workflows/ios.yml          # 🤖 GitHub Actions
├── FlashcardFactory/
│   ├── FlashcardFactoryApp.swift      # 🚀 Point d'entrée
│   ├── Models/                         # 📊 Modèles de données
│   │   ├── FlashcardFactory.xcdatamodeld
│   │   ├── StudyGroupModel.swift
│   │   ├── FlashcardModel.swift
│   │   └── DictionaryAPIResponse.swift
│   ├── Managers/                       # 🔧 Logique métier
│   │   ├── CoreDataManager.swift
│   │   ├── FirebaseManager.swift
│   │   └── APIService.swift
│   ├── Views/                          # 🎨 6 Interfaces
│   │   ├── AuthenticationView.swift   # 1️⃣
│   │   ├── GroupListView.swift        # 2️⃣
│   │   ├── CardCreationView.swift     # 3️⃣
│   │   ├── StudySessionView.swift     # 4️⃣ (Animations!)
│   │   ├── HistoryView.swift          # 5️⃣
│   │   └── StatisticsView.swift       # 6️⃣
│   ├── Info.plist
│   └── GoogleService-Info.plist       # ⚠️ À ajouter (secret GitHub)
├── Podfile                             # 📦 Dépendances
├── .gitignore
└── README.md
```

---

## 🎯 Concepts du Cours Démontrés

### ✅ SwiftUI
- `@State`, `@Binding`, `@FetchRequest`
- `Form`, `TextField`, `List`, `NavigationLink`
- `if/else` pour affichage conditionnel

### ✅ Core Data
- Modèle avec 2 entités (StudyGroup, Flashcard)
- Relation One-to-Many avec cascade delete
- `NSPredicate` et `NSSortDescriptor`

### ✅ Firebase
- Authentication (Email/Password)
- Firestore sync collaborative
- Chaînage optionnel (`?.`) et coalescence nulle (`??`)

### ✅ API REST
- `URLSession` pour requêtes HTTP
- `Decodable` pour parsing JSON
- Free Dictionary API (gratuite)

### ✅ Animations
- **.rotation3DEffect** : Flip 3D
- **DragGesture** : Swipe gauche/droite
- **.withAnimation** : Transitions fluides

### ✅ POO
- `didSet` observer
- Singletons (`CoreDataManager.shared`)
- Propriétés calculées (`var masteredCount: Int { ... }`)

---

## ❓ FAQ

### Q: Je n'ai pas de Mac, puis-je quand même compiler?
**R:** Oui! GitHub Actions compile sur macOS dans le cloud.

### Q: Combien coûte GitHub Actions?
**R:** Gratuit pour repos publics, 2000 min/mois pour repos privés.

### Q: Comment tester l'app?
**R:** Vous avez besoin d'un Mac ou utilisez TestFlight via GitHub Actions avancé (nécessite compte Apple Developer $99/an).

### Q: L'API Dictionary fonctionne-t-elle en français?
**R:** Non, uniquement anglais. Mais vous pouvez changer l'URL dans `APIService.swift`.

### Q: Puis-je déployer sur l'App Store?
**R:** Oui, avec un compte Apple Developer et des certificats de signature.

---

## 🎉 Prochain Push

Une fois Firebase configuré et le secret GitHub ajouté:

```bash
git add .
git commit -m "Add project files"
git push origin main
```

➡️ **Allez dans Actions et regardez la magie opérer!** 🚀

---

## 📞 Besoin d'Aide?

- Vérifiez le README.md complet
- Consultez le code source (commenté en français)
- Regardez les logs GitHub Actions

**Bon courage! 💪**
