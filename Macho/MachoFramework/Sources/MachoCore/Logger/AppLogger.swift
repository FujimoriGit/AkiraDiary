//
//  AppLogger.swift
//
//
//  Created by 佐藤汰一 on 2024/08/06.
//

import Logging

public struct AppLogger {
    
    private var logger: Logger
    
    public init(label: String) {
        
        LoggingSystem.bootstrap { label in
            MachoStandardLogHandler(label)
        }
        
        logger = Logger(label: label)
        
        #if DEBUG
        logger.logLevel = .debug
        #endif
    }
    
    public func debug(file: String = #file,
                      function: String = #function,
                      line: Int = #line,
                      _ message: String) {
        
        logger.debug(Logger.Message(stringLiteral: "\(file.getFileNameWithExtension() ?? "") \(function) \(line): \(message)"))
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
        
        logger.error(Logger.Message(stringLiteral: "\(file.getFileNameWithExtension() ?? "") \(function) \(line): \(message)"))
    }
}
