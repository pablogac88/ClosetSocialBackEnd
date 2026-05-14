import Fluent

struct AddImageURLToGarmentMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(GarmentModel.schema)
            .field("image_url", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(GarmentModel.schema)
            .deleteField("image_url")
            .update()
    }
}
