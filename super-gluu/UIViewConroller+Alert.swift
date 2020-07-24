//
//  UIViewConroller+Alert.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyi on 7/24/20.
//  Copyright © 2020 Gluu. All rights reserved.
//

import UIKit
import SCLAlertView

extension UIViewController {
  
  func showAlert(title: String, message: String) {
    let alert = SCLAlertView(autoDismiss: true, horizontalButtons: false)
    
    alert.showCustom(
      title,
      subTitle: message,
      color: AppConfiguration.systemColor,
      closeButtonTitle: LocalString.Ok.localized,
      timeout: alert.dismissTimeout(),
      circleIconImage: AppConfiguration.systemAlertIcon,
      animationStyle: SCLAnimationStyle.topToBottom
    )
  }
  
  func showAlert(
    title: String,
    message: String,
    buttonOk: String,
    buttonOkHandler: @escaping VoidCallback,
    buttonCancel: String? = nil,
    buttonCancelHandler: VoidCallback? = nil
  ) {
    let alert = SCLAlertView(
      autoDismiss: false,
      showCloseButton: false,
      horizontalButtons: true,
      hideWhenBackgroundViewIsTapped: false
    )
    
    alert.addButton(buttonOk) {
      buttonOkHandler()
      alert.hideView()
    }
    
    if let cancelTitle = buttonCancel, let cancelHandler = buttonCancelHandler {
      alert.addButton(cancelTitle) {
        cancelHandler()
        alert.hideView()
      }
    }
    
    alert.showCustom(
      title,
      subTitle: message,
      color: AppConfiguration.systemColor,
      timeout: nil,
      circleIconImage: AppConfiguration.systemAlertIcon,
      animationStyle: SCLAnimationStyle.topToBottom
    )
  }
}
