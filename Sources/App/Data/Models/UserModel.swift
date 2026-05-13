import Fluent
import Foundation

final class UserModel: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "display_name")
    var displayName: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @OptionalField(key: "avatar_url")
    var avatarURL: String?

    @OptionalField(key: "bio")
    var bio: String?

    @Children(for: \.$user)
    var garments: [GarmentModel]

    @Children(for: \.$user)
    var outfits: [OutfitModel]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        username: String,
        displayName: String,
        email: String,
        passwordHash: String,
        avatarURL: String?
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.passwordHash = passwordHash
        self.avatarURL = avatarURL
    }
}
