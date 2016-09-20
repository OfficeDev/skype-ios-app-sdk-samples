/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit
import GLKit

/**
 *  VideoViewController handles AV chat using Skype for Business SDK.
 *  Namely, it uses a convenient helper SfBConversationHelper.h included in the
 *  Helpers folder of the SDK.
 */
class VideoViewController: UIViewController,SfBConversationHelperDelegate,SfBAlertDelegate {

@IBOutlet weak var infoBarBottomConstraint: NSLayoutConstraint!
@IBOutlet weak var infoBar: UIView!
@IBOutlet weak var participantVideoView: GLKView!
@IBOutlet weak var selfVideoView: UIView!
@IBOutlet weak var muteButton: UIButton!
@IBOutlet weak var dateLabel: UILabel!
@IBOutlet weak var endCallButton: UIButton!

var conversationHelper:SfBConversationHelper? = nil
let DisplayNameInfo:String = "displayName"

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    registerForAppTerminationNotification()
}


override func viewDidLoad() {
    super.viewDidLoad()
    // Hide back button of UINavigation
    self.navigationItem.setHidesBackButton(true, animated: true)
    
    // Set date label to current times
    let dateFormatter:DateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.dateFormat = "yyyy.MM.dd"
    
    self.dateLabel.text = dateFormatter.string(from: Date())
    
    
    // Do any additional setup after loading the view.
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}

override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    
    self.infoBarBottomConstraint.constant = -90;
    
}

override func viewDidAppear(_ animated: Bool) {
    self.initializeUI()
    self.joinMeeting()
}

deinit{
    NotificationCenter.default.removeObserver(self)
    
}

/**
 *  Initialize UI.
 *  Bring information bar from bottom to the visible area of the screen.
 */

func initializeUI()  {
    self.infoBarBottomConstraint.constant = 0
    UIView.animate(withDuration: 0.5, animations: {
        self.infoBar.layoutIfNeeded()
    }) 
}

/**
 *  Joins a Skype meeting.
 */
func joinMeeting() {
    
    let meetingURLString:String = getMeetingURLString
    let meetingDisplayName:String = getMeetingDisplayName
    
    //Override point for customization after application launch.
    let sfb: SfBApplication = SfBApplication.shared()!
    do {
        
        let urlText:String = meetingURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string:urlText)
        let conversation: SfBConversation  = try sfb.joinMeetingAnonymous(withUri: url!, displayName: meetingDisplayName)
        conversation.alertDelegate = self
        
        self.conversationHelper = SfBConversationHelper(conversation: conversation,
                                                        delegate: self,
                                                        devicesManager: sfb.devicesManager,
                                                        outgoingVideoView: self.selfVideoView,
                                                        incomingVideoLayer: self.participantVideoView.layer as! CAEAGLLayer,
                                                        userInfo: [DisplayNameInfo:meetingDisplayName])
        
        conversation.addObserver(self, forKeyPath: "canLeave", options: .initial , context: nil)
        
        
        
    }
    catch let error as NSError {
        print(error.localizedDescription)
        showErrorAlert("Could Not Join Meeting!(System Error)", InViewController: self)
        
        //Enable end call button to let user exit video call screen after failure to join meeting
        self.endCallButton.isEnabled = true
    }
    
}

//MARK: User Button Actions


@IBAction func endCall(_ sender: AnyObject) {
    
    // Get conversation handle and call leave.
    // Need to check for canLeave property of conversation,
    // in this case happens in KVO
    if let conversation = self.conversationHelper?.conversation{
        if(leaveMeetingWithSuccess(conversation)){
            self.conversationHelper?.conversation.removeObserver(self, forKeyPath: "canLeave")
            
        }
        else{
            
            showErrorAlert("Could Not Leave Meeting!", InViewController: self)
        }
    }
    self.navigationController?.popViewController(animated: true)
    
}

@IBAction func toggleMute(_ sender: AnyObject) {
    do{
        try self.conversationHelper?.toggleAudioMuted()
    }
    catch let error as NSError {
        print(error.localizedDescription)
     
        showErrorAlert("Could Not Toggling Mute!", InViewController: self)
        
        
    }
}


//MARK - Skype SfBConversationHelperDelegate Functions

// At incoming video, unhide the participant video view

func conversationHelper(_ conversationHelper: SfBConversationHelper, didSubscribeTo video: SfBParticipantVideo?) {
    self.participantVideoView.isHidden = false
}

// When video service is ready to start, unhide self video view and start the service.

func conversationHelper(_ conversationHelper: SfBConversationHelper, videoService: SfBVideoService, didChangeCanStart canStart: Bool) {
    
    if (canStart) {
        if (self.selfVideoView.isHidden) {
            self.selfVideoView.isHidden = false
        }
        do{
            try videoService.start()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            
        }
    }
}

// When the audio status changes, reflect in UI

func conversationHelper(_ avHelper: SfBConversationHelper, selfAudio audio: SfBParticipantAudio, didChangeIsMuted isMuted: Bool) {
    if !isMuted {
        self.muteButton.setTitle("Unmute", for: UIControlState())
    }
    else {
        self.muteButton.setTitle("Mute", for: UIControlState())
    }
}

    
//MARK - Sfb Alert Delegate
    
    func didReceive(_ alert: SfBAlert) {
        
        alert.show()
    }
    



//MARK: - Additional KVO

// Monitor canLeave property of a conversation to prevent leaving prematurely
override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if (keyPath == "canLeave") {
        self.endCallButton.isEnabled = (self.conversationHelper?.conversation.canLeave)!
        
    }
}
}

extension VideoViewController{

func registerForAppTerminationNotification() {
    
    NotificationCenter.default.addObserver(self, selector:#selector(VideoViewController.leaveMeetingWhenAppTerminates(_:)), name:NSNotification.Name.UIApplicationWillTerminate, object:nil)
}


func leaveMeetingWhenAppTerminates(_ aNotification:Notification) {
    if let conversation = conversationHelper?.conversation{
        leaveMeetingWithSuccess(conversation)
    }
}


}




