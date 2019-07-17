//
//  Constants.swift
//  Super Gluu
//
//  Created by eric webb on 12/6/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import Foundation
import UIKit


fileprivate func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

struct AlertConstants {
    static let yes = LocalString.Yes.localized
    static let no = LocalString.No.localized
    static let delete = LocalString.Delete.localized
}

struct GluuConstants {
    
    // Settings
    static let PRIVACY_POLICY = "https://docs.google.com/document/d/1E1xWq28_f-tam7PihkTZXhlqaXVGZxJbVt4cfx15kB4/edit#heading=h.ifitnnlwr25"
    static let TERMS_OF_SERVICE = "https://gluu.org/docs/supergluu/user-guide/"
    
    // Google Ads
    static let AD_UNIT_ID_BANNER = "ca-app-pub-3326465223655655/9778254436"
    static let AD_UNIT_ID_INTERSTITIAL = "ca-app-pub-3326465223655655/1731023230"
    
    
    static let PIN_PROTECTION_ID = "enabledPinCode"
    static let PIN_SIMPLE_ID = "simplePinCode"
    static let PIN_CODE = "PinCode"
    static let PIN_ENABLED = "PinCodeEnabled"
    static let PIN_TYPE_IS_4_DIGIT = "is_4_digit"
    static let SSL_ENABLED = "is_ssl_enabled"
    static let TOUCH_ID_ENABLED = "is_touchID_enabled"
    static let SECURE_CLICK_ENABLED = "secure_click_enabled"
    static let IS_FIRST_LOAD = "firstLoad"
    static let SECURITY_PROMPT_SHOWN = "securityPromptyShown"
    static let NOTIFICATION_PROMPT = "notificationPrompt"
    static let NOTIFICATION_AD_FREE = "NOTIFICATION_AD_FREE"
    static let NOTIFICATION_AD_NOT_FREE = "NOTIFICATION_AD_NOT_FREE"
    static let LICENSED_KEYS = "LICENSED_KEYS"
    static let SUBSCRIPTION_EXPIRY_DATE = "SUBSCRIPTION_EXPIRY_DATE"
    
    
    static let LOCKED_DATE = "locked_app_date"
    
    static let PUSH_CAME_DATE = "push_recieved_time"
    
    static let LICENSED_AD_FREE = "licensed_AD_FREE"
    
    static let NotificationRequest = "PUSH_NOTIFICATION_REQUEST"
    static let NotificationRequestActionsApprove = "PUSH_NOTIFICATION_REQUEST_ACTION_APPROVE"
    static let NotificationRequestActionsDeny = "PUSH_NOTIFICATION_REQUEST_ACTION_DENY"
    
    static let NotificationCategoryIdent = "ACTIONABLE"
    static let NotificationActionDeny = "ACTION_DENY"
    static let NotificationActionApprove = "ACTION_APPROVE"
    
    static let NOTIFICATION_REGISTRATION_SUCCESS = "NOTIFICATION_REGISTRATION_SUCCESS"
    static let NOTIFICATION_REGISTRATION_FAILED = "NOTIFICATION_REGISTRATION_FAILED"
    static let NOTIFICATION_AUTENTIFICATION_SUCCESS = "NOTIFICATION_AUTENTIFICATION_SUCCESS"
    static let NOTIFICATION_AUTENTIFICATION_FAILED = "NOTIFICATION_AUTENTIFICATION_FAILED"
    static let NOTIFICATION_REGISTRATION_STARTING  = "NOTIFICATION_REGISTRATION_STARTING"
    static let NOTIFICATION_AUTENTIFICATION_STARTING = "NOTIFICATION_AUTENTIFICATION_STARTING"
    
    static let NOTIFICATION_DECLINE_SUCCESS = "NOTIFICATION_DECLINE_SUCCESS"
    static let NOTIFICATION_DECLINE_FAILED = "NOTIFICATION_DECLINE_FAILED"
    static let NOTIFICATION_DECLINE_STARTING = "NOTIFICATION_DECLINE_STARTING"
    
    static let NOTIFICATION_SCANNING_QR = "NOTIFICATION_SCANNING_QR"
    static let NOTIFICATION_SCANNING_CANCELED = "NOTIFICATION_SCANNING_CANCELED"
    
    static let NOTIFICATION_PUSH_RECEIVED = "NOTIFICATION_PUSH_RECEIVED"
    static let NOTIFICATION_PUSH_RECEIVED_APPROVE = "NOTIFICATION_PUSH_RECEIVED_APPROVE"
    static let NOTIFICATION_PUSH_RECEIVED_DENY = "NOTIFICATION_PUSH_RECEIVED_DENY"
    static let NOTIFICATION_PUSH_TIMEOVER = "NOTIFICATION_PUSH_TIMEOVER"
    static let NOTIFICATION_PUSH_ONLINE  = "NOTIFICATION_PUSH_ONLINE"
    static let NOTIFICATION_FAILED_KEYHANDLE = "NOTIFICATION_FAILED_KEYHANDLE"
    static let NOTIFICATION_UNSUPPORTED_VERSION = "NOTIFICATION_UNSUPPORTED_VERSION"
    
    static let NOTIFICATION_ERROR = "ERRROR"
    
    static let INIT_SECURE_CLICK_NOTIFICATION = "INIT_SECURE_CLICK_NOTIFICATION"
    static let DID_DISCONNECT_PERIPHERAL = "didDisconnectPeripheral"
    
    
    static let NETWORK_UNREACHABLE_TEXT = "Your device is currently unable to establish a network connection. You will need a connection to approve or deny authentication requests"
    
    static let MAX_PASSCODE_ATTEMPTS_COUNT = 5
    static let LOCKOUT_DURATION: TimeInterval = 10*60
    
    static let WAITING_TIME: TimeInterval = 40
    
    static let CORNER_RADIUS: CGFloat = 8.0
    static let BUTTON_CORNER_RADIUS: CGFloat = 5.0
    
    static let IS_IPHONE_5 = screenheight == 480.0
    static let IS_IPHONE_6 = screenheight == 568.0
    static let IS_IPHONE_7 = screenheight == 667.0
    
}

