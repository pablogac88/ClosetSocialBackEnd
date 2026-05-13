import Fluent
import Foundation

public struct TimelineService: Sendable {
    let garments: any GarmentRepository

    public init(garments: any GarmentRepository) {
        self.garments = garments
    }

    public func timeline(for user: User, on db: any Database) async throws -> [FeedPost] {
        let allGarments = try await garments.all(on: db)
        let garmentPosts = try await composeGarmentPosts(from: allGarments, on: db)
        let outfitPosts = try await composeOutfitPosts(on: db)
        let realPosts = try await composeRealPosts(for: user, on: db)
        return (garmentPosts + outfitPosts + realPosts).sorted { $0.createdAt > $1.createdAt }
    }

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

    private func composeOutfitPosts(on db: any Database) async throws -> [FeedPost] {
        let outfitModels = try await OutfitModel.query(on: db)
            .with(\.$items) { $0.with(\.$garment) }
            .all()
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

    private func composeRealPosts(for user: User, on db: any Database) async throws -> [FeedPost] {
        let postModels = try await PostModel.query(on: db).all()
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
