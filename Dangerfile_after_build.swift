import Danger
import DangerXCodeSummary
import DangerSwiftCoverage

let danger = Danger()

Coverage.xcodeBuildCoverage(.derivedDataFolder("Build/test.xcresult"),
                            minimumCoverage: 50)
