import SwiftUI
import FirebaseAuth

// MARK: - AuthenticationView
// Interface 1: Authentification avec Firebase Auth
// SYNTAXE DU COURS: Utilisation de if/else pour basculer entre modes
struct AuthenticationView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    // SYNTAXE DU COURS: @State pour l'état local
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dégradé de fond
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Logo et titre
                    VStack(spacing: 10) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("FlashCard Factory")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(isSignUpMode ? "Créer un compte" : "Connexion")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 30)
                    
                    // Formulaire
                    VStack(spacing: 20) {
                        // Email
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        // Mot de passe
                        SecureField("Mot de passe", text: $password)
                            .textFieldStyle(RoundedTextFieldStyle())
                        
                        // SYNTAXE DU COURS: if/else pour afficher conditionnellement
                        if isSignUpMode {
                            SecureField("Confirmer le mot de passe", text: $confirmPassword)
                                .textFieldStyle(RoundedTextFieldStyle())
                        }
                        
                        // Message d'erreur
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Bouton principal
                        Button(action: handleAuthentication) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isSignUpMode ? "S'inscrire" : "Se connecter")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                        .disabled(isLoading)
                        
                        // Toggle entre modes
                        Button(action: {
                            withAnimation {
                                isSignUpMode.toggle()
                                errorMessage = ""
                            }
                        }) {
                            Text(isSignUpMode ? "Déjà un compte? Se connecter" : "Pas de compte? S'inscrire")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Handle Authentication
    private func handleAuthentication() {
        errorMessage = ""
        
        // Validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Veuillez remplir tous les champs"
            return
        }
        
        if isSignUpMode {
            guard password == confirmPassword else {
                errorMessage = "Les mots de passe ne correspondent pas"
                return
            }
            
            guard password.count >= 6 else {
                errorMessage = "Le mot de passe doit contenir au moins 6 caractères"
                return
            }
        }
        
        isLoading = true
        
        if isSignUpMode {
            // S'inscrire
            firebaseManager.signUp(email: email, password: password) { result in
                isLoading = false
                switch result {
                case .success:
                    // Navigation automatique via @Published isAuthenticated
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        } else {
            // Se connecter
            firebaseManager.signIn(email: email, password: password) { result in
                isLoading = false
                switch result {
                case .success:
                    // Navigation automatique
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Custom TextField Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
    }
}

#Preview {
    AuthenticationView()
}
