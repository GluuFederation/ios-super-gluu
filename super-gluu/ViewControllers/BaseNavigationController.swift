//
//  BaseNavigationController.swift
//  Super Gluu
//
//  Created by Eric Webb on 1/6/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    func unwindToRoot() {
        performSegue(withIdentifier: "unwindToRoot", sender: nil)
    }
    
    func popToRoot() {
        popToRootViewController(animated: false)
    }

}
