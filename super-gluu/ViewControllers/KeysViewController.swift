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
    var rowToDelete: Int = 0
    var isLandScape = false
    var keyCells: [String : String] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplay()

        //uniqueKeyLabel.text = [NSString stringWithFormat: NSLocalizedString(@"UniqueKeyLabel", @"UniqueKeyLabel"), [[AppConfiguration sharedInstance] systemTitle]];

        NotificationCenter.default.addObserver(self, selector: #selector(KeysViewController.initPushView), name: noti(GluuConstants.NOTIFICATION_PUSH_ONLINE), object: nil)
    }

    func setupDisplay() {

        navigationItem.title = "Keys"

        view.backgroundColor = UIColor.Gluu.tableBackground

        keyHandleTableView.tableFooterView = UIView()
        keyHandleTableView.tableHeaderView?.backgroundColor = UIColor.Gluu.tableBackground
        keyHandleTableView.backgroundColor = UIColor.Gluu.tableBackground
        keyHandleTableView.separatorColor = UIColor.Gluu.separator

    }

    @objc func initPushView() {
        tabBarController?.selectedIndex = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadKeyHandlesFromDatabase()
        keyHandleTableView.reloadData()
    }

    func showEditNameAlert() {
        
        guard let cell = keyHandleTableView.cellForRow(at: IndexPath(item: rowToDelete, section: 0)) as? KeyHandleCell, let tokenEntity = tokenAt(rowToDelete) else {
            return
        }

        
        let alert = SCLAlertView(autoDismiss: false, closeButtonColor: .red, horizontalButtons: true)
        
        let textField = alert.addTextField("Enter a name")
        
        alert.addButton("Save") {
            if let aText = textField.text {
                print("Text value: \(aText)")
            }
        
            if self.checkUniqueName(textField.text, andID: cell.accessibilityLabel) {
                
                DataStoreManager.sharedInstance().setTokenEntitiesNameByID(tokenEntity.id, userName: tokenEntity.userName, newName: textField.text)
                self.loadKeyHandlesFromDatabase()
                alert.hideView()
                
            } else {
                let alert = SCLAlertView(autoDismiss: false, horizontalButtons: false)
                
                alert.showCustom(NSLocalizedString("Info", comment: "Info"),
                                 subTitle: "Name already exists or is empty. Please enter another one.",
                                 color: AppConfiguration.systemColor,
                                 closeButtonTitle: "Ok",
                                 circleIconImage: AppConfiguration.systemAlertIcon,
                                 animationStyle: SCLAnimationStyle.topToBottom)
            }
        }

        
        alert.showCustom("Change key name",
                         subTitle: "Enter a new name for your key:",
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: "Cancel",
                         circleIconImage: UIImage(named: "icon_pencil")!)
    
    }

    func loadKeyHandlesFromDatabase() {

        if let tokenEnts = DataStoreManager.sharedInstance().getTokenEntities() as? [TokenEntity] {
            keyHandleArray = tokenEnts
            keyHandleTableView.reloadData()
        }

    }

    func checkUniqueName(_ name: String?, andID keyID: String?) -> Bool {
        
        guard let name = name, name.count > 0 else {
            return false
        }

        for cellKey: String in keyCells.keys {
            if !(cellKey == keyID) {
                if (keyCells[cellKey] == name) {
                    return false
                }
            }
        }
        return true
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
        showKeyInfo(indexPath.row)
    }

    
    func tokenAt(_ index: Int) -> TokenEntity? {
        guard keyHandleArray.count > index else {
            return nil
        }
        
        return keyHandleArray[index]
    }
    
    
    func showKeyInfo(_ index: Int) {
        
        let tokenEntity = tokenAt(index)
        
        let infoVC = InformationViewController.fromStoryboard("Main")
        infoVC.token = tokenEntity

        navigationController?.pushViewController(infoVC, animated: true)
        
    }

    func showDeleteAlert() {
        
        let alert = SCLAlertView(autoDismiss: false, horizontalButtons: true)
        
        let subtitle = NSLocalizedString("DeleteKeyHandle", comment: "Delete KeyHandle")
        
        alert.addButton(AlertConstants.yes, backgroundColor: .red, textColor: .white) {
            print("YES clicked")
            self.deleteRow()
            alert.hideView()
        }

        alert.showCustom(AlertConstants.delete,
                         subTitle: subtitle,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: AlertConstants.no,
                         circleIconImage: UIImage(named: "icon_trashcan_large")!)
 
     }

    func deleteRow() {

        guard let tokenEntity = tokenAt(rowToDelete) else { return }
        DataStoreManager.sharedInstance().deleteTokenEntities(byID: tokenEntity.application, userName: tokenEntity.userName)
        loadKeyHandlesFromDatabase()

        // check in mainViewController for matching code. we use the token issuer combined with the username
        let keyId = tokenEntity.application ?? "" + (tokenEntity.userName ?? "")

        // whether the key is licensed or not, call remove to be sure
        GluuUserDefaults.removeLicensedKey(keyId)

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
        switch index {
            case 0:
                print("More button was pressed")
                showKeyInfo(cell?.tag ?? 0)
            
            case 1:
                // Rename button was pressed
                print("Rename button was pressed")
                rowToDelete = Int(cell?.tag ?? 0)
                showEditNameAlert()
            
            case 2:
                // Delete button was pressed
                print("Delete button was pressed")
                rowToDelete = Int(cell?.tag ?? 0)
                showDeleteAlert()
            
            default:
                break
        }
    }
 
}
