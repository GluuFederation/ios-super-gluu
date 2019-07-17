//
//  SecurityPromptViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/14/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

class SecurityPromptViewController: UIViewController {
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var touchStackView: UIStackView?
    @IBOutlet weak var touchButton: UIButton?
    @IBOutlet weak var separatorView: UIView?
    
    let touchAuth = TouchIDAuth()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Add Secure Entry"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = " "
    }
    
    func setupDisplay() {
        
        view.backgroundColor = UIColor.Gluu.tableBackground
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white 
        navigationController?.navigationBar.barTintColor = AppConfiguration.systemColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        separatorView?.backgroundColor = UIColor.Gluu.tableBackground
        
        buttonsStackView.superview?.backgroundColor = UIColor.white
        
        // Eric Point to come back to to enforce security
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(dismissVC))
        
        if touchAuth.canEvaluatePolicy() == false {
            touchStackView?.arrangedSubviews.forEach({$0.removeFromSuperview()})
            touchStackView?.removeFromSuperview()
            touchButton?.removeFromSuperview()
            separatorView?.removeFromSuperview()
        }
    }
    
    @IBAction func pinTapped() {
        goToPinEntry()
    }
    
    @IBAction func touchTapped() {
        touchAuth.authenticateUser { (success, errorMessage) in

            GluuUserDefaults.setTouchAuth(isOn: success)
            
            self.dismissVC()
            
        }
    }
    
    func goToPinEntry() {
        let passcodeVC = PAPasscodeViewController.init(for: .set)
        
        passcodeVC.delegate = self
        passcodeVC.simple = true
        passcodeVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        navigationController?.pushViewController(passcodeVC, animated: true)
        
    }
    
    @objc
    func dismissVC() {
        
        GluuUserDefaults.setSecurityPromptShown()
        
        performSegue(withIdentifier: "segueUnwindSecurityPromptToLanding", sender: nil)
    }
}

// MARK: - PAPasscodeViewController Delegate

extension SecurityPromptViewController: PAPasscodeViewControllerDelegate {
    
    func paPasscodeViewControllerDidSetPasscode(_ controller: PAPasscodeViewController) {
        
        GluuUserDefaults.setUserPin(newPin: controller.passcode)
        
        self.dismissVC()
    }

    func paPasscodeViewControllerDidCancel(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidEnterPasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidChangePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidEnterAlternativePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewController(_ controller: PAPasscodeViewController, didFailToEnterPasscode attempts: Int) {}
    
    
    
    
    
    
}
