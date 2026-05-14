import Fluent
import Foundation

struct SearchService: Sendable {
    // TODO: Product/Privacy — When visibility settings or follower graphs are implemented,
    // this service must filter results to only return content visible to the authenticated
    // user (e.g. private profiles, private garments/outfits).
    private static let limit = 20

    func search(query q: String, on db: any Database) async throws -> SearchResultsDTO {
        async let users = searchUsers(q, on: db)
        async let garments = searchGarments(q, on: db)
        async let outfits = searchOutfits(q, on: db)
        return try await SearchResultsDTO(users: users, garments: garments, outfits: outfits)
    }

    // MARK: Users

    private func searchUsers(_ q: String, on db: any Database) async throws -> [PublicUserDTO] {
        let pattern = "%\(q)%"
        return try await UserModel.query(on: db)
            .group(.or) { group in
                group.filter(\.$username, .custom("LIKE"), pattern)
                group.filter(\.$displayName, .custom("LIKE"), pattern)
            }
            .sort(\.$createdAt, .descending)
            .limit(Self.limit)
            .all()
            .compactMap { try? $0.toDomain().toPublicDTO() }
    }

    // MARK: Garments

    private func searchGarments(_ q: String, on db: any Database) async throws -> [GarmentResponseDTO] {
        let pattern = "%\(q)%"
        return try await GarmentModel.query(on: db)
            .group(.or) { group in
                group.filter(\.$name, .custom("LIKE"), pattern)
                group.filter(\.$brand, .custom("LIKE"), pattern)
                group.filter(\.$category, .custom("LIKE"), pattern)
            }
            .sort(\.$createdAt, .descending)
            .limit(Self.limit)
            .all()
            .compactMap { try? $0.toDomain().toResponse() }
    }

    // MARK: Outfits

    // TODO: Performance — Outfit search loads all rows and filters in Swift because Fluent's
    // typed filter API doesn't cleanly support LIKE on @OptionalField<String>.
    // Replace with a raw SQLKit query (or a generated column / FTS5 index) when row count grows.
    private func searchOutfits(_ q: String, on db: any Database) async throws -> [OutfitResponseDTO] {
        let lowQ = q.lowercased()
        let all = try await OutfitModel.query(on: db)
            .with(\.$items) { $0.with(\.$garment) }
            .sort(\.$createdAt, .descending)
            .all()
        return all
            .filter {
                ($0.title?.lowercased().contains(lowQ) ?? false) ||
                ($0.note?.lowercased().contains(lowQ) ?? false)
            }
            .prefix(Self.limit)
            .compactMap { try? $0.toResponseDTO() }
    }
}
