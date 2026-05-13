import Foundation

public struct Profile: Sendable, Hashable {
    public let user: User
    public let closetCount: Int
    public let outfitCount: Int
    public let postsCount: Int

    public init(user: User, closetCount: Int, outfitCount: Int, postsCount: Int) {
        self.user = user
        self.closetCount = closetCount
        self.outfitCount = outfitCount
        self.postsCount = postsCount
    }
}
