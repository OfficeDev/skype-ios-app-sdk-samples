//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: ConversationViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

extension SfBSpeakerEndpoint: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Loudspeaker:
            return "Loudspeaker"
        case .NonLoudspeaker:
            return "Handset"
        }
    }
}

class ConversationViewController: UIViewController, SfBAlertDelegate {

    @IBOutlet var send: UIButton!

    @IBOutlet var hold: UIButton!

    @IBOutlet var endpoint: UIButton!

    private var kvo = 0

    var devicesManager: SfBDevicesManager? {
        didSet {
            speaker = devicesManager?.selectedSpeaker
        }
    }

    var conversation: SfBConversation? {
        willSet {
            conversation?.alertDelegate = nil
            conversation?.removeObserver(self, forKeyPath: "subject", context: &kvo)
        }
        didSet {
            conversation?.addObserver(self, forKeyPath: "subject", options: [.Initial], context: &kvo)
            chat = conversation?.chatService
            audio = conversation?.audioService
            conversation?.alertDelegate = self
        }
    }

    private var audio: SfBAudioService? {
        willSet {
            audio?.removeObserver(self, forKeyPath: "isOnHold", context: &kvo)
        }
    }

    private var chat: SfBChatService? {
        willSet {
            chat?.removeObserver(self, forKeyPath: "canSendMessage", context: &kvo)
        }
    }

    private var speaker: SfBSpeaker? {
        willSet {
            speaker?.removeObserver(self, forKeyPath: "activeEndpoint", context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "conversation")
        setValue(nil, forKey: "devicesManager")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        chat!.addObserver(self, forKeyPath: "canSendMessage", options: [.Initial], context: &kvo)
        audio!.addObserver(self, forKeyPath: "isOnHold", options: [.Initial], context: &kvo)
        speaker?.addObserver(self, forKeyPath: "activeEndpoint", options: [.Initial], context: &kvo)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &kvo else {
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }

        switch keyPath! {
        case "subject":
            navigationItem.title = conversation?.subject
        case "canSendMessage":
            send.enabled = chat!.canSendMessage
        case "activeEndpoint":
            endpoint.setTitle(speaker!.activeEndpoint.description, forState: .Normal)
        case "isOnHold":
            hold.setTitle(audio!.isOnHold ? "Held" : "Unheld", forState: .Normal)
        default:
            assertionFailure()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.destinationViewController {
        case let history as HistoryViewController:
            history.history = conversation?.historyService
        case let participants as ParticipantsViewController:
            participants.conversation = conversation
            participants.devicesManager = devicesManager
        default:
            assertionFailure()
        }
    }

    @IBOutlet var message: UITextField?

    func didReceiveAlert(alert: SfBAlert) {
        alert.show()
    }

    @IBAction func sendMessage(sender: AnyObject?) {
        do {
            try chat?.sendMessage(message!.text!)
            message?.text = nil
        } catch {
            UIAlertView(title: "Message not sent", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)

        guard parent == nil else {
            return
        }

        do {
            try conversation?.leave()
        } catch {
            UIAlertView(title: "Leaving failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func selectSpeakerEndpoint(sender: AnyObject?) {
        speaker?.activeEndpoint = (speaker?.activeEndpoint == .Loudspeaker) ? .NonLoudspeaker : .Loudspeaker;
    }

    @IBAction func toggleHold(sender: AnyObject?) {
        guard let audio = conversation?.audioService else {
            return
        }

        do {
            try audio.setHold(!audio.isOnHold)
        } catch {
            UIAlertView(title: "Holding failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

}
