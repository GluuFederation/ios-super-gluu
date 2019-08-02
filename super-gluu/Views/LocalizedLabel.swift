//
//  LocalizedLabel.swift
//  Super Gluu
//
//  Created by eric webb on 7/16/19.
//  Copyright © 2019 Gluu. All rights reserved.
//

import UIKit

enum LocalString: String {
    case Landing_Incorrect_Passcode = "Landing_Incorrect_Passcode"
    case Launch_Enter_Passcode  = "Launch_Enter_Passcode"
    case Launch_Forgot_Passcode = "Launch_Forgot_Passcode"
    case Security_Passcode  = "Security_Passcode"
    case Security_Touch_Id  = "Security_Touch_Id"
    case Security_Face_Id   = "Security_Face_Id"
    case Home_Check_Internet       = "Home_Check_Internet"
    case Home_No_Internet          = "Home_No_Internet"
    case Home_Tap_To_Scan_QR       = "Home_Tap_To_Scan_QR"
    case Home_Welcome              = "Home_Welcome"
    case Home_Scan                 = "Home_Scan"
    case Home_Remove_Ads           = "Home_Remove_Ads"
    case Home_QR_Not_Recognized    = "Home_QR_Not_Recognized"
    case Home_Auth_Success         = "Home_Auth_Success"
    case Home_Registration_Success = "Home_Registration_Success"
    case Home_Registration_Failed  = "Home_Registration_Failed"
    case Home_Decline_Failed       = "Home_Decline_Failed"
    case Home_Authenticating       = "Home_Authenticating"
    case Home_Registering          = "Home_Registering"
    case Home_Auth_Failed          = "Home_Auth_Failed"
    case Home_Auth_Declined        = "Home_Auth_Declined"
    case Home_Expired_Push         = "Home_Expired_Push"
    case Subscription_Details = "Subscription_Details"
    case Details              = "Details"
    case Subscription_Info    = "Subscription_Info"
    case Menu_Logs           = "Menu_Logs"
    case Menu_Keys           = "Menu_Keys"
    case Menu_Passcode       = "Menu_Passcode"
    case Menu_User_Guide     = "Menu_User_Guide"
    case Menu_Privacy_Policy = "Menu_Privacy_Policy"
    case Menu_Settings       = "Menu_Settings"
    case Menu_Help           = "Menu_Help"
    case Logs_Description = "Logs_Description"
    case Passcode_Enabled_Info   = "Passcode_Enabled_Info"
    case Passcode_Touch          = "Passcode_Touch"
    case Passcode_Touch_Security = "Passcode_Touch_Security"
    case Passcode_Set                 = "Passcode_Set"
    case Passcode_Enter_A_Passcode    = "Passcode_Enter_A_Passcode"
    case Passcode_Reenter             = "Passcode_Reenter"
    case Passcode_Enter_Passcode      = "Passcode_Enter_Passcode"
    case Passcode_Enter_Your_Passcode = "Passcode_Enter_Your_Passcode"
    case Passcode_Change              = "Passcode_Change"
    case Passcode_Enter_Old           = "Passcode_Enter_Old"
    case Passcode_Enter_New           = "Passcode_Enter_New"
    case Passcode_Reenter_New         = "Passcode_Reenter_New"
    case Passcode_Try_Again           = "Passcode_Try_Again"
    case Passcode_Attempts_Left       = "Passcode_Attempts_Left"
    case Passcode_Next                = "Passcode_Next"
    case SSL_Info  = "SSL_Info"
    case SSL_Trust = "SSL_Trust"
    case Log_Key_Username    = "Log_Key_Username"
    case Log_Key_Created     = "Log_Key_Created"
    case Log_Key_Id_Provider = "Log_Key_Id_Provider"
    case Log_Key_Key_Handle  = "Log_Key_Key_Handle"
    case Keys_Info       = "Keys_Info"
    case Keys_Text_Value = "Keys_Text_Value"
    case Info_Delete_Key           = "Info_Delete_Key"
    case Info_Change_Name_How_To   = "Info_Change_Name_How_To"
    case Info_Change_Name_Question = "Info_Change_Name_Question"
    case Info_Duplicate_Name       = "Info_Duplicate_Name"
    case Info_Enter_Name           = "Info_Enter_Name"
    case Info_Change_Name          = "Info_Change_Name"
    case Info_Enter_New_Name       = "Info_Enter_New_Name"
    case Approve             = "Approve"
    case Deny                = "Deny"
    case Permission_Approval = "Permission_Approval"
    case Approving           = "Approving"
    case Denying             = "Denying"
    case Info       = "Info"
    case Yes        = "Yes"
    case No         = "No"
    case Delete     = "Delete"
    case Clear_Log  = "Clear_Log"
    case Clear_Logs = "Clear_Logs"
    case Close      = "Close"
    case Cancel     = "Cancel"
    case Save       = "Save"
    case Oops       = "Oops"
    case Signed_In_To             = "Signed_In_To"
    case Auth_Failed_To           = "Auth_Failed_To"
    case Registered_To            = "Registered_To"
    case Registration_Failed_To   = "Registration_Failed_To"
    case Auth_Declined_To         = "Auth_Declined_To"
    case Registration_Declined_To = "Registration_Declined_To"
    case Unknown_Error            = "Unknown_Error"
    case Success                  = "Success!"
    case Missing_Request_Info     = "Missing_Request_Info"
    case Unknown_Error_Something  = "Unknown_Error_Something"
    case Not_Allowed_Payment      = "Not_Allowed_Payment"
    case Invalid_Purchase_Id      = "Invalid_Purchase_Id"
    case Unallowed_Device         = "Unallowed_Device"
    case Unavailable_Product      = "Unavailable_Product"
    case Unallowed_Cloud_Access   = "Unallowed_Cloud_Access"
    case No_Network_Connection    = "No_Network_Connection"
    case Enable_TouchID                = "Enable_TouchID"
    case Identify_Yourself             = "Identify_Yourself"
    case Identify_Verification_Problem = "Identify_Verification_Problem"
    case Cancel_Pressed                = "Cancel_Pressed"
    case Password_Pressed              = "Password_Pressed"
    case TouchID_Not_Configured        = "TouchID_Not_Configured"
    case Two_Attempts_Remaining    = "2_Attempts_Remaining"
    case Failed_Attempts_Warning = "Failed_Attempts_Warning"
    
    var localized: String {
        return self.rawValue.localized()
    }
    
    var localizedUppercase: String {
        return self.rawValue.localized().uppercased()
    }
}

final class LocalizedLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        text = text?.localized()
    }

}
