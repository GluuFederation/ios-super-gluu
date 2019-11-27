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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        logLabel.adjustsFontSizeToFitWidth = false
    }
    
    func setData(_ userLoginInfo: UserLoginInfo?) {
        
        guard let info = userLoginInfo else { return }
        
        var logText = logStateText(state: info.logState)
        
        if let server = info.issuer {
            logText.append(" \(server)")
        }
        
        logLabel.text = logText
        logTime.text = getTimeAgo(info.created)
    }

    func getTimeAgo(_ createdTime: String?) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        
        if let date: Date = formatter.date(from: createdTime ?? "") {
            return date.formattedAsTimeAgo()
        }
        
        return ""
    }

    func logStateText(state: LogState) -> String {
        
        // ** Local Text
        switch state {
            case .LOGIN_SUCCESS:
                return LocalString.Signed_In.localized
            case .LOGIN_FAILED:
                return LocalString.Login_Failed.localized
            case .ENROLL_SUCCESS:
                return LocalString.Registered_To.localized
            case .ENROLL_FAILED:
                return LocalString.Registration_Failed.localized
            case .ENROLL_DECLINED:
                return LocalString.Enroll_Declined.localized
            case .LOGIN_DECLINED:
                return LocalString.Login_Declined.localized
            case .UNKNOWN_ERROR:
                return LocalString.Unknown_Error.localized
            default:
                break
        }
        
        return ""
    }

}
