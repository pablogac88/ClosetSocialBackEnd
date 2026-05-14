import Fluent
import Foundation

struct FollowService: Sendable {

    func follow(followerID: UUID, followingID: UUID, on db: any Database) async throws {
        let existing = try await FollowModel.query(on: db)
            .filter(\.$follower.$id == followerID)
            .filter(\.$following.$id == followingID)
            .first()
        guard existing == nil else { return }
        try await FollowModel(followerID: followerID, followingID: followingID).save(on: db)
    }

    func unfollow(followerID: UUID, followingID: UUID, on db: any Database) async throws {
        try await FollowModel.query(on: db)
            .filter(\.$follower.$id == followerID)
            .filter(\.$following.$id == followingID)
            .delete()
    }

    func isFollowing(followerID: UUID, followingID: UUID, on db: any Database) async throws -> Bool {
        try await FollowModel.query(on: db)
            .filter(\.$follower.$id == followerID)
            .filter(\.$following.$id == followingID)
            .first() != nil
    }

    func followerCount(for userID: UUID, on db: any Database) async throws -> Int {
        try await FollowModel.query(on: db)
            .filter(\.$following.$id == userID)
            .count()
    }

    func followingCount(for userID: UUID, on db: any Database) async throws -> Int {
        try await FollowModel.query(on: db)
            .filter(\.$follower.$id == userID)
            .count()
    }

    func fetchFollowers(for userID: UUID, on db: any Database) async throws -> [User] {
        let follows = try await FollowModel.query(on: db)
            .filter(\.$following.$id == userID)
            .with(\.$follower)
            .all()
        return try follows.map { try $0.follower.toDomain() }
    }

    func fetchFollowing(for userID: UUID, on db: any Database) async throws -> [User] {
        let follows = try await FollowModel.query(on: db)
            .filter(\.$follower.$id == userID)
            .with(\.$following)
            .all()
        return try follows.map { try $0.following.toDomain() }
    }
}
