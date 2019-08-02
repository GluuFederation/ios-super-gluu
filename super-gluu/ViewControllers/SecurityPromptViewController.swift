//
//  SecurityPromptViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/14/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import LocalAuthentication

class SecurityPromptViewController: UIViewController {
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var bioButton: UIButton?
    @IBOutlet weak var passcodeButton: UIButton?
    @IBOutlet weak var separatorView: UIView?
    @IBOutlet weak var headerLabel: UILabel?
    
    let touchAuth = TouchIDAuth()
    
    var authEntryCompleted: (()->Void)?
    var presentPasscodeEntry: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        passcodeButton?.addDetailDisclosure()
        bioButton?.addDetailDisclosure()
    }
    
    func setupDisplay() {
        
        view.backgroundColor = UIColor.Gluu.tableBackground
        
        headerLabel?.text = "Add Secure Entry"
        
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.barTintColor = AppConfiguration.systemColor
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        separatorView?.backgroundColor = UIColor.Gluu.tableBackground
        
        buttonsStackView.superview?.backgroundColor = UIColor.white
        
        passcodeButton?.setTitle(LocalString.Security_Passcode.localized, for: .normal)

        
        switch LAContext().biometricType {
        case .faceID:
            let faceIdIcon = UIImage(named: "icon_settings_touchid")
            bioButton?.setImage(faceIdIcon, for: .normal)
            bioButton?.setTitle(LocalString.Security_Face_Id.localized, for: .normal)
        case .touchID:
            let faceIdIcon = UIImage(named: "icon_settings_touchid")
            bioButton?.setImage(faceIdIcon, for: .normal)
            bioButton?.setTitle(LocalString.Security_Touch_Id.localized, for: .normal)
        case .none:
            bioButton?.removeFromSuperview()
            separatorView?.removeFromSuperview()
        }
        
    }
    
    @IBAction func pinTapped() {
        goToPinEntry()
    }
    
    @IBAction func bioTapped() {
        touchAuth.authenticateUser { (success, errorMessage) in

            GluuUserDefaults.setTouchAuth(isOn: success)
            
            self.dismissVC()
            
        }
    }
    
    func goToPinEntry() {
        presentPasscodeEntry?()
//        let passcodeVC = PAPasscodeViewController.init(for: .set)
//
//        passcodeVC.delegate = self
//        passcodeVC.simple = true
//        passcodeVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
//
//        navigationController?.pushViewController(passcodeVC, animated: true)
        
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

    func paPasscodeViewControllerDidCancel(_ controller: PAPasscodeViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func paPasscodeViewControllerDidEnterPasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidChangePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidEnterAlternativePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewController(_ controller: PAPasscodeViewController, didFailToEnterPasscode attempts: Int) {}
    

}
