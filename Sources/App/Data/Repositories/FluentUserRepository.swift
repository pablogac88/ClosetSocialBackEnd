import Fluent
import Foundation

public struct FluentUserRepository: UserRepository {
    public init() {}

    public func findByEmail(_ email: String, on db: any Database) async throws -> (User, passwordHash: String)? {
        guard let model = try await UserModel.query(on: db)
            .filter(\.$email == email)
            .first() else {
            return nil
        }
        let user = try model.toDomain()
        return (user, model.passwordHash)
    }

    public func findByID(_ id: UUID, on db: any Database) async throws -> User? {
        guard let model = try await UserModel.find(id, on: db) else { return nil }
        return try model.toDomain()
    }

    public func create(
        username: String,
        displayName: String,
        email: String,
        passwordHash: String,
        avatarURL: String?,
        on db: any Database
    ) async throws -> User {
        let model = UserModel(
            username: username,
            displayName: displayName,
            email: email,
            passwordHash: passwordHash,
            avatarURL: avatarURL
        )
        try await model.create(on: db)
        return try model.toDomain()
    }
}
