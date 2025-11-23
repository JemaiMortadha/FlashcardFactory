import SwiftUI

// MARK: - StudySessionView
// Interface 4: Session d'étude avec animations 3D et gestes
// SYNTAXE DU COURS: rotation3DEffect, DragGesture, withAnimation
struct StudySessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let group: StudyGroup
    
    // Récupérer les flashcards du groupe
    @FetchRequest private var flashcards: FetchedResults<Flashcard>
    
    // SYNTAXE DU COURS: @State pour l'animation
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset = CGSize.zero
    @State private var rotation: Double = 0
    
    init(group: StudyGroup) {
        self.group = group
        
        // Initialiser FetchRequest avec un prédicat
        _flashcards = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Flashcard.lastReviewed, ascending: true)],
            predicate: NSPredicate(format: "group == %@", group),
            animation: .default
        )
    }
    
    var body: some View {
        ZStack {
            // Dégradé de fond
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if flashcards.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("Aucune flashcard dans ce groupe")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 30) {
                    // Indicateur de progression
                    Text("Carte \(currentIndex + 1) / \(flashcards.count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // La carte avec animation 3D
                    ZStack {
                        // Face avant (Question)
                        CardFaceView(
                            text: flashcards[currentIndex].question ?? "",
                            backgroundColor: .blue,
                            isVisible: !isFlipped
                        )
                        .opacity(isFlipped ? 0 : 1)
                        
                        // Face arrière (Réponse)
                        CardFaceView(
                            text: flashcards[currentIndex].answer ?? "",
                            backgroundColor: .green,
                            isVisible: isFlipped
                        )
                        .opacity(isFlipped ? 1 : 0)
                        // SYNTAXE DU COURS: rotation3DEffect pour retournement 3D
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 400)
                    // SYNTAXE DU COURS: rotation3DEffect avec animation
                    .rotation3DEffect(
                        .degrees(isFlipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .offset(x: dragOffset.width, y: dragOffset.height)
                    .rotationEffect(.degrees(rotation))
                    // SYNTAXE DU COURS: DragGesture pour swiper
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                                rotation = Double(value.translation.width / 20)
                            }
                            .onEnded { value in
                                // Swipe à droite (bonne réponse)
                                if value.translation.width > 100 {
                                    handleSwipe(isCorrect: true)
                                }
                                // Swipe à gauche (mauvaise réponse)
                                else if value.translation.width < -100 {
                                    handleSwipe(isCorrect: false)
                                }
                                // Retour à la position initiale
                                else {
                                    withAnimation(.spring()) {
                                        dragOffset = .zero
                                        rotation = 0
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        // Retourner la carte
                        // SYNTAXE DU COURS: withAnimation
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isFlipped.toggle()
                        }
                    }
                    
                    // Instructions
                    VStack(spacing: 10) {
                        Text("👆 Tapez pour retourner la carte")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 40) {
                            Label("Swipe ← Mauvais", systemImage: "hand.thumbsdown.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Label("Swipe → Bon", systemImage: "hand.thumbsup.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    
                    // Boutons de navigation additionnels
                    HStack(spacing: 30) {
                        Button(action: { handleSwipe(isCorrect: false) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                        }
                        
                        Button(action: { handleSwipe(isCorrect: true) }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Session d'Étude")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Handle Swipe
    private func handleSwipe(isCorrect: Bool) {
        let currentCard = flashcards[currentIndex]
        
        // Mettre à jour le statut
        // 0 = nouveau, 1 = en cours, 2 = maîtrisé
        let newStatus: Int16 = isCorrect ? 2 : 1
        CoreDataManager.shared.updateFlashcardStatus(flashcard: currentCard, newStatus: newStatus)
        
        // Animation de sortie
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(
                width: isCorrect ? 500 : -500,
                height: 0
            )
            rotation = isCorrect ? 20 : -20
        }
        
        // Passer à la carte suivante
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex < flashcards.count - 1 {
                withAnimation {
                    currentIndex += 1
                    isFlipped = false
                    dragOffset = .zero
                    rotation = 0
                }
            } else {
                // Retour au début
                withAnimation {
                    currentIndex = 0
                    isFlipped = false
                    dragOffset = .zero
                    rotation = 0
                }
            }
        }
    }
}

// MARK: - CardFaceView
struct CardFaceView: View {
    let text: String
    let backgroundColor: Color
    let isVisible: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [backgroundColor, backgroundColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack {
                Text(isVisible ? "Réponse" : "Question")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 20)
                
                Spacer()
                
                Text(text)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationView {
        StudySessionView(group: StudyGroup())
            .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
    }
}
