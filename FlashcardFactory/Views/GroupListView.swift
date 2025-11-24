import SwiftUI
import CoreData

// MARK: - GroupListView
// Interface 2: Liste des groupes d'étude
// SYNTAXE DU COURS: Utilisation de @FetchRequest, List, NavigationLink
struct GroupListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    // SYNTAXE DU COURS: @FetchRequest pour Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudyGroup.name, ascending: true)],
        animation: .default
    )
    private var groups: FetchedResults<StudyGroup>
    
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    @State private var isSyncing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // SYNTAXE DU COURS: List pour afficher les données
                List {
                    ForEach(groups) { group in
                        // SYNTAXE DU COURS: NavigationLink pour navigation
                        NavigationLink(destination: FlashcardListView(group: group)) {
                            GroupRowView(group: group)
                        }
                    }
                    .onDelete(perform: deleteGroups)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Mes Groupes")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: syncWithFirebase) {
                            if isSyncing {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.triangle.2.circulepath")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddGroup = true }) {
                            Image(systemName: "plus")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: signOut) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
                .sheet(isPresented: $showingAddGroup) {
                    AddGroupSheet(newGroupName: $newGroupName, onSave: addGroup)
                }
            }
        }
    }
    
    // MARK: - Add Group
    private func addGroup() {
        guard !newGroupName.isEmpty else { return }
        
        let groupID = UUID().uuidString
        
        // Créer dans Core Data
        let _ = CoreDataManager.shared.createStudyGroup(groupID: groupID, name: newGroupName)
        
        // Synchroniser avec Firebase
        let groupModel = StudyGroupModel(groupID: groupID, name: newGroupName)
        firebaseManager.syncGroupToFirestore(group: groupModel) { error in
            if let error = error {
                print("❌ Erreur sync Firebase: \(error.localizedDescription)")
            }
        }
        
        newGroupName = ""
        showingAddGroup = false
    }
    
    // MARK: - Delete Groups
    private func deleteGroups(offsets: IndexSet) {
        for index in offsets {
            let group = groups[index]
            CoreDataManager.shared.delete(group)
        }
    }
    
    // MARK: - Sync with Firebase
    private func syncWithFirebase() {
        isSyncing = true
        
        firebaseManager.fetchGroupsFromFirestore { result in
            switch result {
            case .success(let fetchedGroups):
                // Créer les groupes qui n'existent pas localement
                for groupModel in fetchedGroups {
                    // Vérifier si le groupe existe déjà
                    let existingGroups = CoreDataManager.shared.fetchFlashcards(
                        predicate: NSPredicate(format: "groupID == %@", groupModel.groupID)
                    )
                    
                    if existingGroups.isEmpty {
                        let _ = CoreDataManager.shared.createStudyGroup(
                            groupID: groupModel.groupID,
                            name: groupModel.name
                        )
                    }
                }
                isSyncing = false
            case .failure(let error):
                print("❌ Erreur sync: \(error.localizedDescription)")
                isSyncing = false
            }
        }
    }
    
    // MARK: - Sign Out
    private func signOut() {
        do {
            try firebaseManager.signOut()
        } catch {
            print("❌ Erreur déconnexion: \(error.localizedDescription)")
        }
    }
}

// MARK: - GroupRowView
struct GroupRowView: View {
    let group: StudyGroup
    
    // Compter les flashcards du groupe
    private var flashcardsCount: Int {
        (group.flashcards as? Set<Flashcard>)?.count ?? 0
    }
    
    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                // SYNTAXE DU COURS: Text pour affichage
                Text(group.name ?? "Sans nom")
                    .font(.headline)
                
                Text("\(flashcardsCount) flashcard(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - AddGroupSheet
struct AddGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newGroupName: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations du groupe")) {
                    TextField("Nom du groupe", text: $newGroupName)
                }
            }
            .navigationTitle("Nouveau Groupe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        onSave()
                        dismiss()
                    }
                    .disabled(newGroupName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    GroupListView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
