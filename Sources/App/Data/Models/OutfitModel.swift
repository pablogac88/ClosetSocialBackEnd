import Fluent
import Foundation

final class OutfitModel: Model, @unchecked Sendable {
    static let schema = "outfits"

    @ID(key: .id)
    var id: UUID?

    @OptionalField(key: "title")
    var title: String?

    @OptionalField(key: "note")
    var note: String?

    @Parent(key: "user_id")
    var user: UserModel

    @Children(for: \.$outfit)
    var items: [OutfitItemModel]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        title: String?,
        note: String?,
        userID: UUID
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.$user.id = userID
    }
}
