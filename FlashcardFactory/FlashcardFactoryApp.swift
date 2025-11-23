import SwiftUI
import FirebaseCore
import FirebaseAuth

// MARK: - FlashcardFactoryApp
// Point d'entrée principal de l'application
@main
struct FlashcardFactoryApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    // Initialiser Firebase
    init() {
        FirebaseApp.configure()
        print("✅ Firebase configuré")
    }
    
    var body: some Scene {
        WindowGroup {
            // Injecter le Core Data context dans l'environnement
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
                .environmentObject(firebaseManager)
        }
    }
}

// MARK: - ContentView
// Vue racine qui gère la navigation selon l'état d'authentification
struct ContentView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    
    var body: some View {
        // SYNTAXE DU COURS: if/else pour basculer entre vues
        if firebaseManager.isAuthenticated {
            MainTabView()
        } else {
            AuthenticationView()
        }
    }
}

// MARK: - MainTabView
// TabView principale après authentification
struct MainTabView: View {
    var body: some View {
        TabView {
            // Onglet 1: Liste des groupes
            GroupListView()
                .tabItem {
                    Label("Groupes", systemImage: "folder.fill")
                }
            
            // Onglet 2: Historique
            HistoryView()
                .tabItem {
                    Label("Historique", systemImage: "clock.arrow.circlepath")
                }
            
            // Onglet 3: Statistiques
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
        .environmentObject(FirebaseManager.shared)
}
