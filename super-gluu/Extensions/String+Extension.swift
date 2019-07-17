//
//  String+Extension.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 6/7/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    func getTime() -> String? {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        guard let dateTime = getNSDate() else { return nil }
        
        return formatter.string(from: dateTime)
    }
    
    func getDate() -> String? {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        guard let dateT = getNSDate() else { return nil }
        
        return formatter.string(from: dateT)
        
    }
    
    func getNSDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        
        let date: Date? = formatter.date(from: self)
        
        return date
    }
    
    // localization helper
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
}
