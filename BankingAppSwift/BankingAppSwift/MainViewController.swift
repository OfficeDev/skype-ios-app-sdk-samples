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
    /** Called when new alert appears in the context where this delegate is attached.
     *
     * Each alert is passed to a delegate once and dismissed unconditionally.
     * If no delegate is attached, alerts are accumulated and reported as soon
     * as delegate is set. Accumulated alerts of the same category and type
     * are coalesced, only the last one will be reported.
     */

    fileprivate var sfb: SfBApplication?
    fileprivate var conversation: SfBConversation?
    
    @IBOutlet weak var askAgentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeSkype()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func askAgent(_ sender: AnyObject) {
        let alertController:UIAlertController = UIAlertController(title: "Ask Agent", message: nil, preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Ask using Text Chat", style: .default, handler: { (action:UIAlertAction) in
            self.askAgentText()
        }))
        
        alertController.addAction(UIAlertAction(title: "Ask using Video Chat", style: .default, handler: { (action:UIAlertAction) in
            self.askAgentVideo()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askAgentText()  {
        if(didJoinMeeting()){
            self.performSegue(withIdentifier: "askAgentText", sender: nil)
        }
    }
    
    func askAgentVideo()  {
        
        if let sfb = sfb{
            let config = sfb.configurationManager
            let key = "AcceptedVideoLicense"
            let defaults = UserDefaults.standard
            
            if defaults.bool(forKey: key) {
                config.setEndUserAcceptedVideoLicense()
                if(didJoinMeeting()){
                    self.performSegue(withIdentifier: "askAgentVideo", sender: nil)
                }

            } else {
                
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrosoftLicenseViewController") as! MicrosoftLicenseViewController
                vc.delegate = self
                
                self.present(vc, animated: true, completion: nil)
            }
            
        }

    }
    
    func initializeSkype(){
        sfb = SfBApplication.shared()
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 1
            sfb.configurationManager.requireWifiForAudio = false
            sfb.configurationManager.requireWifiForVideo = false
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .loudspeaker
            sfb.configurationManager.enablePreviewFeatures = getEnablePreviewSwitchState
            sfb.alertDelegate = self
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func didReceive(_ alert: SfBAlert) {
        alert.showSfBAlertInController(self)
    }
    
    func didJoinMeeting() -> Bool {
        
        let meetingURLString:String = getMeetingURLString
        let meetingDisplayName:String = getMeetingDisplayName
        
        do {
            let urlText:String = meetingURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let url = URL(string:urlText)
            conversation = try sfb!.joinMeetingAnonymous(withUri: url!, displayName: meetingDisplayName).conversation
            return true
        }
        catch  {
            print("ERROR! Joining online meeting>\(error)")
            showErrorAlert("Joining online meeting failed. Try again later!", viewController: self)
            return false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "askAgentText"){
            guard let destination = segue.destination as? ChatViewController else {
                return
            }
            destination.conversation = self.conversation
        }
        else if(segue.identifier == "askAgentVideo"){
            guard let destination = segue.destination as? VideoViewController else {
                return
            }
            destination.deviceManagerInstance = sfb!.devicesManager
            destination.conversationInstance = conversation
            destination.displayName = getMeetingDisplayName
            
        }
        conversation = nil
    }
    
    func controller(_ controller: MicrosoftLicenseViewController, didAcceptLicense acceptedLicense: Bool) {
        if(acceptedLicense){
            if let sfb = sfb{
                let config = sfb.configurationManager
                config.setEndUserAcceptedVideoLicense()
                
                if(didJoinMeeting()){
                    self.performSegue(withIdentifier: "askAgentVideo", sender: nil)
                }
                
            }
        }
    }
}
