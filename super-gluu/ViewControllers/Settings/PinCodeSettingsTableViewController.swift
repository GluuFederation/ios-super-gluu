//  PinCodeSettingsTableViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/12/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import LocalAuthentication
import UIKit
import SCLAlertView


class PinCodeSettingsTableViewController: UITableViewController, PAPasscodeViewControllerDelegate {
    
    @IBOutlet weak var pinSwitch: UISwitch!
    
    private var passcodeViewController: PAPasscodeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplay()

    }

    func setupDisplay() {

        view.backgroundColor = UIColor.Gluu.tableBackground

        tableView.backgroundColor = UIColor.Gluu.tableBackground
        tableView.separatorStyle = .singleLine

        let isPinEnabled: Bool = GluuUserDefaults.userPin() != nil
        pinSwitch.isOn = isPinEnabled

        // setup the second section
        updateUI()

        navigationItem.title = "Passcode"

    }

    @IBAction func pinSwitchValueChanged(_ sender: Any) {

        // User turned pincode entry off
        if pinSwitch.isOn == false {
            removeUserPin()
        } else {
            // User turned pincode entry on.
            // Reset the pincode
            displayPinCodeEntryScreen()
        }

    }

    func updateUI() {

        // hide/show second section based on value of PIN_ENABLED

        tableView.reloadData()

    }

    func userPin() -> String? {
        return GluuUserDefaults.userPin()
    }

    func updateUserPin(_ pin: String) {
        
        GluuUserDefaults.setUserPin(newPin: pin)

        updateUI()
    }

    func removeUserPin() {
        GluuUserDefaults.removeUserPin()
        pinSwitch.setOn(false, animated: true)

        updateUI()
    }

// MARK: - Table View DataSource / Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        if pinSwitch.isOn == true {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 1 && indexPath.row == 0 {

            // go to set pin code screen
            displayPinCodeEntryScreen()
        }
    }

    func displayPinCodeEntryScreen() {

        if let pin = userPin() {
            passcodeViewController = PAPasscodeViewController(for: .change)
            passcodeViewController?.passcode = pin
            passcodeViewController?.title = "Reset Passcode"
        } else {
            passcodeViewController = PAPasscodeViewController(for: .set)
        }

        if UI_USER_INTERFACE_IDIOM() == .phone {
            passcodeViewController?.backgroundView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        }

        passcodeViewController?.delegate = self

        if let aController = passcodeViewController {
            present(UINavigationController(rootViewController: aController), animated: true)
        }

    }

// MARK: - PAPasscodeViewControllerDelegate
    func paPasscodeViewControllerDidCancel(_ controller: PAPasscodeViewController) {

        // if the user didn't enter a pin, pincode shouldn't be turned on
        if userPin() == nil {
            removeUserPin()
        }

        dismiss(animated: true)
    }
    
    func paPasscodeViewControllerDidChangePasscode(_ controller: PAPasscodeViewController) {

        self.dismiss(animated: true) {
            let newPassword = controller.passcode
            let oldPassword = UserDefaults.standard.object(forKey: GluuConstants.PIN_CODE) as? String
            if (newPassword == oldPassword) {

                let alert = SCLAlertView(autoDismiss: false, horizontalButtons: false)
                
                alert.showCustom(NSLocalizedString("Info", comment: "Info"),
                                 subTitle: "Your new passcode must be different from your previous one.",
                                 color: AppConfiguration.systemColor,
                                 closeButtonTitle: "Close",
                                 circleIconImage: AppConfiguration.systemAlertIcon,
                                 animationStyle: SCLAnimationStyle.topToBottom)
                
            } else {

                let alert = SCLAlertView(autoDismiss: false, horizontalButtons: false)
                
                alert.showCustom(NSLocalizedString("Info", comment: "Info"),
                                 subTitle: "You have successfully set a new passcode.",
                                 color: AppConfiguration.systemColor,
                                 closeButtonTitle: "Close",
                                 circleIconImage: AppConfiguration.systemAlertIcon,
                                 animationStyle: SCLAnimationStyle.topToBottom)

                self.updateUserPin(controller.passcode)
            }
        }
    }

    func paPasscodeViewControllerDidSetPasscode(_ controller: PAPasscodeViewController) {
        
        
        self.dismiss(animated: true) {

            self.updateUserPin(controller.passcode)

            // eric
            //        [_setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];

        }
    }

    func paPasscodeViewController(_ controller: PAPasscodeViewController, didFailToEnterPasscode attempts: Int) {
        
        // show warning alert
        if attempts == GluuConstants.MAX_PASSCODE_ATTEMPTS_COUNT - 2 {
            showAlertView()
        }
        
        // lock the user out of the app for xx minutes
        if attempts == GluuConstants.MAX_PASSCODE_ATTEMPTS_COUNT {
            
            UserDefaults.standard.set(Date(), forKey: GluuConstants.LOCKED_DATE)
            controller.dismiss(animated: true, completion: {
                AppDelegate.appDel.showLockedScreen()
            })
        
        }
    }
    
    func paPasscodeViewControllerDidEnterAlternativePasscode(_ controller: PAPasscodeViewController) {}
    func paPasscodeViewControllerDidEnterPasscode(_ controller: PAPasscodeViewController) {}

    func showAlertView() {
        let alert = SCLAlertView(autoDismiss: false, showCloseButton: false, horizontalButtons: false)
        
        alert.addButton("Ok", backgroundColor: AppConfiguration.systemColor, textColor: .white) {
            alert.hideView()
            self.passcodeViewController?.showKeyboard()
        }
        
        alert.showCustom(NSLocalizedString("Info", comment: "Info"),
                         subTitle: NSLocalizedString("LastAttempts", comment: "LastAttempts"),
                         color: AppConfiguration.systemColor,
                         circleIconImage: AppConfiguration.systemAlertIcon,
                         animationStyle: SCLAnimationStyle.topToBottom)

        passcodeViewController?.hideKeyboard()
    }
}
