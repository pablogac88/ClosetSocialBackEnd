import Fluent
import Foundation
import Vapor

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
        brand: String?,
        category: String,
        color: String,
        imageURL: String?,
        on db: any Database
    ) async throws -> Garment {
        try await garments.create(
            userID: user.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            brand: brand?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            category: category.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color.trimmingCharacters(in: .whitespacesAndNewlines),
            imageURL: imageURL?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            on: db
        )
    }

    public func deleteGarment(id: UUID, for user: User, on db: any Database) async throws {
        guard try await garments.exists(id: id, userID: user.id, on: db) else {
            throw Abort(.notFound, reason: "Prenda no encontrada.")
        }
        let count = try await garments.countInOutfits(id: id, on: db)
        guard count == 0 else {
            let suffix = count == 1 ? "1 outfit" : "\(count) outfits"
            throw Abort(
                .conflict,
                reason: "Esta prenda pertenece a \(suffix). Elimínala primero de los outfits antes de borrarla del armario."
            )
        }
        try await garments.delete(id: id, userID: user.id, on: db)
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
