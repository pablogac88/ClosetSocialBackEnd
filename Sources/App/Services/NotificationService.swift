import Fluent
import Foundation

enum NotificationType: String, Sendable {
    case follow
    case like
    case comment
}

struct NotificationService: Sendable {

    func notify(
        recipient: UUID,
        actor: UUID,
        type: NotificationType,
        postID: UUID?,
        on db: any Database
    ) async throws {
        guard recipient != actor else { return }

        // Dedup for follow and like — each generates at most one active notification
        if type == .follow || type == .like {
            var query = NotificationModel.query(on: db)
                .filter(\.$recipient.$id == recipient)
                .filter(\.$actor.$id == actor)
                .filter(\.$type == type.rawValue)
            if let postID {
                query = query.filter(\.$post.$id == postID)
            }
            let existing = try await query.first()
            guard existing == nil else { return }
        }

        let notification = NotificationModel(
            recipientID: recipient,
            actorID: actor,
            type: type.rawValue,
            postID: postID
        )
        try await notification.save(on: db)
    }

    func fetchNotifications(for userID: UUID, on db: any Database) async throws -> [NotificationResponseDTO] {
        let models = try await NotificationModel.query(on: db)
            .filter(\.$recipient.$id == userID)
            .with(\.$actor)
            .sort(\.$createdAt, .descending)
            .all()

        return try models.map { model in
            NotificationResponseDTO(
                id: try model.requireID(),
                type: model.type,
                actor: try model.actor.toDomain().toPublicDTO(),
                postID: model.$post.id,
                createdAt: model.createdAt ?? .now,
                readAt: model.readAt
            )
        }
    }

    func markRead(id: UUID, userID: UUID, on db: any Database) async throws {
        guard let model = try await NotificationModel.find(id, on: db),
              model.$recipient.id == userID else { return }
        model.readAt = .now
        try await model.update(on: db)
    }

    func markAllRead(userID: UUID, on db: any Database) async throws {
        let unread = try await NotificationModel.query(on: db)
            .filter(\.$recipient.$id == userID)
            .filter(\.$readAt == nil)
            .all()
        for model in unread {
            model.readAt = .now
            try await model.update(on: db)
        }
    }

    func unreadCount(for userID: UUID, on db: any Database) async throws -> Int {
        try await NotificationModel.query(on: db)
            .filter(\.$recipient.$id == userID)
            .filter(\.$readAt == nil)
            .count()
    }
}
