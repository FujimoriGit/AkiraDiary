// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MachoFramework",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "MachoFramework",
            type: .dynamic,
            targets: [
                "MachoFramework",
                "MachoView",
                "MachoLocalStorage",
                "MachoCore",
                "RealmHelper"
            ]
        ),
        .library(
            name: "MachoView",
            targets: [
                "MachoView",
                "MachoCore"
            ]
        ),
        .library(
            name: "MachoLocalStorage",
            targets: [
                "MachoLocalStorage",
                "MachoCore",
                "RealmHelper"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.12.1"),
//        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.51.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", exact: "6.6.2"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.6.1"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.56.1")
    ],
    targets: [
        .target(
            name: "MachoFramework",
            dependencies: [
                "MachoView",
                "MachoLocalStorage",
                "MachoCore"
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
        .target(
            name: "MachoLocalStorage",
            dependencies: [
                "MachoCore",
                "RealmHelper"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",
                        package: "SwiftLintPlugins")
            ]
        ),
        .target(
            name: "RealmHelper",
            dependencies: [
                "RealmSwiftXcFramework",
                "RealmXcFramework",
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
        .binaryTarget(
            name: "RealmSwiftXcFramework",
            url: "https://github.com/realm/realm-swift/releases/download/v20.0.3/RealmSwift@16.4.spm.zip",
            checksum: "840a5fb0ad5d55d29de2ced5a3c9cb9114360ad906c30b0502ed2a33f1dbba8c"
        ),
        .binaryTarget(
            name: "RealmXcFramework",
            url: "https://github.com/realm/realm-swift/releases/download/v20.0.3/Realm.spm.zip",
            checksum: "6185f0f65c081da02ac90cd3e3db867dfa832cc2f8f7f4d7aba2f091994b311f"
        ),
        .testTarget(
            name: "MachoViewTests",
            dependencies: [
                "MachoLocalStorage",
                "MachoView"
            ]
        ),
        .testTarget(
            name: "MachoCoreTests",
            dependencies: [
                "MachoCore",
            ]
        )
    ]
)
