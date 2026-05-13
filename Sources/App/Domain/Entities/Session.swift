import Foundation

public struct Session: Sendable, Hashable {
    public let token: String
    public let user: User

    public init(token: String, user: User) {
        self.token = token
        self.user = user
    }
}
