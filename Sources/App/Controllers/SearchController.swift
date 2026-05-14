import Vapor

struct SearchController: Sendable {
    let service: SearchService

    func search(_ req: Request) async throws -> SearchResultsDTO {
        guard let raw = req.query[String.self, at: "q"] else {
            throw Abort(.badRequest, reason: "El parámetro 'q' es obligatorio.")
        }
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else {
            throw Abort(.badRequest, reason: "La búsqueda debe tener al menos 2 caracteres.")
        }
        return try await service.search(query: q, on: req.db)
    }
}
