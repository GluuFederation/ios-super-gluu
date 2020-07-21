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
    
    @IBOutlet var logsTableView: UITableView!
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

    func updateLogs() {
        logsArray = [UserLoginInfo]()
		if let arry = DataStoreManager.sharedInstance()?.userLogs() as? [UserLoginInfo] {
			logsArray = arry
		}

        logsTableView.reloadData()
    }

    func deleteLog(_ log: UserLoginInfo) {
        // eric
		print(log)
        DataStoreManager.sharedInstance().deleteLog(log)
        updateLogs()
    }

    func showDeleteLogAlert(log: UserLoginInfo) {
        let alert = SCLAlertView(autoDismiss: false, horizontalButtons: true)
        print(log)
        alert.addButton(AlertConstants.yes, backgroundColor: .red) {
            print("YES clicked")
			
			self.deleteLog(log)
            
            alert.hideView()
        }
        
		let subtext = LocalString.Clear_Log.localized
        
        alert.showCustom(AlertConstants.delete,
                         subTitle: subtext,
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
			showLogDetail(logsArray[indexPath.row])
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
		
		guard
			let cell = cell,
			let ip = self.logsTableView.indexPath(for: cell),
			ip.row < logsArray.count else { return }
		
		let log = logsArray[ip.row]
		
        switch index {
            case 0:
                print("More button was pressed")
                showLogDetail(log)
            case 1:
                // Delete button was pressed
                print("Delete button was pressed")
				
				showDeleteLogAlert(log: log)
            default:
                break
        }
    }

    //------------------ END --------------------------------
	func showLogDetail(_ log: UserLoginInfo) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logVC = storyboard.instantiateViewController(withIdentifier: "LogDetailViewController") as! LogDetailViewController
        
        logVC.userInfo = log
        navigationController?.pushViewController(logVC, animated: true)
    }
}
