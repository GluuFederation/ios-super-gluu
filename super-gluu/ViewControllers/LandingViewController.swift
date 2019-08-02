//
//  LandingViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 6/21/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit


class LandingViewController: UIViewController {
    
    enum DisplayState {
        case prompt
        case locked
        case entry
    }
    
    // MARK: - View Lifecycle
    
    @IBOutlet weak var lockedView: UIView!
    @IBOutlet weak var lockedLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var securityPromptVC: SecurityPromptViewController? {
        didSet {
            securityPromptVC?.authEntryCompleted = {
                self.showMainScreen()
            }
            
            securityPromptVC?.presentPasscodeEntry = {
                self.displayPinCodeEntry()
            }
        }
    }
    
    var securityEntryVC:  LaunchSetupViewController? {
        didSet {
            securityEntryVC?.authCheckComplete = {
                self.showMainScreen()
            }
            
            securityEntryVC?.presentPasscodeEntry = {
                self.displayPinCodeEntry()
            }
        }
    }
    
    var timer: Timer?
    
    var state = DisplayState.prompt {
        didSet {
//            guard state != state else { return }
            
            loadViewIfNeeded()
            
            updateDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // on initial load, prompt user to setup secure entry to app
        
        lockedLabel.text = LocalString.Landing_Incorrect_Passcode.localized

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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }

    
    func goToApp() {
        if GluuUserDefaults.hasTouchAuthEnabled() == true || GluuUserDefaults.userPin() != nil {
            showSecureEntry()
        } else {
            showSecurityPrompt()
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
    
    
    func updateDisplay() {
        switch state {
        case .locked:
            lockedView.isHidden = false
            containerView.isHidden = true
            
        case .entry:
            lockedView.isHidden = true
            containerView.isHidden = false
            
        case .prompt:
            lockedView.isHidden = true
            containerView.isHidden = false
        }
        
        transitionState()
    }
    
    func transitionState() {
        
        var lastVC: UIViewController?
        var nextVC: UIViewController?
        
        switch state {
        case .entry:
            securityEntryVC = LaunchSetupViewController.fromStoryboard("Landing")
            nextVC = securityEntryVC
            lastVC = securityPromptVC
        
        case .prompt:
            securityPromptVC = SecurityPromptViewController.fromStoryboard("Landing")
            nextVC = securityPromptVC
            lastVC = securityEntryVC
        
        default: return
        }
        
        lastVC?.willMove(toParentViewController: nil)
        
        addChildViewController(nextVC!)
        
//        nextVC?.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nextVC!.view)
        
        nextVC?.view.translatesAutoresizingMaskIntoConstraints = false
        nextVC?.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        nextVC?.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        nextVC?.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nextVC?.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        lastVC?.removeFromParentViewController()
        lastVC?.view.removeFromSuperview()
        lastVC = nil
        
        nextVC?.didMove(toParentViewController: self)
        
        /*
//        containerView.insertSubview(homeNavigationController!.view, belowSubview: landingNavigationController!.view)
        
        var frame       = landingNavigationController!.view.bounds
        frame.origin.y -= frame.height
        
        transition(from: landingNavigationController!,
                   to: homeNavigationController!,
                   duration: 0.30,
                   options: .curveEaseOut,
                   animations: {
                    
                    self.landingNavigationController?.view?.frame = frame
                    
        }) { finished in
            
            self.landingNavigationController!.removeFromParentViewController()
            self.landingNavigationController!.view.removeFromSuperview()
            self.landingNavigationController = nil
            
            self.homeNavigationController!.didMove(toParentViewController: self)
            
        }
        */
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
        state = .prompt
//        performSegue(withIdentifier: "segueToSecurityPrompt", sender: nil)
    }
    
    func showSecureEntry() {
        state = .entry
//        performSegue(withIdentifier: "segueToSecureEntry", sender: nil)
    }
    
    func showMainScreen() {
        
        if let parent = navigationController?.parent as? RootContainerViewController {
            parent.updateDisplay(nextState: .home)
        }
        
//        let mainNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//        UIApplication.shared.keyWindow?.rootViewController = mainNavVC
    }
    
    func displayPinCodeEntry() {
        
        let passcodeAction: PasscodeAction = state == .entry ? .enter : .set
        let passcodeVC = PAPasscodeViewController(for: passcodeAction)
        
        passcodeVC.delegate = self
        passcodeVC.passcode = GluuUserDefaults.userPin() ?? ""
        passcodeVC.simple   = true
        
        let navC = UINavigationController(rootViewController: passcodeVC)
        
        present(navC, animated: true, completion: nil)
        
    }
}

extension LandingViewController: PAPasscodeViewControllerDelegate {
    
    func paPasscodeViewControllerDidChangePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidEnterAlternativePasscode(_ controller: PAPasscodeViewController) {}
    
    func paPasscodeViewControllerDidSetPasscode(_ controller: PAPasscodeViewController) {
        
        GluuUserDefaults.setUserPin(newPin: controller.passcode)
        
        controller.dismiss(animated: true) {
            self.showMainScreen()
        }
    }
    
    func paPasscodeViewController(_ controller: PAPasscodeViewController, didFailToEnterPasscode attempts: Int) {
        
        // lock the user out of the app for xx minutes
        if attempts == GluuConstants.MAX_PASSCODE_ATTEMPTS_COUNT {
            
            UserDefaults.standard.set(Date(), forKey: GluuConstants.LOCKED_DATE)
            
            state = .locked
//            controller.dismiss(animated: true) {
//                self.pinButtons(shouldShow: true)
//                AppDelegate.appDel.showLockedScreen()
//            }
        }
    }
    
    func paPasscodeViewControllerDidCancel(_ controller: PAPasscodeViewController) {

        controller.dismiss(animated: true) {
            
        }
        
    }
    
    func paPasscodeViewControllerDidEnterPasscode(_ controller: PAPasscodeViewController) {
        
        // user successfully entered passcode

        controller.dismiss(animated: true) {
            self.showMainScreen()
        }
    }
}
