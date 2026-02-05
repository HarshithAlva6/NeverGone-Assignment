import Foundation
import Supabase

class ChatService {
    private let client = SupabaseService.shared.client
    
    // MARK: - Sessions
    
    func fetchSessions() async throws -> [ChatSession] {
        try await client
            .from("chat_sessions")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func createSession(title: String = "New Chat") async throws -> ChatSession {
        return try await client
            .from("chat_sessions")
            .insert(["title": title])
            .select()
            .single()
            .execute()
            .value
    }
    
    // MARK: - Messages
    
    func fetchMessages(sessionId: UUID) async throws -> [ChatMessage] {
        try await client
            .from("chat_messages")
            .select()
            .eq("session_id", value: sessionId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    
    // MARK: - Streaming
    
    func streamMessage(sessionId: UUID, message: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = URLRequest(url: URL(string: "\(Constants.supabaseUrl)/functions/v1/chat_stream")!)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    guard let session = AuthService.shared.session else {
                         throw NSError(domain: "ChatService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No logged in user found."])
                    }
                    
                    let token = session.accessToken
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "X-Supabase-Auth")

                    let body: [String: String] = [
                        "session_id": sessionId.uuidString,
                        "message": message,
                        "auth_token": token
                    ]
                    
                    request.httpBody = try JSONEncoder().encode(body)
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                        throw NSError(domain: "ChatService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
                    }
                    
                    for try await byte in bytes {
                         if Task.isCancelled { break }
                         let data = Data([byte])
                         if let char = String(data: data, encoding: .utf8) {
                             continuation.yield(char)
                         }
                    }
                    
                    continuation.finish()
                } catch {
                    if !Task.isCancelled {
                        continuation.finish(throwing: error)
                    } else {
                        continuation.finish()
                    }
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    // MARK: - Memory
    
    func summarizeSession(sessionId: UUID) async throws -> String {
        guard let session = await AuthService.shared.session else {
             throw NSError(domain: "ChatService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No logged in user found."])
        }
        
        let token = session.accessToken
        var request = URLRequest(url: URL(string: "\(Constants.supabaseUrl)/functions/v1/summarize_memory")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = [
            "session_id": sessionId.uuidString,
            "auth_token": token
        ]
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
             let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
             throw NSError(domain: "ChatService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMsg)"])
        }
        
        struct SummarizeResponse: Decodable {
            let success: Bool
            let summary: String?
        }
        
        let decoded = try JSONDecoder().decode(SummarizeResponse.self, from: data)
        return decoded.summary ?? "No summary returned."
    }
}
