import Foundation
import Vapor

struct FeedPostResponseDTO: Content, Sendable {
    let id: UUID
    let author: PublicUserDTO
    let kind: String
    let caption: String
    let garment: GarmentResponseDTO?
    let outfit: OutfitResponseDTO?
    let imageURLs: [String]
    let likesCount: Int
    let isLikedByCurrentUser: Bool
    let commentsCount: Int
    let isReal: Bool
    // Legacy fields kept for backward compatibility with older clients.
    let garmentName: String?
    let imageURL: String?
    let createdAt: Date
}

struct TimelineResponseDTO: Content, Sendable {
    let items: [FeedPostResponseDTO]
}

extension FeedPost {
    func toResponse() -> FeedPostResponseDTO {
        FeedPostResponseDTO(
            id: id,
            author: author.toPublicDTO(),
            kind: kind.rawValue,
            caption: caption,
            garment: garment?.toResponse(),
            outfit: outfit,
            imageURLs: imageURLs,
            likesCount: likesCount,
            isLikedByCurrentUser: isLikedByCurrentUser,
            commentsCount: commentsCount,
            isReal: isReal,
            garmentName: garment?.name,
            imageURL: imageURLs.first,
            createdAt: createdAt
        )
    }
}
