import Foundation
import Fluent

public protocol SessionRepository: Sendable {
    func create(userID: UUID, on db: any Database) async throws -> Session
    func userForToken(_ token: String, on db: any Database) async throws -> User?
    func delete(token: String, on db: any Database) async throws
}
