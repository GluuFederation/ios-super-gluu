//
//  SingleCellSettingsDetailViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/7/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import LocalAuthentication

class SingleCellSettingsDetailViewController: UITableViewController {

    enum Display {
        case touchId
        case faceId
        case ssl
        
        var titleAndIcon: (String, UIImage?) {
            switch self {
            case .touchId: return (LocalString.Passcode_Touch.localized, #imageLiteral(resourceName: "icon_settings_touchid"))
            case .faceId: return (LocalString.Face_ID.localized, UIImage(named: "icon_settings_faceid"))
            case .ssl:     return (LocalString.SSL_Trust.localized, #imageLiteral(resourceName: "icon_settings_ssl"))
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
    
    @IBOutlet weak var cell: SettingsTableViewCell!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var authSwitch: UISwitch!
    
    var display: Display = .touchId
    
    let touchAuth = TouchIDAuth()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sizeFooterToFit()
    }
    
    func setupDisplay() {
        
        view.backgroundColor = UIColor.Gluu.tableBackground
        
        cell.titleLabel.text = display.titleAndIcon.0
        
        cell.iconImageView?.image = display.titleAndIcon.1
        
        tableView.separatorStyle = .singleLine
        
        footerLabel.font = UIFont.regular(13)
        footerLabel.textColor = UIColor.Gluu.darkGreyText
        footerLabel.text = display.footerText
        
        switch display {
        case .ssl:
            authSwitch.isOn = GluuUserDefaults.isSSLEnabled()
            navigationItem.title = LocalString.SSL_Trust.localized
        
        case .touchId:
            authSwitch.isOn = GluuUserDefaults.hasBioAuthEnabled()
            navigationItem.title = LocalString.Passcode_Touch_Security.localized
            
        case .faceId:
            authSwitch.isOn = GluuUserDefaults.hasBioAuthEnabled()
            navigationItem.title = LocalString.Face_ID.localized
        }
        
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        switch display {
        
        case .ssl:
            GluuUserDefaults.setSSLEnabled(isEnabled: sender.isOn)
            
        case .touchId:
            GluuUserDefaults.setBioAuth(isOn: sender.isOn)
            
        case .faceId:
            GluuUserDefaults.setBioAuth(isOn: sender.isOn)
            
        }
    }
    
    func sizeFooterToFit() {
        
        guard let footerView = footerLabel.superview else { return }
        
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        
        let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = footerView.frame
        frame.size.height = height + 50
        footerView.frame = frame
        
        tableView.tableFooterView = footerView
        
    }
    
}

