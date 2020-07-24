//
//  SCLAlert+Extension.swift
//  Super Gluu
//
//  Created by Eric Webb on 10/2/18.
//  Copyright © 2018 Gluu. All rights reserved.
//


import SCLAlertView
import UIKit

enum ErrorType {
    
    case general

    var message: String {
        var msg = ""
        
        switch self {
        case .general: msg = ""
        }
        
        return msg
    }
}

/// Extending error to make it alertable
extension Error {
    
    /// displays alert from source controller
    func alert(with controller: UIViewController, errorType: ErrorType) {
        
//        let screencaptureRequest = "PLEASE SCREENSHOT THIS ENTIRE MESSAGE AND SEND TO \(Constants.supportEmail)"
//        let title = "Oops ❗️ \n\n" + screencaptureRequest
//
//        let msg = errorType.message + "\n\n\n \(self)"
//
//        let alert = AlertType.normal.alert
//
//        alert.addButton(title: "OK") {
//            alert.dismiss(animated: true, completion: nil)
//        }
//
//        alert.show(title: title, subTitle: msg, autoDismiss: false, autoDismissAction: nil)
    }
}

enum InfoAlert {
    case homeScreenLoadTime
    
    var message: String {
        switch self {
        case .homeScreenLoadTime: return "We're pulling down a lot of data so that you will have what you need when offline. It may take 1-4 minutes. The indicator at the top right of the screen will stop spinning when loading is complete."
        }
    }
    
    var title: String {
        switch self {
        case .homeScreenLoadTime: return "This could take a couple minutes..."
        }
    }
    
    var key: String {
        switch self {
        case .homeScreenLoadTime: return "" //Constants.UserDefaults.homescreenFetchAlert
        }
    }
}

enum Success {
    case passwordReset
    case createVisit
    
    var message: String {
        switch self {
        case .passwordReset: return "You should receive an email containing instructions on how to reset your password."
        case .createVisit: return "This new visit has been created."
        }
    }
}

enum AlertButtonStyle {
    case normal
    case dismiss
    
    var backgroundColor: UIColor {
        switch self {
        case .normal:
            return UIColor.Gluu.green //Colors.primaryCTA
        case .dismiss:
            return .red
        }
    }
}

extension SCLAlertView {
    
  convenience init(autoDismiss: Bool = false, showCloseButton: Bool = true, closeButtonColor: UIColor = AppConfiguration.systemColor, horizontalButtons: Bool = true, hideWhenBackgroundViewIsTapped: Bool = true) {

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
                                                    hideWhenBackgroundViewIsTapped: hideWhenBackgroundViewIsTapped,
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
    
    /*
    func show(title: String, subTitle: String? = nil, autoDismiss: Bool, autoDismissAction: (()->Void)?) {
        
        let timer = SCLAlertView.SCLTimeoutConfiguration.init(timeoutValue: 3.0, timeoutAction: autoDismissAction ?? {})
        
        showInfo(title,
                 subTitle: subTitle ?? "",
                 closeButtonTitle: nil,
                 timeout: autoDismiss ? timer : nil,
                 colorStyle: 0xFFFFFF,
                 circleIconImage: UIImage(named: "launch_logo")!)
    }
    
    
    func addButton(title: String, style: AlertButtonStyle = .normal, action: (()->Void)?) {
        addButton(title, backgroundColor: style.backgroundColor, textColor: .white, showTimeout: nil, action: action ?? {})
    }
    
    
    static func showError(title: String, error: GluuError) {
        let alert = AlertType.normal.alert
        
        alert.addButton(title: "Ok", style: .dismiss) {
            alert.hideView()
        }
        
        alert.showInfo(title,
                       subTitle: error.message?.capitalized ?? "",
                       closeButtonTitle: nil,
                       timeout: nil,
                       colorStyle: 0xFFFFFF,
                       circleIconImage: UIImage(named: "launch_logo")!)
    }
    
    static func showSuccess(success: Success, dismissAction: (()->Void)?) {
        let alert = AlertType.normal.alert
        
        alert.addButton(title: "Ok", style: .normal) {
            alert.hideView()
            dismissAction?()
        }
        
        alert.showInfo("Success!",
                       subTitle: success.message,
                       closeButtonTitle: nil,
                       timeout: nil,
                       colorStyle: 0xFFFFFF,
                       circleIconImage: UIImage(named: "launch_logo")!)
    }
    
    static func showInfoAlert(_ info: InfoAlert, dismissAction: (()->Void)?) {
        let alert = AlertType.normal.alert
        
        alert.addButton(title: "Ok", style: .normal) {
            alert.hideView()
            dismissAction?()
            
            UserDefaults.standard.set(true, forKey: info.key)
        }
        
        alert.showInfo(info.title,
                       subTitle: info.message,
                       closeButtonTitle: nil,
                       timeout: nil,
                       colorStyle: 0xFFFFFF,
                       circleIconImage: UIImage(named: "launch_logo")!)
    }
 */
}


