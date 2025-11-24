import SwiftUI
import CoreData

// MARK: - FlashcardListView
// Vue pour afficher la liste des flashcards d'un groupe
struct FlashcardListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let group: StudyGroup
    
    // Récupérer les flashcards du groupe avec @FetchRequest
    @FetchRequest private var flashcards: FetchedResults<Flashcard>
    
    @State private var showingAddCard = false
    
    init(group: StudyGroup) {
        self.group = group
        
        // Initialiser FetchRequest avec un prédicat pour filtrer par groupe
        _flashcards = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Flashcard.lastReviewed, ascending: false)],
            predicate: NSPredicate(format: "group == %@", group),
            animation: .default
        )
    }
    
    var body: some View {
        ZStack {
            if flashcards.isEmpty {
                // État vide
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("Aucune flashcard")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Créez votre première flashcard!")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showingAddCard = true }) {
                        Label("Ajouter une carte", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            } else {
                // Liste des flashcards
                List {
                    // Bouton pour démarrer une session d'étude
                    Section {
                        NavigationLink(destination: StudySessionView(group: group)) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading) {
                                    Text("Démarrer l'étude")
                                        .font(.headline)
                                    Text("\(flashcards.count) carte(s) disponible(s)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Liste des flashcards
                    Section(header: Text("Flashcards")) {
                        ForEach(flashcards) { flashcard in
                            FlashcardRowView(flashcard: flashcard)
                        }
                        .onDelete(perform: deleteFlashcards)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle(group.name ?? "Groupe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCard = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            NavigationView {
                CardCreationView(group: group)
            }
        }
    }
    
    // MARK: - Delete Flashcards
    private func deleteFlashcards(offsets: IndexSet) {
        for index in offsets {
            let flashcard = flashcards[index]
            CoreDataManager.shared.delete(flashcard)
        }
    }
}

// MARK: - FlashcardRowView
struct FlashcardRowView: View {
    let flashcard: Flashcard
    
    // Statut de la carte (0 = nouveau, 1 = en cours, 2 = maîtrisé)
    private var statusColor: Color {
        switch flashcard.status {
        case 0: return .gray
        case 1: return .orange
        case 2: return .green
        default: return .gray
        }
    }
    
    private var statusIcon: String {
        switch flashcard.status {
        case 0: return "circle"
        case 1: return "circle.lefthalf.filled"
        case 2: return "checkmark.circle.fill"
        default: return "circle"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Question
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                
                Text(flashcard.question ?? "Sans question")
                    .font(.headline)
                    .lineLimit(2)
            }
            
            // Réponse (preview)
            Text(flashcard.answer ?? "Sans réponse")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Dernière révision
            if let lastReviewed = flashcard.lastReviewed {
                Text("Révisé: \(lastReviewed, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        FlashcardListView(group: StudyGroup())
            .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
    }
}
