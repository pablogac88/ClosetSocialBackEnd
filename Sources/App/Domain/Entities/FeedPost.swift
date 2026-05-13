import Foundation

public enum FeedPostKind: String, Sendable, Hashable {
    case outfit
    case garment
    case purchase
    case post
}

public struct FeedPost: Sendable, Hashable {
    public let id: UUID
    public let author: User
    public let kind: FeedPostKind
    public let caption: String
    public let garment: Garment?
    public let outfit: OutfitResponseDTO?
    public let imageURLs: [String]
    public let likesCount: Int
    public let isLikedByCurrentUser: Bool
    public let commentsCount: Int
    public let isReal: Bool
    public let createdAt: Date

    public init(
        id: UUID,
        author: User,
        kind: FeedPostKind,
        caption: String,
        garment: Garment?,
        outfit: OutfitResponseDTO?,
        imageURLs: [String],
        likesCount: Int,
        isLikedByCurrentUser: Bool,
        commentsCount: Int,
        isReal: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.author = author
        self.kind = kind
        self.caption = caption
        self.garment = garment
        self.outfit = outfit
        self.imageURLs = imageURLs
        self.likesCount = likesCount
        self.isLikedByCurrentUser = isLikedByCurrentUser
        self.commentsCount = commentsCount
        self.isReal = isReal
        self.createdAt = createdAt
    }

    public static func == (lhs: FeedPost, rhs: FeedPost) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
