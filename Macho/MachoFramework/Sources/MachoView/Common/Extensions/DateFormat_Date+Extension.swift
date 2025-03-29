// swiftlint:disable:this file_name
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
    ///   - locale: 指定のロケール(デフォルトは日本)
    /// - Returns: 指定のフォーマットに文字列として返す
    func formatted(_ format: Date.MachoFormat,
                   timeZone: TimeZone = .current,
                   locale: Locale = Locale(identifier: "ja-JP")) -> String {
        
        return formatted(format.getFormat(timeZone: timeZone, locale: locale))
    }
    
    enum MachoFormat {
        
        /// yyyy/MM/dd
        case date
        /// yyyy年MM月dd日 hh:mm:SS
        case localeDateTime
        
        fileprivate func getFormat(timeZone: TimeZone,
                                   locale: Locale) -> FormatStyle {
            
            var resultFormat = FormatStyle(date: dateStyle, time: timeStyle, locale: locale)
            resultFormat.timeZone = timeZone
            resultFormat.locale = locale
            
            return resultFormat
        }
        
        private var dateStyle: FormatStyle.DateStyle? {
            
            switch self {
                
            case .date:
                return .numeric
                
            case .localeDateTime:
                return .abbreviated
            }
        }
        
        private var timeStyle: FormatStyle.TimeStyle? {
            
            switch self {
                
            case .date:
                return .omitted
                
            case .localeDateTime:
                return .standard
            }
        }
    }
}
