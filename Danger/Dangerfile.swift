import Danger
// import DangerSwiftEda
// import DangerSwiftCoverage
// import DangerXCodeSummary

let danger = Danger()
let github = danger.github!

let editedFiles = danger.git.modifiedFiles + danger.git.createdFiles

if editedFiles.count - danger.git.deletedFiles.count > 500 {
//   warn("ソースコードの変更行が500行を超えています！PRの分割を検討してください！")
}

// Encourage writing up some reasoning about the PR, rather than just leaving a title.
// let body = github.pullRequest.body?.count ?? 0
// let linesOfCode = github.pullRequest.additions ?? 0
// if body < 3 && linesOfCode > 10 {
//     warn("プルリクエストの説明少ないんとちゃいまっか？もうちょっとだけ詳しく書いてもろてもええかね。")
// }

// if github.pullRequest.title.contains("WIP") {
//     warn("PR is classed as Work in Progress")
// }

// print("Running Swiftlint on changed files...")
// SwiftLint.lint(.files(editedFiles), inline: true, strict: true, quiet: false)
