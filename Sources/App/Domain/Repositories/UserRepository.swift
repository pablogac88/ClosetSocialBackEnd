import Foundation
import Fluent

public protocol UserRepository: Sendable {
    func findByEmail(_ email: String, on db: any Database) async throws -> (User, passwordHash: String)?
    func findByID(_ id: UUID, on db: any Database) async throws -> User?
    func create(
        username: String,
        displayName: String,
        email: String,
        passwordHash: String,
        avatarURL: String?,
        on db: any Database
    ) async throws -> User
}
