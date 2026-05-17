import Vapor
import Foundation

struct UploadService: Sendable {
    private static let allowedMIMEPrefixes = ["image/"]
    private static let mimeToExtension: [String: String] = [
        "image/jpeg": "jpg",
        "image/png":  "png",
        "image/webp": "webp",
        "image/gif":  "gif",
        "image/heic": "heic",
    ]

    func uploadImage(
        file: File,
        baseURL: String,
        publicDirectory: String,
        logger: Logger
    ) throws -> String {
        let contentType = file.contentType?.serialize() ?? ""
        guard Self.allowedMIMEPrefixes.contains(where: { contentType.hasPrefix($0) }) else {
            throw Abort(.unsupportedMediaType, reason: "Solo se aceptan imágenes.")
        }

        var mutableBuffer = file.data
        guard let bytes = mutableBuffer.readBytes(length: mutableBuffer.readableBytes),
              !bytes.isEmpty else {
            throw Abort(.badRequest, reason: "El archivo está vacío.")
        }

        let ext = Self.mimeToExtension[contentType] ?? "jpg"
        let filename = "\(UUID().uuidString).\(ext)"
        let uploadDir = publicDirectory + "uploads"
        let filePath = uploadDir + "/" + filename

        try FileManager.default.createDirectory(atPath: uploadDir, withIntermediateDirectories: true)
        let data = Data(bytes)
        guard FileManager.default.createFile(atPath: filePath, contents: data) else {
            throw Abort(.internalServerError, reason: "No se pudo guardar el archivo.")
        }

        logger.info("[UploadService] Saved \(filename) (\(bytes.count) bytes)")
        return "\(baseURL)/uploads/\(filename)"
    }
}
