import Vapor

struct PostController: Sendable {
    let service: PostService

    func create(_ req: Request) async throws -> FeedPostResponseDTO {
        let user = try req.authenticatedUser
        let body = try req.content.decode(CreatePostRequestDTO.self)
        return try await service.createPost(
            for: user,
            caption: body.caption,
            outfitID: body.outfitID,
            garmentID: body.garmentID,
            imageURLs: body.imageURLs ?? [],
            on: req.db
        )
    }
}
