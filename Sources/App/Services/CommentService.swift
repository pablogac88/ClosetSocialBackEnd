import Fluent
import Foundation
import Vapor

struct CommentService: Sendable {

    func createComment(
        for user: User,
        postID: UUID,
        text: String,
        on db: any Database
    ) async throws -> CommentResponseDTO {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw Abort(.badRequest, reason: "El comentario no puede estar vacío.")
        }
        guard try await PostModel.find(postID, on: db) != nil else {
            throw Abort(.notFound, reason: "Post no encontrado.")
        }
        let comment = CommentModel(userID: user.id, postID: postID, text: trimmed)
        try await comment.create(on: db)
        return CommentResponseDTO(
            id: try comment.requireID(),
            author: user.toPublicDTO(),
            text: trimmed,
            createdAt: comment.createdAt ?? .now
        )
    }

    func fetchComments(postID: UUID, on db: any Database) async throws -> CommentsResponseDTO {
        guard try await PostModel.find(postID, on: db) != nil else {
            throw Abort(.notFound, reason: "Post no encontrado.")
        }
        let models = try await CommentModel.query(on: db)
            .filter(\.$post.$id == postID)
            .with(\.$user)
            .sort(\.$createdAt, .ascending)
            .all()
        let items = try models.map { model in
            CommentResponseDTO(
                id: try model.requireID(),
                author: try model.user.toDomain().toPublicDTO(),
                text: model.text,
                createdAt: model.createdAt ?? .now
            )
        }
        return CommentsResponseDTO(items: items)
    }
}
