import Fluent

struct CreateBrandMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(BrandModel.schema)
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "name")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(BrandModel.schema).delete()
    }
}
