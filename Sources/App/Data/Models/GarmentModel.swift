import Fluent
import Foundation

final class GarmentModel: Model, @unchecked Sendable {
    static let schema = "garments"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "brand")
    var brand: String

    @Field(key: "category")
    var category: String

    @Field(key: "color")
    var color: String

    @OptionalField(key: "image_url")
    var imageURL: String?

    @Parent(key: "user_id")
    var user: UserModel

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        brand: String,
        category: String,
        color: String,
        imageURL: String? = nil,
        userID: UUID
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.color = color
        self.imageURL = imageURL
        self.$user.id = userID
    }
}
