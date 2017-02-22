//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: Utils.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

let USER_MEETING_URL = "userMeetingUrl"
let USER_DISPLAY_NAME = "userDisplayName"
let ONLINE_MEETING_REQUEST_API_URL = "OnlineMeetingRequestAPIURL"
let TOKEN_AND_DISCOVERY_API_URL = "TokenAndDiscoveryURIRequestAPIURL"
let SFB_ONLINE_MEETING_STATE = "SfBOnlineSwitchState"
let ENABLE_PREVIEW_STATE = "enablePreviewSwitchState"
typealias completionBlock = (   data: NSData?, error: NSError?) -> Void

var getMeetingURLString : String {
get {
    
    return (NSUserDefaults.standardUserDefaults().objectForKey(USER_MEETING_URL) as? String) ?? NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting URL") as! String
}
}

var getMeetingDisplayName: String {
get {
    
    return (NSUserDefaults.standardUserDefaults().objectForKey(USER_DISPLAY_NAME) as? String) ?? NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting display name") as! String
}

}


var getEnablePreviewSwitchState : Bool {
get {
    
    return (NSUserDefaults.standardUserDefaults().objectForKey(ENABLE_PREVIEW_STATE) as? Bool) ?? NSBundle.mainBundle().objectForInfoDictionaryKey("Enable Preview Switch State") as! Bool
}
}

var getSfBOnlineSwitchState : Bool {
get {
    
    return (NSUserDefaults.standardUserDefaults().objectForKey(SFB_ONLINE_MEETING_STATE) as? Bool) ?? NSBundle.mainBundle().objectForInfoDictionaryKey("SfB Online Switch State") as! Bool
}
}

var getTokenAndDiscoveryURIRequestURL: String {
get {
return (NSUserDefaults.standardUserDefaults().objectForKey(TOKEN_AND_DISCOVERY_API_URL) as? String) ?? NSBundle.mainBundle().objectForInfoDictionaryKey("Token and discovery URI request API URL") as! String
}
}

var getOnlineMeetingRequestURL: String {
get {
    
    return (NSUserDefaults.standardUserDefaults().objectForKey(ONLINE_MEETING_REQUEST_API_URL) as? String) ?? NSBundle.mainBundle().objectForInfoDictionaryKey("Online Meeting request API URL") as! String
}
}


func leaveMeetingWithSuccess(conversation:SfBConversation) -> Bool {
    do{
        try conversation.leave()
    }
    catch let error as NSError {
        print(error.localizedDescription)
        return false
    }
    return true
}

func showErrorAlert(readableErrorDescription:String,viewController:UIViewController)  {
    let alertController:UIAlertController =  UIAlertController(title:  "ERROR!", message: readableErrorDescription, preferredStyle: .Alert)
    
    
    alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler:{(alert: UIAlertAction!) in
        if(viewController.isKindOfClass(OnlineMeetingViewController)){
        viewController.navigationController?.popViewControllerAnimated(true)
        }
    }))

    
    
    viewController.presentViewController(alertController, animated: true, completion: nil)
}



extension SfBAlert {
    
    func showSfBAlertInController(viewController:UIViewController) {
        let errorTitle = "Error: " + self.DescriptionOfSfBAlertType()
        let errorDescription = self.error.localizedDescription
        
        let alertController:UIAlertController =  UIAlertController(title: errorTitle, message: errorDescription, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func DescriptionOfSfBAlertType() -> String {
        switch type {
        case .Messaging:return "Messaging"
        case .UcwaObjectModel:return "UcwaObjectModel"
        case .AutoDiscovery:return "AutoDiscovery"
            
        case .SignIn:return "SignIn"
        case .SignOut:return "SignOut"
        case .Connectivity:return "Connectivity"
            
        case .Conferencing:return "Conferencing"
        case .ParticipantMute:return "ParticipantMute"
        case .ParticipantUnmute:return "ParticipantUnmute"
        case .ConferenceUnexpectedDisconnect:return "ConferenceUnexpectedDisconnect"
            
        case .Video:return "Video"
        case .VideoOverWiFiBlocked:return "VideoOverWiFiBlocked"
        case .VideoGenericError:return "VideoGenericError"
            
        case .Voice:return "Voice"
        case .CallFailed:return "CallFailed"
            
        case .ConferenceIsRecording:return "ConferenceIsRecording"
            
        case .Communication:return "Communication"
            
        case .Common:return "Common"

        default:
            "ERROR!"
        }
    }
    
}
