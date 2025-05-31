//
//  AppLogger.swift
//
//
//  Created by 佐藤汰一 on 2024/08/06.
//

import Logging

public struct AppLogger: Sendable {
    
    public static let shared = Self(label: "Macho")
    
    private let logger: Logger
    
    private init(label: String) {
        
        LoggingSystem.bootstrap { label in
            MachoStandardLogHandler(label)
        }
        
        var logger = Logger(label: label)
        
        #if DEBUG
        logger.logLevel = .debug
        #endif
        
        self.logger = logger
    }
    
    public func debug(file: String = #file,
                      function: String = #function,
                      line: Int = #line,
                      _ message: String) {
        
        logger.debug(Logger.Message(
            stringLiteral: "\(file.getFileNameWithExtension() ?? "") \(function) \(line): \(message)")
        )
    }
    
    public func info(file: String = #file,
                     function: String = #function,
                     line: Int = #line,
                     _ message: String) {
        
        logger.info(Logger.Message(stringLiteral: "\(file.getFileNameWithExtension() ?? "") \(function) \(line): \(message)"))
    }
    
    public func error(file: String = #file,
                      function: String = #function,
                      line: Int = #line,
                      _ message: String) {
        
        logger.error(Logger.Message(
            stringLiteral: "\(file.getFileNameWithExtension() ?? "") \(function) \(line): \(message)")
        )
    }
}
