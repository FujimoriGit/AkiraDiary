//
//  MachoStandardLogHandlerTest.swift
//  
//
//  Created by 佐藤汰一 on 2024/08/07.
//

import Logging
import XCTest
@testable import MachoCore

final class MachoStandardLogHandlerTest: XCTestCase {

    func testLogHandler() throws {
        
        LoggingSystem.bootstrap { _ in
            MachoStandardLogHandler()
        }
        
        var logger1 = Logger(label: "first logger")
        logger1.logLevel = .error
        logger1[metadataKey: "only-on"] = "first"
        
        var logger2 = Logger(label: "second logger")
        logger2.logLevel = .debug
        logger2[metadataKey: "only-on"] = "second"
        
        XCTAssertEqual(.error, logger1.logLevel)
        XCTAssertEqual(.debug, logger2.logLevel)
        XCTAssertEqual("first", logger1[metadataKey: "only-on"])
        XCTAssertEqual("second", logger2[metadataKey: "only-on"])
    }
}
