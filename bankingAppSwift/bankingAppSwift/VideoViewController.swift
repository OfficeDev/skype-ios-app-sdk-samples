//
//  VideoViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/9/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
//

import UIKit
import GLKit

class VideoViewController: UIViewController,SfBConversationHelperDelegate {
    
    @IBOutlet weak var infoBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoBar: UIView!
    @IBOutlet weak var participantVideoView: GLKView!
    @IBOutlet weak var selfVideoView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var endCallButton: UIButton!
    
    var conversationHelper:SfBConversationHelper? = nil
    let DisplayNameInfo:String = "displayName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide back button of UINavigation
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // Set date label to current times
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        self.dateLabel.text = dateFormatter.stringFromDate(NSDate())
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.infoBarBottomConstraint.constant = -90;
        
    }
    
    /**
     *  Initialize UI.
     *  Bring information bar from bottom to the visible area of the screen.
     */
    
    override func viewDidAppear(animated: Bool) {
        self.initializeUI()
        self.joinMeeting()
    }
    
    /**
     *  Initialize UI.
     *  Bring information bar from bottom to the visible area of the screen.
     */
    
    func initializeUI()  {
        self.infoBarBottomConstraint.constant = 0
        UIView.animateWithDuration(0.5) {
            self.infoBar.layoutIfNeeded()
        }
    }
    
    /**
     *  Joins a Skype meeting.
     */
    func joinMeeting() {
        
        
        let meetingURLString:String = NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting URL") as! String
        let meetingDisplayName:String = NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting display name") as! String
        
        
        //Override point for customization after application launch.
        let sfb: SfBApplication = SfBApplication.sharedApplication()!
        
        
        do {
            let url = NSURL(string:meetingURLString)
            let conversation: SfBConversation  = try sfb.joinMeetingAnonymousWithUri(url!, displayName: meetingDisplayName)
            
            self.conversationHelper = SfBConversationHelper(conversation: conversation,
                                                            delegate: self,
                                                            devicesManager: sfb.devicesManager,
                                                            outgoingVideoView: self.selfVideoView,
                                                            incomingVideoLayer: self.participantVideoView.layer as! CAEAGLLayer,
                                                            userInfo: [DisplayNameInfo:meetingDisplayName])
            
            conversation.addObserver(self, forKeyPath: "canLeave", options: .Initial , context: nil)
            
            
            
        }
        catch let error as NSError {
            print(error.localizedDescription)
            self.handleError("Could Not Join Meeting")
        }
        
    }
    
    //MARK: User Button Actions
    
    
    @IBAction func endCall(sender: AnyObject) {
        
        // Get conversation handle and call leave.
        // Need to check for canLeave property of conversation,
        // in this case happens in KVO
        do{
            try self.conversationHelper?.conversation.leave()
            self.conversationHelper?.conversation.removeObserver(self, forKeyPath: "canLeave")
            self.navigationController?.popViewControllerAnimated(true)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            self.handleError("Could Not Leave meeting!")
        }
    }
    
    @IBAction func toggleMute(sender: AnyObject) {
        do{
            try self.conversationHelper?.toggleAudioMuted()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            self.handleError("Could Not Toggling Mute!")
            
        }
    }
    
    
    
    //MARK - Skype SfBConversationHelperDelegate Functions
    
    
    // At incoming video, unhide the participant video view
    func conversationHelper(conversationHelper: SfBConversationHelper, didSubscribeToVideo video: SfBParticipantVideo?) {
        self.participantVideoView.hidden = false
    }
    
    // When video service is ready to start, unhide self video view and start the service.
    func conversationHelper(conversationHelper: SfBConversationHelper, videoService: SfBVideoService, didChangeCanStart canStart: Bool) {
        
        if (canStart) {
            if (self.selfVideoView.hidden) {
                self.selfVideoView.hidden = false
            }
            do{
                try videoService.start()
            }
            catch let error as NSError {
                print(error.localizedDescription)
                self.handleError("Could Not Start Video Service!")
                
            }
        }
    }
    
    func conversationHelper(avHelper: SfBConversationHelper, selfAudio audio: SfBParticipantAudio, didChangeIsMuted isMuted: Bool) {
        if !isMuted {
            self.muteButton.setTitle("Unmute", forState: .Normal)
        }
        else {
            self.muteButton.setTitle("Mute", forState: .Normal)
        }
    }
    
    
    
    
    //MARK: - Additional KVO
    
    // Monitor canLeave property of a conversation to prevent leaving prematurely
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "canLeave") {
            self.endCallButton.enabled = (self.conversationHelper?.conversation.canLeave)!
            
        }
    }
    
    //MARK: - Helper UI
    
    func handleError(readableErrorDescription:String)  {
        let alertController:UIAlertController = UIAlertController(title: "ERROR!", message: readableErrorDescription, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion:nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
