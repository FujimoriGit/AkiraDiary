import Danger
import DangerXCodeSummary
import DangerSwiftCoverage

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
let lintTargets = [
    "Macho/MachoFramework/Sources"
]

SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Macho/MachoFramework/Sources"),
               inline: true,
               configFile: "Macho/MachoFramework/Sources/.swiftlint.yml",
               swiftlintPath: swiftLintPath)

// カバレッジの確認

let resultBundlePath = "Build/test.xcresult"
Coverage.xcodeBuildCoverage(.xcresultBundle(resultBundlePath),
                            minimumCoverage: 50)
