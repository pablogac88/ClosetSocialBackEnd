import Foundation
import Vapor

struct ProfileResponseDTO: Content, Sendable {
    let user: PublicUserDTO
    let closetCount: Int
    let outfitCount: Int
    let postsCount: Int
    let followerCount: Int
    let followingCount: Int
}

struct PublicProfileResponseDTO: Content, Sendable {
    let user: PublicUserDTO
    let closetCount: Int
    let outfitCount: Int
    let postsCount: Int
    let recentPosts: [FeedPostResponseDTO]
    let followerCount: Int
    let followingCount: Int
    let isFollowing: Bool
}

extension Profile {
    func toResponse() -> ProfileResponseDTO {
        ProfileResponseDTO(
            user: user.toPublicDTO(),
            closetCount: closetCount,
            outfitCount: outfitCount,
            postsCount: postsCount,
            followerCount: followerCount,
            followingCount: followingCount
        )
    }
}
