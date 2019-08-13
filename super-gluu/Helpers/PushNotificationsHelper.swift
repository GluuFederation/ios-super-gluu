//
//  PushNotificationsHelper.swift
//  Super Gluu
//
//  Created by eric webb on 12/6/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit

class PushHelper: NSObject {
    
    static let shared = PushHelper()
    
    var lastPush: PushNoti?
    
    
    func isLastPushExpired() -> Bool {
        
        let pushReceivedDate = UserDefaults.standard.object(forKey: GluuConstants.PUSH_CAME_DATE) as? Date
        
        if pushReceivedDate == nil {
            return false
        }
        
        let currentDate = Date()
        var distanceBetweenDates: TimeInterval? = nil
        
        if let aDate = pushReceivedDate {
            distanceBetweenDates = currentDate.timeIntervalSince(aDate)
        }
        let seconds = distanceBetweenDates ?? 0
        
        UserDefaults.standard.removeObject(forKey: GluuConstants.PUSH_CAME_DATE)
        
        return seconds > GluuConstants.PUSH_EXPIRY
        
    }
    
    func parsedInfo(_ pushInfo: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        
        guard
            let pushInfo = pushInfo,
            let requestItem = pushInfo["request"] else {
            return nil
        }
        
        var dataOrNil: Data?
        
        if let requestString = requestItem as? String {
            dataOrNil = requestString.data(using: .utf8)
        } else if let requestDict = requestItem as? [AnyHashable : Any] {
            dataOrNil = try? JSONSerialization.data(withJSONObject: requestDict, options: .prettyPrinted)
        }
        
        guard
            let data = dataOrNil,
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else {
            return nil
        }

        
        return json
        
    }
    
    func handlePush() {
        // call approve/deny
        // do what home screen does. If the action is approve/decline, do that.
        // otherwise, show the approve/deny screen
        // this gets triggered in RootContainerVC when user gets through the Landing VC
        // and enters the app securely
        
    }
}


struct PushNoti {
    var date: Date?
    var userInfo: [AnyHashable : Any]?
    var action: PushAction?
}


enum PushAction {
    case approve
    case decline
    case none
}

/*
 
 
 
 
 
 
 
*/
