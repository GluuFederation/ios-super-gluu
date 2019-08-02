//  AppDelegate.swift
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/1/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

import AudioToolbox
import GoogleMobileAds
import UIKit
import UserNotifications
import ox_push3


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var pushNotificationRequest: [AnyHashable : Any]?
    var isDecline = false
    
    var coverWindow: UIWindow?
    private var coverVC: UIViewController?
    var isHidingLockScreen = false
     
    let rootVC = RootContainerViewController()
    
    static let appDel = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Functions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        registerForPushNotifications()

        let remoteNotif = launchOptions?[.remoteNotification] as? [AnyHashable : Any]
     
        PushHelper.shared.lastPush = PushNoti(date: Date(), userInfo: remoteNotif, action: .none)
     
       /*
        //Accept push notification when app is not open
        if remoteNotif != nil {
            UserDefaults.standard.set(remoteNotif, forKey: GluuConstants.NotificationRequest)
        }
      */

        //Setup Basic

        setupAppearance()

        
        GADMobileAds.configure(withApplicationID: AppConfiguration.googleAdsId)

        setupSwiftyStoreKit()
     
        setupRootViewController()

        return true
    }

    func setupSwiftyStoreKit() {
        PurchaseHandler.shared.completeTransactions()
    }

    //Push Notification
    func registerForPushNotifications() {
        
        setupPushNotificationActions()
        requestNotifications()
    }
    
    func appIsLocked() -> Bool {
        guard let lockedDate = UserDefaults.standard.value(forKey: GluuConstants.LOCKED_DATE) as? Date else {
            return false
        }
        
        let unlockDate = lockedDate.addingTimeInterval(GluuConstants.LOCKOUT_DURATION)
        
        if unlockDate < Date() {
            UserDefaults.standard.set(nil, forKey: GluuConstants.LOCKED_DATE)
        }
        
        return unlockDate > Date()

    }
     
     func setupRootViewController() {
          
          window                     = UIWindow(frame: UIScreen.main.bounds)
          window?.rootViewController = rootVC
          window?.makeKeyAndVisible()
          
     }
    
     private func setupPushNotificationActions() {
          
          // Configure User Notification Center
          
          let action1 = UNNotificationAction(identifier: GluuConstants.NotificationActionApprove,
                                             title: LocalString.Approve.localized,
                                             options: [.foreground])
          
          let action2 = UNNotificationAction(identifier: GluuConstants.NotificationActionDeny,
                                             title: LocalString.Deny.localized,
                                             options: [.foreground, .destructive])
          
          let actionCategory = UNNotificationCategory(identifier: GluuConstants.NotificationCategoryIdent,
                                                      actions: [action1, action2],
                                                      intentIdentifiers: [],
                                                      options: [])
          
          // Register Category
          UNUserNotificationCenter.current().setNotificationCategories([actionCategory])
     }
    
    private func requestNotifications(completion: ((Bool) -> Void)? = nil) {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.askForNotifications(completion: completion)
                case .authorized:
                    UIApplication.shared.registerForRemoteNotifications()
                case .denied:
                    return
                case .provisional:
                    return
                }
            }
        })
    }
    
    public func askForNotifications(completion: ((Bool) -> Void)? = nil) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                if let completion = completion {
                    completion(granted)
                }
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = deviceToken.hexEncodedString()
        token = token.replacingOccurrences(of: "<", with: "")
        token = token.replacingOccurrences(of: ">", with: "")
        token = token.replacingOccurrences(of: " ", with: "")
        TokenDevice.sharedInstance().deviceToken = token
        
        print("Token is: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get token, error: \(error)")
    }
    
    // called as soon as a notification is received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        /*
        // store push came date so we don't handle expired auth requests when the user comes into the app
        if application.applicationState == .background {
            UserDefaults.standard.set(Date(), forKey: GluuConstants.PUSH_CAME_DATE)
        }

        if application.applicationState == .active {
            // app was already in the foreground and we show custom push notifications view
            parsePushAndNotify(userInfo)
        } else {
            // app state is Inactive. App was just brought from background to foreground and we wait when user click or slide on push notification
            
            // if/else prevents double handling of pushes received when no security measures are in place
            if GluuUserDefaults.hasTouchAuthEnabled() == true || GluuUserDefaults.userPin() != nil {
                UserDefaults.standard.set(userInfo, forKey: GluuConstants.NotificationRequest)
            } else {
                pushNotificationRequest = userInfo
            }
        }

        UserDefaults.standard.set(false, forKey: GluuConstants.NotificationRequestActionsApprove)
        UserDefaults.standard.set(false, forKey: GluuConstants.NotificationRequestActionsDeny)
        print("Received notification: \(userInfo)")
 
        */
     
        PushHelper.shared.lastPush = PushNoti(date: Date(), userInfo: userInfo, action: .none)
    }

     /*
    func parsePushAndNotify(_ pushInfo: [AnyHashable : Any]?) {

        if pushInfo == nil {
            return
        }

        let parsedPushDict =  PushHelper.shared.parsedInfo(pushInfo)

        if parsedPushDict != nil {
            NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_PUSH_ONLINE), object: parsedPushDict)
        }
    }
 */


    func applicationDidEnterBackground(_ application: UIApplication) {
     
//        rootVC.transitionToLandingNavigationViewController()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        // always update ad status when the user comes into the app
        AdHandler.shared.refreshAdStatus()

//        rootVC.transitionToLandingNavigationViewController()
        rootVC.updateDisplay(nextState: RootState.security)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        print("APP DID BECOME ACTIVE.....")
        
        if appIsLocked() == false && coverWindow != nil && !isHidingLockScreen {
            hideLockedScreen()
        }
     
     /*
        // check if a push has been received. Method handles situation appropriately
        handleAuthenticationRequest(false)
      */
    }
    
    func showLockedScreen() {
        coverVC = LandingViewController.fromStoryboard("Landing")
        coverWindow = UIWindow(frame: UIScreen.main.bounds)
        let existingTopWindow = UIApplication.shared.windows.last
        
        coverWindow?.windowLevel = existingTopWindow!.windowLevel + 1
        coverVC!.view.frame = coverWindow!.bounds
        coverWindow?.rootViewController = coverVC
        coverWindow?.makeKeyAndVisible()
    }
    
    func hideLockedScreen() {
        
        if coverWindow != nil {
            isHidingLockScreen = true
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.coverVC?.view.alpha = 0
            }) { _ in
                self.coverWindow?.isHidden = true
                self.coverWindow?.rootViewController = nil
                self.coverWindow = nil
                self.coverVC = nil
                self.isHidingLockScreen = false
            }
        }
    }

     //
    func handleAuthenticationRequest(_ isAction: Bool) {

     /*
        if pushNotificationRequest == nil {
            return
        }

        let jsonDictionary =  PushHelper.shared.parsedInfo(pushNotificationRequest!)

        if  PushNotificationsHelper.isLastPushExpired() == false {

            if jsonDictionary != nil {

                if !isAction {
                    NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_PUSH_RECEIVED), object: jsonDictionary)
                } else {
                    let notiName = isDecline ? GluuConstants.NOTIFICATION_PUSH_RECEIVED_DENY : GluuConstants.NOTIFICATION_PUSH_RECEIVED_APPROVE
                    
                    NotificationCenter.default.post(name: Notification.Name(notiName), object: jsonDictionary)
                }
            }
        } else {

            UserDefaults.standard.removeObject(forKey: GluuConstants.NotificationRequest)

            NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_PUSH_TIMEOVER), object: jsonDictionary)
        }

        pushNotificationRequest = nil
     
     */
    }


// MARK: - Appearance
    func setupAppearance() {

        UINavigationBar.appearance().barTintColor = AppConfiguration.systemColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().shadowImage = UIImage()

        UITableView.appearance().backgroundColor = UIColor.Gluu.tableBackground

        UISwitch.appearance().onTintColor = AppConfiguration.systemColor

        let titleAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

        UINavigationBar.appearance().titleTextAttributes = titleAttributes

        let backImage = UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage

    }
}

// MARK: - Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    // MARK: UNUserNotificationCenterDelegate
    // swiftlint:disable:next line_length
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        print("Will present a notification : \(notification)")
        completionHandler( [.alert, .badge, .sound])
    }
    
    // Notification tapped via notification center
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Determine the user action
        switch response.actionIdentifier {
            
        case GluuConstants.NotificationActionApprove:
          
          PushHelper.shared.lastPush = PushNoti(date: Date(), userInfo: userInfo, action: .approve)
          
          /*
          
            isDecline = false
            pushNotificationRequest = userInfo
            UserDefaults.standard.set(userInfo, forKey: GluuConstants.NotificationRequest)
            UserDefaults.standard.set(true, forKey: GluuConstants.NotificationRequestActionsApprove)
            UserDefaults.standard.set(false, forKey: GluuConstants.NotificationRequestActionsDeny)
            handleAuthenticationRequest(true)
          */
            
        case GluuConstants.NotificationActionDeny:
          
          PushHelper.shared.lastPush = PushNoti(date: Date(), userInfo: userInfo, action: .approve)
          
          /*
            isDecline = true
            pushNotificationRequest = userInfo
            UserDefaults.standard.set(userInfo, forKey: GluuConstants.NotificationRequest)
            UserDefaults.standard.set(true, forKey: GluuConstants.NotificationRequestActionsDeny)
            UserDefaults.standard.set(false, forKey: GluuConstants.NotificationRequestActionsApprove)
            handleAuthenticationRequest(true)
          */
            
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
            
        default:
            print("Noti tapped on")
        }
        
        completionHandler()
    }
}

