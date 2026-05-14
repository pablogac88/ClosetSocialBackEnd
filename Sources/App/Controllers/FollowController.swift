import Vapor

struct FollowController: Sendable {
    let service: FollowService

    func follow(_ req: Request) async throws -> HTTPStatus {
        let currentUser = try req.authenticatedUser
        guard let targetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de usuario inválido.")
        }
        guard currentUser.id != targetID else {
            throw Abort(.badRequest, reason: "No puedes seguirte a ti mismo.")
        }
        try await service.follow(followerID: currentUser.id, followingID: targetID, on: req.db)
        return .ok
    }

    func unfollow(_ req: Request) async throws -> HTTPStatus {
        let currentUser = try req.authenticatedUser
        guard let targetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de usuario inválido.")
        }
        try await service.unfollow(followerID: currentUser.id, followingID: targetID, on: req.db)
        return .noContent
    }
}
