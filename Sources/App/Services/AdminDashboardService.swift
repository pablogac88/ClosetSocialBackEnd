import Fluent

public struct AdminDashboardService: Sendable {
    public init() {}

    func stats(on db: any Database) async throws -> AdminDashboardStatsDTO {
        async let totalUsers = UserModel.query(on: db).count()
        async let totalGarments = GarmentModel.query(on: db).count()
        async let totalOutfits = OutfitModel.query(on: db).count()
        async let totalPosts = PostModel.query(on: db).count()
        async let totalLikes = LikeModel.query(on: db).count()
        async let totalComments = CommentModel.query(on: db).count()

        return try await AdminDashboardStatsDTO(
            totalUsers: totalUsers,
            totalGarments: totalGarments,
            totalOutfits: totalOutfits,
            totalPosts: totalPosts,
            totalLikes: totalLikes,
            totalComments: totalComments
        )
    }
}
