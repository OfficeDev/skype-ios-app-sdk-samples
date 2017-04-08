//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: ParticipantCell.swift
//----------------------------------------------------------------

import Foundation
import GLKit
import UIKit
import SkypeForBusiness

extension SfBPerson {

    var displayNameLabel: NSAttributedString {
        if displayName == "" {
            return NSAttributedString(string: "No Name",
                attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }

        return NSAttributedString(string: displayName)
    }

}

class BaseParticipantCell: UITableViewCell {

    fileprivate var kvo = 0

    @IBOutlet var displayName: UILabel!
    @IBOutlet var sipUri: UILabel!
    @IBOutlet var isTyping: UIActivityIndicatorView!
    @IBOutlet var chatLabel: UILabel!
    @IBOutlet var audioButton: UIButton!

    var participant: SfBParticipant? {
        didSet {
            person = participant?.person
            chat = participant?.chat
            audio = participant?.audio
            video = participant?.video
        }
    }

    fileprivate var audio: SfBParticipantAudio? {
        willSet {
            audio?.removeObserver(self, forKeyPath: "state", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "isMuted", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "isOnHold", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "isSpeaking", context: &kvo)
        }
        didSet {
            audio?.addObserver(self, forKeyPath: "state", options: [.initial], context: &kvo)
            audio?.addObserver(self, forKeyPath: "isMuted", options: [.initial], context: &kvo)
            audio?.addObserver(self, forKeyPath: "isOnHold", options: [.initial], context: &kvo)
            audio?.addObserver(self, forKeyPath: "isSpeaking", options: [.initial], context: &kvo)
        }
    }

    fileprivate var chat: SfBParticipantChat? {
        willSet {
            chat?.removeObserver(self, forKeyPath: "isTyping", context: &kvo)
            chat?.removeObserver(self, forKeyPath: "state", context: &kvo)
        }
        didSet {
            chat?.addObserver(self, forKeyPath: "isTyping", options: [.initial], context: &kvo)
            chat?.addObserver(self, forKeyPath: "state", options: [.initial], context: &kvo)
        }
    }

    var video: SfBParticipantVideo?

    fileprivate var person: SfBPerson? {
        willSet {
            person?.removeObserver(self, forKeyPath: "displayName", context: &kvo)
            person?.removeObserver(self, forKeyPath: "sipUri", context: &kvo)
        }
        didSet {
            person?.addObserver(self, forKeyPath: "displayName", options: [.initial], context: &kvo)
            person?.addObserver(self, forKeyPath: "sipUri", options: [.initial], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "participant")
    }

    override func prepareForReuse() {
        participant = nil
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvo else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        switch keyPath! {
        case "displayName":
            displayName.attributedText = person?.displayNameLabel
        case "sipUri":
            sipUri.text = person?.sipUri.absoluteString
        case "isTyping":
            if chat!.isTyping {
                isTyping.startAnimating()
            } else {
                isTyping.stopAnimating()
            }
        case "state":
            switch object {
            case is SfBParticipantChat:
                chatLabel.isEnabled = (chat?.state == .connected)
            case is SfBParticipantAudio:
                audioButton.isEnabled = (audio?.state == .connected)
            default:
                assertionFailure()
            }
        case "isSpeaking":
            if (audio?.isSpeaking == true) {
                audioButton.setTitle("Speak", for: UIControlState())
            } else {
                fallthrough
            }
        case "isOnHold":
            if (audio?.isOnHold == true) {
                audioButton.setTitle("Held", for: UIControlState())
            } else {
                fallthrough
            }
        case "isMuted":
            audioButton.setTitle((audio?.isMuted == false) ? "Audio" : "Muted", for: UIControlState())
        default:
            assertionFailure()
        }

        setNeedsLayout()
    }

    @IBAction func mute(_ sender: AnyObject?) {
        do {
            try audio!.setMuted(!audio!.isMuted)
        } catch {
            UIAlertView(title: "Failed to (un)mute", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

}

class ParticipantCell: BaseParticipantCell {

    @IBOutlet var videoView: GLKView!

    fileprivate var kvo2 = 0

    override var video: SfBParticipantVideo? {
        willSet {
            video?.removeObserver(self, forKeyPath: "canSubscribe", context: &kvo2)
            video?.removeObserver(self, forKeyPath: "isPaused", context: &kvo2)
        }
        didSet {
            video?.addObserver(self, forKeyPath: "canSubscribe", options: [.initial, .new, .old], context: &kvo2)
            video?.addObserver(self, forKeyPath: "isPaused", options: [.initial, .new, .old], context: &kvo2)
        }
    }

    fileprivate var displayLink: CADisplayLink {
        let dl = CADisplayLink(target: self, selector: NSSelectorFromString("render:"))
        dl.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        return dl
    }

    fileprivate var renderTarget: SfBVideoStream?

    deinit {
        try? video?.unsubscribe()
        displayLink.invalidate()
        renderTarget = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        try? video?.unsubscribe()
    }

    fileprivate func setVideoViewHidden() {
        let hide = (renderTarget == nil) || video!.isPaused
        videoView.isHidden = hide
        displayLink.isPaused = hide
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvo2 else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        switch keyPath! {

        case "isPaused":
            setVideoViewHidden()

        case "canSubscribe":
            if video!.canSubscribe {
                renderTarget = try! video?.subscribe(videoView.layer as! CAEAGLLayer)
                try? renderTarget?.setAutoFitMode(.crop)
            } else {
                renderTarget = nil
            }
            setVideoViewHidden()

        default:
            assertionFailure()

        }
    }

    func render(_ sender: CADisplayLink) {
        // Any GL usage in background crashes application
        if UIApplication.shared.applicationState == .active {
            try? renderTarget?.render()
        }
    }

}

class SelfParticipantCell: BaseParticipantCell {

    fileprivate var kvo2 = 0

    @IBOutlet var videoView: UIView!

    var videoService: SfBVideoService? {
        didSet {
            renderTarget = try! videoService?.showPreview(on: videoView)
        }
    }

    fileprivate var renderTarget: SfBVideoPreview?

    deinit {
        setValue(nil, forKey: "videoService")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        videoService = nil
    }

}
