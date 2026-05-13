import Foundation
import Vapor

struct AdminCatalogItemDTO: Content, Sendable {
    let id: UUID
    let name: String
    let createdAt: Date?
    let updatedAt: Date?
}

struct AdminCatalogMutationRequestDTO: Content, Sendable {
    let name: String
}

extension GarmentTypeModel {
    func toAdminCatalogDTO() throws -> AdminCatalogItemDTO {
        AdminCatalogItemDTO(
            id: try requireID(),
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension BrandModel {
    func toAdminCatalogDTO() throws -> AdminCatalogItemDTO {
        AdminCatalogItemDTO(
            id: try requireID(),
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
