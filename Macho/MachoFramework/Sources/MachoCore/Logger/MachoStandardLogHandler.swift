//
//  OutputConsoleLogHandler.swift
//
//
//  Created by 佐藤汰一 on 2024/08/07.
//

import Logging
import OSLog

struct MachoStandardLogHandler: LogHandler {
    
    subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set(newValue) {
            guard let newValue else { return }
            metadata.updateValue(newValue, forKey: metadataKey)
        }
    }
        
    var metadata = Logger.Metadata()
    var logLevel: Logging.Logger.Level = .info
    
    private let logger: os.Logger
    private let subSystemName: String
    
    init(_ subSystemName: String) {
        
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: subSystemName)
        self.subSystemName = subSystemName
    }
    
    // swiftlint:disable:next function_parameter_count
    func log(level: Logging.Logger.Level,
             message: Logging.Logger.Message,
             metadata: Logging.Logger.Metadata?, // swiftlint:disable:this unused_parameter
             source: String, // swiftlint:disable:this unused_parameter
             file: String, // swiftlint:disable:this unused_parameter
             function: String, // swiftlint:disable:this unused_parameter
             line: UInt) { // swiftlint:disable:this unused_parameter
        
        showLog(level: level, message: message)
    }
}

private extension MachoStandardLogHandler {
    
    func showLog(level: Logging.Logger.Level, message: Logging.Logger.Message) {
        
        switch level {

        case .debug:
            logger.debug("\(getCurrentTimeString()) 🟢 [debug] [\(subSystemName)] \(message, privacy: .public)")
        case .info:
            logger.debug("\(getCurrentTimeString()) 🟣 [info] [\(subSystemName)] \(message)")
        case .error:
            logger.debug("\(getCurrentTimeString()) 🟥 [error] [\(subSystemName)] \(message)")
        default:
            logger.debug("\(getCurrentTimeString()) 🟢 [debug] [\(subSystemName)] \(message)")
        }
    }
    
    func getCurrentTimeString() -> String {
        
        let dateTime = DateFormatter()
        dateTime.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS"
        dateTime.locale = Locale.current
        dateTime.timeZone = TimeZone.current
        return dateTime.string(from: Date())
    }
}
