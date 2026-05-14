import Fluent
import Foundation

final class NotificationModel: Model, @unchecked Sendable {
    static let schema = "notifications"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "recipient_id")
    var recipient: UserModel

    @Parent(key: "actor_id")
    var actor: UserModel

    @Field(key: "type")
    var type: String

    @OptionalParent(key: "post_id")
    var post: PostModel?

    @OptionalField(key: "read_at")
    var readAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(recipientID: UUID, actorID: UUID, type: String, postID: UUID?) {
        self.$recipient.id = recipientID
        self.$actor.id = actorID
        self.type = type
        self.$post.id = postID
    }
}
