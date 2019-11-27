//
//  WebViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import WebKit


enum WebDisplay: String {
    case privacy = "Privacy Policy"
    case tos = "Terms of Service"
    
    // ** Local Text TOS
    var localized: String {
        switch self {
        case .privacy: return LocalString.Menu_Privacy_Policy.localized
        case .tos: return LocalString.TOS.localized
        }
    }
    
    var urlString: String {
        switch self {
        case .privacy:
            return GluuConstants.PRIVACY_POLICY
            
        case .tos:
            return GluuConstants.TERMS_OF_SERVICE
        }
    }
}

class WebViewController: UIViewController {
    
    let webView = WKWebView()
    
    var display = WebDisplay.privacy
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
        
        title = display.localized
        
        webView.load(URLRequest(url: URL(string: display.urlString)!))
        
    }
    
    // MARK: - View Setup
    
    func setupDisplay() {
        
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
}
