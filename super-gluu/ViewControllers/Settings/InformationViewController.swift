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

        return UIBarButtonItem(title: LocalString.Edit.localized, style: .plain, target: self, action: editSel)

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

        userNameValueLabel.text = token.userName
        createdValueLabel.text = time
        applicationValueLabel.text = url?.host
        keyHandleValueLabel.text = keyHandleString(token: token)
    }
    
    func keyHandleString(token: TokenEntity) -> String {
		guard let keyHandle = token.keyHandle else {
			return ""
		}
		
		let prefixStr = String(keyHandle.prefix(6))
		let suffixStr = String(keyHandle.suffix(6))
        
        return prefixStr + "..." + suffixStr
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
        
    }
    
    func showKeyRenameAlert() {
        
        guard let token = token else { return }
        
        KeyHandler().editKeyToken(token: token) {
            
            self.didEditToken?()
            self.setupInformation()
        }
    }

}
