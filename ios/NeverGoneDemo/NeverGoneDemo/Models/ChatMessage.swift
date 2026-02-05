import Foundation

struct ChatMessage: Codable, Identifiable, Hashable {
    let id: UUID
    let sessionId: UUID
    let authorId: UUID
    let content: String
    let role: MessageRole
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case authorId = "author_id"
        case content
        case role
        case createdAt = "created_at"
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}
