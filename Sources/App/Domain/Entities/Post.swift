import Foundation

public struct Post: Sendable, Hashable {
    public let id: UUID
    public let authorID: UUID
    public let caption: String
    public let outfitID: UUID?
    public let garmentID: UUID?
    public let imageURLs: [String]
    public let createdAt: Date

    public var kind: FeedPostKind {
        if outfitID != nil { return .outfit }
        if garmentID != nil { return .garment }
        return .post
    }
}
