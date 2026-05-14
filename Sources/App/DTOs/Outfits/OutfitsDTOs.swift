import Foundation
import Vapor

struct CreateOutfitRequestDTO: Content, Sendable {
    let title: String?
    let note: String?
    let garmentIDs: [UUID]
    let layoutJSON: String?
}

public struct OutfitResponseDTO: Content, Sendable {
    public let id: UUID
    public let title: String?
    public let note: String?
    public let garments: [GarmentResponseDTO]
    public let layoutJSON: String?
    public let createdAt: Date
}

struct OutfitsResponseDTO: Content, Sendable {
    let items: [OutfitResponseDTO]
}
