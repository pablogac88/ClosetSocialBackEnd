import Fluent
import Foundation
import Vapor

public struct ProfileService: Sendable {
    let garments: any GarmentRepository

    public init(garments: any GarmentRepository) {
        self.garments = garments
    }

    public func profile(for user: User, on db: any Database) async throws -> Profile {
        let closetCount = try await garments.countForUser(user.id, on: db)
        let outfitCount = try await OutfitModel.query(on: db)
            .filter(\.$user.$id == user.id)
            .count()
        let postsCount = try await PostModel.query(on: db)
            .filter(\.$user.$id == user.id)
            .count()
        return Profile(
            user: user,
            closetCount: closetCount,
            outfitCount: outfitCount,
            postsCount: postsCount
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

        return PublicProfileResponseDTO(
            user: profileUser.toPublicDTO(),
            closetCount: closetCount,
            outfitCount: outfitCount,
            postsCount: postModels.count,
            recentPosts: recentPosts
        )
    }
}
