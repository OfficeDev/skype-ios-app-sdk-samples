//
//  OnlineMainViewController.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 2/21/17.
//  Copyright © 2017 Aasveen Kaur. All rights reserved.
//

import UIKit

class OnlineMainViewController: UIViewController, SfBAlertDelegate {
    fileprivate var sfb: SfBApplication?
    
    
    @IBAction func joinOnlineMeeting(_ sender: AnyObject) {
        performSegue(withIdentifier: "segueToOnlineMeeting", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeSkype()
       
    }

   override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func initializeSkype(){
        
        // Configure Shared application instance for Online meeting
        sfb = SfBApplication.shared()
        
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 1
            sfb.configurationManager.requireWifiForAudio = false
            sfb.configurationManager.requireWifiForVideo = false
            sfb.alertDelegate = self
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .loudspeaker
            
            // For OnPrem topolgies enablePreview features should be enabled for Audio/Video.
            sfb.configurationManager.enablePreviewFeatures = getEnablePreviewSwitchState
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueToOnlineMeeting"){
            let vc = segue.destination as! OnlineMeetingViewController
            vc.sfb = sfb
        }
    }
    
    //MARK: SfBAlertDelegate alert function
    func didReceive(_ alert: SfBAlert) {
        alert.showSfBAlertInController(self)
    }

}
