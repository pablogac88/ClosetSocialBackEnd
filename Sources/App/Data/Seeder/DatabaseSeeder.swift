import Fluent
import Foundation
import Vapor

public struct DatabaseSeeder: Sendable {
    public init() {}

    public func seedIfNeeded(on db: any Database) async throws {
        guard try await UserModel.query(on: db).count() == 0 else { return }

        let pablo = UserModel(
            username: "pablogarcia",
            displayName: "Pablo García",
            email: "pablo@closetsocial.app",
            passwordHash: try Bcrypt.hash("password123"),
            avatarURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800"
        )

        let ana = UserModel(
            username: "anagarcia",
            displayName: "Ana García",
            email: "ana@closetsocial.app",
            passwordHash: try Bcrypt.hash("password123"),
            avatarURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800"
        )

        try await pablo.create(on: db)
        try await ana.create(on: db)

        guard let pabloID = pablo.id, let anaID = ana.id else {
            throw Abort(.internalServerError, reason: "No se pudieron generar los usuarios seed")
        }

        let garments = [
            GarmentModel(
                name: "Cazadora denim",
                brand: "Levi's",
                category: "Chaqueta",
                color: "Azul",
                imageURL: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=1200&auto=format&fit=crop&q=80",
                userID: pabloID
            ),
            GarmentModel(
                name: "Camiseta oversize",
                brand: "COS",
                category: "Top",
                color: "Blanco",
                imageURL: "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=1200&auto=format&fit=crop&q=80",
                userID: pabloID
            ),
            GarmentModel(
                name: "Blazer relaxed",
                brand: "Massimo Dutti",
                category: "Blazer",
                color: "Beige",
                imageURL: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=1200&auto=format&fit=crop&q=80",
                userID: anaID
            ),
            GarmentModel(
                name: "Vaquero recto",
                brand: "Mango",
                category: "Pantalón",
                color: "Índigo",
                imageURL: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=1200&auto=format&fit=crop&q=80",
                userID: anaID
            )
        ]

        try await garments.create(on: db)
    }
}
