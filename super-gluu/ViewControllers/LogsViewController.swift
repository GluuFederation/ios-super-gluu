//  LogsViewController.swift
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.

import SWTableViewCell
import UIKit
import SCLAlertView
import ox_push3

class LogsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate {
    
//    @IBOutlet var topView: UIView!
//    @IBOutlet var topIconView: UIImageView!
    @IBOutlet var logsTableView: UITableView!
//    @IBOutlet var editLogsButton: UIButton!
//    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var noLogsLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var selectAllButton: UIButton!
    @IBOutlet var selectAllView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageBackgroundView: UIView!

    var logsArray: [UserLoginInfo] = []

    override func viewDidLoad() {

        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(LogsViewController.initPushView), name: NSNotification.Name(rawValue: GluuConstants.NOTIFICATION_PUSH_ONLINE), object: nil)

        navigationItem.title = LocalString.Menu_Logs.localized
        view.backgroundColor = UIColor.Gluu.tableBackground

        logsTableView.tableFooterView = UIView()
        logsTableView.allowsMultipleSelectionDuringEditing = true
        logsTableView.separatorColor = UIColor.Gluu.separator
        logsTableView.backgroundColor = UIColor.Gluu.tableBackground
        logsTableView.tableHeaderView?.backgroundColor = UIColor.Gluu.tableBackground

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLogs()

        headerImageBackgroundView.layer.cornerRadius = 47

    }

    @objc func initPushView() {
        tabBarController?.selectedIndex = 0
    }

    func getLogs() {
        logsArray = [UserLoginInfo]()
        logsArray = DataStoreManager.sharedInstance().getUserLoginInfo() as! [UserLoginInfo]

        logsTableView.reloadData()

    }

    func deleteLog(_ log: UserLoginInfo?) {
        // eric
        DataStoreManager.sharedInstance().deleteLog(log)
        updateLogs()
    }

    func deleteLogs(_ logs: [Any]?) {
        // eric
        DataStoreManager.sharedInstance().deleteLogs(logs)
        updateLogs()
        selectAllView.isHidden = true
    }

    func updateLogs() {
        getLogs()
        logsTableView.setEditing(false, animated: true)
    }

    @IBAction func editCleanLogs(_ sender: Any) {
        /*
        if editLogsButton.tag == 1 {
            //Editing table
            logsTableView.setEditing(true, animated: true)
            cancelButton.isHidden = false
            editLogsButton.tag = 2
            editLogsButton.setTitle("Delete", for: .normal)
            selectAllView.isHidden = false
        } else {
            //Deleting logs
            var logsForDeleteArray = getLogsForDelete()
            if logsForDeleteArray?.count == 0 {
                showNoLogsToDeleteAlert()
            } else {
                deleteLogsAlert(nil, array: logsForDeleteArray)
            }
            editLogsButton.tag = 1
        }
 */
    }

    @IBAction func cancelEditLogs(_ sender: Any) {
        /*
        cancelButton.isHidden = true
        logsTableView.setEditing(false, animated: true)
        editLogsButton.tag = 1
        updateButtons()
        selectAllView.isHidden = true
        deselectAllLogs()
 */
    }

    // ** Local Text
    @IBAction func selectAllClick(_ sender: Any) {
        let tag = Int((sender as? UIButton)?.tag ?? 0)
        if tag == 1 {
            //select all
            selectAllLogs(true)
            selectAllButton.tag = 2
            selectAllButton.setTitle("Deselect All", for: .normal)
        } else {
            //deselect all
            deselectAllLogs()
        }
    }

    func deselectAllLogs() {
        selectAllLogs(false)
        selectAllButton.tag = 1
        selectAllButton.setTitle("Select All", for: .normal)
    }

    
    func selectAllLogs(_ isSelect: Bool) {
        /*
        for i in 0..<logsTableView.numberOfSections {
            for j in 0..<logsTableView.numberOfRows(inSection: i) {
                let ints = [i, j]
                let indexPath = IndexPath(indexes: &ints, length: 2)
                if isSelect {
                    logsTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                } else {
                    logsTableView.deselectRow(at: indexPath, animated: true)
                }
                //Here is your code
            }
        }
         */
    }
 

    func updateButtons() {
        /*
        let title = editLogsButton.tag == 2 ? "Delete" : "Edit"
        editLogsButton.setTitle(title, for: .normal)
 */
    }

    func deleteLogsAlert(_ log: UserLoginInfo?, array logs: [Any]?) {
        let alert = SCLAlertView(autoDismiss: false, horizontalButtons: true)
        
        alert.addButton(AlertConstants.yes, backgroundColor: .red) {
            print("YES clicked")
            
            if log != nil {
                self.deleteLog(log)
            } else if logs != nil || (logs?.count ?? 0) > 0 {
                self.deleteLogs(logs)
            } else {
                return
            }
            
            alert.hideView()
        }
        
        let subText = logs != nil || (logs?.count ?? 0) > 0 ? LocalString.Clear_Logs.localized : LocalString.Clear_Log.localized
        
        alert.showCustom(AlertConstants.delete,
                         subTitle: subText,
                         color: AppConfiguration.systemColor,
                         closeButtonTitle: AlertConstants.no,
                         circleIconImage: UIImage(named: "icon_trashcan_large")!)
    }


// MARK: - UITableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userInfo = logsArray[indexPath.row]
        var cellId = "LogsTableCellID"
        
        switch userInfo.logState {
        case .LOGIN_FAILED, .ENROLL_FAILED, .ENROLL_DECLINED, .LOGIN_DECLINED, .UNKNOWN_ERROR:
            cellId = "LogsFailedTableCellID"
            
        default: break
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? LogsTableCell else {
            return UITableViewCell()
        }
        
        cell.setData(userInfo)
        cell.tag = indexPath.row

        cell.rightUtilityButtons = rightButtons()
        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if logsTableView.isEditing != true {
            showLogDetail(indexPath.row)
        }
    }

    func rightButtons() -> [Any]? {
        
        let viewButton = UIButton()
        viewButton.setImage(UIImage(named: "icon_eye"), for: .normal)
        viewButton.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)
        
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(named: "icon_trashcan_large"), for: .normal)
        deleteButton.backgroundColor = UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0)
        
        return [viewButton, deleteButton]

    }

    func swipeableTableViewCell(_ cell: SWTableViewCell?, didTriggerLeftUtilityButtonWith index: Int) {
    }

    func swipeableTableViewCell(_ cell: SWTableViewCell?, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
            case 0:
                print("More button was pressed")
                showLogDetail(Int(cell?.tag ?? 0))
            case 1:
                // Delete button was pressed
                print("Delete button was pressed")
                let log = logsArray[cell?.tag ?? 0] as? UserLoginInfo
                deleteLogsAlert(log, array: nil)
            default:
                break
        }
    }

    //------------------ END --------------------------------
    func showLogDetail(_ index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logVC = storyboard.instantiateViewController(withIdentifier: "LogDetailViewController") as! LogDetailViewController
        
        let userInfo = logsArray[index] as? UserLoginInfo
        logVC.userInfo = userInfo
        navigationController?.pushViewController(logVC, animated: true)
    }

    func getLogsForDelete() -> [AnyHashable]? {
        let selectedCells = logsTableView.indexPathsForSelectedRows
        var updatedLogsArray: [AnyHashable] = []
        for indexParh: IndexPath? in selectedCells ?? [] {
            let log = logsArray[indexParh?.row ?? 0] as? UserLoginInfo
            if let aLog = log {
                updatedLogsArray.append(aLog)
            }
        }

        return updatedLogsArray
    }
}
