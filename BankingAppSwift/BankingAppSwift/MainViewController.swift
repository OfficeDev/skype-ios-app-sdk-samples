//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: MainViewController.swift
//----------------------------------------------------------------
/*
MainViewController implements the meeting call flow for 
Onprem CU4 / Onprem CU3 / {Online meeting-enablePreviewFeatures = True} scenarios.
 */
import UIKit

class MainViewController: UIViewController,SfBAlertDelegate, MicrosoftLicenseViewControllerDelegate {
    
    private var sfb: SfBApplication?
    private var conversation: SfBConversation?
    
    @IBOutlet weak var askAgentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeSkype()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func askAgent(sender: AnyObject) {
        let alertController:UIAlertController = UIAlertController(title: "Ask Agent", message: nil, preferredStyle: .ActionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Ask using Text Chat", style: .Default, handler: { (action:UIAlertAction) in
            self.askAgentText()
        }))
        
        alertController.addAction(UIAlertAction(title: "Ask using Video Chat", style: .Default, handler: { (action:UIAlertAction) in
            self.askAgentVideo()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askAgentText()  {
        if(didJoinMeeting()){
            self.performSegueWithIdentifier("askAgentText", sender: nil)
        }
    }
    
    func askAgentVideo()  {
        
        if let sfb = sfb{
            let config = sfb.configurationManager
            let key = "AcceptedVideoLicense"
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if defaults.boolForKey(key) {
                config.setEndUserAcceptedVideoLicense()
                if(didJoinMeeting()){
                    self.performSegueWithIdentifier("askAgentVideo", sender: nil)
                }

            } else {
                
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MicrosoftLicenseViewController") as! MicrosoftLicenseViewController
                vc.delegate = self
                
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
        }

    }
    
    func initializeSkype(){
        sfb = SfBApplication.sharedApplication()
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 1
            sfb.configurationManager.requireWifiForAudio = false
            sfb.configurationManager.requireWifiForVideo = false
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .Loudspeaker
            sfb.configurationManager.enablePreviewFeatures = getEnablePreviewSwitchState
            sfb.alertDelegate = self
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func didReceiveAlert(alert: SfBAlert) {
        alert.showSfBAlertInController(self)
    }
    
    func didJoinMeeting() -> Bool {
        
        let meetingURLString:String = getMeetingURLString
        let meetingDisplayName:String = getMeetingDisplayName
        
        do {
            let urlText:String = meetingURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let url = NSURL(string:urlText)
            conversation = try sfb!.joinMeetingAnonymousWithUri(url!, displayName: meetingDisplayName).conversation
            return true
        }
        catch  {
            print("Error : Join Failed>\(error)")
            return false
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "askAgentText"){
            guard let destination = segue.destinationViewController as? ChatViewController else {
                return
            }
            destination.conversation = self.conversation
        }
        else if(segue.identifier == "askAgentVideo"){
            guard let destination = segue.destinationViewController as? VideoViewController else {
                return
            }
            destination.deviceManagerInstance = sfb!.devicesManager
            destination.conversationInstance = conversation
            destination.displayName = getMeetingDisplayName
            
        }
        conversation = nil
    }
    
    func controller(controller: MicrosoftLicenseViewController, didAcceptLicense acceptedLicense: Bool) {
        if(acceptedLicense){
            if let sfb = sfb{
                let config = sfb.configurationManager
                config.setEndUserAcceptedVideoLicense()
                
                if(didJoinMeeting()){
                    self.performSegueWithIdentifier("askAgentVideo", sender: nil)
                }
                
            }
        }
    }
}
