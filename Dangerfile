# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

warn("PR大きすぎるよ！500行以下にしてもらえるとレビュワーが泣いて喜びます！😺") if git.lines_of_code > 500
warn("PRのタイトルが短すぎるよ！5行以上にしてね！🐶") if github.pr_title.length < 5
warn("PRの説明が短すぎるよ！レビュアーが見て分かる説明を書いてね！🦈") if github.pr_body.length < 100
warn("PRにassigneeが設定されてないよ！👹") unless github.pr_json["assignee"]

# PRで出た差分以外の部分に関しては無視する設定
github.dismiss_out_of_range_messages
# SwiftLintの設定
swiftlint.config_file = 'Macho/MachoFramework/Sources/.swiftlint.yml'
swiftlint.directory = "Macho/MachoFramework/Sources/"
# swiftlint.binary_path = ''
# swiftlint.lint_files inline_mode: true