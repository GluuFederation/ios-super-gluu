//  SettingsViewController.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/9/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

import SWTableViewCell
import UIKit
import ox_push3
import SCLAlertView

    
class KeysViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var keyHandleTableView: UITableView!
    @IBOutlet var uniqueKeyLabel: UILabel!
    
    var keyHandleArray: [TokenEntity] = []
    var isLandScape = false
    var keyCells: [String : String] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()

        NotificationCenter.default.addObserver(self, selector: #selector(KeysViewController.initPushView), name: noti(GluuConstants.NOTIFICATION_PUSH_ONLINE), object: nil)
        
        loadKeyHandlesFromDatabase()
    }

    func setupDisplay() {
        
        navigationItem.title = LocalString.Menu_Keys.localized

        view.backgroundColor = UIColor.Gluu.tableBackground

        keyHandleTableView.tableFooterView = UIView()
        keyHandleTableView.tableHeaderView?.backgroundColor = UIColor.Gluu.tableBackground
        keyHandleTableView.backgroundColor = UIColor.Gluu.tableBackground
        keyHandleTableView.separatorColor = UIColor.Gluu.separator

        uniqueKeyLabel.text = LocalString.Keys_Info.localized
    }

    @objc func initPushView() {
    }

    func loadKeyHandlesFromDatabase() {

		keyHandleArray = [TokenEntity]()
        
		if let tokens = DataStoreManager.sharedInstance()?.keys() as? [TokenEntity] {
            keyHandleArray = tokens
            keyHandleTableView.reloadData()
        }

    }

// MARK: - UITableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keyHandleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeyHandleCell") as? KeyHandleCell else {
            return UITableViewCell()
        }
        
        if let tokenEntity = tokenAt(indexPath.row) {
            cell.setToken(tokenEntity)
            
            let keyName = tokenEntity.keyName == nil ? tokenEntity.application : tokenEntity.keyName
            keyCells[tokenEntity.application] = keyName
        }
        
        cell.tag = indexPath.row
        cell.rightUtilityButtons = rightButtons()
        cell.delegate = self

        return cell
 
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let token = tokenAt(indexPath.row) {
            showKeyInfo(token)
        }
    }

    
    func tokenAt(_ index: Int) -> TokenEntity? {
        guard keyHandleArray.count > index else {
            return nil
        }
        
        return keyHandleArray[index]
    }
    
    
    func showKeyInfo(_ token: TokenEntity) {
        
        let infoVC = InformationViewController.fromStoryboard("Main")
        infoVC.token = token
        infoVC.didEditToken = {
            self.loadKeyHandlesFromDatabase()
        }

        navigationController?.pushViewController(infoVC, animated: true)
        
    }

    func rightButtons() -> [UIButton]? {
        
        let viewButton = UIButton()
        viewButton.setImage(UIImage(named: "icon_eye"), for: .normal)
        viewButton.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)

        let renameButton = UIButton()
        renameButton.setImage(UIImage(named: "icon_pencil"), for: .normal)
        renameButton.backgroundColor = AppConfiguration.systemColor
        
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(named: "icon_trashcan_large"), for: .normal)
        deleteButton.backgroundColor = UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0)
        
        return [viewButton, renameButton, deleteButton]

    }

    func swipeableTableViewCell(_ cell: SWTableViewCell?, didTriggerRightUtilityButtonWith index: Int) {
        
        guard let swipedRow = cell?.tag, let token = tokenAt(swipedRow) else {
            return
        }
        
        switch index {
            case 0:
                // More button was pressed
                showKeyInfo(token)
            
            case 1:
                // Rename button was pressed
                KeyHandler().editTokenName(token) {
                    self.loadKeyHandlesFromDatabase()
                }
            
            case 2:
                // Delete button was pressed
                KeyHandler().confirmDelete(token: token) {
                    self.loadKeyHandlesFromDatabase()
                }
            
            default:
                break
        }
    }
}


class KeyHandler: NSObject {
    
    func confirmDelete(token: TokenEntity, didDelete: @escaping ()->Void) {
        
        let alert = SCLAlertView(autoDismiss: false, horizontalButtons: true)
        
        alert.addButton(AlertConstants.yes, backgroundColor: .red, textColor: .white) {
            self.deleteToken(token: token, tokenDeleted: {
                didDelete()
            })
            alert.hideView()
        }
        
        alert.showCustom(AlertConstants.delete,
                         subTitle: LocalString.Info_Delete_Key.localized,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: AlertConstants.no,
                         circleIconImage: UIImage(named: "icon_trashcan_large")!)
    }
    
    func deleteToken(token: TokenEntity, tokenDeleted: @escaping ()->Void) {
        
        // check in mainViewController for matching code. we use the token issuer combined with the username
        let keyId = token.application ?? "" + (token.userName ?? "")
        
        // whether the key is licensed or not, call remove to be sure
        GluuUserDefaults.removeLicensedKey(keyId)
		
		DataStoreManager.sharedInstance()?.delete(token)
        
        tokenDeleted()
    }
    
    func editTokenName(_ token: TokenEntity, didEdit: @escaping ()->Void ) {
        
        let alert = SCLAlertView(autoDismiss: false, closeButtonColor: .red, horizontalButtons: true)
        
        let textField = alert.addTextField("Enter a name")
        
        alert.addButton(LocalString.Save.localized) {
            
            guard let newName = textField.text else {
                alert.hideView()
                return
            }

            if DataStoreManager.sharedInstance().isUniqueTokenName(newName) {
                
				DataStoreManager.sharedInstance()?.editToken(token, name: newName)
                
                didEdit()
                alert.hideView()
                
            } else {
                SCLAlertView().showCustom(LocalString.Info.localized,
                                          subTitle: LocalString.Info_Duplicate_Name.localized,
                                          color: AppConfiguration.systemColor,
                                          closeButtonTitle: LocalString.Close.localized,
                                          circleIconImage: AppConfiguration.systemAlertIcon)
            }
        }
        
        
        alert.showCustom(LocalString.Info_Change_Name.localized,
                         subTitle: LocalString.Info_Enter_New_Name.localized,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: LocalString.Cancel.localized,
                         circleIconImage: UIImage(named: "icon_pencil"))
        
    }
    
}
