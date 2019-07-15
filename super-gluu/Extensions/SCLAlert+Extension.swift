//
//  SCLAlert+Extension.swift
//  Super Gluu
//
//  Created by Eric Webb on 10/2/18.
//  Copyright © 2018 Gluu. All rights reserved.
//


import SCLAlertView
import UIKit

extension SCLAlertView {
    
    convenience init(autoDismiss: Bool = false, showCloseButton: Bool = true, closeButtonColor: UIColor = AppConfiguration.systemColor, horizontalButtons: Bool = true) {

        let bgColor = UIColor.white
        let titleFont = UIFont(name: "ProximaNova-Semibold", size: 20)
        let titleColor = AppConfiguration.systemColor
        let subtitleColor = UIColor.darkGray
        let bodyFont = UIFont(name: "ProximaNova-Regular", size: 15)
        let buttonFont = UIFont(name: "ProximaNova-Regular", size: 15)

        let buttonLayout: SCLAlertButtonLayout = horizontalButtons ? .horizontal : .vertical

        let appearance = SCLAlertView.SCLAppearance(kTitleFont: titleFont!,
                                                    kTextFont: bodyFont!,
                                                    kButtonFont: buttonFont!,
                                                    showCloseButton: showCloseButton,
                                                    showCircularIcon: true,
                                                    shouldAutoDismiss: autoDismiss,
                                                    hideWhenBackgroundViewIsTapped: true,
                                                    contentViewColor: bgColor,
                                                    titleColor: titleColor,
                                                    subTitleColor: subtitleColor,
                                                    closeButtonColor: closeButtonColor,
                                                    buttonsLayout: buttonLayout)

        self.init(appearance: appearance)

    }
    
    func dismissTimeout(delay: Int = 3, action: (()->())? = nil) -> SCLTimeoutConfiguration {
        return SCLAlertView.SCLTimeoutConfiguration.init(timeoutValue: 3, timeoutAction: {
            self.dismiss(animated: true, completion: nil)
            
            action?()
        })
    }
}

