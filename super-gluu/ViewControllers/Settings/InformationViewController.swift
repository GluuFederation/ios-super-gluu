//  InformationViewController.swift
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/9/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

import UIKit
import ox_push3
import SCLAlertView


class InformationViewController: BaseViewController, UIScrollViewDelegate {
    
    var token: TokenEntity?
    
    @IBOutlet var userNameValueLabel: UILabel!
    @IBOutlet var createdValueLabel: UILabel!
    @IBOutlet var applicationValueLabel: UILabel!
    @IBOutlet var keyHandleValueLabel: UILabel!
    @IBOutlet var valueLabels: [UILabel]!
    @IBOutlet var separators: [UIView]!
    @IBOutlet var keyLabels: [UILabel]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInformation()
        initLocalization()

        setupView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupView() {

        view.backgroundColor = UIColor.Gluu.tableBackground

        valueLabels.forEach({
            $0.font = UIFont.regular(16)
            $0.textColor = AppConfiguration.systemColor
        })
        
        keyLabels.forEach({
            $0.font = UIFont.regular(16)
            $0.textColor = UIColor.black
        })
        
        separators.forEach({
            $0.backgroundColor = UIColor.Gluu.tableBackground
        })

        navigationItem.rightBarButtonItem = editBBI()

    }

    func editBBI() -> UIBarButtonItem? {

        let editSel: Selector = #selector(InformationViewController.showEditActionSheet)

        return UIBarButtonItem(title: "Edit", style: .plain, target: self, action: editSel)

    }

    @objc func showEditActionSheet() {

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            actionSheet.dismiss(animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            actionSheet.dismiss(animated: true, completion: nil)
            
            self.showDeleteAlert()
        }))

        actionSheet.addAction(UIAlertAction(title: "Edit Name", style: .default, handler: { action in
            actionSheet.dismiss(animated: true, completion: nil)
            
            self.showKeyRenameAlert()
        }))

        present(actionSheet, animated: true)
    }

    func setupInformation() {
        guard let token = token else {
            return
        }

        let url = URL(string: token.application)
        let time = convertPairingTime(token.pairingTime)

        userNameValueLabel.text = token.keyName
        createdValueLabel.text = time
        applicationValueLabel.text = url?.host
        keyHandleValueLabel.text = keyHandleString(token: token)
    }
    
    func keyHandleString(token: TokenEntity) -> String {
        let firstSix = token.keyHandle.substring(to: 6)
        let fromChar = token.keyHandle.count - 6
        let lastSix = token.keyHandle.substring(from: fromChar)
        
        return firstSix + "..." + lastSix
    }

    func convertPairingTime(_ time: String?) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        let date: Date? = formatter.date(from: time ?? "")
        formatter.dateFormat = " MMM dd, yyyy hh:mm:ss"
        if let aDate = date {
            return formatter.string(from: aDate)
        }
        return nil
    }

    func initLocalization() {
//        informationLabel.text = NSLocalizedString(@"Information", @"Information");
//        userNameLabel.text = NSLocalizedString(@"UserName", @"UserName");
//        createdLabel.text = NSLocalizedString(@"Created", @"Created");
//        applicationLabel.text = NSLocalizedString(@"Application", @"Application");
//        issuerLabel.text = NSLocalizedString(@"Issuer", @"Issuer");
//        closeButton.titleLabel.text = NSLocalizedString(@"CloseButton", @"CloseButton");
//        keyHandleLabel.text = NSLocalizedString(@"keyHandle", @"Key handle");
    }

    @objc
    func showDeleteAlert() {
        
        let alert = SCLAlertView(autoDismiss: false, horizontalButtons: true)
        
        let subtitle = NSLocalizedString("DeleteKeyHandle", comment: "Delete KeyHandle")
        
        alert.addButton(AlertConstants.yes, backgroundColor: .red, textColor: .white) {
            print("YES clicked")
            self.deleteKey()
            alert.hideView()
        }
        
        alert.showCustom(AlertConstants.delete,
                         subTitle: subtitle,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: AlertConstants.no,
                         circleIconImage: UIImage(named: "icon_trashcan_large")!)
        
    }
    
    func showKeyRenameAlert() {
        
        guard let token = token else { return }
        
        let alert = SCLAlertView(autoDismiss: false, closeButtonColor: .red, horizontalButtons: true)
        
        let textField = alert.addTextField("Enter a name")
        
        alert.addButton("Save") {
            
//            textField.endEditing(true)
            
            if let newName = textField.text {
                
                print("Text value: \(newName)")
                
                if DataStoreManager.sharedInstance().isUniqueTokenName(newName) {
                    DataStoreManager.sharedInstance().setTokenEntitiesNameByID(token.id, userName: token.userName, newName: newName)
                    token.keyName = newName
                    self.setupInformation()
                    alert.hideView()
                } else {
                    let alert = SCLAlertView()
                    alert.showCustom(NSLocalizedString("Info", comment: "Info"),
                                     subTitle: "Name already exists or is empty. Please enter another one.",
                                     color: AppConfiguration.systemColor,
                                     closeButtonTitle: "Close",
                                     circleIconImage: AppConfiguration.systemAlertIcon)
                }
            }
        }
        
        alert.showCustom("Change key name",
                         subTitle: "Enter a new name for your key:",
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: "Cancel",
                         circleIconImage: UIImage(named: "icon_pencil"))
        
    }

    @objc
    func deleteKey() {
        
        guard let token = token else { return }
        
        DataStoreManager.sharedInstance().deleteTokenEntities(byID: token.application, userName: token.userName)

        dismiss(animated: true)
    }

    func generateAttrStrings(_ name: String?, value: String?) -> NSAttributedString? {

        let wholeString = "\(name ?? "") : \(value ?? "")"
        let attrString = NSMutableAttributedString(string: wholeString)

        let rangeName: NSRange = (wholeString as NSString).range(of: name ?? "")
        let rangeDots: NSRange = (wholeString as NSString).range(of: ":")
        let rangeValue: NSRange = (wholeString as NSString).range(of: value ?? "")

        attrString.addAttribute(.foregroundColor, value: UIColor.black, range: rangeName)
        attrString.addAttribute(.foregroundColor, value: AppConfiguration.systemColor, range: rangeDots)
        attrString.addAttribute(.foregroundColor, value: UIColor.gray, range: rangeValue)

        return attrString
    }

}
