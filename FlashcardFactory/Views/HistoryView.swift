import SwiftUI
import CoreData

// MARK: - HistoryView
// Interface 5: Historique de révision
// SYNTAXE DU COURS: NSPredicate, NSSortDescriptor, @FetchRequest
struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // SYNTAXE DU COURS: @FetchRequest avec NSPredicate et NSSortDescriptor
    // Filtre: status > 0 (cartes révisées au moins une fois)
    // Tri: lastReviewed décroissant
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Flashcard.lastReviewed, ascending: false)],
        predicate: NSPredicate(format: "status > %d", 0),
        animation: .default
    )
    private var reviewedFlashcards: FetchedResults<Flashcard>
    
    var body: some View {
        NavigationView {
            List {
                if reviewedFlashcards.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Aucune carte révisée")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Commencez une session d'étude!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(reviewedFlashcards) { flashcard in
                        HistoryCardRow(flashcard: flashcard)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - HistoryCardRow
struct HistoryCardRow: View {
    let flashcard: Flashcard
    
    // Status icons et couleurs
    private var statusInfo: (icon: String, color: Color, text: String) {
        switch flashcard.status {
        case 0:
            return ("circle", .gray, "Nouveau")
        case 1:
            return ("arrow.triangle.2.circlepath", .orange, "En cours")
        case 2:
            return ("checkmark.circle.fill", .green, "Maîtrisé")
        default:
            return ("questionmark", .gray, "Inconnu")
        }
    }
    
    // Formatter la date
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: flashcard.lastReviewed ?? Date(), relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(flashcard.question ?? "")
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                Image(systemName: statusInfo.icon)
                    .foregroundColor(statusInfo.color)
            }
            
            Text(flashcard.answer ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Label(statusInfo.text, systemImage: statusInfo.icon)
                    .font(.caption)
                    .foregroundColor(statusInfo.color)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
