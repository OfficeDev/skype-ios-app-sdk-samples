//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: IdentityViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class IdentityViewController: UIViewController, SfBAlertDelegate {

    private var kvo = 0

    private var sfb: SfBApplication!
    private var conversation: SfBConversation?

    @IBOutlet var displayName: UITextField!
    @IBOutlet var meetingUrl: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        sfb = SfBApplication.sharedApplication()

        sfb.configurationManager.maxVideoChannels = 1
        sfb.configurationManager.requireWifiForAudio = false
        sfb.configurationManager.requireWifiForVideo = false
        sfb.alertDelegate = self
    }

    func didReceiveAlert(alert: SfBAlert) {
        alert.show()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        do {
            conversation = try sfb.joinMeetingAnonymousWithUri(NSURL(string: meetingUrl.text!)!, displayName: displayName.text!).conversation
            return true
        } catch {
            UIAlertView(title: "Join failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
            return false
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let destination = segue.destinationViewController as? ConversationViewController else {
            return
        }

        destination.devicesManager = sfb.devicesManager
        destination.conversation = conversation
        conversation = nil
    }

}
