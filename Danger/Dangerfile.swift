import Danger
import DangerSwiftCoverage

// MARK: - Run Review

let danger = Danger()

// PR自体のレビュー

if let github = danger.github {
    
    if (github.pullRequest.body?.count ?? 0) < 100 {
        warn("PRの説明が短すぎます。100行以上は書いてね！")
    }
    
    let changeLineCount = (github.pullRequest.additions ?? .zero) + (github.pullRequest.deletions ?? .zero)
    if (changeLineCount) >= 500 {
        warn("PRの変更行が多すぎます。500行以内にしてね！理想は400行！")
    }
}

// SwiftLintのレビュー

let swiftLintPath = SwiftLint.SwiftlintPath.bin(".build/artifacts/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/swiftlint-0.58.0-macos/bin/swiftlint")
let lintTargets: [SwiftLintTarget] = [
    .init(
        targetPath: "Macho/MachoFramework/Sources/MachoView",
        configPath: "Macho/MachoFramework/Sources/MachoView/.swiftlint.yml"
    ),
    .init(targetPath: "Macho/MachoFramework/Sources/MachoCore"),
    .init(
        targetPath: "Macho/MachoFramework/Sources/RealmHelper",
        configPath: "Macho/MachoFramework/Sources/RealmHelper/.swiftlint.yml"
    )
]

for targetInfo in lintTargets {
    SwiftLint.lint(.modifiedAndCreatedFiles(directory: targetInfo.targetPath),
                   inline: true,
                   configFile: targetInfo.configPath,
                   swiftlintPath: swiftLintPath)
}

// カバレッジの確認

let resultBundlePath = "Build/test.xcresult"
Coverage.xcodeBuildCoverage(.xcresultBundle(resultBundlePath),
                            minimumCoverage: 50)

// MARK: - Definition

struct SwiftLintTarget {
    
    let targetPath: String
    let configPath: String
    
    init(targetPath: String,
         configPath: String = "Macho/MachoFramework/Sources/.swiftlint.yml") {
        self.targetPath = targetPath
        self.configPath = configPath
    }
}
