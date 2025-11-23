import Foundation

// MARK: - DictionaryAPIResponse
// Modèles Decodable pour parser la réponse de l'API Free Dictionary
// API: https://api.dictionaryapi.dev/api/v2/entries/en/{word}

struct DictionaryAPIResponse: Decodable {
    let word: String?
    let meanings: [Meaning]?
    
    // Extrait la première définition disponible
    func getFirstDefinition() -> String? {
        return meanings?.first?.definitions?.first?.definition
    }
}

struct Meaning: Decodable {
    let partOfSpeech: String?
    let definitions: [Definition]?
}

struct Definition: Decodable {
    let definition: String
    let example: String?
    let synonyms: [String]?
}
