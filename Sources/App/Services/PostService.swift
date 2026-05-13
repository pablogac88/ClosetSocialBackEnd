import Fluent
import Foundation
import Vapor

struct PostService: Sendable {

    func createPost(
        for user: User,
        caption: String,
        outfitID: UUID?,
        garmentID: UUID?,
        imageURLs: [String],
        on db: any Database
    ) async throws -> FeedPostResponseDTO {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw Abort(.badRequest, reason: "El caption no puede estar vacío.")
        }
        guard !(outfitID != nil && garmentID != nil) else {
            throw Abort(.badRequest, reason: "Un post no puede referenciar outfit y prenda a la vez.")
        }

        var garmentDomain: Garment? = nil
        var outfitDTO: OutfitResponseDTO? = nil

        if let outfitID {
            let outfitQuery = OutfitModel.query(on: db)
                .filter(\.$id == outfitID)
                .filter(\.$user.$id == user.id)
                .with(\.$items) { $0.with(\.$garment) }
            guard let model = try await outfitQuery.first()
            else { throw Abort(.forbidden, reason: "Referencia no válida.") }
            outfitDTO = try model.toResponseDTO()
        }

        if let garmentID {
            guard let model = try await GarmentModel.query(on: db)
                .filter(\.$id == garmentID)
                .filter(\.$user.$id == user.id)
                .first()
            else { throw Abort(.forbidden, reason: "Referencia no válida.") }
            garmentDomain = try model.toDomain()
        }

        let post = PostModel(
            userID: user.id,
            caption: trimmed,
            outfitID: outfitID,
            garmentID: garmentID,
            imageURLs: imageURLs
        )
        try await post.create(on: db)

        let kind: FeedPostKind = outfitID != nil ? .outfit : (garmentID != nil ? .garment : .post)

        return FeedPost(
            id: try post.requireID(),
            author: user,
            kind: kind,
            caption: trimmed,
            garment: garmentDomain,
            outfit: outfitDTO,
            imageURLs: imageURLs,
            likesCount: 0,
            isLikedByCurrentUser: false,
            commentsCount: 0,
            isReal: true,
            createdAt: post.createdAt ?? .now
        ).toResponse()
    }
}
