import Fluent
import Foundation
import Vapor

struct AdminCatalogService: Sendable {
    func garmentTypes(on db: any Database) async throws -> [AdminCatalogItemDTO] {
        let models = try await GarmentTypeModel.query(on: db)
            .sort(\.$name, .ascending)
            .all()
        return try models.map { try $0.toAdminCatalogDTO() }
    }

    func createGarmentType(name: String, on db: any Database) async throws -> AdminCatalogItemDTO {
        let sanitizedName = try normalize(name)
        try await ensureGarmentTypeNameAvailable(sanitizedName, excluding: nil, on: db)

        let model = GarmentTypeModel(name: sanitizedName)
        try await model.create(on: db)
        return try model.toAdminCatalogDTO()
    }

    func updateGarmentType(id: UUID, name: String, on db: any Database) async throws -> AdminCatalogItemDTO {
        guard let model = try await GarmentTypeModel.find(id, on: db) else {
            throw Abort(.notFound, reason: "Tipo de prenda no encontrado.")
        }

        let sanitizedName = try normalize(name)
        try await ensureGarmentTypeNameAvailable(sanitizedName, excluding: id, on: db)

        model.name = sanitizedName
        try await model.update(on: db)
        return try model.toAdminCatalogDTO()
    }

    func deleteGarmentType(id: UUID, on db: any Database) async throws {
        guard let model = try await GarmentTypeModel.find(id, on: db) else {
            throw Abort(.notFound, reason: "Tipo de prenda no encontrado.")
        }
        try await model.delete(on: db)
    }

    func brands(on db: any Database) async throws -> [AdminCatalogItemDTO] {
        let models = try await BrandModel.query(on: db)
            .sort(\.$name, .ascending)
            .all()
        return try models.map { try $0.toAdminCatalogDTO() }
    }

    func createBrand(name: String, on db: any Database) async throws -> AdminCatalogItemDTO {
        let sanitizedName = try normalize(name)
        try await ensureBrandNameAvailable(sanitizedName, excluding: nil, on: db)

        let model = BrandModel(name: sanitizedName)
        try await model.create(on: db)
        return try model.toAdminCatalogDTO()
    }

    func updateBrand(id: UUID, name: String, on db: any Database) async throws -> AdminCatalogItemDTO {
        guard let model = try await BrandModel.find(id, on: db) else {
            throw Abort(.notFound, reason: "Marca no encontrada.")
        }

        let sanitizedName = try normalize(name)
        try await ensureBrandNameAvailable(sanitizedName, excluding: id, on: db)

        model.name = sanitizedName
        try await model.update(on: db)
        return try model.toAdminCatalogDTO()
    }

    func deleteBrand(id: UUID, on db: any Database) async throws {
        guard let model = try await BrandModel.find(id, on: db) else {
            throw Abort(.notFound, reason: "Marca no encontrada.")
        }
        try await model.delete(on: db)
    }

    private func normalize(_ name: String) throws -> String {
        let sanitizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedName.isEmpty else {
            throw Abort(.badRequest, reason: "El nombre no puede estar vacío.")
        }
        return sanitizedName
    }

    private func ensureGarmentTypeNameAvailable(
        _ name: String,
        excluding id: UUID?,
        on db: any Database
    ) async throws {
        let models = try await GarmentTypeModel.query(on: db).all()
        let duplicateExists = models.contains { model in
            model.name.caseInsensitiveCompare(name) == .orderedSame && model.id != id
        }

        guard !duplicateExists else {
            throw Abort(.conflict, reason: "Ya existe un tipo de prenda con ese nombre.")
        }
    }

    private func ensureBrandNameAvailable(
        _ name: String,
        excluding id: UUID?,
        on db: any Database
    ) async throws {
        let models = try await BrandModel.query(on: db).all()
        let duplicateExists = models.contains { model in
            model.name.caseInsensitiveCompare(name) == .orderedSame && model.id != id
        }

        guard !duplicateExists else {
            throw Abort(.conflict, reason: "Ya existe una marca con ese nombre.")
        }
    }
}
