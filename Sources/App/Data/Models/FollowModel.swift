import Fluent
import Foundation

final class FollowModel: Model, @unchecked Sendable {
    static let schema = "follows"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "follower_id")
    var follower: UserModel

    @Parent(key: "following_id")
    var following: UserModel

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(followerID: UUID, followingID: UUID) {
        self.$follower.id = followerID
        self.$following.id = followingID
    }
}
