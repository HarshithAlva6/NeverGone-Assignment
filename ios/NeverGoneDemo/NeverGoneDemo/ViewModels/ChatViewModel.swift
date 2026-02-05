import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage = ""
    @Published var isStreaming = false
    @Published var currentStreamingResponse = ""
    @Published var errorMessage: String?
    
    @Published var isSummarizing = false
    @Published var showSummaryAlert = false
    @Published var lastSummary: String = ""
    
    let session: ChatSession
    private let chatService = ChatService()
    private var streamingTask: Task<Void, Never>?
    
    init(session: ChatSession) {
        self.session = session
    }
    
    func loadMessages() async {
        errorMessage = nil
        do {
            messages = try await chatService.fetchMessages(sessionId: session.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMsgContent = inputMessage
        inputMessage = ""
        errorMessage = nil
        
        let pendingUserMessage = ChatMessage(
            id: UUID(),
            sessionId: session.id,
            authorId: UUID(), 
            content: userMsgContent,
            role: .user,
            createdAt: Date()
        )
        messages.append(pendingUserMessage)
        
        isStreaming = true
        currentStreamingResponse = ""
        
        streamingTask = Task {
            do {
                for try await chunk in chatService.streamMessage(sessionId: session.id, message: userMsgContent) {
                    await MainActor.run {
                        currentStreamingResponse += chunk
                    }
                }
                
                let assistantMessage = ChatMessage(
                    id: UUID(),
                    sessionId: session.id,
                    authorId: UUID(),
                    content: currentStreamingResponse,
                    role: .assistant,
                    createdAt: Date()
                )
                messages.append(assistantMessage)
                currentStreamingResponse = ""
                isStreaming = false
                
            } catch {
                if !Task.isCancelled {
                   errorMessage = "Error: \(error.localizedDescription)"
                }
                isStreaming = false
            }
        }
    }
    
    func cancelStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
        isStreaming = false
    }
    
    func summarizeSession() async {
        isSummarizing = true
        errorMessage = nil
        do {
            lastSummary = try await chatService.summarizeSession(sessionId: session.id)
            showSummaryAlert = true
        } catch {
            errorMessage = "Failed to summarize: \(error.localizedDescription)"
        }
        isSummarizing = false
    }
}
