import Fluent
import Foundation
import Vapor

struct OutfitsService: Sendable {
    let garments: any GarmentRepository

    func outfits(for user: User, on db: any Database) async throws -> [OutfitResponseDTO] {
        try await OutfitModel.query(on: db)
            .filter(\.$user.$id == user.id)
            .with(\.$items) { $0.with(\.$garment) }
            .sort(\.$createdAt, .descending)
            .all()
            .map { try $0.toResponseDTO() }
    }

    func createOutfit(
        for user: User,
        title: String?,
        note: String?,
        garmentIDs: [UUID],
        on db: any Database
    ) async throws -> OutfitResponseDTO {
        guard !garmentIDs.isEmpty else {
            throw Abort(.badRequest, reason: "El outfit debe contener al menos una prenda.")
        }

        let found = try await garments.forIDs(garmentIDs, userID: user.id, on: db)
        guard found.count == garmentIDs.count else {
            throw Abort(.forbidden, reason: "Una o más prendas no pertenecen al usuario.")
        }

        // Preserva el orden que envió el cliente usando el índice original.
        let garmentByID = Dictionary(uniqueKeysWithValues: found.map { ($0.id, $0) })
        let orderedGarments = garmentIDs.compactMap { garmentByID[$0] }

        let outfitModel = OutfitModel(
            title: title?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            userID: user.id
        )

        try await db.transaction { tx in
            try await outfitModel.create(on: tx)
            let outfitID = try outfitModel.requireID()
            for (index, garment) in orderedGarments.enumerated() {
                let item = OutfitItemModel(
                    outfitID: outfitID,
                    garmentID: garment.id,
                    position: index
                )
                try await item.create(on: tx)
            }
        }

        return OutfitResponseDTO(
            id: try outfitModel.requireID(),
            title: outfitModel.title,
            note: outfitModel.note,
            garments: orderedGarments.map { $0.toResponse() },
            createdAt: outfitModel.createdAt ?? .now
        )
    }

    func deleteOutfit(id: UUID, for user: User, on db: any Database) async throws {
        guard let outfit = try await OutfitModel.query(on: db)
            .filter(\.$id == id)
            .filter(\.$user.$id == user.id)
            .first()
        else {
            throw Abort(.notFound, reason: "Outfit no encontrado.")
        }
        try await db.transaction { tx in
            try await OutfitItemModel.query(on: tx)
                .filter(\.$outfit.$id == id)
                .delete()
            try await outfit.delete(on: tx)
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
