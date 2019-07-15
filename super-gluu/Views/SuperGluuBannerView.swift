//  SuperGluuBannerView.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 5/2/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import GoogleMobileAds
import UIKit

class SuperGluuBannerView: UIView, GADInterstitialDelegate {
    
    
    private var bannerView: GADBannerView?
    var interstitial: GADInterstitial?

    // add bannerview in Storyboard and use this to display banner ad
    func loadBannerAd() {

        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView?.adUnitID = GluuConstants.AD_UNIT_ID_BANNER
        
        if let app = UIApplication.shared.delegate, let window = app.window {

            bannerView?.rootViewController = window?.rootViewController
        }

        if let aView = bannerView {
            addSubview(aView)
        }
        let bannerCenter = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        bannerView?.center = bannerCenter
        bannerView?.load(GADRequest())
    }

    convenience init(adSize: GADAdSize, andRootViewController rootVC: UIViewController?) {
        //Determine type of AD (banner or interstitial)
        
        let frm = CGRect(x: 0, y: 0, width: adSize.size.width, height: adSize.size.height)
        
        self.init(frame: frm)

        if adSize.size.height == kGADAdSizeBanner.size.height && adSize.size.width == kGADAdSizeBanner.size.width {

            //Banner
            if bannerView == nil {
                backgroundColor = UIColor.red
                bannerView = GADBannerView(adSize: adSize)
                bannerView?.adUnitID = GluuConstants.AD_UNIT_ID_BANNER
                bannerView?.rootViewController = rootVC

                let screenWidth: CGFloat = UIScreen.main.bounds.size.width
                let screenHeight: CGFloat? = rootVC?.view.bounds.size.height

                let adHeight = adSize.size.height

                let adCenterX: CGFloat = screenWidth / 2
                let adCenterY: CGFloat = (screenHeight ?? 0.0) / 2 //- (adHeight / 2);

                center = CGPoint(x: adCenterX, y: adCenterY)

                bannerView?.frame = bounds

                if let aView = bannerView {
                    addSubview(aView)
                }

                rootVC?.view.addSubview(self)
                rootVC?.view.bringSubview(toFront: self)

                bannerView?.load(GADRequest())

                print("Banner loaded successfully")
            }
        }
    }

    func createAndLoadInterstitial() {
        interstitial = nil
        interstitial?.delegate = nil
        let newInterstitial = GADInterstitial(adUnitID: GluuConstants.AD_UNIT_ID_INTERSTITIAL)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        newInterstitial.load(request)
        interstitial = newInterstitial
        interstitial?.delegate = self
    }

    func showInterstitial(_ rootView: UIViewController?) {

        let shared = AdHandler.shared
        if AdHandler.shared.shouldShowAds == false {
            return
        }

        guard let interstitial = self.interstitial, let root = rootView else {
            return
        }
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: root)
        } else {
            rootView?.delay(delay: 1.0, closure: {
                self.showInterstitial(rootView)
            })
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
//                self.showInterstitial(rootView)
//            })

            print("Ad wasn't ready")
        }
    }

    func closeAD() {
        bannerView?.isHidden = true
        removeFromSuperview()
    }

    func interstitialDidDismissScreen(_ interstitial: GADInterstitial?) {
        createAndLoadInterstitial()
    }
}
