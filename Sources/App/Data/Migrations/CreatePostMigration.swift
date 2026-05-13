import Fluent

struct CreatePostMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("posts")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("caption", .string, .required)
            .field("outfit_id", .uuid, .references("outfits", "id", onDelete: .setNull))
            .field("garment_id", .uuid, .references("garments", "id", onDelete: .setNull))
            .field("image_urls", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("posts").delete()
    }
}
