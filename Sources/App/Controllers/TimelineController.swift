import Vapor

struct TimelineController: Sendable {
    let service: TimelineService

    func index(_ req: Request) async throws -> TimelineResponseDTO {
        let user = try req.authenticatedUser
        let posts = try await service.timeline(for: user, on: req.db)
        return TimelineResponseDTO(items: posts.map { $0.toResponse() })
    }
}
