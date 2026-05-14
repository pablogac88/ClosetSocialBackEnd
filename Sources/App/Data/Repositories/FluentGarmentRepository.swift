import Fluent
import Foundation
import Vapor

public struct FluentGarmentRepository: GarmentRepository {
    public init() {}

    public func all(on db: any Database) async throws -> [Garment] {
        try await GarmentModel.query(on: db)
            .with(\.$user)
            .sort(\.$createdAt, .descending)
            .all()
            .map { try $0.toDomain() }
    }

    public func forUser(_ userID: UUID, on db: any Database) async throws -> [Garment] {
        try await GarmentModel.query(on: db)
            .filter(\.$user.$id == userID)
            .sort(\.$createdAt, .descending)
            .all()
            .map { try $0.toDomain() }
    }

    public func forIDs(_ ids: [UUID], userID: UUID, on db: any Database) async throws -> [Garment] {
        try await GarmentModel.query(on: db)
            .filter(\.$id ~~ ids)
            .filter(\.$user.$id == userID)
            .all()
            .map { try $0.toDomain() }
    }

    public func countForUser(_ userID: UUID, on db: any Database) async throws -> Int {
        try await GarmentModel.query(on: db)
            .filter(\.$user.$id == userID)
            .count()
    }

    public func create(
        userID: UUID,
        name: String,
        brand: String,
        category: String,
        color: String,
        imageURL: String?,
        on db: any Database
    ) async throws -> Garment {
        let model = GarmentModel(
            name: name,
            brand: brand,
            category: category,
            color: color,
            imageURL: imageURL,
            userID: userID
        )
        try await model.create(on: db)
        return try model.toDomain()
    }

    public func exists(id: UUID, userID: UUID, on db: any Database) async throws -> Bool {
        try await GarmentModel.query(on: db)
            .filter(\.$id == id)
            .filter(\.$user.$id == userID)
            .first() != nil
    }

    public func delete(id: UUID, userID: UUID, on db: any Database) async throws {
        guard let model = try await GarmentModel.query(on: db)
            .filter(\.$id == id)
            .filter(\.$user.$id == userID)
            .first()
        else {
            throw Abort(.notFound, reason: "Prenda no encontrada.")
        }
        try await model.delete(on: db)
    }

    public func countInOutfits(id: UUID, on db: any Database) async throws -> Int {
        try await OutfitItemModel.query(on: db)
            .filter(\.$garment.$id == id)
            .count()
    }
}
