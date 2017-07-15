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
typealias completionBlock = (   _ data: Data?, _ error: NSError?) -> Void

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


var getEnablePreviewSwitchState : Bool {
get {
    
    return (UserDefaults.standard.object(forKey: ENABLE_PREVIEW_STATE) as? Bool) ?? Bundle.main.object(forInfoDictionaryKey: "Enable Preview Switch State") as! Bool
}
}

var getSfBOnlineSwitchState : Bool {
get {
    
    return (UserDefaults.standard.object(forKey: SFB_ONLINE_MEETING_STATE) as? Bool) ?? Bundle.main.object(forInfoDictionaryKey: "SfB Online Switch State") as! Bool
}
}

var getTokenAndDiscoveryURIRequestURL: String {
get {
return (UserDefaults.standard.object(forKey: TOKEN_AND_DISCOVERY_API_URL) as? String) ?? Bundle.main.object(forInfoDictionaryKey: "Token and discovery URI request API URL") as! String
}
}

var getOnlineMeetingRequestURL: String {
get {
    
    return (UserDefaults.standard.object(forKey: ONLINE_MEETING_REQUEST_API_URL) as? String) ?? Bundle.main.object(forInfoDictionaryKey: "Online Meeting request API URL") as! String
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

func showErrorAlert(_ readableErrorDescription:String,viewController:UIViewController)  {
    let alertController:UIAlertController =  UIAlertController(title:  "ERROR!", message: readableErrorDescription, preferredStyle: .alert)
    
    
    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:{(alert: UIAlertAction!) in
        if(viewController.isKind(of: OnlineMeetingViewController.self)){
        viewController.navigationController?.popViewController(animated: true)
        }
    }))

    
    
    viewController.present(alertController, animated: true, completion: nil)
}



extension SfBAlert {
    
    func showSfBAlertInController(_ viewController:UIViewController) {
        let errorTitle = "Error: " + self.DescriptionOfSfBAlertType()
        let errorDescription = self.error.localizedDescription
        
        let alertController:UIAlertController =  UIAlertController(title: errorTitle, message: errorDescription, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        viewController.present(alertController, animated: true, completion: nil)
        
    }
    
    func DescriptionOfSfBAlertType() -> String {
        switch type {
        case .messaging:return "Messaging"
        case .ucwaObjectModel:return "UcwaObjectModel"
        case .autoDiscovery:return "AutoDiscovery"
            
        case .signIn:return "SignIn"
        case .signOut:return "SignOut"
        case .connectivity:return "Connectivity"
            
        case .conferencing:return "Conferencing"
        case .participantMute:return "ParticipantMute"
        case .participantUnmute:return "ParticipantUnmute"
        case .conferenceUnexpectedDisconnect:return "ConferenceUnexpectedDisconnect"
            
        case .video:return "Video"
        case .videoOverWiFiBlocked:return "VideoOverWiFiBlocked"
        case .videoGenericError:return "VideoGenericError"
            
        case .voice:return "Voice"
        case .callFailed:return "CallFailed"
            
        case .conferenceIsRecording:return "ConferenceIsRecording"
            
        case .communication:return "Communication"
            
        case .common:return "Common"

        default:
            "ERROR!"
        }
    }
    
}
