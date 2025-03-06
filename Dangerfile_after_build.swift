import Danger
import DangerXCodeSummary
import DangerSwiftCoverage

let danger = Danger()

let resultBundlePath = "Build/test.xcresult"
Coverage.xcodeBuildCoverage(.xcresultBundle(resultBundlePath),
                            minimumCoverage: 50)
