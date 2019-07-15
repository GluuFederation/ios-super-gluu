//
//  UIViewController+SuperGluu.swift
//  Super Gluu
//
//  Created by Eric Webb on 9/25/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit

extension UIViewController {

    class func fromStoryboard(_ name: String = "Main") -> Self {
        return instantiateFromStoryboardHelper(name)
    }

    class func instantiateFromStoryboardHelper<T>(_ name: String) -> T {
        
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        let identifier = String(describing: self)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            return (UIViewController() as? T)!
        }
        
        return controller
        
    }
    
    /*
     Convenience method for delaying a block from executing
     */
    public func delay(delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    public func noti(_ name: String) -> Notification.Name {
        return Notification.Name(name)
    }

}
