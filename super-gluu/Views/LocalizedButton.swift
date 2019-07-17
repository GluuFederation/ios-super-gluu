//
//  LocalizedButton.swift
//  Super Gluu
//
//  Created by eric webb on 7/16/19.
//  Copyright © 2019 Gluu. All rights reserved.
//

import UIKit

class LocalizedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let title = self.title(for: .normal)?.localized()
        setTitle(title, for: .normal)
    }

}
