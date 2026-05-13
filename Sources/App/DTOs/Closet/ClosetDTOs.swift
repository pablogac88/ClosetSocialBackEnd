import Foundation
import Vapor

public struct GarmentResponseDTO: Content, Sendable {
    public let id: UUID
    public let name: String
    public let brand: String
    public let category: String
    public let color: String
    public let createdAt: Date
}

struct ClosetResponseDTO: Content, Sendable {
    let items: [GarmentResponseDTO]
}

struct CreateGarmentRequestDTO: Content, Sendable {
    let name: String
    let brand: String
    let category: String
    let color: String
}

extension Garment {
    func toResponse() -> GarmentResponseDTO {
        GarmentResponseDTO(
            id: id,
            name: name,
            brand: brand,
            category: category,
            color: color,
            createdAt: createdAt
        )
    }
}
