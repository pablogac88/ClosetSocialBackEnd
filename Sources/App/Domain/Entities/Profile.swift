import Foundation

public struct Profile: Sendable, Hashable {
    public let user: User
    public let closetCount: Int
    public let outfitCount: Int
    public let postsCount: Int
    public let followerCount: Int
    public let followingCount: Int

    public init(
        user: User,
        closetCount: Int,
        outfitCount: Int,
        postsCount: Int,
        followerCount: Int,
        followingCount: Int
    ) {
        self.user = user
        self.closetCount = closetCount
        self.outfitCount = outfitCount
        self.postsCount = postsCount
        self.followerCount = followerCount
        self.followingCount = followingCount
    }
}
