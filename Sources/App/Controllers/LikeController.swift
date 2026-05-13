import Vapor

struct LikeController: Sendable {
    let service: LikeService

    func like(_ req: Request) async throws -> HTTPStatus {
        let user = try req.authenticatedUser
        guard let postID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de post inválido.")
        }
        try await service.like(for: user, postID: postID, on: req.db)
        return .ok
    }

    func unlike(_ req: Request) async throws -> HTTPStatus {
        let user = try req.authenticatedUser
        guard let postID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de post inválido.")
        }
        try await service.unlike(for: user, postID: postID, on: req.db)
        return .ok
    }
}
