import Fluent
import Foundation

/// Builds a single FeedPost from a persisted PostModel with all computed fields
/// (likes, comments, author lookup). Used by both TimelineService and ProfileService
/// to avoid duplicating that logic.
struct FeedPostBuilder: Sendable {

    static func build(
        from postModel: PostModel,
        currentUser: User,
        on db: any Database
    ) async throws -> FeedPost? {
        guard let authorModel = try await UserModel.find(postModel.$user.id, on: db) else {
            return nil
        }
        let author = try authorModel.toDomain()
        let postID = try postModel.requireID()

        var garmentDomain: Garment? = nil
        var outfitDTO: OutfitResponseDTO? = nil

        if let outfitID = postModel.$outfit.id {
            let outfitQuery = OutfitModel.query(on: db)
                .filter(\.$id == outfitID)
                .with(\.$items) { $0.with(\.$garment) }
            if let outfitModel = try await outfitQuery.first() {
                outfitDTO = try outfitModel.toResponseDTO()
            }
        }

        if let garmentID = postModel.$garment.id,
           let garmentModel = try await GarmentModel.find(garmentID, on: db) {
            garmentDomain = try garmentModel.toDomain()
        }

        let likesCount = try await LikeModel.query(on: db)
            .filter(\.$post.$id == postID)
            .count()
        let isLikedByCurrentUser = try await LikeModel.query(on: db)
            .filter(\.$post.$id == postID)
            .filter(\.$user.$id == currentUser.id)
            .first() != nil
        let commentsCount = try await CommentModel.query(on: db)
            .filter(\.$post.$id == postID)
            .count()

        let kind: FeedPostKind = postModel.$outfit.id != nil ? .outfit
            : (postModel.$garment.id != nil ? .garment : .post)

        return FeedPost(
            id: postID,
            author: author,
            kind: kind,
            caption: postModel.caption,
            garment: garmentDomain,
            outfit: outfitDTO,
            imageURLs: postModel.imageURLs,
            likesCount: likesCount,
            isLikedByCurrentUser: isLikedByCurrentUser,
            commentsCount: commentsCount,
            isReal: true,
            createdAt: postModel.createdAt ?? .now
        )
    }
}
