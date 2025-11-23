import SwiftUI
import CoreData

// MARK: - StatisticsView
// Interface 6: Statistiques
// SYNTAXE DU COURS: Propriété calculée (computed var)
struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Récupérer toutes les flashcards
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Flashcard.lastReviewed, ascending: false)],
        animation: .default
    )
    private var allFlashcards: FetchedResults<Flashcard>
    
    // SYNTAXE DU COURS: Propriétés calculées (computed var)
    
    // Nombre total de cartes
    private var totalCards: Int {
        allFlashcards.count
    }
    
    // Nombre de cartes maîtrisées (status == 2)
    private var masteredCount: Int {
        allFlashcards.filter { $0.status == 2 }.count
    }
    
    // Nombre de cartes en cours (status == 1)
    private var inProgressCount: Int {
        allFlashcards.filter { $0.status == 1 }.count
    }
    
    // Nombre de cartes nouvelles (status == 0)
    private var newCount: Int {
        allFlashcards.filter { $0.status == 0 }.count
    }
    
    // Pourcentage de progression
    private var progressPercentage: Double {
        guard totalCards > 0 else { return 0 }
        return Double(masteredCount) / Double(totalCards) * 100
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Carte de progression globale
                    VStack(spacing: 15) {
                        Text("Progression Globale")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Cercle de progression
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(progressPercentage / 100))
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: progressPercentage)
                            
                            VStack(spacing: 5) {
                                Text("\(Int(progressPercentage))%")
                                    .font(.system(size: 50, weight: .bold))
                                
                                Text("Maîtrisées")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // Statistiques détaillées
                    VStack(spacing: 15) {
                        Text("Détails")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Total
                        StatCard(
                            title: "Total de Cartes",
                            value: totalCards,
                            icon: "square.stack.3d.up.fill",
                            color: .blue
                        )
                        
                        // Maîtrisées
                        StatCard(
                            title: "Cartes Maîtrisées",
                            value: masteredCount,
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        // En cours
                        StatCard(
                            title: "Cartes En Cours",
                            value: inProgressCount,
                            icon: "arrow.triangle.2.circulepath",
                            color: .orange
                        )
                        
                        // Nouvelles
                        StatCard(
                            title: "Cartes Nouvelles",
                            value: newCount,
                            icon: "sparkles",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Informations additionnelles
                    if totalCards > 0 {
                        VStack(spacing: 10) {
                            Text("💡 Conseil")
                                .font(.headline)
                            
                            if newCount > 0 {
                                Text("Vous avez \(newCount) nouvelle(s) carte(s) à découvrir!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            } else if inProgressCount > 0 {
                                Text("Continuez à réviser les \(inProgressCount) carte(s) en cours!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            } else if masteredCount == totalCards {
                                Text("🎉 Félicitations! Toutes les cartes sont maîtrisées!")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - StatCard
struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(value)")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    StatisticsView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
