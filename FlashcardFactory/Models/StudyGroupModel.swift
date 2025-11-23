import Foundation

// MARK: - StudyGroupModel
// Modèle Swift pour synchronisation Firestore (conforme à Codable)
struct StudyGroupModel: Codable, Identifiable {
    var id: String { groupID }
    var groupID: String
    var name: String
    var createdAt: Date
    
    init(groupID: String, name: String, createdAt: Date = Date()) {
        self.groupID = groupID
        self.name = name
        self.createdAt = createdAt
    }
    
    // Dictionnaire pour Firestore
    func toDictionary() -> [String: Any] {
        return [
            "groupID": groupID,
            "name": name,
            "createdAt": createdAt
        ]
    }
}
