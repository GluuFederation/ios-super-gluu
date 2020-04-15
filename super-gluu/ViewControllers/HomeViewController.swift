//
//  HomeViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 9/20/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit
import ox_push3
import QRCodeReader
import SCLAlertView
import AVFoundation


class HomeViewController: BaseViewController, ApproveDenyDelegate, QRCodeReaderViewControllerDelegate {

    // MARK: - Outlets
    
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusView: UIView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var scanTextLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var removeAdsView: UIView!
    @IBOutlet var smallBannerView: SuperGluuBannerView!
    @IBOutlet var removeAdsButton: UIButton!
    
    // MARK: - Variables
    
    var isResultFromScan = false
    var isStatusViewVisible = false
    
    var scanJsonDictionary = [AnyHashable: Any]()

    var isSecureClick = false
    var isEnroll = false
    var isShowingQRReader = false
    
    var oxPushManager: OXPushManager?
    var bannerView: SuperGluuBannerView?
    
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var qrReaderVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
        
        initNotificationCenterObservers()
        setupDisplay()
        setupAdHandling()
        oxPushManager = OXPushManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let secureClickEnable: Bool = UserDefaults.standard.bool(forKey: GluuConstants.SECURE_CLICK_ENABLED)
        isSecureClick = secureClickEnable
        
        reloadFullPageAd()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = qrReaderVC
    }
    
    // MARK: - View Setup
    
    func setupDisplay() {
        
        removeAdsView.layer.shadowColor = UIColor.black.cgColor
        removeAdsView.layer.shadowRadius = 3
        removeAdsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        removeAdsView.layer.shadowOpacity = 0.3
        removeAdsView.layer.cornerRadius = GluuConstants.CORNER_RADIUS
        
        removeAdsButton.layer.cornerRadius = GluuConstants.CORNER_RADIUS
        removeAdsButton.setTitle(LocalString.Home_Remove_Ads.localized, for: .normal)
        
        let sel: Selector = #selector(self.goToSettings)
        let menuButton = UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: self, action: sel)
        navigationItem.leftBarButtonItem = menuButton
        
        // setup the center logo icon
        if let iconImage = UIImage(named: "icon_gluu_logo_nav") {
            let logoIconView = UIImageView(image: iconImage)
            logoIconView.frame = CGRect(x: 0, y: 0, width: iconImage.size.width, height: iconImage.size.height)
            navigationItem.titleView = logoIconView
        }
            
        if GluuConstants.IS_IPHONE_6 {
            scanTextLabel.font = UIFont.systemFont(ofSize: 17)
        }
        
        statusView.layer.cornerRadius = GluuConstants.BUTTON_CORNER_RADIUS
        
        scanButton.layer.cornerRadius = scanButton.bounds.size.height / 2
        scanButton.setTitle(LocalString.Home_Scan.localized, for: .normal)
        
        statusView.backgroundColor = AppConfiguration.systemColor
        
        welcomeLabel.text = LocalString.Home_Welcome.localized
        
        scanTextLabel.text = LocalString.Home_Tap_To_Scan_QR.localized
        
    }
    
    func setupAdHandling() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideBannerAd), name: noti(GluuConstants.NOTIFICATION_AD_FREE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showBannerAd), name: noti(GluuConstants.NOTIFICATION_AD_NOT_FREE), object: nil)
        
        bannerView = SuperGluuBannerView()
        
        bannerView?.createAndLoadInterstitial()
        
        AdHandler.shared.refreshAdStatus()
    }
    
    func initNotificationCenterObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showFullScreenAd), name: noti(GluuConstants.NOTIFICATION_SHOW_FULLSCREEN_AD), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_PUSH_TIMEOVER), object: nil)
    }
    
    @objc
    func notificationRecieved(_ notification: Notification?) {

        let localFail = LocalString.Oops.localized
        
        guard let name = notification?.name else {
            return
        }
        
        print("Noti name: \(name)")
        
        if name == noti(GluuConstants.NOTIFICATION_ERROR) {
            
            let errorMessage = notification?.object as? String ?? ""
            
            //        [UserLoginInfo sharedInstance]->logState = UNKNOWN_ERROR;
            
            UserLoginInfo.sharedInstance().errorMessage = errorMessage
            
            DataStoreManager.sharedInstance().save(UserLoginInfo.sharedInstance())
            
            showAlertView(withTitle: localFail, andMessage: errorMessage)
        
         } else if name == noti(GluuConstants.NOTIFICATION_UNSUPPORTED_VERSION) {
            
            let message = LocalString.Unsopported_Fido.localized
            showAlertView(withTitle: localFail, andMessage: message)
            
         } else if name == noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED) {

            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(1003) //push sound
            
            handlePush()
        }
        
        if name == noti(GluuConstants.NOTIFICATION_FAILED_KEYHANDLE) {
            let message = LocalString.Failed_KeyHandles.localized
            showAlertView(withTitle: localFail, andMessage: message)
        }
        
        if name == noti(GluuConstants.NOTIFICATION_PUSH_TIMEOVER) {
            showAlertView(withTitle: localFail, andMessage: LocalString.Home_Expired_Push.localized)
            return
        }
        
    }
    
    //LicenseAgreementDelegates
    
    func handlePush() {
        guard let push = PushHelper.shared.lastPush, !push.isExpired else { return }
        
        switch push.action {
        case .none: openRequest()
        case .approve: approveRequest()
        case .decline: denyRequest()
        }
    }
    
    func approveRequest() {
        
        AuthHelper.shared.handleRequest(isApproved: true) { (success, errorMessage) in
            
        }
        
    }
    
    func denyRequest() {
        
        AuthHelper.shared.handleRequest(isApproved: false) { (success, errorMessage) in
            
        }
        
    }
    
    func openRequest() {
        loadApproveDenyView()
    }
    
    
    // MARK: - Navigation
    
    @objc
    func goToSettings() {
        let settingsVC = SettingsViewController.fromStoryboard("Main")
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func loadApproveDenyView() {
 
        let approveDenyVC = ApproveDenyViewController.fromStoryboard("Main")
        
        navigationController?.pushViewController(approveDenyVC, animated: true)
    }
    
    func showQRReader() {
        
        if ConnectionCheck.isConnectedToNetwork(), QRCodeReader.isAvailable() {
            
            qrReaderVC.title = LocalString.Home_Scan.localized
            qrReaderVC.delegate = self
            
            navigationController?.pushViewController(qrReaderVC, animated: true)
        } else {
            showAlertView(withTitle: LocalString.Home_No_Internet.localized, andMessage: LocalString.Home_Check_Internet.localized)
        }
        
        scanButton.isEnabled = true
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        
        reader.stopScanning()
        
        guard
            let encodedData = result.value.data(using: .utf8),
            let jsonDictionary = try? JSONSerialization.jsonObject(with: encodedData, options: []) as? [AnyHashable : Any] else {
                
                self.showAlertView(withTitle: nil, andMessage: LocalString.Home_QR_Not_Recognized.localized)

                navigationController?.popViewController(animated: true)
                
                return
        }
        
        reader.dismiss(animated: true, completion: nil)
        
        var push = PushNoti(pushData: nil)
        push.userInfo = jsonDictionary
        PushHelper.shared.lastPush = push
        
        handlePush()
        
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()

        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Camera Permission Handling
    @IBAction func scanQRTapped() {
        
        scanButton.isEnabled = false
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch authStatus {
        case .authorized:
            showQRReader()
        case .notDetermined:
            
            print("\("Camera access not determined. Ask for permission.")")
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                
                if granted {
                    
                    print("Granted access to \(AVMediaType.video)")
                    self.showQRReader()
                } else {
                    
                    print("Not granted access to \(AVMediaType.video)")
                    self.cameraDenied()
                }
            })
        case .restricted:
            // User is restricted
            cameraDenied()
        case .denied:
            // User needs to head to settings
            cameraDenied()
        default:
            break
        }
    }
    
    func cameraDenied() {
        
        print("Denied camera access")
        
        // ** LOCAL TEXT
//        let alertText = "It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again."
        
        let alertText = LocalString.Camera_Denied_Directions.localized
        let alert = UIAlertController(title: LocalString.Camera_Access_Needed.localized, message: alertText, preferredStyle: .alert)
        
        let action = UIAlertAction(title: LocalString.Go.localized, style: UIAlertActionStyle.default) { (action) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        scanButton.isEnabled = true
    }
    
    func showAlertView(withTitle title: String?, andMessage message: String?) {
        let alert = SCLAlertView(autoDismiss: true, horizontalButtons: false)
        
        alert.showCustom(title ?? "",
                         subTitle: message ?? "",
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: LocalString.Ok.localized,
                         timeout: alert.dismissTimeout(),
                         circleIconImage: AppConfiguration.systemAlertIcon,
                         animationStyle: SCLAnimationStyle.topToBottom)
    }
    
    // MARK: - Ad Handling:
    @objc func showBannerAd(_ notification: Notification) {
        
        print("Show small banner view")
        
        smallBannerView.loadBannerAd()
        smallBannerView.isHidden = false
        removeAdsView.isHidden = false
        
    }
    
    @objc func hideBannerAd(_ notification: Notification) {
        
        print("Remove small banner view")
        
        removeAdsView.isHidden = true
        smallBannerView.isHidden = true
    }
    
    @objc func showFullScreenAd() {
        // ad handler shouldShowAds state is checked in function prior to showing ad
        
        if bannerView == nil {
            bannerView = SuperGluuBannerView()
        }
        
        reloadFullPageAd()
        bannerView?.showInterstitial(self)
    }
    
    func reloadFullPageAd() {
        if bannerView == nil {
            bannerView = SuperGluuBannerView()
        }
        
        bannerView?.createAndLoadInterstitial()
    }
    
    func updateStatus(_ status: String?) {
        if status != nil {
            statusLabel.text = status
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.statusView.alpha = 0.0
            self.statusView.center = CGPoint(x: self.statusView.center.x, y: -40)
        }) { finished in
            
            UIView.animate(withDuration: 0.5, animations: {
                self.statusView.alpha = 1.0
                if GluuConstants.IS_IPHONE_5 {
                    //IS_IPHONE_4 ||
                    self.statusView.center = CGPoint(x: self.statusView.center.x, y: 45)
                } else {
                    self.statusView.center = CGPoint(x: self.statusView.center.x, y: 65)
                }
                self.isStatusViewVisible = true
            })
            
        }
    }
    
    @objc func hideStatusBar() {
        UIView.animate(withDuration: 1.0, animations: {
            self.statusView.alpha = 0.0
            self.isStatusViewVisible = false
        }) { finished in
            //
        }
    }
 
    func showSystemMessage(_ title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: LocalString.Ok.localized, style: .default, handler: { action in
            //Handle your yes please button action here
        })
        
        alert.addAction(yesButton)
        
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

