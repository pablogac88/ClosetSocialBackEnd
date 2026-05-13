import Fluent
import Foundation

final class LikeModel: Model, @unchecked Sendable {
    static let schema = "likes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: UserModel

    @Parent(key: "post_id")
    var post: PostModel

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(userID: UUID, postID: UUID) {
        self.$user.id = userID
        self.$post.id = postID
    }
}
