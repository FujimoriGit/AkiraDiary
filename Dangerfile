# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500
