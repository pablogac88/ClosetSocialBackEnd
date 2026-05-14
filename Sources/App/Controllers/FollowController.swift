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

    func followers(_ req: Request) async throws -> [PublicUserDTO] {
        _ = try req.authenticatedUser
        guard let targetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de usuario inválido.")
        }
        let users = try await service.fetchFollowers(for: targetID, on: req.db)
        return users.map { $0.toPublicDTO() }
    }

    func following(_ req: Request) async throws -> [PublicUserDTO] {
        _ = try req.authenticatedUser
        guard let targetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de usuario inválido.")
        }
        let users = try await service.fetchFollowing(for: targetID, on: req.db)
        return users.map { $0.toPublicDTO() }
    }
}
