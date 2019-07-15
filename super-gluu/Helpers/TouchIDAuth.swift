//
//  TouchIDAuth.swift
//  Super Gluu
//
//  Created by Eric Webb on 3/8/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit
import LocalAuthentication


@objc class TouchIDAuth: NSObject {
    
    let context = LAContext()
    
    func canEvaluatePolicy() -> Bool {
        
        var error: NSError?
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            
            if #available(iOS 11.0, *) {
                
                if (context.biometryType == .touchID) {
                    return true
                }
                
            } else {
                return true
            }
            
        } else {
            
            // check to see if they need to enter their passcode
            // due to touchId attempts failing too many times
            if error?.code == -8 {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "To enable touch auth", reply: { (success, error) in
                    return success
                })
            } else {
                return false
            }
        }
        
        return false
        
    }

    
    func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        
        guard canEvaluatePolicy() else {
            return
        }
        
        let reason = "Identify yourself!"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            [unowned self] success, authenticationError in
            
            DispatchQueue.main.async {
                if success {
                    completion(success, nil)
                    //                    self.runSecretCode()
                } else {
                    
                    let message: String
                    
                    switch authenticationError {
                        
                    case LAError.authenticationFailed?:
                        message = "There was a problem verifying your identity."
                    case LAError.userCancel?:
                        message = "You pressed cancel."
                    case LAError.userFallback?:
                        message = "You pressed password."
                    default:
                        message = "Touch ID may not be configured"
                    }
                    
                    completion(false, message)
                    
                }
            }
        }
    }
}
