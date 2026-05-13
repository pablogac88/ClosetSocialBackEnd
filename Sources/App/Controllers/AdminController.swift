import Vapor

struct AdminController: Sendable {
    let service: AdminDashboardService

    func dashboard(_ req: Request) async throws -> AdminDashboardStatsDTO {
        try await service.stats(on: req.db)
    }
}
