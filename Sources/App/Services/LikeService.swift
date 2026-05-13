import Fluent
import Foundation
import Vapor

struct LikeService: Sendable {

    func like(for user: User, postID: UUID, on db: any Database) async throws {
        guard try await PostModel.find(postID, on: db) != nil else {
            throw Abort(.notFound, reason: "Post no encontrado.")
        }
        let existing = try await LikeModel.query(on: db)
            .filter(\.$user.$id == user.id)
            .filter(\.$post.$id == postID)
            .first()
        guard existing == nil else { return }
        try await LikeModel(userID: user.id, postID: postID).create(on: db)
    }

    func unlike(for user: User, postID: UUID, on db: any Database) async throws {
        guard try await PostModel.find(postID, on: db) != nil else {
            throw Abort(.notFound, reason: "Post no encontrado.")
        }
        try await LikeModel.query(on: db)
            .filter(\.$user.$id == user.id)
            .filter(\.$post.$id == postID)
            .delete()
    }
}
