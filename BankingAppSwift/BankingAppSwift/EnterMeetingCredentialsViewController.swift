//
//  EnterMeetingUrlViewController.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 5/23/16.
// Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
// See LICENSE in the project root for license information.
//

import UIKit


class EnterMeetingCredentialsViewController: UIViewController,UITextFieldDelegate {
    
   
    @IBOutlet weak var meetingDisplayName: UITextField!
    @IBOutlet weak var meetingUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meetingDisplayName.delegate = self
        self.meetingUrl.delegate = self
        self.showCurrentMeetingUrl()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Display saved meeting url on screen
    func showCurrentMeetingUrl(){
        if (NSUserDefaults.standardUserDefaults().objectForKey(USER_MEETING_URL) != nil) {
            
            meetingUrl.text = (NSUserDefaults.standardUserDefaults().objectForKey(USER_MEETING_URL) as! String)
            
        }
        else{
            
            meetingUrl.text = meetingUrl.placeholder
            
        }
        
        
    }
    
    @IBAction func okButtonPressed(sender: AnyObject) {
        
        self.hideKeyboard()
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        //Save Skype display name and meeting url.
        if ((checkIfTextFieldHasText(meetingUrl)) && (meetingUrl.text != meetingUrl.placeholder))
        {
            if ((checkIfTextFieldHasText(meetingDisplayName)) && (meetingDisplayName.text != meetingDisplayName.placeholder)) {
                
                prefs.setValue(meetingDisplayName.text, forKey: USER_DISPLAY_NAME)
                
            }
            
            prefs.setValue(meetingUrl.text, forKey: USER_MEETING_URL)
            prefs.synchronize()
            
            // show saved message and dismiss EnterMeetingCredentialsViewController
            let alertController:UIAlertController = UIAlertController(title: "SAVED!", message: nil, preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler:{(alert: UIAlertAction!) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(alertController, animated: true, completion:nil)
            
            
            
        }
        else{
            // show alert message if meeting url is empty
            let alertController:UIAlertController = UIAlertController(title: "Alert!", message: "Please enter valid meeting url!", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            presentViewController(alertController, animated: true, completion:nil)
        }
        
    }
    
    //MARK: - Text field handlers
    
    func hideKeyboard() {
        if (self.meetingDisplayName.isFirstResponder()) {
            self.meetingDisplayName.resignFirstResponder()
        } else if (self.meetingUrl.isFirstResponder()) {
            self.meetingUrl.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField.text == textField.placeholder){
        textField.placeholder = ""
        textField.text = ""
        }
    }
    
    func checkIfTextFieldHasText(textField:UITextField) -> Bool {
        if let text = textField.text where !text.isEmpty
        {
            //return true if it's not empty
            return true
        }
        return false
    }
    
    //MARK: - Hide status bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
   
}
