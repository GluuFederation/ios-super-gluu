//  LogsTableCell.swift
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

import UIKit
import ox_push3
import SWTableViewCell


class LogsTableCell: SWTableViewCell {
    
    @IBOutlet var logTime: UILabel!
    @IBOutlet var logLabel: UILabel!
    @IBOutlet var logo: UIImageView!
    

    func setData(_ userLoginInfo: UserLoginInfo?) {
        
        guard userLoginInfo != nil else { return }
        
        let server = userLoginInfo?.issuer
        if server != nil, userLoginInfo?.logState != nil {
            let serverURL = URL(string: server ?? "")
            adoptLog(byState: serverURL, andState: userLoginInfo!.logState)
        }
        logTime.text = getTimeAgo(userLoginInfo?.created)
    }

    func getTimeAgo(_ createdTime: String?) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        
        if let date: Date = formatter.date(from: createdTime ?? "") {
            return date.formattedAsTimeAgo()
        }
        
        return ""
    }

    func adoptLog(byState serverURL: URL?, andState logState: LogState) {
        let state: LogState = logState
        
        // ** Local Text
        switch state {
            case .LOGIN_SUCCESS:
                logLabel.text = String(format: NSLocalizedString("LoggedIn", comment: "Logged in"), serverURL?.host ?? "")
            case .LOGIN_FAILED:
                logLabel.text = String(format: NSLocalizedString("LoggedInFailed", comment: "Logged in failed"), serverURL?.host ?? "")
            case .ENROLL_SUCCESS:
                logLabel.text = String(format: NSLocalizedString("EnrollIn", comment: "Enroll in"), serverURL?.host ?? "")
            case .ENROLL_FAILED:
                logLabel.text = String(format: NSLocalizedString("EnrollInFailed", comment: "Enroll in failed"), serverURL?.host ?? "")
            case .ENROLL_DECLINED:
                logLabel.text = String(format: NSLocalizedString("EnrollDeclined", comment: "Login declined"), serverURL?.host ?? "")
            case .LOGIN_DECLINED:
                logLabel.text = String(format: NSLocalizedString("LoginDeclined", comment: "Enroll declined"), serverURL?.host ?? "")
            case .UNKNOWN_ERROR:
                logLabel.text = String(format: NSLocalizedString("UnKnownError", comment: "UnKnownError"), serverURL?.host ?? "")
            default:
                break
        }
    }

}
