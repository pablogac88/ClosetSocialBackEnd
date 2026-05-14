import Fluent
import Foundation
import Vapor

public struct ProfileService: Sendable {
    let garments: any GarmentRepository
    let follows: FollowService
    let users: any UserRepository

    init(garments: any GarmentRepository, follows: FollowService, users: any UserRepository) {
        self.garments = garments
        self.follows = follows
        self.users = users
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

    func updateProfile(
        user: User,
        request: UpdateProfileRequestDTO,
        on db: any Database
    ) async throws -> Profile {
        let trimmedName = request.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw Abort(.unprocessableEntity, reason: "El nombre no puede estar vacío.")
        }
        if let bio = request.bio, bio.count > 160 {
            throw Abort(.unprocessableEntity, reason: "La bio no puede superar los 160 caracteres.")
        }
        if let urlString = request.avatarURL, !urlString.isEmpty, URL(string: urlString) == nil {
            throw Abort(.unprocessableEntity, reason: "La URL del avatar no es válida.")
        }
        let normalizedAvatarURL = request.avatarURL.flatMap { $0.isEmpty ? nil : $0 }
        let updatedUser = try await users.update(
            id: user.id,
            displayName: trimmedName,
            bio: request.bio.flatMap { $0.isEmpty ? nil : $0 },
            avatarURL: normalizedAvatarURL,
            on: db
        )
        return try await profile(for: updatedUser, on: db)
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
