import Fluent
import Foundation
import Vapor

public struct ProfileService: Sendable {
    let garments: any GarmentRepository
    let follows: FollowService

    init(garments: any GarmentRepository, follows: FollowService) {
        self.garments = garments
        self.follows = follows
    }

    public func profile(for user: User, on db: any Database) async throws -> Profile {
        async let closetCount = garments.countForUser(user.id, on: db)
        async let outfitCount = OutfitModel.query(on: db)
            .filter(\.$user.$id == user.id)
            .count()
        async let postsCount = PostModel.query(on: db)
            .filter(\.$user.$id == user.id)
            .count()
        async let followerCount = follows.followerCount(for: user.id, on: db)
        async let followingCount = follows.followingCount(for: user.id, on: db)
        return try await Profile(
            user: user,
            closetCount: closetCount,
            outfitCount: outfitCount,
            postsCount: postsCount,
            followerCount: followerCount,
            followingCount: followingCount
        )
    }

    func publicProfile(
        userID: UUID,
        currentUser: User,
        on db: any Database
    ) async throws -> PublicProfileResponseDTO {
        guard let userModel = try await UserModel.find(userID, on: db) else {
            throw Abort(.notFound, reason: "Usuario no encontrado.")
        }
        let profileUser = try userModel.toDomain()
        let closetCount = try await garments.countForUser(userID, on: db)
        let outfitCount = try await OutfitModel.query(on: db)
            .filter(\.$user.$id == userID)
            .count()
        let postModels = try await PostModel.query(on: db)
            .filter(\.$user.$id == userID)
            .sort(\.$createdAt, .descending)
            .all()

        var recentPosts: [FeedPostResponseDTO] = []
        for postModel in postModels {
            if let feedPost = try await FeedPostBuilder.build(from: postModel, currentUser: currentUser, on: db) {
                recentPosts.append(feedPost.toResponse())
            }
        }

        async let followerCount = follows.followerCount(for: userID, on: db)
        async let followingCount = follows.followingCount(for: userID, on: db)
        async let isFollowing = follows.isFollowing(followerID: currentUser.id, followingID: userID, on: db)

        return try await PublicProfileResponseDTO(
            user: profileUser.toPublicDTO(),
            closetCount: closetCount,
            outfitCount: outfitCount,
            postsCount: postModels.count,
            recentPosts: recentPosts,
            followerCount: followerCount,
            followingCount: followingCount,
            isFollowing: isFollowing
        )
    }
}
