import Fluent

struct AddBioToUserMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .field("bio", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .deleteField("bio")
            .update()
    }
}
