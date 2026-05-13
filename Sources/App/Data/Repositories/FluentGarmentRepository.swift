import Fluent
import Foundation

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
        on db: any Database
    ) async throws -> Garment {
        let model = GarmentModel(
            name: name,
            brand: brand,
            category: category,
            color: color,
            userID: userID
        )
        try await model.create(on: db)
        return try model.toDomain()
    }
}
