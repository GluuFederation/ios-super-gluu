//
//  AuthHelper.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import ox_push3
import SCLAlertView

// Relates to String in https://github.com/GluuFederation/oxAuth/blob/master/Server/integrations/super_gluu/SuperGluuExternalAuthenticator.py#L400

enum OxRequestType: String {
    case authenticate = "authenticate"
    case enroll = "enroll"
    
    func localizedString() -> String {
        switch self {
            case .authenticate: return LocalString.Authentication.localized
            case .enroll: return LocalString.Registration.localized
        }
    }
    
}

@objc class AuthHelper: NSObject {
    
    static let shared = AuthHelper()
    
    let oxPushManager = OXPushManager()
    
    var requestDictionary: [AnyHashable : Any]?
    
    //This prevents others from using the default '()' initializer for this class.
    private override init() {}
    
    func handleRequest(isApproved: Bool, completion: @escaping (Bool, String?) -> Void) {
        handleRequest(isDecline: !isApproved) { (success, errorMessage) in
            if success {
                completion(true, LocalString.Success.localized)
            } else {
                completion(false, errorMessage)
            }
        }
    }
    
    
    fileprivate func handleRequest(isDecline: Bool, completion: @escaping (Bool, String?) -> Void) {
        
        guard let requestDictionary = self.requestDictionary else {
            completion(false, LocalString.Missing_Request_Info.localized)
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
            
            self.showAlert(requestType: requestType, isApproval: !isDecline, didSucceed: result != nil)
            
            NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_SHOW_FULLSCREEN_AD), object: nil)
            
            if result != nil {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    fileprivate func showAlert(requestType: OxRequestType?, isApproval: Bool, didSucceed: Bool) {
        guard let reqType = requestType else {
            return
        }
        
        let localSuccess = LocalString.Success.localized
        let localFail = LocalString.Oops.localized
        
        switch reqType {
        case .enroll:
            if didSucceed == true {
                if isApproval == true {
                    showAlertView(withTitle: localSuccess, andMessage: LocalString.Home_Registration_Success.localized)
                } else {
                    showAlertView(withTitle: LocalString.Home_Auth_Declined.localized, andMessage: nil)
                }
            } else {
                if isApproval == true {
                    showAlertView(withTitle: localFail, andMessage: LocalString.Home_Registration_Failed.localized)
                } else {
                    showAlertView(withTitle: localFail, andMessage: LocalString.Home_Decline_Failed.localized)
                }
            }

        case .authenticate:
            if didSucceed == true {
                if isApproval == true {
                    showAlertView(withTitle: LocalString.Home_Auth_Success.localized, andMessage: nil)
                } else {
                    showAlertView(withTitle: LocalString.Home_Auth_Declined.localized, andMessage: nil)
                }
            } else {
                if isApproval == true {
                    showAlertView(withTitle: localFail, andMessage: LocalString.Home_Auth_Failed.localized)
                } else {
                    showAlertView(withTitle: localFail, andMessage: LocalString.Home_Decline_Failed.localized)
                }
            }
        }
    }
    
    
    func showAlertView(withTitle title: String?, andMessage message: String?, withCloseButton: Bool = true) {
        let alert = SCLAlertView(autoDismiss: true, horizontalButtons: false)
        
        alert.showCustom(title ?? "",
                         subTitle: message ?? "",
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: LocalString.Ok.localized,
                         timeout: alert.dismissTimeout(),
                         circleIconImage: AppConfiguration.systemAlertIcon,
                         animationStyle: SCLAnimationStyle.topToBottom)
    }
}
