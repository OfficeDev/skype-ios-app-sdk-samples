//
//  OnlineMainViewController.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 2/21/17.
//  Copyright © 2017 Aasveen Kaur. All rights reserved.
//

import UIKit

class OnlineMainViewController: UIViewController, SfBAlertDelegate {
    private var sfb: SfBApplication?
    
    
    @IBAction func joinOnlineMeeting(sender: AnyObject) {
        performSegueWithIdentifier("segueToOnlineMeeting", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeSkype()
       
    }

   override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func initializeSkype(){
        
        // Configure Shared application instance for Online meeting
        sfb = SfBApplication.sharedApplication()
        
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 1
            sfb.configurationManager.requireWifiForAudio = false
            sfb.configurationManager.requireWifiForVideo = false
            sfb.alertDelegate = self
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .Loudspeaker
            
            // For OnPrem topolgies enablePreview features should be enabled for Audio/Video.
            sfb.configurationManager.enablePreviewFeatures = getEnablePreviewSwitchState
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "segueToOnlineMeeting"){
            let vc = segue.destinationViewController as! OnlineMeetingViewController
            vc.sfb = sfb
        }
    }
    
    //MARK: SfBAlertDelegate alert function
    func didReceiveAlert(alert: SfBAlert) {
        alert.showSfBAlertInController(self)
    }

}
