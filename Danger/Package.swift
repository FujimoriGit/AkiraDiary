// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dangerfile",
    platforms: [.macOS(.v14), .iOS(.v16)],
    products: [
        .library(
            name: "Danger",
            type: .dynamic,
            targets: ["MachoDanger"]
        ),
    ],
    dependencies: [
        // Danger
        .package(url: "https://github.com/danger/swift.git", from: "3.0.0"),
        // Danger Plugins
        .package(url: "https://github.com/f-meloni/danger-swift-xcodesummary.git", from: "1.2.0"),
        .package(url: "https://github.com/f-meloni/danger-swift-coverage.git", from: "1.2.0"),
        .package(url: "https://github.com/yumemi-inc/danger-swift-eda.git", from: "0.1.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.45.0")
    ],
    targets: [
        .target(
            name: "MachoDanger",
            dependencies: [
                .product(name: "Danger", package: "swift"),
                .product(name: "DangerSwiftCoverage", package: "danger-swift-coverage"),
                .product(name: "DangerXCodeSummary", package: "danger-swift-xcodesummary"),
                .product(name: "DangerSwiftEda", package: "danger-swift-eda"),
                .product(name: "swiftlint", package: "SwiftLint"),
            ]
        ),
    ]
)
