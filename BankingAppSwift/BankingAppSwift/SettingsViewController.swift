//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: SettingsViewController.swift
//----------------------------------------------------------------
//
/**
 *  SettingsViewController configures the meeting type and enablePreviewFeature.
 *   Meeting type - Online/On-Prem
 *   enablePreviewSwitch - True/False
 *   Default settings are - On-prem meeting with enablePreviewFeature = false
 */
import UIKit

class SettingsViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var SfBOnlineSwitch: UISwitch!
    @IBOutlet weak var enablePreviewSwitch: UISwitch!
    @IBOutlet weak var meetingUrl: UITextField!
    @IBOutlet weak var meetingDisplayName: UITextField!
    @IBOutlet weak var TokenAndDiscoveryRequestAPIUrl: UITextField!
    @IBOutlet weak var meetingRequestAPIUrl: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroller: UIScrollView!
    
    let defaults = UserDefaults.standard
    
    
    
    @IBAction func saveSettings(_ sender: AnyObject) {
        saveSkypeForBusinessOnlineValueChange()
        saveEnablePreviewValueChange()
        saveSettings()
        self.navigationController?.popViewController(animated: true)

    }
    
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveSkypeForBusinessOnlineValueChange() {
        
        if SfBOnlineSwitch.isOn {
            defaults.set(true, forKey:SFB_ONLINE_MEETING_STATE)
        } else {
            defaults.set(false, forKey:SFB_ONLINE_MEETING_STATE)
        }
        defaults.synchronize()
        
    }
    
    func saveEnablePreviewValueChange() {
        if enablePreviewSwitch.isOn {
            defaults.set(true, forKey: ENABLE_PREVIEW_STATE)
        } else {
            defaults.set(false, forKey: ENABLE_PREVIEW_STATE)
        }
        defaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        
        scroller.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.meetingDisplayName.delegate = self
        self.meetingUrl.delegate = self
        self.meetingRequestAPIUrl.delegate = self
        self.TokenAndDiscoveryRequestAPIUrl.delegate = self
        self.SfBOnlineSwitch.tintColor = UIColor.white
        self.enablePreviewSwitch.tintColor = UIColor.white
        
        if let SfBOnlineSwitchState:Bool = defaults.object(forKey: SFB_ONLINE_MEETING_STATE) as? Bool {
            self.SfBOnlineSwitch.isOn = SfBOnlineSwitchState
        }
        if let enablePreviewSwitchState:Bool = defaults.object(forKey: ENABLE_PREVIEW_STATE) as? Bool {
            self.enablePreviewSwitch.isOn = enablePreviewSwitchState
        }
        showCurrentMeetingUrlAndDisplayName()
    }
    
    
    
    // Display saved meeting url on screen
    func showCurrentMeetingUrlAndDisplayName(){
        
        if(getMeetingURLString != "SkypeMeetingUrl")
        {
            meetingUrl.text = getMeetingURLString
        }
       
        if (getMeetingDisplayName != "Jake") {
            
            meetingDisplayName.text = getMeetingDisplayName
        }
        if (getTokenAndDiscoveryURIRequestURL != "TokenAndDiscoveryURIRequestAPIURL") {
            
            TokenAndDiscoveryRequestAPIUrl.text = getTokenAndDiscoveryURIRequestURL
        }
        if (getOnlineMeetingRequestURL != "OnlineMeetingRequestAPIURL") {
            
            meetingRequestAPIUrl.text = getOnlineMeetingRequestURL
        }
        
    }
    
    func saveSettings() {
        self.hideKeyboard()
        
        let prefs = UserDefaults.standard
        
        //Save Skype display name and meeting url.
        if ((checkIfTextFieldHasText(meetingUrl)) && (meetingUrl.text != meetingUrl.placeholder))
        {
            prefs.setValue(meetingUrl.text, forKey: USER_MEETING_URL)
        }
        if ((checkIfTextFieldHasText(meetingDisplayName)) && (meetingDisplayName.text != meetingDisplayName.placeholder)) {
            prefs.setValue(meetingDisplayName.text, forKey: USER_DISPLAY_NAME)
        }
        if ((checkIfTextFieldHasText(TokenAndDiscoveryRequestAPIUrl)) && (TokenAndDiscoveryRequestAPIUrl.text != TokenAndDiscoveryRequestAPIUrl.placeholder)){
            prefs.setValue(TokenAndDiscoveryRequestAPIUrl.text, forKey: TOKEN_AND_DISCOVERY_API_URL)
        }
        if ((checkIfTextFieldHasText(meetingRequestAPIUrl)) && (meetingRequestAPIUrl.text != meetingRequestAPIUrl.placeholder)){
            prefs.setValue(meetingRequestAPIUrl.text, forKey: ONLINE_MEETING_REQUEST_API_URL)
        }
        prefs.synchronize()
    }
    
    //MARK: - Text field handlers
    
    func hideKeyboard() {
        if (self.meetingDisplayName.isFirstResponder) {
            self.meetingDisplayName.resignFirstResponder()
        } else if (self.meetingUrl.isFirstResponder) {
            self.meetingUrl.resignFirstResponder()
        }else if(self.meetingRequestAPIUrl.isFirstResponder) {
            self.meetingRequestAPIUrl.resignFirstResponder()
        }else if(self.TokenAndDiscoveryRequestAPIUrl.isFirstResponder) {
            self.TokenAndDiscoveryRequestAPIUrl.resignFirstResponder()
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
    
   
    
    //MARK: - Scroll screen on keyboard show/hide
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
            else {
                
            }
        }
        
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            else {
                
            }
        }
    }
    @IBAction func prepareForUnwind(_ segue:UIStoryboardSegue){
        
    }
    

    
    
}
