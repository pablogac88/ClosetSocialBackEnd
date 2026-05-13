import Foundation

public enum DomainError: Error, Sendable, Hashable {
    case invalidCredentials
    case emailAlreadyExists
    case unauthenticated
    case userNotFound
    case persistence(message: String)
}
