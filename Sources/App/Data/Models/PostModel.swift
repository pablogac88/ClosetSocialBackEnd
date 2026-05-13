import Fluent
import Foundation

final class PostModel: Model, @unchecked Sendable {
    static let schema = "posts"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: UserModel

    @Field(key: "caption")
    var caption: String

    @OptionalParent(key: "outfit_id")
    var outfit: OutfitModel?

    @OptionalParent(key: "garment_id")
    var garment: GarmentModel?

    @Field(key: "image_urls")
    var imageURLsJSON: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(userID: UUID, caption: String, outfitID: UUID?, garmentID: UUID?, imageURLs: [String]) {
        self.$user.id = userID
        self.caption = caption
        self.$outfit.id = outfitID
        self.$garment.id = garmentID
        let data = (try? JSONEncoder().encode(imageURLs)) ?? Data("[]".utf8)
        self.imageURLsJSON = String(data: data, encoding: .utf8) ?? "[]"
    }

    var imageURLs: [String] {
        (try? JSONDecoder().decode([String].self, from: Data(imageURLsJSON.utf8))) ?? []
    }
}
