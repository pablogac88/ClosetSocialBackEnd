import Fluent
import Foundation

final class SessionModel: Model, @unchecked Sendable {
    static let schema = "sessions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String

    @Parent(key: "user_id")
    var user: UserModel

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, token: String, userID: UUID) {
        self.id = id
        self.token = token
        self.$user.id = userID
    }
}
