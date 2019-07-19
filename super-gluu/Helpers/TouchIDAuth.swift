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
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: LocalString.Enable_TouchID.localized, reply: { (success, error) in
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
        
        let reason = LocalString.Identify_Yourself.localized
        
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
                        message = LocalString.Identify_Verification_Problem.localized
                    case LAError.userCancel?:
                        message = LocalString.Cancel_Pressed.localized
                    case LAError.userFallback?:
                        message = LocalString.Password_Pressed.localized
                    default:
                        message = LocalString.TouchID_Not_Configured.localized
                    }
                    
                    completion(false, message)
                    
                }
            }
        }
    }
}
