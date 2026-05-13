import Fluent
import Foundation

public struct FluentSessionRepository: SessionRepository {
    public init() {}

    public func create(userID: UUID, on db: any Database) async throws -> Session {
        let token = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let model = SessionModel(token: token, userID: userID)
        try await model.create(on: db)

        guard let userModel = try await UserModel.find(userID, on: db) else {
            throw DomainError.userNotFound
        }
        let user = try userModel.toDomain()
        return Session(token: token, user: user)
    }

    public func userForToken(_ token: String, on db: any Database) async throws -> User? {
        guard let session = try await SessionModel.query(on: db)
            .filter(\.$token == token)
            .with(\.$user)
            .first() else {
            return nil
        }
        return try session.user.toDomain()
    }

    public func delete(token: String, on db: any Database) async throws {
        try await SessionModel.query(on: db)
            .filter(\.$token == token)
            .delete()
    }
}
