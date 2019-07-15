//
//  SettingsTableViewCell.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/4/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import UIKit


class SettingsSwitchTableViewCell: SettingsTableViewCell {
    
    @IBOutlet weak var settingsSwitch: UISwitch!
    
}


class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView?
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        titleLabel.font = UIFont.regular(17)
        
    }

    override func prepareForReuse() {
        
        titleLabel.text = nil
        iconImageView?.image = nil
        
    }


}
