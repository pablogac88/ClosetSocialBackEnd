import Fluent

struct CreateGarmentTypeMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(GarmentTypeModel.schema)
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "name")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(GarmentTypeModel.schema).delete()
    }
}
