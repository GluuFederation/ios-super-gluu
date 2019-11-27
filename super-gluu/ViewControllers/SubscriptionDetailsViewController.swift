//
//  SubscriptionDetailsViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 4/5/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit
import SafariServices
import SCLAlertView


class SubscriptionDetailsViewController: UIViewController {

    @IBOutlet var titleL: UILabel!
    @IBOutlet var descL: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    @IBOutlet var buttonsContainerView: UIView!
    @IBOutlet var restorePurchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissVC), name: NSNotification.Name(rawValue: GluuConstants.NOTIFICATION_AD_NOT_FREE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissVC), name: NSNotification.Name(rawValue: GluuConstants.NOTIFICATION_AD_FREE), object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonsContainerView.layer.shadowColor = UIColor.black.cgColor
        buttonsContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        buttonsContainerView.layer.shadowRadius = 6.0
        buttonsContainerView.layer.shadowOpacity = 0.4
        buttonsContainerView.layer.masksToBounds = false
        
    }

    func setupDisplay() {
        title = LocalString.Subscription_Details.localized
        
        titleL.text = LocalString.Details.localized
        
        // ** Local Text ( Check out line breaks here)
        descL.text = LocalString.Subscription_Info.localized //"The monthly subscription makes Super Gluu totally ad-free. After successfully purchasing you will not see banners ads or full screen ads.\n\nYour payment will be charged to your iTunes Account once you confirm your purchase.\n\nYour iTunes account will be charged again when your subscription automatically renews at the end of your current subscription period unless auto-renew is turned off at least 24 hours prior to end of the current period.\n\nAny unused portion of the free trial period will be forfeited when subscription is purchased. You can manage or turn off auto-renew in your Apple ID Account Settings any time after purchase."
        
        purchaseButton.backgroundColor = AppConfiguration.systemColor
        purchaseButton.layer.cornerRadius = purchaseButton.bounds.height / 2
        purchaseButton.setTitle(LocalString.Ad_Free_Promo.localized, for: .normal)
        
        restorePurchaseButton.setTitleColor(AppConfiguration.systemColor, for: .normal)
        restorePurchaseButton.setTitle(LocalString.Restore_Subscription.localized, for: .normal)
        
    }
    
    @IBAction func privacyTapped() {
        showWebVC(display: .privacy)
    }
    
    @IBAction func tosTapped() {
        showWebVC(display: .tos)
    }
    
    func showWebVC(display: WebDisplay) {
        let webVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webVC.display = display
        
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @IBAction func restorePurchaseTapped() {
        restorePurchaseButton.showSpinner(style: .gray)
        PurchaseHandler.shared.restorePurchase { (success) in
            self.restorePurchaseButton.hideSpinner()
            
            if success == true {
                AdHandler.shared.refreshAdStatus()
            } else {
                let alert = SCLAlertView(autoDismiss: true, horizontalButtons: false)
                
                alert.showCustom(LocalString.Unable_To_Restore.localized,
                                 subTitle: LocalString.Purchase_Not_Found.localized,
                                 color: AppConfiguration.systemColor,
                                 closeButtonTitle: LocalString.Ok.localized,
                                 timeout: alert.dismissTimeout(),
                                 circleIconImage: AppConfiguration.systemAlertIcon)
        
            }
        }
    }
    
    @IBAction func purchaseTapped() {
        purchaseButton.showSpinner()
        
        PurchaseHandler.shared.purchaseSubscription { (success) in
            self.purchaseButton.hideSpinner()

            if success == true {
                // update ads
                AdHandler.shared.refreshAdStatus()
            } else {
                // handled in PurchaseHandler
            }
        }
    }
    
    func showSafariForURL(URL: NSURL) {
        let viewController = SFSafariViewController(url: URL as URL)
        present(viewController, animated: true, completion: nil)
    }
    
    @objc
    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    
//    -(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    }
    


}
