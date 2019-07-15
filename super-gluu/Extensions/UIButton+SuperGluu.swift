//
//  UIButton+SuperGluu.swift
//  Super Gluu
//
//  Created by Eric Webb on 4/5/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import Foundation
import UIKit

extension UIButton
{
    
    enum SpinnerLocation {
        case Center
        case Right
    }
    
    
    // display a spinner in a UIButton with a location of Center or Right
    func showSpinner(location: SpinnerLocation? = .Center, style: UIActivityIndicatorViewStyle? = .white) {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = style ?? .white
        
        isEnabled = false
        
        if location == .Center {
            setTitle("", for: .disabled)
            spinner.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        } else {
            var mid = self.center
            mid.x = (self.bounds.maxX - 30)
            mid.y = self.bounds.size.height / 2
            spinner.center = mid
        }
        
        addSubview(spinner)
        spinner.startAnimating()
    }
    
    
    func hideSpinner() {
        
        //        guard let superV = self.superview else { return }
        for v in subviews {
            if v is UIActivityIndicatorView {
                v.removeFromSuperview()
            }
        }
        
        self.isEnabled = true
    }
    
    
    func correctButtonWidth() -> CGFloat {
        
        let titleInsets = titleEdgeInsets.left + titleEdgeInsets.right
        let imageInsets = imageEdgeInsets.left + imageEdgeInsets.right
        let contentInsets = contentEdgeInsets.left + contentEdgeInsets.right
        
        var imgWidth: CGFloat = 0
        var titleWidth: CGFloat = 0
        
        if let img = image(for: .normal) {
            imgWidth = img.size.width
        }
        
        if let titleL = titleLabel {
            titleWidth = titleL.intrinsicContentSize.width
        }
        
        let realWidth = titleWidth + imgWidth + contentInsets + imageInsets + titleInsets
        
        var widthConstraint: NSLayoutConstraint?
        for constraint: NSLayoutConstraint in self.constraints {
            if constraint.firstAttribute == .width {
                widthConstraint = constraint
                self.removeConstraint(widthConstraint!)
            }
        }
        
        widthAnchor.constraint(equalToConstant: realWidth).isActive = true
        
        return realWidth
    }
}
