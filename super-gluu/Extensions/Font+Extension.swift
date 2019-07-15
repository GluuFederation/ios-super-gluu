//
//  Font+Extension.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/4/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func light(_ size: Float) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(size), weight: .thin)
    }
    
    class func regular(_ size: Float) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(size), weight: .regular)
    }
    
    class func medium(_ size: Float) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(size), weight: .medium)
    }
    
    class func semibold(_ size: Float) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(size), weight: .semibold)
    }
    
    class func bold(_ size: Float) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(size), weight: .bold)
    }
    
}
