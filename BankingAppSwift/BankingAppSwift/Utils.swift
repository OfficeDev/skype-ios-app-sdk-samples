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
    
    return (UserDefaults.standard.object(forKey: USER_MEETING_URL) as? String) ?? Bundle.main.object(forInfoDictionaryKey: "Skype meeting URL") as! String
}
}

var getMeetingDisplayName: String {
get {
    
    return (UserDefaults.standard.object(forKey: USER_DISPLAY_NAME) as? String) ?? Bundle.main.object(forInfoDictionaryKey: "Skype meeting display name") as! String
}

}

extension SfBAlert {

    func show() {
        UIAlertView(title: "\(level): \(type)",
            message: "\(error.localizedDescription)", delegate: nil, cancelButtonTitle: "OK").show()
    }

}

func leaveMeetingWithSuccess(_ conversation:SfBConversation) -> Bool {
    do{
        try conversation.leave()
    }
    catch let error as NSError {
        print(error.localizedDescription)
        return false
    }
    return true
}

func showErrorAlert(_ readableErrorDescription:String, InViewController viewController:UIViewController)  {
    let alertController:UIAlertController = UIAlertController(title: "ERROR!", message: readableErrorDescription, preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
    viewController.present(alertController, animated: true, completion:nil)
}

