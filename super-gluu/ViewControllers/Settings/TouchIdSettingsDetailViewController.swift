//
//  TouchIdSettingsDetailViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/7/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

class TouchIdSettingsDetailViewController: UITableViewController {

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
                return "When enabled, access to your \(AppConfiguration.systemTitle) app will be protected by touch ID."
            case .ssl:
                return "Enable this option only during devlopment. When enabled, \(AppConfiguration.systemTitle) will trust self-signed certificates. \n\n If the certificate is signed by a certificate authority (CA) trust all should be disabled."
            }
        }
        
    }
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var cellIconImageView: UIImageView!
    
    var display: Display = .touchId
    
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
        
        cellTitleLabel.font = UIFont.regular(17)
        cellTitleLabel.text = display.titleAndIcon.0
        
        cellIconImageView.image = display.titleAndIcon.1
        
        tableView.separatorStyle = .singleLine
        
        footerLabel.font = UIFont.regular(13)
        footerLabel.textColor = UIColor.Gluu.darkGreyText
        footerLabel.text = display.footerText
        
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        switch display {
        case .ssl:
            return
            
        case .touchId:
            return
        }
    }
    
    func sizeFooterToFit() {
        
        guard let footerView = footerLabel.superview else { return }
        
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        
        let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = footerView.frame
        frame.size.height = height
        footerView.frame = frame
        
        tableView.tableFooterView = footerView
        
    }

}
