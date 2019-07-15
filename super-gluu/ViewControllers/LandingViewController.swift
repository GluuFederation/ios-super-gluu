//
//  LandingViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 6/21/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit


class LandingViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    @IBOutlet weak var lockedView: UIView!
    @IBOutlet weak var lockedLabel: UILabel!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // on initial load, prompt user to setup secure entry to app

        if AppDelegate.appDel.appIsLocked() {
            print("Timer created")
            view.backgroundColor = .red
            lockedView.isHidden = false
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkLockedTimer), userInfo: nil, repeats: true)
            }
        } else {
            goToApp()
        }
    }
    
    func goToApp() {
        if GluuUserDefaults.hasSeenSecurityPrompt() == false {
            showSecurityPrompt()
        } else if GluuUserDefaults.hasTouchAuthEnabled() == true || GluuUserDefaults.userPin() != nil {
            showSecureEntry()
        } else {
            showMainScreen()
        }
    }
    
    @objc
    func checkLockedTimer() {
        if AppDelegate.appDel.appIsLocked() == false {
            
            timer?.invalidate()
            timer = nil
            print("Timer invalidated")
            print("Hide Lock called")
            
            if AppDelegate.appDel.coverWindow != nil {
                AppDelegate.appDel.hideLockedScreen()
            } else {
                goToApp()
            }

        }
    }
    
    // MARK: - Action Handling
    
    @IBAction func unwindFromSecurityPrompt(sender: UIStoryboardSegue) {
        showMainScreen()
    }
    
    @IBAction func unwindFromSecureEntry(sender: UIStoryboardSegue) {
        showMainScreen()
    }
    
    
    // MARK: - Navigation
    
    func showSecurityPrompt() {
        performSegue(withIdentifier: "segueToSecurityPrompt", sender: nil)
    }
    
    func showSecureEntry() {
        performSegue(withIdentifier: "segueToSecureEntry", sender: nil)
    }
    
    func showMainScreen() {
        let mainNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = mainNavVC
    }
}

