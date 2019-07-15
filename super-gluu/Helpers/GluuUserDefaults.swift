//
//  GluuUserDefaults.swift
//  Super Gluu
//
//  Created by Eric Webb on 11/5/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import Foundation


@objc class GluuUserDefaults: NSObject {
    
    class func userPin() -> String? {
        return UserDefaults.standard.string(forKey: GluuConstants.PIN_CODE)
    }
    
    class func setUserPin(newPin: String) {
        UserDefaults.standard.set(newPin, forKey: GluuConstants.PIN_CODE)
        UserDefaults.standard.set(true, forKey: GluuConstants.PIN_ENABLED)
    }
    
    class func removeUserPin() {
        UserDefaults.standard.removeObject(forKey: GluuConstants.PIN_CODE)
        UserDefaults.standard.set(false, forKey: GluuConstants.PIN_ENABLED)
    }
    
    class func setTouchAuth(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: GluuConstants.TOUCH_ID_ENABLED)
    }
    
    class func hasTouchAuthEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.TOUCH_ID_ENABLED)
    }
    
    class func isSSLEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.SSL_ENABLED)
    }
    
    class func setSSLEnabled(isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: GluuConstants.SSL_ENABLED)
    }
    
    class func isFirstLoad() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.IS_FIRST_LOAD)
    }
    
    class func setFirstLoad() {
        UserDefaults.standard.set(true, forKey: GluuConstants.IS_FIRST_LOAD)
    }
    
    class func hasSeenSecurityPrompt() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.SECURITY_PROMPT_SHOWN)
    }
    
    class func setSecurityPromptShown() {
        UserDefaults.standard.set(true, forKey: GluuConstants.SECURITY_PROMPT_SHOWN)
    }
    
    class func setSubscriptionExpiration(date: Date?) {
        UserDefaults.standard.set(date, forKey: GluuConstants.SUBSCRIPTION_EXPIRY_DATE)
    }
    
    class func subscriptionExpirationDate() -> Date? {
        return UserDefaults.standard.value(forKey: GluuConstants.SUBSCRIPTION_EXPIRY_DATE) as? Date
    }
    
    class func licensedKeys() -> [String]? {
        return UserDefaults.standard.array(forKey: GluuConstants.LICENSED_KEYS) as? [String]
    }
    
    class func saveLicensedKey(_ key: String) {
        var newKeyArray: [String]?
        if var licensedKeys = GluuUserDefaults.licensedKeys() {
            if licensedKeys.contains(key) == false {
                licensedKeys.append(key)
            }
            newKeyArray = licensedKeys
        } else {
            newKeyArray = [key]
        }
        
        UserDefaults.standard.set(newKeyArray, forKey: GluuConstants.LICENSED_KEYS)
        
        AdHandler.shared.refreshAdStatus()
    }
    
    class func removeLicensedKey(_ key: String) {
        
        guard let licensedKeys = GluuUserDefaults.licensedKeys(), licensedKeys.contains(key) else {
            return
        }
        
        let cleanedKeys = licensedKeys.filter({ $0 != key })
        
        UserDefaults.standard.set(cleanedKeys, forKey: GluuConstants.LICENSED_KEYS)
        
        AdHandler.shared.refreshAdStatus()
        
    }
}
