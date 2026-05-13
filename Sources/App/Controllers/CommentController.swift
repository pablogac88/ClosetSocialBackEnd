import Vapor

struct CommentController: Sendable {
    let service: CommentService

    func create(_ req: Request) async throws -> CommentResponseDTO {
        let user = try req.authenticatedUser
        guard let postID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de post inválido.")
        }
        let body = try req.content.decode(CreateCommentRequestDTO.self)
        return try await service.createComment(for: user, postID: postID, text: body.text, on: req.db)
    }

    func list(_ req: Request) async throws -> CommentsResponseDTO {
        guard let postID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de post inválido.")
        }
        return try await service.fetchComments(postID: postID, on: req.db)
    }
}
