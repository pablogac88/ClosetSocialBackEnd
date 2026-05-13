import Fluent

struct CreateSessionMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(SessionModel.schema)
            .id()
            .field("token", .string, .required)
            .field("user_id", .uuid, .required, .references(UserModel.schema, .id, onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "token")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(SessionModel.schema).delete()
    }
}
