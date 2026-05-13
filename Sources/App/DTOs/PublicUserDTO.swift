import Foundation
import Vapor

struct PublicUserDTO: Content, Sendable {
    let id: UUID
    let username: String
    let displayName: String
    let avatarURL: String?
    let bio: String?
}

extension User {
    func toPublicDTO() -> PublicUserDTO {
        PublicUserDTO(
            id: id,
            username: username,
            displayName: displayName,
            avatarURL: avatarURL,
            bio: bio
        )
    }
}
