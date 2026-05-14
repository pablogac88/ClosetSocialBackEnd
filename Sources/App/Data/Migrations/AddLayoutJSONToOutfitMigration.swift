import Fluent

struct AddLayoutJSONToOutfitMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(OutfitModel.schema)
            .field("layout_json", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(OutfitModel.schema)
            .deleteField("layout_json")
            .update()
    }
}
