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
            guard let newValue = newValue else { return }
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
    
    func log(level: Logging.Logger.Level,
             message: Logging.Logger.Message,
             metadata: Logging.Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt) {
        
        showLog(level: level, message: message)
    }
}

private extension MachoStandardLogHandler {
    
    func showLog(level: Logging.Logger.Level, message: Logging.Logger.Message) {
        
        switch level {

        case .debug:
            logger.debug("🟢 [debug] [\(subSystemName)] \(getCurrentTimeString()) \(message, privacy: .public)")
        case .info:
            logger.debug("🟣 [info] [\(subSystemName)] \(getCurrentTimeString()) \(message)")
        case .error:
            logger.debug("🟥 [error] [\(subSystemName)] \(getCurrentTimeString()) \(message)")
        default:
            logger.debug("🟢 [debug] [\(subSystemName)] \(getCurrentTimeString()) \(message)")
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
