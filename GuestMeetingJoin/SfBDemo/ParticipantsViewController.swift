//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: ParticipantsViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class ParticipantsViewController: UITableViewController {

    private var kvo = 0

    @IBOutlet var videoStart: UIBarButtonItem!
    @IBOutlet var videoPause: UIBarButtonItem!
    @IBOutlet var videoStop: UIBarButtonItem!
    @IBOutlet var camera: UIBarButtonItem!

    var devicesManager: SfBDevicesManager!

    var conversation: SfBConversation? {
        willSet {
            conversation?.removeObserver(self, forKeyPath: "remoteParticipants", context: &kvo)
        }
        didSet {
            conversation?.addObserver(self, forKeyPath: "remoteParticipants", options: [.Initial], context: &kvo)
            videoService = conversation?.videoService
            selfVideo = conversation?.selfParticipant.video
        }
    }

    private var videoService: SfBVideoService? {
        willSet {
            videoService?.removeObserver(self, forKeyPath: "canSetPaused", context: &kvo)
            videoService?.removeObserver(self, forKeyPath: "canStart", context: &kvo)
            videoService?.removeObserver(self, forKeyPath: "canStop", context: &kvo)
            videoService?.removeObserver(self, forKeyPath: "canSetActiveCamera", context: &kvo)
        }
        didSet {
            videoService?.addObserver(self, forKeyPath: "canSetPaused", options: [.Initial], context: &kvo)
            videoService?.addObserver(self, forKeyPath: "canStart", options: [.Initial], context: &kvo)
            videoService?.addObserver(self, forKeyPath: "canStop", options: [.Initial], context: &kvo)
            videoService?.addObserver(self, forKeyPath: "canSetActiveCamera", options: [.Initial], context: &kvo)
        }
    }

    private var selfVideo: SfBParticipantVideo? {
        willSet {
            selfVideo?.removeObserver(self, forKeyPath: "isPaused", context: &kvo)
        }
        didSet {
            selfVideo?.addObserver(self, forKeyPath: "isPaused", options: [.Initial], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "conversation")
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &kvo else {
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }

        switch keyPath! {
        case "remoteParticipants":
            tableView.updateRowsWithChange(KeyValueChange(change: change!))
        case "canStart", "canSetPaused", "isPaused":
            let isPaused = (selfVideo?.isPaused == true)
            let canSetPaused = (videoService?.canSetPaused == true)
            videoStart.enabled =  (isPaused && canSetPaused) || videoService?.canStart == true
            videoPause.enabled = !isPaused && canSetPaused
        case "canStop":
            videoStop.enabled = videoService!.canStop
        case "canSetActiveCamera":
            camera.enabled = videoService!.canSetActiveCamera
        default:
            assertionFailure()
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return conversation?.remoteParticipants.count ?? 0
        case 1:
            return 1
        default:
            assertionFailure()
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ParticipantCell", forIndexPath: indexPath) as! ParticipantCell
            cell.participant = conversation?.remoteParticipants[indexPath.row]
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfParticipantCell", forIndexPath: indexPath) as! SelfParticipantCell
            cell.participant = conversation?.selfParticipant
            cell.videoService = conversation?.videoService
            return cell
        default:
            fatalError()
        }
    }

    @IBAction func startVideo(sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        do {
            try selfVideo!.isPaused ? videoService.setPaused(false) : videoService.start()
        } catch {
            UIAlertView(title: "Starting video failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func stopVideo(sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        do {
            try videoService.stop()
        } catch {
            UIAlertView(title: "Stopping video failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func pauseVideo(sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        do {
            try videoService.setPaused(true)
        } catch {
            UIAlertView(title: "Pausing video failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func changeCamera(sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        let cameras = devicesManager.cameras
        var next: SfBCamera?

        if let activeCamera = videoService.activeCamera {
            if let curr = cameras.indexOf(activeCamera) {
                next = cameras[(curr + 1) % cameras.count]
            }
        }

        if let camera = next ?? cameras.first {
            do {
                try videoService.setActiveCamera(camera)
            } catch {
                UIAlertView(title: "Changing camera failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }

}
