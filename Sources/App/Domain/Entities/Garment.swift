import Foundation

public struct Garment: Sendable, Hashable {
    public let id: UUID
    public let name: String
    public let brand: String
    public let category: String
    public let color: String
    public let imageURL: String?
    public let userID: UUID
    public let createdAt: Date

    public init(
        id: UUID,
        name: String,
        brand: String,
        category: String,
        color: String,
        imageURL: String?,
        userID: UUID,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.color = color
        self.imageURL = imageURL
        self.userID = userID
        self.createdAt = createdAt
    }
}
