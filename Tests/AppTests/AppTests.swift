import Foundation
import Testing
@testable import App

@Test("DomainError es comparable")
func domainErrorIsComparable() async throws {
    let lhs: DomainError = .invalidCredentials
    let rhs: DomainError = .invalidCredentials
    #expect(lhs == rhs)
}

@Test("AuthService se puede instanciar")
func authServiceInstantiation() async throws {
    let service = AuthService(
        users: FluentUserRepository(),
        sessions: FluentSessionRepository()
    )
    _ = service
    #expect(true)
}
