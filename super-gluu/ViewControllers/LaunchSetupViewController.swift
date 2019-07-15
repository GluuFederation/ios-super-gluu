//
//  LaunchSetupViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

class LaunchSetupViewController: UIViewController {

    // MARK: - Variables
    
    @IBOutlet weak var lockedOutButton: UIButton!
    @IBOutlet weak var enterPasscodeButton: UIButton!
    @IBOutlet weak var fingerprintButton: UIButton!
    
    let touchAuth = TouchIDAuth()
    
    var ranOnce = false
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        
        setupDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ranOnce == false {
            
            ranOnce = true
            checkSecurity()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // View Setup
    
    func setupDisplay() {
        
        enterPasscodeButton.layer.cornerRadius = enterPasscodeButton.bounds.height / 2
        enterPasscodeButton.layer.masksToBounds = true
        
        fingerprintButton.layer.cornerRadius = fingerprintButton.bounds.height / 2
        fingerprintButton.layer.masksToBounds = true
        
        pinButtons(shouldShow: false)
    }
    
    func checkSecurity() {
        
        // Check for touch
        if GluuUserDefaults.hasTouchAuthEnabled() && touchAuth.canEvaluatePolicy() == true {
            
            touchAuth.authenticateUser { (success, errorMessage) in
                
                if success {
                    self.goToHomeScreen()
                } else {
                    self.pinButtons(shouldShow: true)
                }
            }
            
        } else if GluuUserDefaults.userPin() != nil {
            displayPinCodeEntry()
        } else {
            // go to main view controller

            goToHomeScreen()
        }
    }
    
    func displayPinCodeEntry() {
        
        let passcodeVC = PAPasscodeViewController(for: .enter)
        
        passcodeVC.delegate = self
        passcodeVC.passcode = GluuUserDefaults.userPin() ?? ""
        passcodeVC.simple   = true

        let navC = UINavigationController(rootViewController: passcodeVC);
        
        present(navC, animated: false, completion: nil)
        
    }
    
    
    func goToHomeScreen() {
        performSegue(withIdentifier: "segueUnwindSecureEntryToLanding", sender: nil)
//        performSegue(withIdentifier: "SegueLaunchToHome", sender: nil)
    }
    
    @IBAction func unwindToLaunchSetup(segue:UIStoryboardSegue) {
        ranOnce = false
    }

    
    // MARK: - Action Handling
    
    @IBAction func enterPasscodeTapped() {
        displayPinCodeEntry()
    }

    @IBAction func fingerprintTapped() {
        touchAuth.authenticateUser { (success, errorMessage) in
            
            if success {
                self.goToHomeScreen()
            } else {
                self.pinButtons(shouldShow: true)
            }
        }
    }
    
    
    @IBAction func lockedOutTapped() {
        // HELP!!!
    }
    
    func pinButtons(shouldShow: Bool) {
        
        fingerprintButton.isHidden = !(touchAuth.canEvaluatePolicy() && shouldShow == true)
        
        if shouldShow == true {
            enterPasscodeButton.isHidden = GluuUserDefaults.userPin() == nil
        } else {
            enterPasscodeButton.isHidden = true
        }
        
        // not an option currently. 
//        lockedOutButton.isHidden = !shouldShow
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

