import Fluent
import Foundation
import Vapor

public struct AuthService: Sendable {
    let users: any UserRepository
    let sessions: any SessionRepository

    public init(users: any UserRepository, sessions: any SessionRepository) {
        self.users = users
        self.sessions = sessions
    }

    public func register(
        username: String,
        displayName: String,
        email: String,
        password: String,
        on db: any Database
    ) async throws -> Session {
        let normalizedEmail = normalize(email)

        if try await users.findByEmail(normalizedEmail, on: db) != nil {
            throw DomainError.emailAlreadyExists
        }

        let hash = try Bcrypt.hash(password)
        let user = try await users.create(
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: normalizedEmail,
            passwordHash: hash,
            avatarURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800",
            on: db
        )
        return try await sessions.create(userID: user.id, on: db)
    }

    public func login(email: String, password: String, on db: any Database) async throws -> Session {
        let normalizedEmail = normalize(email)
        guard let (user, hash) = try await users.findByEmail(normalizedEmail, on: db) else {
            throw DomainError.invalidCredentials
        }
        guard (try? Bcrypt.verify(password, created: hash)) == true else {
            throw DomainError.invalidCredentials
        }
        return try await sessions.create(userID: user.id, on: db)
    }

    public func authenticatedUser(token: String, on db: any Database) async throws -> User {
        guard let user = try await sessions.userForToken(token, on: db) else {
            throw DomainError.unauthenticated
        }
        return user
    }

    private func normalize(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
