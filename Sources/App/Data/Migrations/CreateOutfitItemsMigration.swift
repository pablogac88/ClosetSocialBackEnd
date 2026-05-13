import Fluent

struct CreateOutfitItemsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(OutfitItemModel.schema)
            .id()
            .field("outfit_id", .uuid, .required, .references(OutfitModel.schema, .id, onDelete: .cascade))
            .field("garment_id", .uuid, .required, .references(GarmentModel.schema, .id, onDelete: .cascade))
            .field("position", .int, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(OutfitItemModel.schema).delete()
    }
}
