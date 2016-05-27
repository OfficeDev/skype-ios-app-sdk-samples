//
//  EnterMeetingUrlViewController.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 5/23/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
//

import UIKit


class EnterMeetingCredentialsViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var currentMeetingUrl: UILabel!
    @IBOutlet weak var meetingDisplayName: UITextField!
    
    @IBOutlet weak var meetingUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meetingDisplayName.delegate = self
        self.meetingUrl.delegate = self
        self.showCurrentMeetingUrl()
        // Do any additional setup after loading the view.
    }
    
    func showCurrentMeetingUrl(){
        if (NSUserDefaults.standardUserDefaults().objectForKey(USER_MEETING_URL) != nil) {
           currentMeetingUrl.text = (NSUserDefaults.standardUserDefaults().objectForKey(USER_MEETING_URL) as! String)
        }
        else{
            currentMeetingUrl.text = "Meeting Url not set!"
        }

        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    @IBAction func okButtonPressed(sender: AnyObject) {
        
        if (self.meetingDisplayName.isFirstResponder()) {
            self.meetingDisplayName.resignFirstResponder()
        } else if (self.meetingUrl.isFirstResponder()) {
            self.meetingUrl.resignFirstResponder()
        }
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if (checkIfTextFieldHasText(meetingUrl))
        {
            //do something if it's not empty
            if (checkIfTextFieldHasText(meetingDisplayName)) {
                prefs.setValue(meetingDisplayName.text, forKey: USER_DISPLAY_NAME)
            }
            
            prefs.setValue(meetingUrl.text, forKey: USER_MEETING_URL)
            prefs.synchronize()
            
            let alertController:UIAlertController = UIAlertController(title: "SAVED!", message: nil, preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler:{(alert: UIAlertAction!) in
            self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(alertController, animated: true, completion:nil)
            
            

        }
        else{
            let alertController:UIAlertController = UIAlertController(title: "Alert!", message: "Please enter valid meeting url!", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            presentViewController(alertController, animated: true, completion:nil)
            
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
    
    
    
    // To hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
