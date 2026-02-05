import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let lastActive: Date?
    let handle: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastActive = "last_active"
        case handle
    }
}
