import Vapor

struct OutfitsController: Sendable {
    let service: OutfitsService

    func index(_ req: Request) async throws -> OutfitsResponseDTO {
        let user = try req.authenticatedUser
        let outfits = try await service.outfits(for: user, on: req.db)
        return OutfitsResponseDTO(items: outfits)
    }

    func create(_ req: Request) async throws -> OutfitResponseDTO {
        let user = try req.authenticatedUser
        let body = try req.content.decode(CreateOutfitRequestDTO.self)
        return try await service.createOutfit(
            for: user,
            title: body.title,
            note: body.note,
            garmentIDs: body.garmentIDs,
            layoutJSON: body.layoutJSON,
            on: req.db
        )
    }
}
