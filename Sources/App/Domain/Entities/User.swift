import Foundation

public struct User: Sendable, Hashable {
    public let id: UUID
    public let username: String
    public let displayName: String
    public let email: String
    public let avatarURL: String?
    public let bio: String?
    public let role: UserRole

    public init(
        id: UUID,
        username: String,
        displayName: String,
        email: String,
        avatarURL: String?,
        bio: String? = nil,
        role: UserRole = .user
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.bio = bio
        self.role = role
    }

    public var isAdmin: Bool {
        role == .admin
    }
}
