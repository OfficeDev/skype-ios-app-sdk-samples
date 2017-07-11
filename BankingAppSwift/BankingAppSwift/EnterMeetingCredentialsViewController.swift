//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Module name: EnterMeetingCredentialsViewController.swift
//----------------------------------------------------------------


import UIKit


class EnterMeetingCredentialsViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var meetingDisplayName: UITextField!
    @IBOutlet weak var meetingUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meetingDisplayName.delegate = self
        self.meetingUrl.delegate = self
        self.showCurrentMeetingUrlAndDisplayName()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Display saved meeting url on screen
    func showCurrentMeetingUrlAndDisplayName(){
        if (UserDefaults.standard.object(forKey: USER_MEETING_URL) != nil) {
            
            meetingUrl.text = (UserDefaults.standard.object(forKey: USER_MEETING_URL) as! String)
            
        }
        else{
            
            meetingUrl.text = meetingUrl.placeholder
            
        }
        if (UserDefaults.standard.object(forKey: USER_DISPLAY_NAME) != nil) {
            
            meetingDisplayName.text = (UserDefaults.standard.object(forKey: USER_DISPLAY_NAME) as! String)
            
        }
        else{
            
            meetingDisplayName.text = meetingDisplayName.placeholder
            
        }
    }
    
    @IBAction func okButtonPressed(_ sender: AnyObject) {
        
        self.hideKeyboard()
        
        let prefs = UserDefaults.standard
        
        //Save Skype display name and meeting url.
        if ((checkIfTextFieldHasText(meetingUrl)) && (meetingUrl.text != meetingUrl.placeholder))
        {
            if ((checkIfTextFieldHasText(meetingDisplayName)) && (meetingDisplayName.text != meetingDisplayName.placeholder)) {
                
                prefs.setValue(meetingDisplayName.text, forKey: USER_DISPLAY_NAME)
                
            }
            
            prefs.setValue(meetingUrl.text, forKey: USER_MEETING_URL)
            prefs.synchronize()
            
            // show saved message and dismiss EnterMeetingCredentialsViewController
            let alertController:UIAlertController = UIAlertController(title: "SAVED!", message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{(alert: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
            
            present(alertController, animated: true, completion:nil)
            
            
            
        }
        else{
            // show alert message if meeting url is empty
            let alertController:UIAlertController = UIAlertController(title: "Alert!", message: "Please enter valid meeting url!", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            present(alertController, animated: true, completion:nil)
        }
        
    }
    
    //MARK: - Text field handlers
    
    func hideKeyboard() {
        if (self.meetingDisplayName.isFirstResponder) {
            self.meetingDisplayName.resignFirstResponder()
        } else if (self.meetingUrl.isFirstResponder) {
            self.meetingUrl.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.text == textField.placeholder){
            textField.placeholder = ""
            textField.text = ""
        }
    }
    
    func checkIfTextFieldHasText(_ textField:UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty
        {
            //return true if it's not empty
            return true
        }
        return false
    }
    
    //MARK: - Hide status bar
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}
