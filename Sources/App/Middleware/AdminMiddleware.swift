import Vapor

struct AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let user = try request.authenticatedUser
        guard user.isAdmin else {
            throw Abort(.forbidden, reason: "Se requieren permisos de administrador")
        }
        return try await next.respond(to: request)
    }
}
