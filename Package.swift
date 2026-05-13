// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClosetSocialBackend",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.121.4"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: [
                "App"
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App"
            ]
        )
    ]
)
