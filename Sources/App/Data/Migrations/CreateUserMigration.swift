import Fluent

struct CreateUserMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserModel.schema)
            .id()
            .field("username", .string, .required)
            .field("display_name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("avatar_url", .string)
            .field("created_at", .datetime)
            .unique(on: "username")
            .unique(on: "email")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UserModel.schema).delete()
    }
}
