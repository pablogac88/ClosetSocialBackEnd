import Vapor

struct ProfileController: Sendable {
    let service: ProfileService

    func show(_ req: Request) async throws -> ProfileResponseDTO {
        let user = try req.authenticatedUser
        let profile = try await service.profile(for: user, on: req.db)
        return profile.toResponse()
    }

    func publicProfile(_ req: Request) async throws -> PublicProfileResponseDTO {
        let currentUser = try req.authenticatedUser
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de usuario inválido.")
        }
        return try await service.publicProfile(userID: userID, currentUser: currentUser, on: req.db)
    }
}
