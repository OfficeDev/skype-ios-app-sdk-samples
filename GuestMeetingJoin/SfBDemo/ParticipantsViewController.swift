//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: ParticipantsViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class ParticipantsViewController: UITableViewController {

    fileprivate var kvo = 0

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
            conversation?.addObserver(self, forKeyPath: "remoteParticipants", options: [.initial], context: &kvo)
            videoService = conversation?.videoService
            selfVideo = conversation?.selfParticipant.video
        }
    }

    fileprivate var videoService: SfBVideoService? {
        willSet {
            videoService?.removeObserver(self, forKeyPath: "canSetPaused", context: &kvo)
            videoService?.removeObserver(self, forKeyPath: "canStart", context: &kvo)
            videoService?.removeObserver(self, forKeyPath: "canStop", context: &kvo)
            videoService?.removeObserver(self, forKeyPath: "canSetActiveCamera", context: &kvo)
        }
        didSet {
            videoService?.addObserver(self, forKeyPath: "canSetPaused", options: [.initial], context: &kvo)
            videoService?.addObserver(self, forKeyPath: "canStart", options: [.initial], context: &kvo)
            videoService?.addObserver(self, forKeyPath: "canStop", options: [.initial], context: &kvo)
            videoService?.addObserver(self, forKeyPath: "canSetActiveCamera", options: [.initial], context: &kvo)
        }
    }

    fileprivate var selfVideo: SfBParticipantVideo? {
        willSet {
            selfVideo?.removeObserver(self, forKeyPath: "isPaused", context: &kvo)
        }
        didSet {
            selfVideo?.addObserver(self, forKeyPath: "isPaused", options: [.initial], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "conversation")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvo else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        switch keyPath! {
        case "remoteParticipants":
            tableView.updateRowsWithChange(KeyValueChange(change: change!))
        case "canStart", "canSetPaused", "isPaused":
            let isPaused = (selfVideo?.isPaused == true)
            let canSetPaused = (videoService?.canSetPaused == true)
            videoStart.isEnabled =  (isPaused && canSetPaused) || videoService?.canStart == true
            videoPause.isEnabled = !isPaused && canSetPaused
        case "canStop":
            videoStop.isEnabled = videoService!.canStop
        case "canSetActiveCamera":
            camera.isEnabled = videoService!.canSetActiveCamera
        default:
            assertionFailure()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantCell
            cell.participant = conversation?.remoteParticipants[indexPath.row]
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelfParticipantCell", for: indexPath) as! SelfParticipantCell
            cell.participant = conversation?.selfParticipant
            cell.videoService = conversation?.videoService
            return cell
        default:
            fatalError()
        }
    }

    @IBAction func startVideo(_ sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        do {
            try selfVideo!.isPaused ? videoService.setPaused(false) : videoService.start()
        } catch {
            UIAlertView(title: "Starting video failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func stopVideo(_ sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        do {
            try videoService.stop()
        } catch {
            UIAlertView(title: "Stopping video failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func pauseVideo(_ sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        do {
            try videoService.setPaused(true)
        } catch {
            UIAlertView(title: "Pausing video failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    @IBAction func changeCamera(_ sender: AnyObject?) {
        guard let videoService = videoService else {
            return
        }

        let cameras = devicesManager.cameras
        var next: SfBCamera?

        if let activeCamera = videoService.activeCamera {
            if let curr = cameras.index(of: activeCamera) {
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
