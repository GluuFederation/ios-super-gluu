//
//  SettingsViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/1/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import UIKit

let screenheight = UIScreen.main.bounds.size.height
let screenwidth = UIScreen.main.bounds.size.width

enum SettingsTableSections {
    case history
    case settings
    case help
    
    func items() -> [SettingsTableItem] {
        switch self {
        case .history:
            return [.logs, .keys]
        
        case .settings:
            
            // Don't show touch auth if user's device doesn't have it
            // Removing SSL for time being
            let touchAuth = TouchIDAuth()
            if touchAuth.canEvaluatePolicy() {
                return [.pinCodes, .touchId] //, .ssl]
            } else {
                return [.pinCodes] //, .ssl]
            }
            
        case .help:
            return [.userGuide, .privacyPolicy]
        }
    }
    
    // ** Local Text
    var title: String {
        switch self {
        case .history:  return "HISTORY"
        case .settings: return LocalString.Menu_Settings.localizedUppercase
        case .help:     return LocalString.Menu_Help.localizedUppercase
        }
    }

}

enum SettingsTableItem {
    case logs
    case keys
    case pinCodes
    case touchId
    case ssl
    case userGuide
    case privacyPolicy
    
    var icon: UIImage? {
        switch self {
        case .logs: return #imageLiteral(resourceName: "icon_settings_logs")
        case .keys: return #imageLiteral(resourceName: "icon_settings_keys")
        case .pinCodes: return #imageLiteral(resourceName: "icon_settings_pin")
        case .touchId: return #imageLiteral(resourceName: "icon_settings_touchid")
        case .ssl: return #imageLiteral(resourceName: "icon_settings_ssl")
        case .userGuide, .privacyPolicy: return nil
        }
    }
    
    var title: String? {
        switch self {
        case .logs: return LocalString.Menu_Logs.localized
        case .keys: return LocalString.Menu_Keys.localized
        case .pinCodes: return LocalString.Menu_Passcode.localized
        case .touchId: return  LocalString.Security_TouchId.localized
        case .ssl: return LocalString.SSL_Trust.localized
        case .userGuide: return LocalString.Menu_User_Guide.localized
        case .privacyPolicy: return LocalString.Menu_Privacy_Policy.localized
        }
    }
    
    var segueId: String {
        switch self {
        case .logs:          return "segueSettingsToLogs"
        case .keys:          return "segueSettingsToKeys"
        case .pinCodes:      return "segueSettingsToPin"
        case .touchId:       return "segueSettingsToSingleCell"
        case .ssl:           return "segueSettingsToSingleCell"
        case .userGuide:     return "segueSettingsToWeb"
        case .privacyPolicy: return "segueSettingsToWeb"
        }
    }
    
}



class SettingsViewController: UIViewController {
    
    // MARK: - Variables
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    
    let tableSections: [SettingsTableSections] = [.history, .settings, .help]
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(versionLabelLongPressed))
        longPressGesture.minimumPressDuration = 2.0
        longPressGesture.delaysTouchesBegan = true
        versionLabel.superview?.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // View Setup
    
    func setupDisplay() {
        
        self.navigationItem.title = " "
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_x"), style: .plain, target: self, action: #selector(dismissVC))
        
        view.backgroundColor = UIColor.Gluu.tableBackground
        
        tableView?.register( UINib(nibName: "SelectablePortraitView", bundle: nil), forCellReuseIdentifier: "SelectablePortraitView")
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.allowsMultipleSelection        = false
        tableView.backgroundColor    = UIColor.Gluu.tableBackground
        tableView.tableHeaderView    = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.rowHeight          = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.delegate   = self
        tableView.dataSource = self
    }
    
    
    // MARK: - Action Handling
    
    @objc
    func versionLabelLongPressed() {
        let version = AppInfo()?.version ?? "Unknown"
        let build = AppInfo()?.build ?? "Unknown"
        let commit = AppInfo()?.gitCommitSHA ?? "Unknown"
        
        let title = "v\(version) #\(build)"
        let description = "\(commit) is the last commit"
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive) { (action) in
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // handle mode setting for SSL/TouchId VC
        
        if let sender = sender as? SettingsTableItem {
            
            switch segue.destination {
                
            case is SingleCellSettingsDetailViewController:
                
                let destVC = segue.destination as! SingleCellSettingsDetailViewController
                
                switch sender {
                case .touchId: destVC.display = .touchId
                case .ssl: destVC.display = .ssl
                    
                default: break
            }
                
            case is WebViewController:
                
                let destVC = segue.destination as! WebViewController
                
                switch sender {
                case .privacyPolicy: destVC.display = .privacy
                case .userGuide: destVC.display = .tos
                    
                default: break
                }

            default: break
            }
        }
    }
    
    func dataItem(atIndexPath ip: IndexPath) -> SettingsTableItem {
        return tableSections[ip.section].items()[ip.row]
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[section].items().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else {
            return UITableViewCell()
        }
        
        let item = dataItem(atIndexPath: indexPath)
        
        cell.titleLabel.text = item.title
        
        if let icon = item.icon {
            cell.iconImageView?.isHidden = false
            cell.iconImageView?.image = icon
        } else {
            cell.iconImageView?.isHidden = true
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenwidth, height: 60))
        headerView.backgroundColor = UIColor.Gluu.tableBackground
        
        let titleLabel = UILabel(frame: CGRect(x: 12, y: 38, width: 200, height: 15))
        titleLabel.textColor = UIColor.Gluu.darkGreyText
        titleLabel.font = UIFont.regular(14)
        titleLabel.text = tableSections[section].title
        
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = dataItem(atIndexPath: indexPath)
        
        self.performSegue(withIdentifier: item.segueId, sender: item)
    }
    
    
    
}
