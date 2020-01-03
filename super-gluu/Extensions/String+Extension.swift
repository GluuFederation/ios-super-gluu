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
    
    private func getNSDate() -> Date? {
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
