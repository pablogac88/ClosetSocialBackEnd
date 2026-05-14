import Vapor

/// Stack de dependencias compartido por toda la app.
/// Se inicializa en `configure` y vive en `Application.storage`.
public struct AppDependencies: Sendable {
    public let userRepository: any UserRepository
    public let sessionRepository: any SessionRepository
    public let garmentRepository: any GarmentRepository
    public let authService: AuthService
    public let closetService: ClosetService
    public let timelineService: TimelineService
    let outfitsService: OutfitsService
    let postService: PostService
    let likeService: LikeService
    let commentService: CommentService
    let adminDashboardService: AdminDashboardService
    let adminCatalogService: AdminCatalogService
    public let profileService: ProfileService
    let followService: FollowService
    let searchService: SearchService
    public let seeder: DatabaseSeeder

    public init(
        userRepository: any UserRepository,
        sessionRepository: any SessionRepository,
        garmentRepository: any GarmentRepository
    ) {
        self.userRepository = userRepository
        self.sessionRepository = sessionRepository
        self.garmentRepository = garmentRepository
        self.authService = AuthService(users: userRepository, sessions: sessionRepository)
        self.closetService = ClosetService(garments: garmentRepository)
        self.outfitsService = OutfitsService(garments: garmentRepository)
        self.postService = PostService()
        self.likeService = LikeService()
        self.commentService = CommentService()
        self.adminDashboardService = AdminDashboardService()
        self.adminCatalogService = AdminCatalogService()
        self.followService = FollowService()
        self.timelineService = TimelineService(garments: garmentRepository, follows: followService)
        self.profileService = ProfileService(garments: garmentRepository, follows: followService)
        self.searchService = SearchService()
        self.seeder = DatabaseSeeder()
    }

    public static var live: AppDependencies {
        AppDependencies(
            userRepository: FluentUserRepository(),
            sessionRepository: FluentSessionRepository(),
            garmentRepository: FluentGarmentRepository()
        )
    }
}

private enum AppDependenciesKey: StorageKey {
    typealias Value = AppDependencies
}

extension Application {
    public var dependencies: AppDependencies {
        get {
            guard let deps = storage[AppDependenciesKey.self] else {
                fatalError("AppDependencies no configurado. Llama a configure(_:) primero.")
            }
            return deps
        }
        set { storage[AppDependenciesKey.self] = newValue }
    }
}
