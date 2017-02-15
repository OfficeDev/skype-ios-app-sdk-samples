//
//  MainViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/9/16.
// Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
// See LICENSE in the project root for license information.
//

import UIKit

class MainViewController: UIViewController,SfBAlertDelegate, MicrosoftLicenseViewControllerDelegate {
   var sfb:SfBApplication?
    @IBOutlet weak var askAgentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self .initializeSkype()

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
        self.performSegueWithIdentifier("askAgentText", sender: nil)
    }
    
    func askAgentVideo()  {
        if let sfb = sfb{
        let config = sfb.configurationManager
        let key = "AcceptedVideoLicense"
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.boolForKey(key) {
            config.setEndUserAcceptedVideoLicense()
            self.performSegueWithIdentifier("askAgentVideo", sender: nil)
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
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .Loudspeaker
            sfb.configurationManager.enablePreviewFeatures = true
            sfb.alertDelegate = self
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func didReceiveAlert(alert: SfBAlert) {
        
        alert.show()
    }

    func controller(controller: MicrosoftLicenseViewController, didAcceptLicense acceptedLicense: Bool) {
        if(acceptedLicense){
            if let sfb = sfb{
            let config = sfb.configurationManager
            config.setEndUserAcceptedVideoLicense()
            self.performSegueWithIdentifier("askAgentVideo", sender: nil)
        }
        }
    }
}
