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

extension SfBAlert {

    func show() {
        UIAlertView(title: "\(level): \(type)",
            message: "\(error.localizedDescription)", delegate: nil, cancelButtonTitle: "OK").show()
    }

}
