import Foundation
import CoreData

// MARK: - CoreDataManager
// Classe singleton pour gérer la persistance locale avec Core Data
class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    // SYNTAXE DU COURS: Utilisation de didSet pour logger les sauvegardes
    @Published var lastSaveTime: Date = Date() {
        didSet {
            print("✅ Core Data sauvegardé à: \(lastSaveTime)")
        }
    }
    
    // Persistent Container
    let persistentContainer: NSPersistentContainer
    
    // View Context (pour les opérations UI)
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "FlashcardFactory")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("❌ Erreur Core Data: \(error.localizedDescription)")
            }
            print("✅ Core Data initialisé: \(description)")
        }
        
        // Configuration pour merge automatique
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    // MARK: - Save Context
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                lastSaveTime = Date()  // Déclenche didSet
            } catch {
                print("❌ Erreur lors de la sauvegarde: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Create StudyGroup
    func createStudyGroup(groupID: String, name: String) -> StudyGroup? {
        let group = StudyGroup(context: viewContext)
        group.groupID = groupID
        group.name = name
        
        saveContext()
        return group
    }
    
    // MARK: - Create Flashcard
    func createFlashcard(cardID: String, question: String, answer: String, status: Int16 = 0, group: StudyGroup) -> Flashcard? {
        let card = Flashcard(context: viewContext)
        card.cardID = cardID
        card.question = question
        card.answer = answer
        card.lastReviewed = Date()
        card.status = status
        card.group = group
        
        saveContext()
        return card
    }
    
    // MARK: - Fetch Flashcards with Predicate and Sort
    // SYNTAXE DU COURS: Utilisation de NSPredicate et NSSortDescriptor
    func fetchFlashcards(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [Flashcard] {
        let request: NSFetchRequest<Flashcard> = Flashcard.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Erreur lors du fetch: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Update Flashcard Status
    func updateFlashcardStatus(flashcard: Flashcard, newStatus: Int16) {
        flashcard.status = newStatus
        flashcard.lastReviewed = Date()
        saveContext()
    }
    
    // MARK: - Delete
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }
}
