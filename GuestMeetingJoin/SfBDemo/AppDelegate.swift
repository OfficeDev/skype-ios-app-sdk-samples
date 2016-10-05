//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: AppDelegate.swift
//----------------------------------------------------------------

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
                withOptions: [.AllowBluetooth, .MixWithOthers, .DuckOthers])
            try audioSession.setMode(AVAudioSessionModeVoiceChat)
        } catch {
            UIAlertView(title: "Audio Session failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }

        return true
    }

	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		// The URL scheme should follow the format 'sfbmeeting://FirstName%20LastName@tenant/user/meetingID'
        if url.host == nil {
			return false;
		}
		let urlComponents = url.absoluteString!.stringByRemovingPercentEncoding!.componentsSeparatedByString("/")
		if urlComponents.count != 5 {
            return false;
        }
        let partialData = urlComponents[2].componentsSeparatedByString("@")
        let displayName = partialData[0]
        let meetingUriComponents = ["https://meet.lync.com/", partialData[1]] + urlComponents[3...4]

        // Join the meeting
        let navController:UINavigationController = window!.rootViewController as! UINavigationController
        if navController.topViewController is IdentityViewController {
            let dstController = navController.topViewController as! IdentityViewController
            navController.popToViewController(dstController, animated: true)
            if #available(iOS 9.0, *) {
                dstController.loadViewIfNeeded()
            } else {
                let _ = dstController.view;
            }
            dstController.loadMeeting(meetingUriComponents.joinWithSeparator("/"), displayName: displayName)
            dstController.performSegueWithIdentifier("JoinConversation", sender: nil)
            return true
        }
        else {
            UIAlertView(title: "Join failed", message: "You are currently in another meeting.", delegate: nil, cancelButtonTitle: "OK").show()
        }
        return false
	}

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

