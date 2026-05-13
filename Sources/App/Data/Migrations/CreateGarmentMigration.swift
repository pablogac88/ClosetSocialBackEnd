import Fluent

struct CreateGarmentMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(GarmentModel.schema)
            .id()
            .field("name", .string, .required)
            .field("brand", .string, .required)
            .field("category", .string, .required)
            .field("color", .string, .required)
            .field("user_id", .uuid, .required, .references(UserModel.schema, .id, onDelete: .cascade))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(GarmentModel.schema).delete()
    }
}
