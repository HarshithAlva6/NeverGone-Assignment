import Foundation

struct ChatSession: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let createdAt: Date
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case createdAt = "created_at"
        case title
    }
}
