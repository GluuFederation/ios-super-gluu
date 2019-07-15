
//  KeyHandleCell.swift
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/10/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

import UIKit
import SWTableViewCell
import ox_push3

class KeyHandleCell: SWTableViewCell {
    
    var key = ""
    
    @IBOutlet var keyHandleNameLabel: UILabel!
    @IBOutlet var keyHandleTime: UILabel!
    
    
    func setToken(_ tokenEntity: TokenEntity) {
        
        key = tokenEntity.keyHandle.base64Encoded()
        let urlIssuer = URL(string: tokenEntity.issuer ?? "")
        let keyName = tokenEntity.keyName == nil ? "https://\(urlIssuer?.host ?? "")" : tokenEntity.keyName
        keyHandleNameLabel.text = keyName
        keyHandleTime.text = getTime(tokenEntity.pairingTime)
        accessibilityLabel = tokenEntity.application
        accessibilityValue = tokenEntity.userName



            /* Eric
                    if ([tokenEntity isExternalKey]){
                        _keyHandleNameLabel.textColor = [UIColor colorWithRed:22/256.0 green:159/256.0 blue:220/256.0 alpha:1.0];
            //            _bleLabel.hidden = NO;
                    } else {
            //            _bleLabel.hidden = YES;
                    }
                     */
        
    }

    func getTime(_ createdTime: String?) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        let date: Date? = formatter.date(from: createdTime ?? "")
        formatter.dateFormat = "MMM dd, yyyy hh:mm:ss"
        if let aDate = date {
            return formatter.string(from: aDate)
        }
        return nil
    }
}
