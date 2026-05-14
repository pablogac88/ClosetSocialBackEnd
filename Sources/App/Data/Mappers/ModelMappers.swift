import Foundation
import Vapor

enum ModelMappingError: Error, Sendable {
    case missingPersistedID
}

extension UserModel {
    func toDomain() throws -> User {
        guard let id else { throw ModelMappingError.missingPersistedID }
        return User(
            id: id,
            username: username,
            displayName: displayName,
            email: email,
            avatarURL: avatarURL,
            bio: bio,
            role: role
        )
    }
}

extension GarmentModel {
    func toDomain() throws -> Garment {
        guard let id else { throw ModelMappingError.missingPersistedID }
        return Garment(
            id: id,
            name: name,
            brand: brand,
            category: category,
            color: color,
            userID: $user.id,
            createdAt: createdAt ?? .now
        )
    }

}

extension OutfitModel {
    func toDomain() throws -> Outfit {
        guard let id else { throw ModelMappingError.missingPersistedID }
        return Outfit(
            id: id,
            ownerId: $user.id,
            title: title,
            note: note,
            createdAt: createdAt ?? .now
        )
    }

    /// Requiere que `items` y `items.$garment` estén eager-loaded antes de llamar.
    func toResponseDTO() throws -> OutfitResponseDTO {
        guard let id else { throw ModelMappingError.missingPersistedID }
        let garmentDTOs = try items
            .sorted { $0.position < $1.position }
            .map { try $0.garment.toDomain().toResponse() }
        return OutfitResponseDTO(
            id: id,
            title: title,
            note: note,
            garments: garmentDTOs,
            layoutJSON: layoutJSON,
            createdAt: createdAt ?? .now
        )
    }
}
