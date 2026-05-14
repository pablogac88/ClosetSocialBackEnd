import Fluent

struct CreateNotificationMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("notifications")
            .id()
            .field("recipient_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("actor_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("type", .string, .required)
            .field("post_id", .uuid, .references("posts", "id", onDelete: .cascade))
            .field("read_at", .datetime)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("notifications").delete()
    }
}
