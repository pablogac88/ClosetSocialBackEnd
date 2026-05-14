import Foundation
import Vapor

struct SearchResultsDTO: Content, Sendable {
    let users: [PublicUserDTO]
    let garments: [GarmentResponseDTO]
    let outfits: [OutfitResponseDTO]
}
