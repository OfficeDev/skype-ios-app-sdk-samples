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
                attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        }

        return NSAttributedString(string: displayName)
    }

}

class BaseParticipantCell: UITableViewCell {

    private var kvo = 0

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

    private var audio: SfBParticipantAudio? {
        willSet {
            audio?.removeObserver(self, forKeyPath: "state", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "isMuted", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "isOnHold", context: &kvo)
            audio?.removeObserver(self, forKeyPath: "isSpeaking", context: &kvo)
        }
        didSet {
            audio?.addObserver(self, forKeyPath: "state", options: [.Initial], context: &kvo)
            audio?.addObserver(self, forKeyPath: "isMuted", options: [.Initial], context: &kvo)
            audio?.addObserver(self, forKeyPath: "isOnHold", options: [.Initial], context: &kvo)
            audio?.addObserver(self, forKeyPath: "isSpeaking", options: [.Initial], context: &kvo)
        }
    }

    private var chat: SfBParticipantChat? {
        willSet {
            chat?.removeObserver(self, forKeyPath: "isTyping", context: &kvo)
            chat?.removeObserver(self, forKeyPath: "state", context: &kvo)
        }
        didSet {
            chat?.addObserver(self, forKeyPath: "isTyping", options: [.Initial], context: &kvo)
            chat?.addObserver(self, forKeyPath: "state", options: [.Initial], context: &kvo)
        }
    }

    var video: SfBParticipantVideo?

    private var person: SfBPerson? {
        willSet {
            person?.removeObserver(self, forKeyPath: "displayName", context: &kvo)
            person?.removeObserver(self, forKeyPath: "sipUri", context: &kvo)
        }
        didSet {
            person?.addObserver(self, forKeyPath: "displayName", options: [.Initial], context: &kvo)
            person?.addObserver(self, forKeyPath: "sipUri", options: [.Initial], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "participant")
    }

    override func prepareForReuse() {
        participant = nil
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &kvo else {
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
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
                chatLabel.enabled = (chat?.state == .Connected)
            case is SfBParticipantAudio:
                audioButton.enabled = (audio?.state == .Connected)
            default:
                assertionFailure()
            }
        case "isSpeaking":
            if (audio?.isSpeaking == true) {
                audioButton.setTitle("Speak", forState: .Normal)
            } else {
                fallthrough
            }
        case "isOnHold":
            if (audio?.isOnHold == true) {
                audioButton.setTitle("Held", forState: .Normal)
            } else {
                fallthrough
            }
        case "isMuted":
            audioButton.setTitle((audio?.isMuted == false) ? "Audio" : "Muted", forState: .Normal)
        default:
            assertionFailure()
        }

        setNeedsLayout()
    }

    @IBAction func mute(sender: AnyObject?) {
        do {
            try audio!.setMuted(!audio!.isMuted)
        } catch {
            UIAlertView(title: "Failed to (un)mute", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

}

class ParticipantCell: BaseParticipantCell {

    @IBOutlet var videoView: GLKView!

    private var kvo2 = 0

    override var video: SfBParticipantVideo? {
        willSet {
            video?.removeObserver(self, forKeyPath: "canSubscribe", context: &kvo2)
            video?.removeObserver(self, forKeyPath: "isPaused", context: &kvo2)
        }
        didSet {
            video?.addObserver(self, forKeyPath: "canSubscribe", options: [.Initial, .New, .Old], context: &kvo2)
            video?.addObserver(self, forKeyPath: "isPaused", options: [.Initial, .New, .Old], context: &kvo2)
        }
    }

    private var displayLink: CADisplayLink {
        let dl = CADisplayLink(target: self, selector: NSSelectorFromString("render:"))
        dl.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        return dl
    }

    private var renderTarget: SfBVideoStream?

    deinit {
        try? video?.unsubscribe()
        displayLink.invalidate()
        renderTarget = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        try? video?.unsubscribe()
    }

    private func setVideoViewHidden() {
        let hide = (renderTarget == nil) || video!.isPaused
        videoView.hidden = hide
        displayLink.paused = hide
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &kvo2 else {
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }

        switch keyPath! {

        case "isPaused":
            setVideoViewHidden()

        case "canSubscribe":
            if video!.canSubscribe {
                renderTarget = try! video?.subscribe(videoView.layer as! CAEAGLLayer)
                try? renderTarget?.setAutoFitMode(.Crop)
            } else {
                renderTarget = nil
            }
            setVideoViewHidden()

        default:
            assertionFailure()

        }
    }

    func render(sender: CADisplayLink) {
        // Any GL usage in background crashes application
        if UIApplication.sharedApplication().applicationState == .Active {
            try? renderTarget?.render()
        }
    }

}

class SelfParticipantCell: BaseParticipantCell {

    private var kvo2 = 0

    @IBOutlet var videoView: UIView!

    var videoService: SfBVideoService? {
        didSet {
            renderTarget = try! videoService?.showPreviewOnView(videoView)
        }
    }

    private var renderTarget: SfBVideoPreview?

    deinit {
        setValue(nil, forKey: "videoService")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        videoService = nil
    }

}
