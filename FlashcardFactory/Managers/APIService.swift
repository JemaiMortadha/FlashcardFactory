import Foundation

// MARK: - APIService
// Classe pour appeler l'API REST (Free Dictionary API)
// SYNTAXE DU COURS: Utilisation de URLSession et Decodable
class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    
    private init() {}
    
    // MARK: - Fetch Definition
    // SYNTAXE DU COURS: URLSession, Decodable, chaînage optionnel, coalescence nulle
    func fetchDefinition(word: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Nettoyer le mot (enlever espaces)
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanWord.isEmpty else {
            completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Le mot est vide"])))
            return
        }
        
        // Construire l'URL
        let urlString = baseURL + cleanWord
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL invalide"])))
            return
        }
        
        // SYNTAXE DU COURS: URLSession
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Gestion d'erreur réseau
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // SYNTAXE DU COURS: Chaînage optionnel (?.)
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Réponse invalide"])))
                }
                return
            }
            
            // Vérifier le code de statut
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Code HTTP: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            // SYNTAXE DU COURS: Coalescence nulle (??)
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pas de données reçues"])))
                }
                return
            }
            
            // SYNTAXE DU COURS: Decodable pour parser JSON
            do {
                let decoder = JSONDecoder()
                let responses = try decoder.decode([DictionaryAPIResponse].self, from: data)
                
                // Extraire la première définition avec chaînage optionnel et coalescence nulle
                let definition = responses.first?.getFirstDefinition() ?? "Aucune définition trouvée"
                
                DispatchQueue.main.async {
                    completion(.success(definition))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Fetch Detailed Info (Optionnel)
    // Méthode additionnelle pour obtenir plus d'informations
    func fetchDetailedInfo(word: String, completion: @escaping (Result<DictionaryAPIResponse, Error>) -> Void) {
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanWord.isEmpty else {
            completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Le mot est vide"])))
            return
        }
        
        let urlString = baseURL + cleanWord
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL invalide"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pas de données"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responses = try decoder.decode([DictionaryAPIResponse].self, from: data)
                
                if let first = responses.first {
                    DispatchQueue.main.async {
                        completion(.success(first))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Aucune réponse"])))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
