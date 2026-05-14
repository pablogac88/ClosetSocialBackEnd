import Fluent
import Foundation

public struct TimelineService: Sendable {
    let garments: any GarmentRepository
    let follows: FollowService

    init(garments: any GarmentRepository, follows: FollowService) {
        self.garments = garments
        self.follows = follows
    }

    /// Personalized feed: own posts + posts from users the current user follows.
    public func timeline(for user: User, on db: any Database) async throws -> [FeedPost] {
        let followedUsers = try await follows.fetchFollowing(for: user.id, on: db)
        let allowedIDs = Set([user.id] + followedUsers.map(\.id))

        let allGarments = try await garments.all(on: db)
        let visibleGarments = allGarments.filter { allowedIDs.contains($0.userID) }

        let garmentPosts = try await composeGarmentPosts(from: visibleGarments, on: db)
        let outfitPosts = try await composeOutfitPosts(allowedIDs: allowedIDs, on: db)
        let realPosts = try await composeRealPosts(for: user, allowedIDs: allowedIDs, on: db)
        return (garmentPosts + outfitPosts + realPosts).sorted { $0.createdAt > $1.createdAt }
    }

    /// Global discovery feed: all users' content. Used by Explore.
    public func globalDiscoveryTimeline(for user: User, on db: any Database) async throws -> [FeedPost] {
        let allGarments = try await garments.all(on: db)
        let garmentPosts = try await composeGarmentPosts(from: allGarments, on: db)
        let outfitPosts = try await composeOutfitPosts(allowedIDs: nil, on: db)
        let realPosts = try await composeRealPosts(for: user, allowedIDs: nil, on: db)
        return (garmentPosts + outfitPosts + realPosts).sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Composers

    private func composeGarmentPosts(from garments: [Garment], on db: any Database) async throws -> [FeedPost] {
        var posts: [FeedPost] = []
        posts.reserveCapacity(garments.count)
        for garment in garments {
            guard let userModel = try await UserModel.find(garment.userID, on: db) else { continue }
            let author = try userModel.toDomain()
            posts.append(
                FeedPost(
                    id: garment.id,
                    author: author,
                    kind: .purchase,
                    caption: "\(author.displayName) ha compartido una compra nueva.",
                    garment: garment,
                    outfit: nil,
                    imageURLs: [],
                    likesCount: 0,
                    isLikedByCurrentUser: false,
                    commentsCount: 0,
                    isReal: false,
                    createdAt: garment.createdAt
                )
            )
        }
        return posts
    }

    /// `allowedIDs: nil` means no filter (global).
    private func composeOutfitPosts(allowedIDs: Set<UUID>?, on db: any Database) async throws -> [FeedPost] {
        var query = OutfitModel.query(on: db)
            .with(\.$items) { $0.with(\.$garment) }
        if let ids = allowedIDs {
            query = query.filter(\.$user.$id ~~ Array(ids))
        }
        let outfitModels = try await query.all()
        var posts: [FeedPost] = []
        posts.reserveCapacity(outfitModels.count)
        for outfitModel in outfitModels {
            guard let userModel = try await UserModel.find(outfitModel.$user.id, on: db) else { continue }
            let author = try userModel.toDomain()
            let outfitDTO = try outfitModel.toResponseDTO()
            posts.append(
                FeedPost(
                    id: try outfitModel.requireID(),
                    author: author,
                    kind: .outfit,
                    caption: "\(author.displayName) ha creado un nuevo outfit.",
                    garment: nil,
                    outfit: outfitDTO,
                    imageURLs: [],
                    likesCount: 0,
                    isLikedByCurrentUser: false,
                    commentsCount: 0,
                    isReal: false,
                    createdAt: outfitModel.createdAt ?? .now
                )
            )
        }
        return posts
    }

    /// `allowedIDs: nil` means no filter (global).
    private func composeRealPosts(for user: User, allowedIDs: Set<UUID>?, on db: any Database) async throws -> [FeedPost] {
        var query = PostModel.query(on: db)
        if let ids = allowedIDs {
            query = query.filter(\.$user.$id ~~ Array(ids))
        }
        let postModels = try await query.all()
        var posts: [FeedPost] = []
        posts.reserveCapacity(postModels.count)
        for postModel in postModels {
            if let post = try await FeedPostBuilder.build(from: postModel, currentUser: user, on: db) {
                posts.append(post)
            }
        }
        return posts
    }
}
