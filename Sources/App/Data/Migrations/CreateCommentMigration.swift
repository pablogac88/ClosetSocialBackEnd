import Fluent

struct CreateCommentMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("comments")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("post_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("text", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("comments").delete()
    }
}
