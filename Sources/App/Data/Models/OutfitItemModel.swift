import Fluent
import Foundation

final class OutfitItemModel: Model, @unchecked Sendable {
    static let schema = "outfit_items"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "outfit_id")
    var outfit: OutfitModel

    @Parent(key: "garment_id")
    var garment: GarmentModel

    @Field(key: "position")
    var position: Int

    init() { }

    init(
        id: UUID? = nil,
        outfitID: UUID,
        garmentID: UUID,
        position: Int
    ) {
        self.id = id
        self.$outfit.id = outfitID
        self.$garment.id = garmentID
        self.position = position
    }
}
