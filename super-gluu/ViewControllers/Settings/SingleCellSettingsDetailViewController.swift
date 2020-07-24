//
//  SingleCellSettingsDetailViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/7/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import LocalAuthentication

final class SingleCellSettingsDetailViewController: UITableViewController {
    
    enum Display {
        
        case touchId
        case faceId
        case ssl
        
        var title: String {
            switch self {
            case .touchId:
                return LocalString.Passcode_Touch.localized
            case .faceId:
                return LocalString.Face_ID.localized
            case .ssl:
                return LocalString.SSL_Trust.localized
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .touchId:
                return #imageLiteral(resourceName: "icon_settings_touchid")
            case .faceId:
                return UIImage(named: "icon_settings_faceid")
            case .ssl:
                return #imageLiteral(resourceName: "icon_settings_ssl")
            }
        }
        
        var footerText: String {
            switch self {
            case .touchId:
                return LocalString.Passcode_Enabled_Info.localized
            case .faceId:
                return LocalString.When_Enabled_FaceId.localized
            case .ssl:
                return LocalString.SSL_Info.localized
            }
        }
        
    }
    
    @IBOutlet private weak var cell: SettingsTableViewCell!
    @IBOutlet private weak var footerLabel: UILabel!
    @IBOutlet private weak var authSwitch: UISwitch!
    
    private let touchAuth = TouchIDAuth()
    
    var display: Display = .touchId
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sizeFooterToFit()
    }
    
    // MARK: - IBAction
    
    @IBAction private func switchValueChanged(sender: UISwitch) {
        switch display {
        case .ssl:
            sender.isOn ? showAdmitAlertForSSL() : enableSSL(enabled: sender.isOn)
            
        case .touchId:
            GluuUserDefaults.setBioAuth(isOn: sender.isOn)
            
        case .faceId:
            GluuUserDefaults.setBioAuth(isOn: sender.isOn)
            
        }
    }
    
    // MARK: - Private
    
    private func sizeFooterToFit() {
        
        guard let footerView = footerLabel.superview else {
            return
        }
        
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        
        let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = footerView.frame
        frame.size.height = height + 50
        footerView.frame = frame
        
        tableView.tableFooterView = footerView
    }
    
    private func setupDisplay() {
        view.backgroundColor = UIColor.Gluu.tableBackground
        tableView.separatorStyle = .singleLine
        
        cell.titleLabel.text = display.title
        cell.iconImageView?.image = display.icon
        
        footerLabel.font = UIFont.regular(13)
        footerLabel.textColor = UIColor.Gluu.darkGreyText
        footerLabel.text = display.footerText
        
        setupTitle()
        setupSwitch()
    }
    
    private func setupTitle() {
        switch display {
        case .ssl:
            navigationItem.title = LocalString.SSL_Trust.localized
            
        case .touchId:
            navigationItem.title = LocalString.Passcode_Touch_Security.localized
            
        case .faceId:
            navigationItem.title = LocalString.Face_ID.localized
        }
    }
    
    private func setupSwitch() {
        switch display {
        case .ssl:
            authSwitch.isOn = GluuUserDefaults.isSSLEnabled()
            
        case .touchId:
            authSwitch.isOn = GluuUserDefaults.hasBioAuthEnabled()
            
        case .faceId:
            authSwitch.isOn = GluuUserDefaults.hasBioAuthEnabled()
        }
    }
    
    private func showAdmitAlertForSSL() {
        showAlert(
            title: "Admin Testing Only",
            message: "This feature is just for admin testing proposes. Are an admin needing enable it?",
            buttonOk: "Yes",
            buttonOkHandler: { [weak self] in
                self?.enableSSL(enabled: true)
        }, buttonCancel: "No",
           buttonCancelHandler: { [weak self] in
            self?.enableSSL(enabled: false)
        })
    }
    
    private func enableSSL(enabled: Bool) {
        GluuUserDefaults.setSSLEnabled(isEnabled: enabled)
        setupSwitch()
    }
}

