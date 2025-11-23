import SwiftUI

// MARK: - CardCreationView
// Interface 3: Création de flashcard avec intégration API REST
// SYNTAXE DU COURS: Form, TextField, @State, @Binding, API REST
struct CardCreationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let group: StudyGroup
    
    @State private var question = ""
    @State private var answer = ""
    @State private var isLoadingDefinition = false
    @State private var apiError = ""
    @State private var showingSuccess = false
    
    var body: some View {
        // SYNTAXE DU COURS: Form pour les formulaires
        Form {
            Section(header: Text("Question")) {
                // SYNTAXE DU COURS: TextField avec @State
                TextField("Entrez la question", text: $question)
                    .textInputAutocapitalization(.sentences)
                
                // Bouton API REST
                HStack {
                    TextField("Mot en anglais pour recherche", text: $question)
                        .textInputAutocapitalization(.never)
                    
                    // SYNTAXE DU COURS: API REST Integration
                    Button(action: fetchDefinitionFromAPI) {
                        if isLoadingDefinition {
                            ProgressView()
                        } else {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(isLoadingDefinition || question.isEmpty)
                }
            }
            
            Section(header: Text("Réponse")) {
                TextEditor(text: $answer)
                    .frame(height: 120)
                
                if isLoadingDefinition {
                    HStack {
                        ProgressView()
                        Text("Recherche de la définition...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // SYNTAXE DU COURS: Coalescence nulle pour affichage d'erreur
                if !apiError.isEmpty {
                    Text(apiError)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Actions API REST")) {
                Button(action: fetchDefinitionFromAPI) {
                    Label("Rechercher Définition (API)", systemImage: "cloud.fill")
                }
                .disabled(question.isEmpty || isLoadingDefinition)
                
                Text("💡 Entrez un mot anglais dans la question, puis cliquez pour pré-remplir la réponse avec la définition depuis l'API Free Dictionary")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button(action: saveFlashcard) {
                    Label("Créer la Flashcard", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .disabled(question.isEmpty || answer.isEmpty)
            }
        }
        .navigationTitle("Nouvelle Flashcard")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Flashcard créée!", isPresented: $showingSuccess) {
            Button("OK") {
                question = ""
                answer = ""
            }
        }
    }
    
    // MARK: - Fetch Definition from API
    // SYNTAXE DU COURS: URLSession, Decodable, chaînage optionnel, coalescence nulle
    private func fetchDefinitionFromAPI() {
        apiError = ""
        isLoadingDefinition = true
        
        // Utilisation de la classe APIService
        APIService.shared.fetchDefinition(word: question) { result in
            isLoadingDefinition = false
            
            switch result {
            case .success(let definition):
                // SYNTAXE DU COURS: Coalescence nulle (??)
                answer = definition
                apiError = ""
            case .failure(let error):
                // SYNTAXE DU COURS: Chaînage optionnel (?.)
                apiError = "Erreur API: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Save Flashcard
    private func saveFlashcard() {
        let cardID = UUID().uuidString
        
        // Créer dans Core Data
        if let flashcard = CoreDataManager.shared.createFlashcard(
            cardID: cardID,
            question: question,
            answer: answer,
            status: 0,
            group: group
        ) {
            // Synchroniser avec Firebase
            let flashcardModel = FlashcardModel(
                cardID: cardID,
                question: question,
                answer: answer,
                lastReviewed: Date(),
                status: 0,
                groupID: group.groupID ?? ""
            )
            
            FirebaseManager.shared.syncFlashcardToFirestore(flashcard: flashcardModel) { error in
                if let error = error {
                    print("❌ Erreur sync Firebase: \(error.localizedDescription)")
                }
            }
            
            showingSuccess = true
        }
    }
}

#Preview {
    NavigationView {
        CardCreationView(group: StudyGroup())
            .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
    }
}
