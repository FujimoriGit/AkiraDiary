// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dangerfile",
    platforms: [.macOS(.v14)],
    products: [.library(name: "DangerDeps", type: .dynamic, targets: ["Dangerfile"])],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", exact: "3.21.1"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.58.0")
    ],
    targets: [
        .target(
            name: "Dangerfile",
            dependencies: [
                .product(name: "Danger", package: "swift")
            ]
        ),
    ]
)
