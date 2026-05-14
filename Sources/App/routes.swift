import Vapor

func routes(_ app: Application) throws {
    let deps = app.dependencies

    let health = HealthController()
    let auth = AuthController(service: deps.authService)
    let closet = ClosetController(service: deps.closetService)
    let timeline = TimelineController(service: deps.timelineService)
    let outfits = OutfitsController(service: deps.outfitsService)
    let posts = PostController(service: deps.postService)
    let likes = LikeController(service: deps.likeService)
    let comments = CommentController(service: deps.commentService)
    let profile = ProfileController(service: deps.profileService)
    let admin = AdminController(service: deps.adminDashboardService)
    let adminCatalog = AdminCatalogController(service: deps.adminCatalogService)
    let adminWeb = AdminWebController()
    let debug = DebugController()

    app.get(use: health.welcome)
    app.get("health", use: health.health)
    app.get("admin", use: adminWeb.index)
    app.get("debug", use: debug.index)
    app.get("debug", "users", use: debug.users)
    app.get("debug", "garments", use: debug.garments)

    let authGroup = app.grouped("auth")
    authGroup.post("register", use: auth.register)
    authGroup.post("login", use: auth.login)

    let protected = app
        .grouped("api")
        .grouped(BearerAuthMiddleware(authService: deps.authService))

    protected.get("timeline", use: timeline.index)
    protected.get("closet", use: closet.index)
    protected.post("closet", use: closet.create)
    protected.delete("garments", ":id", use: closet.delete)
    protected.get("outfits", use: outfits.index)
    protected.post("outfits", use: outfits.create)
    protected.delete("outfits", ":id", use: outfits.delete)
    protected.post("posts", use: posts.create)
    protected.post("posts", ":id", "like", use: likes.like)
    protected.delete("posts", ":id", "like", use: likes.unlike)
    protected.post("posts", ":id", "comments", use: comments.create)
    protected.get("posts", ":id", "comments", use: comments.list)
    protected.get("profile", use: profile.show)
    protected.get("users", ":id", "profile", use: profile.publicProfile)

    let adminRoutes = app
        .grouped("admin")
        .grouped(BearerAuthMiddleware(authService: deps.authService))
        .grouped(AdminMiddleware())

    adminRoutes.get("dashboard", use: admin.dashboard)
    adminRoutes.get("garment-types", use: adminCatalog.garmentTypes)
    adminRoutes.post("garment-types", use: adminCatalog.createGarmentType)
    adminRoutes.patch("garment-types", ":id", use: adminCatalog.updateGarmentType)
    adminRoutes.delete("garment-types", ":id", use: adminCatalog.deleteGarmentType)
    adminRoutes.get("brands", use: adminCatalog.brands)
    adminRoutes.post("brands", use: adminCatalog.createBrand)
    adminRoutes.patch("brands", ":id", use: adminCatalog.updateBrand)
    adminRoutes.delete("brands", ":id", use: adminCatalog.deleteBrand)
}
