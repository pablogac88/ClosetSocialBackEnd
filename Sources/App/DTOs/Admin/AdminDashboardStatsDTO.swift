import Vapor

struct AdminDashboardStatsDTO: Content, Sendable {
    let totalUsers: Int
    let totalGarments: Int
    let totalOutfits: Int
    let totalPosts: Int
    let totalLikes: Int
    let totalComments: Int
}
