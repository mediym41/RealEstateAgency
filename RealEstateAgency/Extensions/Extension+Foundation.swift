//
//  Extension+Foundation.swift
//  MediumChat.ios
//
//  Created by Mediym on 3/7/19.
//  Copyright © 2019 Mediym. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func updated(with key: NSAttributedString.Key, value: Any) -> NSAttributedString {
        let result = NSMutableAttributedString(string: self)
        result.addAttribute(key, value: value,
                            range: NSRange(location:0, length: self.count)
        )
        return result
    }
}

extension NSAttributedString {
    func updated(with key: NSAttributedString.Key, value: Any, in range: NSRange? = nil) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        let range = range ?? NSRange(location: 0, length: self.length)
        
        result.addAttribute(key, value: value, range: range)
        return result
    }
    
    func updated(with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        result.addAttributes(attributes, range: NSRange(location:0, length: self.length))
        return result
    }
}

extension Date {
    var yearsOld: Int {
        let now = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: self, to: now)
        return ageComponents.year!
    }
    
    public static func dateUS(from value:String?) -> Date? {
        return date(from: value, with: "MM/dd/yyyy")
    }
    
    public static func dateEU(from value:String?) -> Date? {
        return date(from: value, with: "yyyy-MM-dd")
    }
    
    public static func dateCustom(from value:String?) -> Date? {
        return date(from: value, with: "yyyy-MM-dd HH:mm:ss")
    }
    
    public static func date(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        return calendar.date(from: components) ?? Date()
    }
    
    public static func date(from value: String?, with format: String) -> Date? {
        guard let value = value else {
            return nil
        }
        let formatter = DateFormatter(locale: "en-US")
        formatter.dateFormat = format
        return formatter.date(from: value)
    }
    
    public func formatted(format: String) -> String {
        let formatter = DateFormatter(locale: "en-US")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var formattedUS: String {
        return formatted(format: "MM/dd/yyyy")
    }
    
    var formattedEU: String {
        return formatted(format: "yyyy-MM-dd")
    }
    
    var time: String {
        return formatted(format: "hh:mm a")
    }
    
    var formattedISO8601: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

extension DateFormatter {
    convenience init(locale: String) {
        self.init()
        self.locale = Locale(identifier: locale)
    }
    
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}
