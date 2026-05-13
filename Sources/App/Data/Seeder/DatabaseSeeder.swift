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
            GarmentModel(name: "Cazadora denim", brand: "Levi's", category: "Chaqueta", color: "Azul", userID: pabloID),
            GarmentModel(name: "Camiseta oversize", brand: "COS", category: "Top", color: "Blanco", userID: pabloID),
            GarmentModel(name: "Blazer relaxed", brand: "Massimo Dutti", category: "Blazer", color: "Beige", userID: anaID),
            GarmentModel(name: "Vaquero recto", brand: "Mango", category: "Pantalón", color: "Índigo", userID: anaID)
        ]

        try await garments.create(on: db)
    }
}
