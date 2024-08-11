// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MachoFramework",
    platforms: [.macOS(.v12),.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MachoFramework",
            type: .dynamic,
            targets: ["MachoFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.6.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.0.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.0"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.6.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MachoFramework",
            dependencies: ["MachoView"]
        ),
        .target(
            name: "MachoView",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                "RealmHelper",
                "MachoCore"
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .target(
            name: "RealmHelper",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Realm", package: "realm-swift"),
                "MachoCore"
            ]
        ),
        .target(
            name: "MachoCore",
            dependencies: [.product(name: "Logging", package: "swift-log")]
        ),
        .testTarget(
            name: "MachoFrameworkTests",
            dependencies: [
                "MachoFramework",
                "MachoView",
                "RealmHelper",
                "MachoCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Logging", package: "swift-log")
            ]),
    ]
)
