//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Module name: LoginViewController.swift
//----------------------------------------------------------------


import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var credentialTextFields: [UITextField]!
    @IBOutlet weak var addURLButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBAction func signInButtonPressed(sender: AnyObject) {
        
        /* Online meeting with enable preview = FALSE, chat/AV will work only WITH Trusted application API service app. Use func joinMeetingAnonymousWithDiscoverUrl(discoverUrl: NSURL, authToken: String, displayName: String)
         */
        if((getSfBOnlineSwitchState == true) && (getEnablePreviewSwitchState == false))
        {
            performSegueWithIdentifier("segueToOnlineMeetingSceneFromLoginScene", sender: nil)
        }
            /*Onprem CU4/Onprem CU3/Online-enable preview = True.
             Use func joinMeetingAnonymousWithUri(meetingUri: NSURL, displayName: String)
             */
        else{
            performSegueWithIdentifier("segueToMainSceneFromLoginScene", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        
        super.viewDidLoad()
        addURLButton.titleLabel?.textAlignment = NSTextAlignment.Center
        settingsButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        credentialTextFields[0].delegate = self
        credentialTextFields[1].delegate = self
    }
    
    // Hide Keyboard on return.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue){
        
    }
    
    
}
