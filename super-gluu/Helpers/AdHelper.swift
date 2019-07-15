//
//  AdHelper.swift
//  Super Gluu
//
//  Created by Eric Webb on 6/25/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import Foundation
import UIKit

class AdHandler: NSObject {
    
    static let shared = AdHandler()
    
    var shouldShowAds = true
    
    func refreshAdStatus() {
        // if the user has a licensed key, don't show ads
        
        if GluuUserDefaults.licensedKeys()?.first != nil {
            shouldShowAds = false
            NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_FREE), object: nil)
        
        } else if let expirationDate = GluuUserDefaults.subscriptionExpirationDate(), expirationDate > Date() {
            shouldShowAds = false
            NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_FREE), object: nil)
        
        } else {
            shouldShowAds = true
            NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_NOT_FREE), object: nil)
            
//            PurchaseHandler.shared.hasValidSubscription(completion: { (hasSubscription) in
//                if hasSubscription {
//                    self.shouldShowAds = false
//                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_FREE), object: nil)
//                } else {
//                    self.shouldShowAds = true
//                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_NOT_FREE), object: nil)
//                }
//            })
        }
    }
}

