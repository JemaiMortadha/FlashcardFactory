import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

// MARK: - FirebaseManager
// Classe pour gérer Firebase Authentication et Firestore sync
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var isAuthenticated = false
    @Published var currentUserEmail: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // Collections Firestore
    private let groupsCollection = "groups"
    private let flashcardsCollection = "flashcards"
    
    private init() {
        // Vérifier l'état d'authentification
        if let user = auth.currentUser {
            isAuthenticated = true
            currentUserEmail = user.email
        }
        
        // Observer les changements d'auth
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.currentUserEmail = user?.email
        }
    }
    
    // MARK: - Authentication
    
    // SYNTAXE DU COURS: Utilisation du chaînage optionnel (?.)
    func signUp(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Chaînage optionnel pour accéder à l'uid
            if let uid = result?.user.uid {
                completion(.success(uid))
            } else {
                completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "UID non disponible"])))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let uid = result?.user.uid {
                completion(.success(uid))
            } else {
                completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "UID non disponible"])))
            }
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - Firestore Sync - Groups
    
    func syncGroupToFirestore(group: StudyGroupModel, completion: @escaping (Error?) -> Void) {
        // SYNTAXE DU COURS: Chaînage optionnel et coalescence nulle
        guard let _ = auth.currentUser?.uid else {
            completion(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié"]))
            return
        }
        
        db.collection(groupsCollection)
            .document(group.groupID)
            .setData(group.toDictionary()) { error in
                completion(error)
            }
    }
    
    func fetchGroupsFromFirestore(completion: @escaping (Result<[StudyGroupModel], Error>) -> Void) {
        guard let _ = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié"])))
            return
        }
        
        db.collection(groupsCollection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // SYNTAXE DU COURS: Utilisation de coalescence nulle (??)
            let documents = snapshot?.documents ?? []
            
            let groups = documents.compactMap { doc -> StudyGroupModel? in
                let data = doc.data()
                guard let groupID = data["groupID"] as? String,
                      let name = data["name"] as? String,
                      let timestamp = data["createdAt"] as? Timestamp else {
                    return nil
                }
                
                return StudyGroupModel(
                    groupID: groupID,
                    name: name,
                    createdAt: timestamp.dateValue()
                )
            }
            
            completion(.success(groups))
        }
    }
    
    // MARK: - Firestore Sync - Flashcards
    
    func syncFlashcardToFirestore(flashcard: FlashcardModel, completion: @escaping (Error?) -> Void) {
        guard let _ = auth.currentUser?.uid else {
            completion(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié"]))
            return
        }
        
        db.collection(flashcardsCollection)
            .document(flashcard.cardID)
            .setData(flashcard.toDictionary()) { error in
                completion(error)
            }
    }
    
    func fetchFlashcardsFromFirestore(groupID: String, completion: @escaping (Result<[FlashcardModel], Error>) -> Void) {
        guard let _ = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié"])))
            return
        }
        
        db.collection(flashcardsCollection)
            .whereField("groupID", isEqualTo: groupID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let documents = snapshot?.documents ?? []
                
                let flashcards = documents.compactMap { doc -> FlashcardModel? in
                    let data = doc.data()
                    guard let cardID = data["cardID"] as? String,
                          let question = data["question"] as? String,
                          let answer = data["answer"] as? String,
                          let timestamp = data["lastReviewed"] as? Timestamp,
                          let status = data["status"] as? Int16,
                          let groupID = data["groupID"] as? String else {
                        return nil
                    }
                    
                    return FlashcardModel(
                        cardID: cardID,
                        question: question,
                        answer: answer,
                        lastReviewed: timestamp.dateValue(),
                        status: status,
                        groupID: groupID
                    )
                }
                
                completion(.success(flashcards))
            }
    }
}
