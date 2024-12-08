// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MachoFramework",
    platforms: [.macOS(.v12),.iOS(.v17)],
    products: [
        .library(
            name: "MachoFramework",
            targets: [
                "MachoFramework",
            ]
        ),
        .library(
            name: "MachoView",
            targets: [
                "MachoView",
            ]
        ),
        .library(
            name: "MachoModel",
            targets: [
                "MachoModel",
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.12.1"),
        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.51.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", exact: "6.6.2"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.6.1"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.56.1")
    ],
    targets: [
        .target(
            name: "MachoFramework",
            dependencies: [
                "MachoView",
                "MachoModel",
            ]
        ),
        .target(
            name: "MachoView",
            dependencies: [
                "MachoCore"
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .target(name: "MachoModel",
                dependencies: [
                    "MachoCore",
                    "RealmHelper"
                ],
                plugins: [
                    .plugin(name: "SwiftLintBuildToolPlugin",
                            package: "SwiftLintPlugins")
                ]),
        .target(
            name: "RealmHelper",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift"),
                "MachoCore"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",
                        package: "SwiftLintPlugins")
            ]
        ),
        .target(
            name: "MachoCore",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(name: "Logging", package: "swift-log")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",
                        package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "MachoViewTests",
            dependencies: [
                "MachoView",
            ]),
        .testTarget(
            name: "MachoModelTests",
            dependencies: [
                "MachoModel",
            ])
    ]
)
