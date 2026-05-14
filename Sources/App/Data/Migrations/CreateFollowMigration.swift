import Fluent

struct CreateFollowMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("follows")
            .id()
            .field("follower_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("following_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "follower_id", "following_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("follows").delete()
    }
}
