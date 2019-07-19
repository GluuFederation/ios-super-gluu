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

    var scanner: PeripheralScanner?
    var isSecureClick = false
    var isEnroll = false
    var isShowingQRReader = false
    
    var count = 0
    var oxPushManager: OXPushManager?
    var alert: UIAlertController?
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
        checkPushNotification()
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
        navigationItem.rightBarButtonItem = menuButton
        
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
    
    @objc
    func initSecureClickScanner(_ notification: Notification) {
        let valueData = notification.object as? Data
        let scanner = PeripheralScanner()
        scanner.valueForWrite = valueData
        scanner.isEnroll = isEnroll
        scanner.start()
        
        showAlertView(withTitle: "SecureClick", andMessage: "Short click on device button")
    }

    func checkPushNotification() {
        // check for an existing request via push notification
        guard let pushNotificationRequest = UserDefaults.standard.object(forKey: GluuConstants.NotificationRequest) as? [AnyHashable: Any] else {
            return
        }
        
        let jsonDictionary =  PushNotificationsHelper.parsedInfo(pushNotificationRequest)
        
        // If the push is expired, clear it out and let the user know
        guard PushNotificationsHelper.isLastPushExpired() == false else {
            UserDefaults.standard.removeObject(forKey: GluuConstants.NotificationRequest)
            NotificationCenter.default.post(name: noti(GluuConstants.NOTIFICATION_PUSH_TIMEOVER), object: jsonDictionary)
            return
        }
        
        if jsonDictionary != nil {
            //        NSString* message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
            //        [self updateStatus:message];
            
            //            [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
            
            
            AuthHelper.shared.requestDictionary = jsonDictionary
            
            initUserInfo(jsonDictionary)
            
            let isApprove: Bool = UserDefaults.standard.bool(forKey: NotificationRequestActionsApprove)
            let isDeny: Bool = UserDefaults.standard.bool(forKey: NotificationRequestActionsDeny)
            
            // Currently, we are double calling approve request.
            // It's getting called both when we approve via the home screen, then again when
            // the user comes into the app and the Main VC is launched.
            
            if isApprove {
                approveRequest()
            } else if isDeny {
                denyRequest()
            } else {
                self.delay(delay: 1.0) {
                    print("Stored push auth request")
                    self.handleAuthRequest(jsonDictionary)
                }
            }
            
            // clear existing data
            UserDefaults.standard.removeObject(forKey: GluuConstants.NotificationRequest)
            UserDefaults.standard.set(false, forKey: NotificationRequestActionsApprove)
            UserDefaults.standard.set(false, forKey: NotificationRequestActionsDeny)
        }
    }
    
    @objc func initPushView(_ notification: Notification?) {
        //Make sound and vibrate like push
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(1003) //push sound
        
        let requestDictionary = notification?.object as? [AnyHashable : Any]
        
        AuthHelper.shared.requestDictionary = requestDictionary
        
        print("init push view called")
        
        handleAuthRequest(requestDictionary)
    }
    
    func initNotificationCenterObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_REGISTRATION_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_REGISTRATION_FAILED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_AUTENTIFICATION_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_AUTENTIFICATION_FAILED), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_ERROR), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED_APPROVE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED_DENY), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.initPushView(_:)), name: noti(GluuConstants.NOTIFICATION_PUSH_ONLINE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_DECLINE_FAILED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_DECLINE_SUCCESS), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationRecieved(_:)), name: noti(GluuConstants.NOTIFICATION_PUSH_TIMEOVER), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.initSecureClickScanner(_:)), name: noti(GluuConstants.INIT_SECURE_CLICK_NOTIFICATION), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationDidDisconnecPeritheralRecieved(_:)), name: noti(GluuConstants.DID_DISCONNECT_PERIPHERAL), object: nil)
    }
    
    @objc
    func notificationDidDisconnecPeritheralRecieved(_ notification: Notification?) {
        scanner?.scanning = false
    }
    
    @objc
    func notificationRecieved(_ notification: Notification?) {
        
//        let step = notification?.userInfo?["oneStep"] as? String
//        let oneStep = Bool(step ?? "") ?? false
//        var message = ""
        
        let localSuccess = LocalString.Success.localized
        let localFail = LocalString.Oops.localized
        
        guard let name = notification?.name else {
            return
        }
        
        print("Noti name: \(name)")
        
        if name == noti(GluuConstants.NOTIFICATION_REGISTRATION_SUCCESS) {
            
            showAlertView(withTitle: localSuccess, andMessage: LocalString.Home_Registration_Success.localized)
            
            showFullScreenAd()
            
        } else if name == noti(GluuConstants.NOTIFICATION_REGISTRATION_FAILED) {
            
            showAlertView(withTitle: localFail, andMessage: LocalString.Home_Registration_Failed.localized)
            
            showFullScreenAd()
            
        } else if name == noti(GluuConstants.NOTIFICATION_REGISTRATION_STARTING) {
            
            showAlertView(withTitle: LocalString.Home_Registering.localized, andMessage: nil)

        } else if name == noti(GluuConstants.NOTIFICATION_AUTENTIFICATION_SUCCESS) {
            
            showAlertView(withTitle: LocalString.Home_Auth_Success.localized, andMessage: nil)
            
            showFullScreenAd()
            
        } else if name == noti(GluuConstants.NOTIFICATION_AUTENTIFICATION_FAILED) {
            
            showAlertView(withTitle: localFail, andMessage: LocalString.Home_Auth_Failed.localized)
            
            showFullScreenAd()
            
        } else if name == noti(GluuConstants.NOTIFICATION_ERROR) {
            
            let errorMessage = notification?.object as? String ?? ""
            
            //        [UserLoginInfo sharedInstance]->logState = UNKNOWN_ERROR;
            
            UserLoginInfo.sharedInstance().errorMessage = errorMessage
            
            DataStoreManager.sharedInstance().save(UserLoginInfo.sharedInstance())
            
            showAlertView(withTitle: localFail, andMessage: errorMessage)
        
         } else if name == noti(GluuConstants.NOTIFICATION_UNSUPPORTED_VERSION) {
            
            let message = NSLocalizedString("UnsupportedU2FV2Version", comment: "Unsupported U2F_V2 version...")
            showAlertView(withTitle: localFail, andMessage: message)
            
         } else if name == noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED) {

            print("NOTIFICATION_PUSH_RECEIVED called")
            
            showAlertView(withTitle: LocalString.Home_Authenticating.localized, andMessage: nil)
            
            UserDefaults.standard.removeObject(forKey: GluuConstants.NotificationRequest)
            
            let pushAuthRequest = notification?.object as? [AnyHashable : Any]
            handleAuthRequest(pushAuthRequest)
            
        } else if name == noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED_APPROVE)  {
            // clear out the notification from user defaults. That way
            // the check in viewWillAppear doesn't get called
            
            UserDefaults.standard.removeObject(forKey: GluuConstants.NotificationRequest)
            
            let pushRequest = notification?.object as? [AnyHashable : Any]
            AuthHelper.shared.requestDictionary = pushRequest
            initUserInfo(pushRequest)
            approveRequest()
            return
            
        } else if name == noti(GluuConstants.NOTIFICATION_PUSH_RECEIVED_DENY) {
            // clear out the notification from user defaults. That way
            // the check in viewWillAppear doesn't get called
            
            UserDefaults.standard.removeObject(forKey: GluuConstants.NotificationRequest)
            let pushRequest = notification?.object as? [AnyHashable : Any]
            AuthHelper.shared.requestDictionary = pushRequest
            initUserInfo(pushRequest)
            denyRequest()
            return
        }
        
        if name == noti(GluuConstants.NOTIFICATION_DECLINE_SUCCESS) {
            showAlertView(withTitle: localSuccess, andMessage: LocalString.Home_Auth_Declined.localized)
            return
        }
        
        if name == noti(GluuConstants.NOTIFICATION_DECLINE_FAILED) {
            showAlertView(withTitle: localFail, andMessage: LocalString.Home_Decline_Failed.localized)
            return
        }
        
        if name == noti(GluuConstants.NOTIFICATION_FAILED_KEYHANDLE) {
            let message = NSLocalizedString("FailedKeyHandle", comment: "Failed KeyHandles")
            showAlertView(withTitle: localFail, andMessage: message)
        }
        
        if name == noti(GluuConstants.NOTIFICATION_PUSH_TIMEOVER) {
            showAlertView(withTitle: localFail, andMessage: LocalString.Home_Expired_Push.localized)
            return
        }
        
    }
    
    //LicenseAgreementDelegates
    
    func approveRequest() {
        
        AuthHelper.shared.approveRequest(completion: { success, errorMessage in
            // AuthHelper handles success/failure
        })
        
    }
    
    func denyRequest() {
        
        AuthHelper.shared.denyRequest(completion: { success, errorMessage in
            // AuthHelper handles success/failure
        })
        
    }
    
    func openRequest() {
        loadApproveDenyView()
    }
    
    //# ------------ END -----------------------------
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func handleAuthRequest(_ jsonDictionary: [AnyHashable : Any]?) {
        
        print("Handle Auth Request")
        
        if jsonDictionary != nil {
            
            AuthHelper.shared.requestDictionary = jsonDictionary
            initUserInfo(jsonDictionary)
            loadApproveDenyView()
        } else {
            updateStatus(LocalString.Home_QR_Not_Recognized.localized)
            perform(#selector(HomeViewController.hideStatusBar), with: nil, afterDelay: 5.0)
        }
    }
    
    // MARK: - Navigation
    
    @objc
    func goToSettings() {
        let settingsVC = SettingsViewController.fromStoryboard("Main")
        let navC = UINavigationController(rootViewController: settingsVC)
        
        present(navC, animated: true, completion: nil)
    }
    
    func loadApproveDenyView() {
        
        count += 1
        
        print("Count = \(count)")
 
        let approveDenyVC = ApproveDenyViewController.fromStoryboard("Main")
        approveDenyVC.isLogDisplay = false
        
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
//                self.showAlertView(withTitle: "Unrecognized QR Code", andMessage: "The QR code scanned wasn't recognized. Please make sure it is from Gluu.")

                navigationController?.popViewController(animated: true)
                
                return
        }
        
        reader.dismiss(animated: true, completion: nil)
        
        handleAuthRequest(jsonDictionary)
        
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
        let alertText = "It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again."
        
        let alert = UIAlertController(title: "Camera Issue", message: alertText, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Go", style: UIAlertActionStyle.default) { (action) in
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
                         closeButtonTitle: "OK",
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
    
    func showFullScreenAd() {
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
                    if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                        // code for landscape orientation
                        self.statusView.center = CGPoint(x: self.statusView.center.x, y: 15)
                    } else {
                        self.statusView.center = CGPoint(x: self.statusView.center.x, y: 45)
                    }
                } else {
                    if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                        // code for landscape orientation
                        self.statusView.center = CGPoint(x: self.statusView.center.x, y: 35)
                    } else {
                        self.statusView.center = CGPoint(x: self.statusView.center.x, y: 65)
                    }
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
    
    func initUserInfo(_ parameters: [AnyHashable : Any]?) {
        
        let app = parameters?["app"] as? String ?? ""
        let created = "\(Date())"
        let issuer = parameters?["issuer"] as? String ?? ""
        let username = parameters?["username"] as? String ?? ""
        let method = parameters?["method"] as? String ?? ""
        
        let isLicensedInt = parameters?["licensed"] as? Int ?? 0
        let isLicensed: Bool = isLicensedInt != 0
        
        let oneStep: Bool = username.isEmpty ? true : false
        
        UserLoginInfo.sharedInstance().application = app
        UserLoginInfo.sharedInstance().created = created
        UserLoginInfo.sharedInstance().issuer = issuer
        UserLoginInfo.sharedInstance().userName = username
        
        isEnroll = (method == "enroll") ? true : false
        if isEnroll {
            let type = NSLocalizedString("Enrol", comment: "Enrol")
            UserLoginInfo.sharedInstance().authenticationType = type
        } else {
            UserLoginInfo.sharedInstance().authenticationType = method
        }
        
        // we use the token application combined with the username to identify a licensed key
        
        let keyIssuer = app + username
        
        // if isLicensed is true, this is a licensed account and
        // ads should not display. As long as the user has 1 key that is licensed
        // ads should not display, regardless of other unlicensed keys the user has
        
        if isLicensed == true {
            print("Saving Licensed Key")
            GluuUserDefaults.saveLicensedKey(keyIssuer)
            AdHandler.shared.refreshAdStatus()
        } else {
            print("Removing Licensed Key")
            GluuUserDefaults.removeLicensedKey(keyIssuer)
            AdHandler.shared.refreshAdStatus()
        }
        
        let mode = oneStep ? NSLocalizedString("OneStepMode", comment: "One Step") : NSLocalizedString("TwoStepMode", comment: "Two Step")
        UserLoginInfo.sharedInstance().authenticationMode = mode
        UserLoginInfo.sharedInstance().locationCity = parameters?["req_loc"] as? String ?? ""
        UserLoginInfo.sharedInstance().locationIP = parameters?["req_ip"] as? String ?? ""
    }
    
    func showSystemMessage(_ title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
            //Handle your yes please button action here
        })
        
        alert.addAction(yesButton)
        
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

