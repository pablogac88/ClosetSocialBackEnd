import Vapor

struct ClosetController: Sendable {
    let service: ClosetService

    func index(_ req: Request) async throws -> ClosetResponseDTO {
        let user = try req.authenticatedUser
        let items = try await service.closet(for: user, on: req.db)
        return ClosetResponseDTO(items: items.map { $0.toResponse() })
    }

    func create(_ req: Request) async throws -> GarmentResponseDTO {
        let user = try req.authenticatedUser
        let body = try req.content.decode(CreateGarmentRequestDTO.self)
        let garment = try await service.createGarment(
            for: user,
            name: body.name,
            brand: body.brand,
            category: body.category,
            color: body.color,
            on: req.db
        )
        return garment.toResponse()
    }
}
