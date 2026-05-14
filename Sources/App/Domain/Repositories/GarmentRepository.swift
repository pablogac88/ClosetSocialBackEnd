import Foundation
import Fluent

public protocol GarmentRepository: Sendable {
    func all(on db: any Database) async throws -> [Garment]
    func forUser(_ userID: UUID, on db: any Database) async throws -> [Garment]
    func forIDs(_ ids: [UUID], userID: UUID, on db: any Database) async throws -> [Garment]
    func countForUser(_ userID: UUID, on db: any Database) async throws -> Int
    func create(
        userID: UUID,
        name: String,
        brand: String,
        category: String,
        color: String,
        imageURL: String?,
        on db: any Database
    ) async throws -> Garment
    func exists(id: UUID, userID: UUID, on db: any Database) async throws -> Bool
    func delete(id: UUID, userID: UUID, on db: any Database) async throws
    func countInOutfits(id: UUID, on db: any Database) async throws -> Int
}
