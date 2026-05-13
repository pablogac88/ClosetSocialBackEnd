import Vapor

struct AuthenticatedUserKey: StorageKey {
    typealias Value = User
}

extension Request {
    var authenticatedUser: User {
        get throws {
            guard let user = storage[AuthenticatedUserKey.self] else {
                throw Abort(.unauthorized, reason: "Falta el token de sesión")
            }
            return user
        }
    }
}

struct BearerAuthMiddleware: AsyncMiddleware {
    let authService: AuthService

    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Falta el token de sesión")
        }
        do {
            let user = try await authService.authenticatedUser(token: bearer.token, on: request.db)
            request.storage[AuthenticatedUserKey.self] = user
            return try await next.respond(to: request)
        } catch DomainError.unauthenticated {
            throw Abort(.unauthorized, reason: "Sesión no válida")
        }
    }
}
