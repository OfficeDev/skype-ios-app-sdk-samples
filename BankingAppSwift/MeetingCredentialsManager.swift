//
//  MeetingUrlManager.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 5/24/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
//


let USER_MEETING_URL = "userMeetingUrl"
let USER_DISPLAY_NAME = "userDisplayName"

class MeetingCredentialsManager {
    static let sharedInstance = MeetingCredentialsManager()
    private init() {} //This prevents others from using the default '()' initializer for this class.

    func getMeetingUrl() ->  String {
        if (NSUserDefaults.standardUserDefaults().objectForKey(USER_MEETING_URL) != nil) {
            return NSUserDefaults.standardUserDefaults().objectForKey(USER_MEETING_URL) as! String
        }
        return NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting URL") as! String

    }
    
    func getSkypeDisplayName() ->  String {
        if  (NSUserDefaults.standardUserDefaults().objectForKey(USER_DISPLAY_NAME) != nil) {
            return NSUserDefaults.standardUserDefaults().objectForKey(USER_DISPLAY_NAME) as! String
        }
        return NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting display name") as! String
    }
    
}
