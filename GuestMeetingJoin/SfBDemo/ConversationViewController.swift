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
        case .loudspeaker:
            return "Loudspeaker"
        case .nonLoudspeaker:
            return "Handset"
        }
    }
}

class ConversationViewController: UIViewController, SfBAlertDelegate {

    @IBOutlet var send: UIButton!

    @IBOutlet var mute: UIButton!
    @IBOutlet var hold: UIButton!

    @IBOutlet var endpoint: UIButton!

    fileprivate var kvo = 0

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
            conversation?.addObserver(self, forKeyPath: "subject", options: [.initial], context: &kvo)
            chat = conversation?.chatService
            audio = conversation?.audioService
            conversation?.alertDelegate = self
        }
    }

    fileprivate var audio: SfBAudioService? {
        willSet {
            audio?.removeObserver(self, forKeyPath: "isOnHold", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "muted", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "canToggleMute", context: &kvo)
        }
    }

    fileprivate var chat: SfBChatService? {
        willSet {
            chat?.removeObserver(self, forKeyPath: "canSendMessage", context: &kvo)
        }
    }

    fileprivate var speaker: SfBSpeaker? {
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
        chat!.addObserver(self, forKeyPath: "canSendMessage", options: [.initial], context: &kvo)
        audio!.addObserver(self, forKeyPath: "isOnHold", options: [.initial], context: &kvo)
        audio!.addObserver(self, forKeyPath: "muted", options: [.initial], context: &kvo)
        audio!.addObserver(self, forKeyPath: "canToggleMute", options: [.initial], context: &kvo)
        speaker?.addObserver(self, forKeyPath: "activeEndpoint", options: [.initial], context: &kvo)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvo else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        switch keyPath! {
        case "subject":
            navigationItem.title = conversation?.subject
        case "canSendMessage":
            send.isEnabled = chat!.canSendMessage
        case "activeEndpoint":
            endpoint.setTitle(speaker!.activeEndpoint.description, for: UIControlState())
        case "isOnHold":
            hold.setTitle(audio!.isOnHold ? "Held" : "Unheld", for: UIControlState())
        case "muted":
            mute.setTitle(audio!.muted.description, for: UIControlState())
        case "canToggleMute":
            mute.isEnabled = audio!.canToggleMute
        default:
            assertionFailure()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
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

    func didReceive(_ alert: SfBAlert) {
        alert.show()
    }

    @IBAction func sendMessage(_ sender: AnyObject?) {
        do {
            try chat?.sendMessage(message!.text!)
            message?.text = nil
        } catch {
            UIAlertView(title: "Message not sent", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        guard parent == nil else {
            return
        }

        do {
            try conversation?.leave()
        } catch {
            UIAlertView(title: "Leaving failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func selectSpeakerEndpoint(_ sender: AnyObject?) {
        speaker?.activeEndpoint = (speaker?.activeEndpoint == .loudspeaker) ? .nonLoudspeaker : .loudspeaker;
    }

    @IBAction func toggleHold(_ sender: AnyObject?) {
        guard let audio = audio else {
            return
        }

        do {
            try audio.setHold(!audio.isOnHold)
        } catch {
            UIAlertView(title: "Holding failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func toggleMute(_ sender: AnyObject?) {
        guard let audio = audio else {
            return
        }

        do {
            try audio.toggleMute()
        } catch {
            UIAlertView(title: "Toggling mute failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

}
