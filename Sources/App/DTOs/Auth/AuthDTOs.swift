import Foundation
import Vapor

struct RegisterRequestDTO: Content, Sendable {
    let username: String
    let displayName: String
    let email: String
    let password: String
}

struct LoginRequestDTO: Content, Sendable {
    let email: String
    let password: String
}

struct AuthResponseDTO: Content, Sendable {
    let token: String
    let user: PublicUserDTO
}

extension Session {
    func toResponse() -> AuthResponseDTO {
        AuthResponseDTO(token: token, user: user.toPublicDTO())
    }
}
