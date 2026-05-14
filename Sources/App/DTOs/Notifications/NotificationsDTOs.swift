import Foundation
import Vapor

struct NotificationResponseDTO: Content, Sendable {
    let id: UUID
    let type: String
    let actor: PublicUserDTO
    let postID: UUID?
    let createdAt: Date
    let readAt: Date?
}
