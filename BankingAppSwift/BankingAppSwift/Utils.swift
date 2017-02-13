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
    return NSBundle.mainBundle().objectForInfoDictionaryKey("Token and discovery URI request URL") as! String
}
}

var getOnlineMeetingRequestURL: String {
get {
    
    return NSBundle.mainBundle().objectForInfoDictionaryKey("Online Meeting request URL") as! String
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
    
    alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
    
    viewController.presentViewController(alertController, animated: true, completion: nil)
  }



extension SfBAlert {

    func show() {
        UIAlertView(title: "\(level): \(type)",
            message: "\(error.localizedDescription)", delegate: nil, cancelButtonTitle: "OK").show()
    }

}
