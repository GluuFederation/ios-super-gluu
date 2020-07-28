//
//  PushNotificationsHelper.swift
//  Super Gluu
//
//  Created by eric webb on 12/6/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit
import ox_push3



enum PushAction {
    case approve
    case decline
    case none
}

class PushHelper: NSObject {
    
    static let shared = PushHelper()
    
    var lastPush: PushNoti? {

        didSet {
            guard lastPush != nil else { return }
            
            initUserInfo(self.lastPush?.userInfo)
            AuthHelper.shared.requestDictionary =  lastPush?.userInfo
        }
    }
    
    fileprivate func initUserInfo(_ parameters: [AnyHashable : Any]?) {
        
        let app = parameters?["app"] as? String ?? ""
        let created = "\(Date())"
        let issuer = parameters?["issuer"] as? String ?? ""
        let username = parameters?["username"] as? String ?? ""
        let method = parameters?["method"] as? String ?? ""
        
        let isLicensedInt = parameters?["licensed"] as? Int ?? 0
        let isLicensed: Bool = isLicensedInt != 0
        
        let oneStep: Bool = username.isEmpty ? true : false
        
        UserLoginInfo.sharedInstance().application = app
        UserLoginInfo.sharedInstance().created = created
        UserLoginInfo.sharedInstance().issuer = issuer
        UserLoginInfo.sharedInstance().userName = username
        
        if let authType = OxRequestType(rawValue: method) {
            UserLoginInfo.sharedInstance().authenticationType = authType.rawValue
        } else {
            print("Auth Type Error in PushNotificationsHelper")
        }
        
        // we use the token application combined with the username to identify a licensed key
        
        let keyIssuer = app + username
        
        // if isLicensed is true, this is a licensed account and
        // ads should not display. As long as the user has 1 key that is licensed
        // ads should not display, regardless of other unlicensed keys the user has
        
        if isLicensed == true {
//            print("Saving Licensed Key")
            GluuUserDefaults.saveLicensedKey(keyIssuer)
            AdHandler.shared.refreshAdStatus()
        } else {
//            print("Removing Licensed Key")
            GluuUserDefaults.removeLicensedKey(keyIssuer)
            AdHandler.shared.refreshAdStatus()
        }
        
        // ** Local Text
        let mode = oneStep ? NSLocalizedString("OneStepMode", comment: "One Step") : NSLocalizedString("TwoStepMode", comment: "Two Step")
        UserLoginInfo.sharedInstance().authenticationMode = mode
        UserLoginInfo.sharedInstance().locationCity = parameters?["req_loc"] as? String ?? ""
        UserLoginInfo.sharedInstance().locationIP = parameters?["req_ip"] as? String ?? ""
    }
    
}


struct PushNoti {
    var receivedDate: Date = Date()
    var action = PushAction.none {
        didSet {
            print("Action:\(action)")
        }
    }
    var userInfo: [AnyHashable : Any]? = nil
    
    var isExpired: Bool {
        print("Current Date: \(Date())")
        print("Received Date: \(receivedDate)")
        print("Elapsed Time: \(Date().timeIntervalSince(receivedDate))")
        
        return Date().timeIntervalSince(receivedDate) > GluuConstants.PUSH_EXPIRY
    }
    
    var timeTillExpired: TimeInterval {
        return GluuConstants.PUSH_EXPIRY - Date().timeIntervalSince(receivedDate)
    }
    
    init(pushData: [AnyHashable : Any]?, action: PushAction = PushAction.none) {
        self.userInfo = self.parsedInfo(pushData)
        self.action = action
    }
    
    fileprivate func parsedInfo(_ pushData: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        
        guard
            let data = pushData,
            let requestItem = data["request"] else {
                return nil
        }
        
        var dataOrNil: Data?
        
        if let requestString = requestItem as? String {
            dataOrNil = requestString.data(using: .utf8)
        } else if let requestDict = requestItem as? [AnyHashable : Any] {
            dataOrNil = try? JSONSerialization.data(withJSONObject: requestDict, options: .prettyPrinted)
        }
        
        guard
            let finalData = dataOrNil,
            let json = try? JSONSerialization.jsonObject(with: finalData, options: []) as? [AnyHashable : Any] else {
                return nil
        }
        
        
        return json
        
    }
}

