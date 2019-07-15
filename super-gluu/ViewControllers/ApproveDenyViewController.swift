//  ApproveDenyViewController.swift
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/3/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

import UIKit
import CFNetwork
import CoreTelephony
import SCLAlertView
import ox_push3


/*
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <CFNetwork/CFNetwork.h>
#import "NSString+URLEncode.h"

#import "OXPushManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "DataStoreManager.h"
 */

let moveUpY = 70
let LANDSCAPE_Y = 290
let LANDSCAPE_Y_IPHONE_5 = 245
let START_TIME = 40

class ApproveDenyViewController: UIViewController {
    
    @IBOutlet var approveDenyContainerView: UIView!
    @IBOutlet var approveRequest: UIButton!
    @IBOutlet var denyRequest: UIButton!
    //Info
    @IBOutlet var serverNameLabel: UILabel!
    @IBOutlet var serverUrlLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var createdTimeLabel: UILabel!
    @IBOutlet var createdDateLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var separators: [UIView]!
    @IBOutlet var titleLabels: [UILabel]!
    
    
    // if isLogDisplay, we're displaying info about a previous authorization
    var isLogDisplay = false
    var userInfo: UserLoginInfo?
    var isLandScape = false
    var timer: Timer?
    var time: Int = 0
    var timerLabel: UILabel?
    
    private var alertView: SCLAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocalization()
        updateInfo()

        if !isLogDisplay {
            initAndStartTimer()
        } else {
            // showing info about a specific log
            let sel: Selector = #selector(ApproveDenyViewController.showDeleteLogAlert)
            let trashButton = UIBarButtonItem(image: UIImage(named: "icon_nav_trash"), style: .plain, target: self, action: sel)
            navigationItem.rightBarButtonItem = trashButton
        }

        setupDisplay()

        let tap = UITapGestureRecognizer(target: self, action: #selector(ApproveDenyViewController.openURL(_:)))
        serverUrlLabel.isUserInteractionEnabled = true
        serverUrlLabel.addGestureRecognizer(tap)
    }
    
    func setupDisplay() {
        
        separators.forEach({ $0.backgroundColor = UIColor.Gluu.separator })
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

    func initAndStartTimer() {

        // Add countdown timer label to right side of navbar

        timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 24))
        timerLabel?.numberOfLines = 1
        timerLabel?.backgroundColor = UIColor.clear
        timerLabel?.textColor = UIColor.white
        timerLabel?.textAlignment = .right
        
        let timerBBI = UIBarButtonItem(customView: timerLabel!)

        navigationItem.rightBarButtonItem = timerBBI

        timerLabel?.text = String(format: "%i", START_TIME)
        time = START_TIME
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ApproveDenyViewController.updateTime), userInfo: nil, repeats: true)

    }

    @objc func updateTime() {
        time -= 1
        timerLabel?.text = String(format: "%i", time)
        
        if time == 20 {
            timerLabel?.textColor = UIColor.yellow
        }
        
        if time == 10 {
            timerLabel?.textColor = UIColor.red
        }
        
        if time == 0 {
            denyTapped()
        }

    }

    func initLocalization() {
        //    [approveRequest setTitle:NSLocalizedString(@"Approve", @"Approve") forState:UIControlStateNormal];
        //    [denyRequest setTitle:NSLocalizedString(@"Deny", @"Deny") forState:UIControlStateNormal];
        
        
//        titleLabel.text = NSLocalizedString("PressApprove", comment: "To continue, press Approve")
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
            serverNameLabel.text = "Gluu Server \(serverURL?.host ?? "")"
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
        typeLabel.text = info!.authenticationType

        if isLogDisplay {
            approveDenyContainerView.isHidden = true
            
            switch info!.logState {
            case .LOGIN_FAILED, .ENROLL_FAILED, .ENROLL_DECLINED, .LOGIN_DECLINED, .UNKNOWN_ERROR:
                logoImageView.image = AppConfiguration.systemLogRedIcon
                
            default: break
            }
            
        } else {
            navigationItem.hidesBackButton = true

            title = "Permission Approval"

//            navigationView.hidden = true
        }
        
        moveUpViews()
    }

    func moveUpViews() {
        /*
        let moveUpPosition: Int = titleLabel.center.y - timerView.center.y
        mainInfoView.center = CGPoint(x: mainInfoView.center.x, y: titleLabel.center.y + titleLabel.frame.size.height / 1.5)
        if !isLogDisplay {
            timerView.center = CGPoint(x: timerView.center.x, y: CGFloat(timerView.center.y - moveUpPosition))
            titleLabel.center = CGPoint(x: titleLabel.center.x, y: CGFloat(titleLabel.center.y - moveUpPosition))
            mainInfoView.frame = CGRect(x: mainInfoView.frame.origin.x, y: titleLabel.center.y + titleLabel.frame.size.height / 2, width: mainInfoView.frame.size.width, height: mainInfoView.frame.size.height)
        }
 */
    }

    @IBAction func approveTapped() {

        view.isUserInteractionEnabled = false
        
        showAlertView(withTitle: "Approving...", andMessage: "", withCloseButton: false)

        AuthHelper.shared.approveRequest(completion: { success, errorMessage in

            self.alertView?.hideView()

            self.view.isUserInteractionEnabled = true
            self.navigationController?.popToRootViewController(animated: true)
        })

        timer?.invalidate()
        timer = nil
    }

    @IBAction func denyTapped() {

        view.isUserInteractionEnabled = false

        showAlertView(withTitle: "Denying...", andMessage: "", withCloseButton: false)

        AuthHelper.shared.denyRequest(completion: { success, errorMessage in

            self.alertView?.hideView()

            self.view.isUserInteractionEnabled = true
            self.navigationController?.popToRootViewController(animated: true)
        })

        timer?.invalidate()
        timer = nil
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
                         subTitle: AlertConstants.clearLog,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: AlertConstants.no,
                         circleIconImage: UIImage(named: "icon_trashcan_large")!)
        
    }

    func deleteLog(_ log: UserLoginInfo?) {
        // Eric
        DataStoreManager.sharedInstance().deleteLog(log)
        
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
