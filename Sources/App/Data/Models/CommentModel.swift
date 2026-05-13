import Fluent
import Foundation

final class CommentModel: Model, @unchecked Sendable {
    static let schema = "comments"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: UserModel

    @Parent(key: "post_id")
    var post: PostModel

    @Field(key: "text")
    var text: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(userID: UUID, postID: UUID, text: String) {
        self.$user.id = userID
        self.$post.id = postID
        self.text = text
    }
}
