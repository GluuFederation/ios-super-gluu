//
//  LogDetailViewController.swift
//  Super Gluu
//
//  Created by eric webb on 8/1/19.
//  Copyright © 2019 Gluu. All rights reserved.
//

import UIKit
import CFNetwork
import CoreTelephony
import SCLAlertView
import ox_push3


class LogDetailViewController: UIViewController {
    
    @IBOutlet var serverNameLabel: UILabel!
    @IBOutlet var serverUrlLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var createdTimeLabel: UILabel!
    @IBOutlet var createdDateLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var titleLabels: [UILabel]!
    
    
    var userInfo: UserLoginInfo?
    
    private var alertView: SCLAlertView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateInfo()
        
        let sel: Selector = #selector(LogDetailViewController.showDeleteLogAlert)
        let trashButton = UIBarButtonItem(image: UIImage(named: "icon_nav_trash"), style: .plain, target: self, action: sel)
        navigationItem.rightBarButtonItem = trashButton
        
        setupDisplay()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ApproveDenyViewController.openURL(_:)))
        serverUrlLabel.isUserInteractionEnabled = true
        serverUrlLabel.addGestureRecognizer(tap)
    }
    
    func setupDisplay() {
        
        titleLabels.forEach({ $0.textColor = UIColor.black })
        
        cityNameLabel.textColor = UIColor.Gluu.lightGreyText
        createdDateLabel.textColor = UIColor.Gluu.lightGreyText
        
    }
    
    @objc func openURL(_ tap: UITapGestureRecognizer?) {
        let label = tap?.view as? UILabel
        let targetURL = URL(string: label?.text ?? "")
        if let anURL = targetURL {
            UIApplication.shared.open(anURL, options: [:])
        }
    }
    
    func updateInfo() {
        var info: UserLoginInfo? = userInfo
        
        if info == nil {
            info = UserLoginInfo.sharedInstance()
        }
        
        userNameLabel.text = info!.userName
        
        let server = info!.issuer
        serverUrlLabel.text = server
        
        if server != nil {
            let serverURL = URL(string: server ?? "")
            serverNameLabel.text = "\(serverURL?.host ?? "")"
        }
        
        if info!.created != nil {
            createdTimeLabel.text = info!.created.getTime()
            createdDateLabel.text = info!.created.getDate()
        }
        
        if info!.locationIP != nil {
            locationLabel.text = info!.locationIP
        }
        if info!.locationCity != nil {
            let location = info!.locationCity
            let locationDecode = location?.urlDecode()
            cityNameLabel.text = locationDecode
        }
        
        if let authType = OxRequestType(rawValue: info!.authenticationType) {
            typeLabel.text = authType.localizedString()
        } else {
            // handles legacy cases where the authType was "enrol"
            var authType = OxRequestType.authenticate
            if info!.authenticationType.lowercased().hasPrefix("enr") {
                authType = OxRequestType.enroll
            }
            
            typeLabel.text = authType.localizedString()
        }
        
        
        switch info!.logState {
        case .LOGIN_FAILED, .ENROLL_FAILED, .ENROLL_DECLINED, .LOGIN_DECLINED, .UNKNOWN_ERROR:
            logoImageView.image = AppConfiguration.systemLogRedIcon
            
        default: break
        }
            
        
    }
    
    @IBAction func onDeleteClick() {
        showDeleteLogAlert()
    }
    
    func showAlertView(withTitle title: String?, andMessage message: String?, withCloseButton showCloseButton: Bool) {
        
        if alertView == nil {
            alertView = SCLAlertView(autoDismiss: false, showCloseButton: showCloseButton, horizontalButtons: false)
        }
        
        alertView?.showCustom(title ?? "",
                              subTitle: message ?? "",
                              color: AppConfiguration.systemColor,
                              closeButtonTitle: "",
                              timeout: nil,
                              circleIconImage: AppConfiguration.systemAlertIcon,
                              animationStyle: .topToBottom)
    }
    
    @objc func showDeleteLogAlert() {
        let alert = SCLAlertView(autoDismiss: false, showCloseButton: true, horizontalButtons: true)
        
        alert.addButton(AlertConstants.yes, backgroundColor: .red, action: {
            if self.userInfo != nil {
                self.deleteLog(self.userInfo!)
            }
            
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.showCustom(AlertConstants.delete,
                         subTitle: LocalString.Clear_Log.localized,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: AlertConstants.no,
                         circleIconImage: UIImage(named: "icon_trashcan_large")!)
        
    }
    
    func deleteLog(_ log: UserLoginInfo?) {
        // Eric
        DataStoreManager.sharedInstance().deleteLog(log)
        
        navigationController?.popViewController(animated: true)
    }
    
}


