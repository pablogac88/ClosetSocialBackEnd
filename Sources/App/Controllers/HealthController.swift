import Vapor

struct HealthController: Sendable {
    struct StatusDTO: Content, Sendable {
        let status: String
    }

    struct WelcomeDTO: Content, Sendable {
        let message: String
    }

    func welcome(_: Request) async throws -> WelcomeDTO {
        WelcomeDTO(message: "ClosetSocial backend listo")
    }

    func health(_: Request) async throws -> StatusDTO {
        StatusDTO(status: "ok")
    }
}
