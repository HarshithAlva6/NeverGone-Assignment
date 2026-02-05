import Foundation
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let chatService = ChatService()
    
    func loadSessions() async {
        isLoading = true
        errorMessage = nil
        do {
            sessions = try await chatService.fetchSessions()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func createSession() async {
        isLoading = true
        do {
            let sessionNumber = sessions.count + 1
            let title = "Chat #\(sessionNumber)"
            let session = try await chatService.createSession(title: title)
            sessions.insert(session, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signOut() async {
        try? await AuthService.shared.signOut()
    }
}
