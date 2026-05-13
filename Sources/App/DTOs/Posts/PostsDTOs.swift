import Foundation
import Vapor

struct CreatePostRequestDTO: Content, Sendable {
    let caption: String
    let outfitID: UUID?
    let garmentID: UUID?
    let imageURLs: [String]?
}
