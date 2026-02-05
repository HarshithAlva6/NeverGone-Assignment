import Foundation
import Supabase
import Combine

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    private let client = SupabaseService.shared.client
    
    @Published var session: Session?
    @Published var currentUser: User?
    
    // Auth state listener
    init() {
        Task {
            for await state in client.auth.authStateChanges {
                self.session = state.session
                self.currentUser = state.session?.user
            }
        }
    }

    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
}
