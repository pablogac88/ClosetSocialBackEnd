import Vapor

struct UploadController: Sendable {
    let service: UploadService

    struct UploadRequest: Content {
        let file: File
    }

    func uploadImage(_ req: Request) async throws -> UploadResponseDTO {
        let body = try req.content.decode(UploadRequest.self)
        let baseURL = Environment.get("BASE_URL") ?? "http://127.0.0.1:8080"

        let url = try service.uploadImage(
            file: body.file,
            baseURL: baseURL,
            publicDirectory: req.application.directory.publicDirectory,
            logger: req.logger
        )

        return UploadResponseDTO(url: url)
    }
}
