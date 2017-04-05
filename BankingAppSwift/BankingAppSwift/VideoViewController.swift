//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Module name: VideoViewController.swift
//----------------------------------------------------------------


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
    
    var conversationInstance:SfBConversation? = nil
    var deviceManagerInstance: SfBDevicesManager? = nil
    var displayName: String? = nil

    
    var conversationHelper:SfBConversationHelper? = nil
    let DisplayNameInfo:String = "displayName"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.registerForAppTerminationNotification()
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
    
    /**
     *  Initialize UI.
     *  Bring information bar from bottom to the visible area of the screen.
     */
    
    override func viewDidAppear(_ animated: Bool) {
        self.initializeUI()
        self.joinMeeting()
    }
    
    deinit {
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
        

       
        conversationInstance!.alertDelegate = self
        
        self.conversationHelper = SfBConversationHelper(conversation: conversationInstance!,
                                                        delegate: self,
                                                        devicesManager: deviceManagerInstance!,
                                                        outgoingVideoView: self.selfVideoView,
                                                        incomingVideoLayer: self.participantVideoView.layer as! CAEAGLLayer,
                                                        userInfo: [DisplayNameInfo:displayName!])
        
        conversationInstance!.addObserver(self, forKeyPath: "canLeave", options: .initial , context: nil)
        
        
    }
    
    //MARK: User Button Actions
    
    
    @IBAction func endCall(_ sender: AnyObject) {
        
        // Get conversation handle and call leave.
        // Need to check for canLeave property of conversation,
        // in this case happens in KVO
        if let conversation = self.conversationHelper?.conversation{
            if(!leaveMeetingWithSuccess(conversation)){
                
            showErrorAlert("Could Not Leave Meeting!", viewController: self)
           }
            self.conversationHelper?.conversation.removeObserver(self, forKeyPath: "canLeave")
        }
        
        var presentedFromOnlineMeetingViewController = false
        let allViewControllers = self.navigationController?.viewControllers
        for viewController in allViewControllers!{
            if(viewController.isKind(of: OnlineMainViewController.self)){
                presentedFromOnlineMeetingViewController = true
                self.navigationController?.popToViewController(viewController, animated: true)
                break;
            }
        }
        if(!presentedFromOnlineMeetingViewController){
            self.navigationController?.popViewController(animated: true)
        }        
        
    
}


   
    
    @IBAction func toggleMute(_ sender: AnyObject) {
        do{
            try self.conversationHelper?.conversation.audioService.toggleMute()

        }
        catch let error as NSError {
            print(error.localizedDescription)
            self.handleError("Could Not Toggling Mute!")
            
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
   

    func conversationHelper(_ conversationHelper: SfBConversationHelper, audioService: SfBAudioService, didChangeMuted muted: SfBAudioServiceMuteState) {
        if muted == .muted {
            self.muteButton.setTitle("Unmute", for: UIControlState())
        }
        else {
            self.muteButton.setTitle("Mute", for: UIControlState())
        }
    }
    

   //MARK: - Additional KVO

    
    // Monitor canLeave property of a conversation to prevent leaving prematurely
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "canLeave") {
            self.endCallButton.isEnabled = (self.conversationHelper?.conversation.canLeave)!
            
        }
    }
    
    func registerForAppTerminationNotification() {
        
        NotificationCenter.default.addObserver(self, selector:#selector(VideoViewController.leaveMeetingWhenAppTerminates(_:)), name:NSNotification.Name.UIApplicationWillTerminate, object:nil)
    }
    
    
    func leaveMeetingWhenAppTerminates(_ aNotification:Notification) {
        if let conversation = conversationHelper?.conversation{
            leaveMeetingWithSuccess(conversation)
        }
    }

    
    //MARK: - Helper UI
    
    func handleError(_ readableErrorDescription:String)  {
        let alertController:UIAlertController = UIAlertController(title: "ERROR!", message: readableErrorDescription, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alertController, animated: true, completion:nil)
    }
   
    
    func didReceive(_ alert: SfBAlert) {
       alert.showSfBAlertInController(self)
    }
    
}


    

        




