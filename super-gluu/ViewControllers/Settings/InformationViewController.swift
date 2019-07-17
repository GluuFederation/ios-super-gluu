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
    
    @IBOutlet var userNameValueLabel: UILabel!
    @IBOutlet var createdValueLabel: UILabel!
    @IBOutlet var applicationValueLabel: UILabel!
    @IBOutlet var keyHandleValueLabel: UILabel!
    
    @IBOutlet var userNameTitleLabel: UILabel!
    @IBOutlet var createdTitleLabel: UILabel!
    @IBOutlet var applicationTitleLabel: UILabel!
    @IBOutlet var keyHandleTitleLabel: UILabel!
    
    @IBOutlet var valueLabels: [UILabel]!
    @IBOutlet var separators: [UIView]!
    @IBOutlet var keyLabels: [UILabel]!
    
    
    var token: TokenEntity?
    var didEditToken: (()-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInformation()

    }

    func setupView() {

        userNameTitleLabel.text = LocalString.Log_Key_Username.localized
        createdTitleLabel.text = LocalString.Log_Key_Created.localized
        keyHandleTitleLabel.text = LocalString.Log_Key_Key_Handle.localized
        applicationTitleLabel.text = LocalString.Log_Key_Id_Provider.localized
        
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

    // ** Local Text
    func editBBI() -> UIBarButtonItem? {

        let editSel: Selector = #selector(InformationViewController.showEditActionSheet)

        return UIBarButtonItem(title: "Edit", style: .plain, target: self, action: editSel)

    }

    @objc func showEditActionSheet() {
        


        let actionSheet = UIAlertController(title: LocalString.Info_Change_Name.localized,
                                            message: LocalString.Info_Change_Name_Question.localized,
                                            preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: LocalString.Cancel.localized, style: .cancel, handler: { action in
            actionSheet.dismiss(animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: LocalString.Delete.localized, style: .destructive, handler: { action in
            actionSheet.dismiss(animated: true, completion: nil)

            self.showDeleteAlert()
        }))

        actionSheet.addAction(UIAlertAction(title: LocalString.Info_Change_Name.localized, style: .default, handler: { action in
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

    @objc
    func showDeleteAlert() {
        
        guard let token = token else { return }
        
        KeyHandler().confirmDelete(token: token) {
            
            self.didEditToken?()
            self.dismiss(animated: true)
        }
        
        /*
        let alert = SCLAlertView(autoDismiss: false, horizontalButtons: true)
        
        alert.addButton(AlertConstants.yes, backgroundColor: .red, textColor: .white) {
            
            self.deleteKey()
            alert.hideView()
        }
        
        alert.showCustom(AlertConstants.delete,
                         subTitle: LocalString.Info_Delete_Key.localized,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: AlertConstants.no,
                         circleIconImage: UIImage(named: "icon_trashcan_large")!)
        
        */
        
    }
    
    func showKeyRenameAlert() {
        
        guard let token = token else { return }
        
        KeyHandler().editKeyToken(token: token) {
            
            self.didEditToken?()
            self.setupInformation()
        }
        
        /*
        let alert = SCLAlertView(autoDismiss: false, closeButtonColor: .red, horizontalButtons: true)
        
        let textField = alert.addTextField(LocalString.Info_Enter_Name.localized)
        
        alert.addButton(LocalString.Save.localized) {
            
//            textField.endEditing(true)
            
            if let newName = textField.text {
                
                print("Text value: \(newName)")
                
                if DataStoreManager.sharedInstance().isUniqueTokenName(newName) {
                    DataStoreManager.sharedInstance().setTokenEntitiesNameByID(token.id, userName: token.userName, newName: newName)
                    token.keyName = newName
                    self.setupInformation()
                    alert.hideView()
                } else {
                    
                    SCLAlertView().showCustom(LocalString.Info.localized,
                                     subTitle: LocalString.Info_Duplicate_Name.localized,
                                     color: AppConfiguration.systemColor,
                                     closeButtonTitle: LocalString.Close.localized,
                                     circleIconImage: AppConfiguration.systemAlertIcon)
                }
            }
        }
        
        alert.showCustom(LocalString.Info_Change_Name.localized,
                         subTitle: LocalString.Info_Enter_New_Name.localized,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: LocalString.Cancel.localized,
                         circleIconImage: UIImage(named: "icon_pencil"))
        
        */
    }

    @objc
    func deleteKey() {
        
        /*
        guard let token = token else { return }
        
        DataStoreManager.sharedInstance().deleteTokenEntities(byID: token.application, userName: token.userName)

        dismiss(animated: true)
         */
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
