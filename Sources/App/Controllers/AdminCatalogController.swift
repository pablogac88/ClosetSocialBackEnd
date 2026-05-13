import Vapor

struct AdminCatalogController: Sendable {
    let service: AdminCatalogService

    func garmentTypes(_ req: Request) async throws -> [AdminCatalogItemDTO] {
        try await service.garmentTypes(on: req.db)
    }

    func createGarmentType(_ req: Request) async throws -> AdminCatalogItemDTO {
        let body = try req.content.decode(AdminCatalogMutationRequestDTO.self)
        return try await service.createGarmentType(name: body.name, on: req.db)
    }

    func updateGarmentType(_ req: Request) async throws -> AdminCatalogItemDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de tipo de prenda inválido.")
        }
        let body = try req.content.decode(AdminCatalogMutationRequestDTO.self)
        return try await service.updateGarmentType(id: id, name: body.name, on: req.db)
    }

    func deleteGarmentType(_ req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de tipo de prenda inválido.")
        }
        try await service.deleteGarmentType(id: id, on: req.db)
        return .noContent
    }

    func brands(_ req: Request) async throws -> [AdminCatalogItemDTO] {
        try await service.brands(on: req.db)
    }

    func createBrand(_ req: Request) async throws -> AdminCatalogItemDTO {
        let body = try req.content.decode(AdminCatalogMutationRequestDTO.self)
        return try await service.createBrand(name: body.name, on: req.db)
    }

    func updateBrand(_ req: Request) async throws -> AdminCatalogItemDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de marca inválido.")
        }
        let body = try req.content.decode(AdminCatalogMutationRequestDTO.self)
        return try await service.updateBrand(id: id, name: body.name, on: req.db)
    }

    func deleteBrand(_ req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de marca inválido.")
        }
        try await service.deleteBrand(id: id, on: req.db)
        return .noContent
    }
}
