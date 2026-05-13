import Fluent

struct AddRoleToUserMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserModel.schema)
            .field("role", .string, .required, .sql(.default(UserRole.user.rawValue)))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UserModel.schema)
            .deleteField("role")
            .update()
    }
}
