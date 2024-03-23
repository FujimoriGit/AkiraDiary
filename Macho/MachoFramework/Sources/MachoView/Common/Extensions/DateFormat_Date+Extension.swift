//
//  DateFormat_Date+Extension.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/03/02.
//

import Foundation

extension Date {
    
    /// 文字列に変換する
    /// - Parameters:
    ///   - format: 変換後のフォーマット
    ///   - timeZone: 指定のタイムゾーン
    ///   - isOmissionTens: 1桁の場合十の位を省略するかどうか、trueの場合は省略
    /// - Returns: 指定のフォーマットに文字列として返す
    func toString(_ format: Format, timeZone: TimeZone = .current, isOmissionTens: Bool = false) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.getFormatString(omissionTens: isOmissionTens)
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: self)
    }
    
    struct Format {
        
        private let date: DateFormat
        private let time: TimeFormat?
        
        fileprivate func getFormatString(omissionTens: Bool) -> String {
            
            guard let time = time else {
                
                return date.getFormatString(omissionTens: omissionTens)
            }
            
            return date.getFormatString(omissionTens: omissionTens)
            + " "
            + time.getFormatString(omissionTens: omissionTens)
        }
        
        init(date: DateFormat = .basic, time: TimeFormat? = nil) {
            
            self.date = date
            self.time = time
        }
    }
    
    enum DateFormat {
        
        /// yyyy/MM/dd(ex. 2000:01:01)
        case basic
        /// yyyy年MM月dd日(ex. 2000年01月01日)
        case jp
        
        fileprivate func getFormatString(omissionTens: Bool) -> String {
            
            switch self {
                
            case .basic:
                return omissionTens ? "yyyy/M/d" : "yyyy/MM/dd"
                
            case .jp:
                return omissionTens ? "yyyy年M月d日" : "yyyy年MM月dd日"
            }
        }
    }
    
    enum TimeFormat {
        
        /// hh:mm:ss(ex. 00:01:01)
        case short_basic
        /// hh時mm分ss秒(ex. 00時00分00秒)
        case short_jp
        /// hh:mm:SS.sss(ex. 00:01:01.000)
        case large_basic
        /// hh時mm分SS.sss秒(ex. 00時00分00.000秒)
        case large_jp
        
        fileprivate func getFormatString(omissionTens: Bool = false) -> String {
            
            switch self {
                
            case .short_basic:
                return omissionTens ? "h:m:S" : "hh:mm:SS"
                
            case .short_jp:
                return omissionTens ? "h時m分S秒" : "hh時mm分SS秒"
                
            case .large_basic:
                return omissionTens ? "h:m:S.sss" : "hh:mm:SS.sss"
                
            case .large_jp:
                return omissionTens ? "h時m分S.sss秒" : "hh時mm分SS.sss秒"
            }
        }
    }
}
