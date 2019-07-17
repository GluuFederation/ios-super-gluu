//
//  PurchaseHandler.swift
//  Super Gluu
//
//  Created by Eric Webb on 6/26/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import SCLAlertView


class PurchaseHandler: NSObject {
    
    static let shared = PurchaseHandler()
    
    let monthlySubscriptionProductId = "com.gluu.org.monthly.ad.free"
    let sharedSecretKey = "44b38fbde32249fe9bf43e30c760ed94"
    
    func restorePurchase(completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
            
            self.hasValidSubscription(completion: { (success) in
                completion(success)
            })
        }
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = SCLAlertView(autoDismiss: true, horizontalButtons: true)
        
        alert.showCustom(title,
                         subTitle: message,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: "OK",
                         circleIconImage: AppConfiguration.systemAlertIcon,
                         animationStyle: SCLAnimationStyle.topToBottom)
 
    }
    
    
    func hasValidSubscription(completion: @escaping (Bool) -> Void ) {
        
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = self.monthlySubscriptionProductId
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    GluuUserDefaults.setSubscriptionExpiration(date: expiryDate)
                    completion(true)
                case .expired(let expiryDate, let items):
                    completion(false)
                case .notPurchased:
                    completion(false)
                    print("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                completion(false)
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func purchaseSubscription(completion: @escaping (Bool) -> Void ) {
        
        let productId = monthlySubscriptionProductId
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
            
            var msg: String?
            
            switch result {
                
            case .success(let purchase):
                
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                self.hasValidSubscription(completion: { (success) in
                    completion(success)
                })
                
            case .error(let error):
                switch error.code {
                    
                case .paymentCancelled:                    break
                case .unknown:                             msg = LocalString.Unknown_Error_Something.localized
                case .clientInvalid:                       msg = LocalString.Not_Allowed_Payment.localized
                case .paymentInvalid:                      msg = LocalString.Invalid_Purchase_Id.localized
                case .paymentNotAllowed:                   msg = LocalString.Unallowed_Device.localized
                case .storeProductNotAvailable:            msg = LocalString.Unavailable_Product.localized
                case .cloudServicePermissionDenied:        msg = LocalString.Unallowed_Cloud_Access.localized
                case .cloudServiceNetworkConnectionFailed: msg = LocalString.No_Network_Connection.localized
                default:
                    break
                }
                
                completion(false)
            
                if let message = msg {
                    let alert = SCLAlertView(autoDismiss: true, horizontalButtons: false)
                    
                    alert.showCustom(LocalString.Oops.localized,
                                     subTitle: message,
                                     color: AppConfiguration.systemColor,
                                     closeButtonTitle: "OK",
                                     timeout: alert.dismissTimeout(),
                                     circleIconImage: AppConfiguration.systemAlertIcon,
                                     animationStyle: SCLAnimationStyle.topToBottom)
                }
            }
        }
    }

    
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { products in
            
            for product in products {
                
                if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                    
                    if product.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                    print("purchased: \(product)")
                }
            }
        }
    }
}
