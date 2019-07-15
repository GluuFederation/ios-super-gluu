//
//  AuthHelper.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import ox_push3

enum OxRequestType: String {
    case authenticate = "authenticate"
    case enroll = "enroll"
}

@objc class AuthHelper: NSObject {
    
    static let shared = AuthHelper()
    
    let oxPushManager = OXPushManager()
    
    var requestDictionary: [AnyHashable : Any]?
    
    //This prevents others from using the default '()' initializer for this class.
    private override init() {}
    
    func approveRequest(completion: @escaping (Bool, String?) -> Void) {
        
        handleRequest(isDecline: false) { (success, errorMessage) in
            if success {
                completion(true, "Success!")
            } else {
                completion(false, errorMessage)
            }
        }
    }
    
    func denyRequest(completion: @escaping (Bool, String?) -> Void) {
        
        handleRequest(isDecline: true) { (success, errorMessage) in
            if success {
                completion(true, "Success!")
            } else {
                completion(false, errorMessage)
            }
        }
    }
    
    fileprivate func handleRequest(isDecline: Bool, completion: @escaping (Bool, String?) -> Void) {
        
        guard let requestDictionary = self.requestDictionary else {
            completion(false, "Missing request info")
            return
        }
        
        oxPushManager.onOxPushApproveRequest(requestDictionary, isDecline: isDecline, isSecureClick: false){ (result, error) in
            
            var requestType: OxRequestType?
            
            if let requestTypeStr: String = requestDictionary["method"] as? String,
                let requestMethod = OxRequestType(rawValue: requestTypeStr) {
                switch requestMethod {
                case .enroll: requestType = OxRequestType.enroll
                case .authenticate: requestType = OxRequestType.authenticate
                }
            }
            
            self.postNotification(requestType: requestType, isApproval: !isDecline, didSucceed: result != nil)
            
            if result != nil {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    fileprivate func postNotification(requestType: OxRequestType?, isApproval: Bool, didSucceed: Bool) {
        guard let reqType = requestType else {
            return
        }
        
        switch reqType {
        case .enroll:
            if didSucceed == true {
                if isApproval == true {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_REGISTRATION_SUCCESS), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_DECLINE_SUCCESS), object: nil)
                }
            } else {
                if isApproval == true {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_REGISTRATION_FAILED), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_DECLINE_FAILED), object: nil)
                }
            }

        case .authenticate:
            if didSucceed == true {
                if isApproval == true {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AUTENTIFICATION_SUCCESS), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_DECLINE_SUCCESS), object: nil)
                }
            } else {
                if isApproval == true {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AUTENTIFICATION_FAILED), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_DECLINE_FAILED), object: nil)
                }
            }
        }
    }
}
