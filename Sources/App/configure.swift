import Foundation
import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .iso8601

    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .iso8601

    ContentConfiguration.global.use(encoder: jsonEncoder, for: .json)
    ContentConfiguration.global.use(decoder: jsonDecoder, for: .json)

    let databasePath = app.directory.workingDirectory + "closet-social.sqlite"
    app.databases.use(.sqlite(.file(databasePath)), as: .sqlite)

    app.migrations.add(CreateUserMigration())
    app.migrations.add(AddBioToUserMigration())
    app.migrations.add(AddRoleToUserMigration())
    app.migrations.add(CreateSessionMigration())
    app.migrations.add(CreateGarmentMigration())
    app.migrations.add(AddImageURLToGarmentMigration())
    app.migrations.add(CreateGarmentTypeMigration())
    app.migrations.add(CreateBrandMigration())
    app.migrations.add(CreateOutfitMigration())
    app.migrations.add(CreateOutfitItemsMigration())
    app.migrations.add(AddLayoutJSONToOutfitMigration())
    app.migrations.add(CreatePostMigration())
    app.migrations.add(CreateLikeMigration())
    app.migrations.add(CreateCommentMigration())
    app.migrations.add(CreateFollowMigration())

    app.dependencies = .live
    try routes(app)
}
