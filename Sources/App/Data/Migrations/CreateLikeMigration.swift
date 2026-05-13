import Fluent

struct CreateLikeMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("likes")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("post_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "user_id", "post_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("likes").delete()
    }
}
