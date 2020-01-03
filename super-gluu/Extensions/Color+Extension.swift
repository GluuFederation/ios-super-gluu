//
//  Color+Extension.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/1/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit


extension UIColor {

    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat? = 1.0) {
        
        let newRed   = CGFloat(Double(red)   / 255.0)
        let newGreen = CGFloat(Double(green) / 255.0)
        let newBlue  = CGFloat(Double(blue)  / 255.0)
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha:alpha ?? 1.0)
        
    }

    struct Gluu {
        
        static let green           = UIColor(red: 0, green: 161, blue: 97)
        static let darkGreyText    = UIColor(red: 100, green: 100, blue: 100)
        static let lightGreyText   = UIColor(red: 180, green: 180, blue: 180)
        static let separator       = UIColor(red: 210, green: 210, blue: 210)
        static let tableBackground = UIColor(red: 247, green: 247, blue: 247)

    }
	
}
