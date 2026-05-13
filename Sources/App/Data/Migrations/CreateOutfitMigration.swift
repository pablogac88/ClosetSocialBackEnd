import Fluent

struct CreateOutfitMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(OutfitModel.schema)
            .id()
            .field("title", .string)
            .field("note", .string)
            .field("user_id", .uuid, .required, .references(UserModel.schema, .id, onDelete: .cascade))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(OutfitModel.schema).delete()
    }
}
