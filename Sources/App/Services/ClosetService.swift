import Fluent
import Foundation

public struct ClosetService: Sendable {
    let garments: any GarmentRepository

    public init(garments: any GarmentRepository) {
        self.garments = garments
    }

    public func closet(for user: User, on db: any Database) async throws -> [Garment] {
        try await garments.forUser(user.id, on: db)
    }

    public func createGarment(
        for user: User,
        name: String,
        brand: String,
        category: String,
        color: String,
        on db: any Database
    ) async throws -> Garment {
        try await garments.create(
            userID: user.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color.trimmingCharacters(in: .whitespacesAndNewlines),
            on: db
        )
    }
}
