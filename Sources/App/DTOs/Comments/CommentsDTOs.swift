import Foundation
import Vapor

struct CreateCommentRequestDTO: Content, Sendable {
    let text: String
}

struct CommentResponseDTO: Content, Sendable {
    let id: UUID
    let author: PublicUserDTO
    let text: String
    let createdAt: Date
}

struct CommentsResponseDTO: Content, Sendable {
    let items: [CommentResponseDTO]
}
