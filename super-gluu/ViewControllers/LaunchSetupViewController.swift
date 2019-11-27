//
//  LaunchSetupViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import LocalAuthentication

class LaunchSetupViewController: UIViewController {

    // MARK: - Variables
    
    @IBOutlet weak var lockedOutButton: UIButton!
    @IBOutlet weak var enterPasscodeButton: UIButton!
    @IBOutlet weak var bioAuthButton: UIButton!
    
    let touchAuth = TouchIDAuth()
    
    var ranOnce = false
    
    var authCheckComplete: (()->Void)?
    var presentPasscodeEntry: (()->Void)?
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        
        setupDisplay()
        NotificationCenter.default.addObserver(self, selector: #selector(checkSecurity), name: noti(GluuConstants.NOTIFICATION_APP_ENTERING_FOREGROUND), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ranOnce == false {
            
            ranOnce = true
            checkSecurity()
            
        } else if GluuUserDefaults.userPin() != nil {
            pinButtons(shouldShow: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // View Setup
    
    func setupDisplay() {
        
        enterPasscodeButton.layer.cornerRadius = enterPasscodeButton.bounds.height / 2
        enterPasscodeButton.layer.masksToBounds = true
        enterPasscodeButton.setTitle(LocalString.Launch_Enter_Passcode.localized, for: .normal)
        
        lockedOutButton.setTitle(LocalString.Launch_Forgot_Passcode.localized, for: .normal)
        
        pinButtons(shouldShow: false)
        
        switch LAContext().biometricType {
        case .faceID:
            bioAuthButton.setImage(UIImage(named: "icon_face"), for: .normal)
            bioAuthButton.layer.cornerRadius = 8
        case .touchID:
            bioAuthButton.setImage(UIImage(named: "icon_fingerprint"), for: .normal)
            bioAuthButton.layer.cornerRadius = bioAuthButton.bounds.height / 2
        case .none:
            bioAuthButton.isHidden = true
        }
        
        bioAuthButton.layer.masksToBounds = true
    }
    
    @objc
    func checkSecurity() {
        
        // Check for touch
        if GluuUserDefaults.userPin() != nil {
            presentPasscodeEntry?()
            
        } else if GluuUserDefaults.hasBioAuthEnabled() && touchAuth.canEvaluatePolicy() == true {
            
            touchAuth.authenticateUser { (success, errorMessage) in
                
                if success {
                    self.authCheckComplete?()
                } else {
                    self.pinButtons(shouldShow: true)
                }
            }
            
        } else {
            // go to main view controller

            goToHomeScreen()
        }
    }
    
//    func displayPinCodeEntry() {
//
//        let passcodeVC = PAPasscodeViewController(for: .enter)
//
//        passcodeVC.delegate = self
//        passcodeVC.passcode = GluuUserDefaults.userPin() ?? ""
//        passcodeVC.simple   = true
//
//        let navC = UINavigationController(rootViewController: passcodeVC);
//
//
//        present(navC, animated: false, completion: nil)
//
//    }
    
    
    func goToHomeScreen() {
        
//        performSegue(withIdentifier: "segueUnwindSecureEntryToLanding", sender: nil)
//        performSegue(withIdentifier: "SegueLaunchToHome", sender: nil)
    }
    
    @IBAction func unwindToLaunchSetup(segue:UIStoryboardSegue) {
        ranOnce = false
    }

    
    // MARK: - Action Handling
    
    @IBAction func enterPasscodeTapped() {
        presentPasscodeEntry?()
    }

    @IBAction func bioAuthTapped() {
        touchAuth.authenticateUser { (success, errorMessage) in
            
            if success {
                self.authCheckComplete?()
            } else {
                self.pinButtons(shouldShow: true)
            }
        }
    }
    
    
    @IBAction func lockedOutTapped() {
        // HELP!!!
    }
    
    func pinButtons(shouldShow: Bool) {
        
//        bioAuthButton.isHidden = !(touchAuth.canEvaluatePolicy() && shouldShow == true)
        
        if shouldShow == true {
            enterPasscodeButton.isHidden = GluuUserDefaults.userPin() == nil
        } else {
            enterPasscodeButton.isHidden = true
        }
        
        // not an option currently. 
//        lockedOutButton.isHidden = !shouldShow
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LaunchSetupViewController: PAPasscodeViewControllerDelegate {
    
    func paPasscodeViewControllerDidChangePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidEnterAlternativePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidSetPasscode(_ controller: PAPasscodeViewController) {}
    
    func paPasscodeViewController(_ controller: PAPasscodeViewController, didFailToEnterPasscode attempts: Int) {
        
        // lock the user out of the app for xx minutes
        if attempts == GluuConstants.MAX_PASSCODE_ATTEMPTS_COUNT {
            
            UserDefaults.standard.set(Date(), forKey: GluuConstants.LOCKED_DATE)
            
            controller.dismiss(animated: true) {
                self.pinButtons(shouldShow: true)
                AppDelegate.appDel.showLockedScreen()
            }
        }
    }
    
    func paPasscodeViewControllerDidCancel(_ controller: PAPasscodeViewController) {
        
        controller.dismiss(animated: true) {
            self.pinButtons(shouldShow: true)
        }
        
    }
    
    func paPasscodeViewControllerDidEnterPasscode(_ controller: PAPasscodeViewController) {
        
        // user successfully entered passcode
        // go to the main screen
//        navigationController?.popViewController(animated: true)
        controller.dismiss(animated: true) {
            self.goToHomeScreen()
        }
        
    }
}

