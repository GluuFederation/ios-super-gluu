//
//  SingleCellSettingsDetailViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/7/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

class SingleCellSettingsDetailViewController: UITableViewController {

    enum Display {
        case touchId
        case ssl
        
        var titleAndIcon: (String, UIImage?) {
            switch self {
            case .touchId: return ("Touch ID", #imageLiteral(resourceName: "icon_settings_touchid"))
            case .ssl:     return ("Trust all SSL", #imageLiteral(resourceName: "icon_settings_ssl"))
            }
        }
        
        var footerText: String {
            switch self {
            case .touchId:
                return "When enabled, access to your Super Gluu app will be protected by touch ID."
            case .ssl:
                return "Enable this option only during devlopment. When enabled, Super Gluu will trust self-signed certificates. \n\n If the certificate is signed by a certificate authority (CA) trust all should be disabled."
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
            navigationItem.title = "Trust SSL"
        
        case .touchId:
            authSwitch.isOn = GluuUserDefaults.hasTouchAuthEnabled()
            navigationItem.title = "Touch Security"
        
        }
        
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        switch display {
        
        case .ssl:
            GluuUserDefaults.setSSLEnabled(isEnabled: sender.isOn)
            
        case .touchId:
            GluuUserDefaults.setTouchAuth(isOn: sender.isOn)
            
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

