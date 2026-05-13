import Vapor

struct AuthController: Sendable {
    let service: AuthService

    func register(_ req: Request) async throws -> AuthResponseDTO {
        let body = try req.content.decode(RegisterRequestDTO.self)
        do {
            let session = try await service.register(
                username: body.username,
                displayName: body.displayName,
                email: body.email,
                password: body.password,
                on: req.db
            )
            return session.toResponse()
        } catch DomainError.emailAlreadyExists {
            throw Abort(.conflict, reason: "Ya existe un usuario con ese email")
        }
    }

    func login(_ req: Request) async throws -> AuthResponseDTO {
        let body = try req.content.decode(LoginRequestDTO.self)
        do {
            let session = try await service.login(email: body.email, password: body.password, on: req.db)
            return session.toResponse()
        } catch DomainError.invalidCredentials {
            throw Abort(.unauthorized, reason: "Credenciales inválidas")
        }
    }
}
