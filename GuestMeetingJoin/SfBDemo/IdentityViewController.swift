//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: IdentityViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class IdentityViewController: UIViewController, SfBAlertDelegate {

    fileprivate var kvo = 0

    fileprivate var sfb: SfBApplication!
    fileprivate var conversation: SfBConversation?

    @IBOutlet var displayName: UITextField!
    @IBOutlet var meetingUrl: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        sfb = SfBApplication.shared()

        let config = sfb.configurationManager
        let key = "AcceptedVideoLicense"
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: key) {
            config.setEndUserAcceptedVideoLicense()
        } else {
            let sheet = UIAlertController(title: "Video License",
                                          message: "You shall obey terms of the license.",
                                          preferredStyle: .actionSheet)

            sheet.addAction(UIAlertAction(title: "Decline", style: .default, handler: nil))

            sheet.addAction(UIAlertAction(title: "Accept", style: .destructive) { action in
                defaults.set(true, forKey: key)
                config.setEndUserAcceptedVideoLicense()
                })

            present(sheet, animated: true, completion: nil)
        }

        sfb.configurationManager.maxVideoChannels = 1
        sfb.configurationManager.requireWifiForAudio = false
        sfb.configurationManager.requireWifiForVideo = false

        // For OnPrem topolgies enablePreview features should be enabled for Audio/Video.
        sfb.configurationManager.enablePreviewFeatures = true

        sfb.alertDelegate = self
    }

    func didReceive(_ alert: SfBAlert) {
        alert.show()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        do {
            // To join an Online meeting use the discover URL method. Please refer the documentation for
            // the overall procedure of getting the discover URL and authorization token for a meeting.
            //
            // let discoverUrl = NSURL(string: "https://meetings.lync.com/platformService/discover?...")!
            // let authToken = "psat=...";
            // let session = try sfb.joinMeetingAnonymousWithDiscoverUrl(discoverUrl, authToken: authToken, displayName: displayName.text!)

            let session = try sfb.joinMeetingAnonymous(withUri: URL(string: meetingUrl.text!)!, displayName: displayName.text!)
            conversation = session.conversation
            return true
        } catch {
            UIAlertView(title: "Join failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
            return false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ConversationViewController else {
            return
        }

        destination.devicesManager = sfb.devicesManager
        destination.conversation = conversation
        conversation = nil
    }

}
