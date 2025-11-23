import Foundation

// MARK: - FlashcardModel
// Modèle Swift pour synchronisation Firestore (conforme à Codable)
struct FlashcardModel: Codable, Identifiable {
    var id: String { cardID }
    var cardID: String
    var question: String
    var answer: String
    var lastReviewed: Date
    var status: Int16  // 0=nouveau, 1=en cours, 2=maîtrisé
    var groupID: String
    
    init(cardID: String, question: String, answer: String, lastReviewed: Date = Date(), status: Int16 = 0, groupID: String) {
        self.cardID = cardID
        self.question = question
        self.answer = answer
        self.lastReviewed = lastReviewed
        self.status = status
        self.groupID = groupID
    }
    
    // Dictionnaire pour Firestore
    func toDictionary() -> [String: Any] {
        return [
            "cardID": cardID,
            "question": question,
            "answer": answer,
            "lastReviewed": lastReviewed,
            "status": status,
            "groupID": groupID
        ]
    }
}
