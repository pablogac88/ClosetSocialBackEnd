import Vapor

struct NotificationController: Sendable {
    let service: NotificationService

    func list(_ req: Request) async throws -> [NotificationResponseDTO] {
        let currentUser = try req.authenticatedUser
        return try await service.fetchNotifications(for: currentUser.id, on: req.db)
    }

    func markRead(_ req: Request) async throws -> HTTPStatus {
        let currentUser = try req.authenticatedUser
        guard let notificationID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de notificación inválido.")
        }
        try await service.markRead(id: notificationID, userID: currentUser.id, on: req.db)
        return .ok
    }

    func markAllRead(_ req: Request) async throws -> HTTPStatus {
        let currentUser = try req.authenticatedUser
        try await service.markAllRead(userID: currentUser.id, on: req.db)
        return .ok
    }
}
