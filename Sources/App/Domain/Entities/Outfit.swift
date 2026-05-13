import Foundation

public struct Outfit: Sendable, Hashable {
    public let id: UUID
    public let ownerId: UUID
    public let title: String?
    public let note: String?
    public let createdAt: Date

    public init(
        id: UUID,
        ownerId: UUID,
        title: String?,
        note: String?,
        createdAt: Date
    ) {
        self.id = id
        self.ownerId = ownerId
        self.title = title
        self.note = note
        self.createdAt = createdAt
    }
}
