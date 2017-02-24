//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: OnlineMeetingViewController.swift
//----------------------------------------------------------------
/**
 *  OnlineMeetingViewController implements the online meeting call flow using client-side
 *  functionality of Skype for Business App SDK.
 *  You will require Trusted Application API Service Application(SaaS app) for this work-flow.
 *
 */



import Foundation
import UIKit
import SkypeForBusiness


class OnlineMeetingViewController: UIViewController, SfBAlertDelegate,UITextFieldDelegate, MicrosoftLicenseViewControllerDelegate {
    
    var sfb: SfBApplication?
    private var conversation: SfBConversation?
    private var token: String?
    private var discoveryURI: String?
    
    @IBOutlet var meetingUrl: UITextView!
    @IBOutlet var displayName: UITextField!
    @IBOutlet var join: UIButton!
    @IBOutlet var tokenAndDiscoveryURISuccessLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorForServiceApplicationResponse: UIActivityIndicatorView!
    //MARK: Lifecycle and helper functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI
        join.titleLabel?.textAlignment = NSTextAlignment.Center
        displayName.text = getMeetingDisplayName
        displayName.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // First POST request to fetch meeting URL
        sendPostRequestForMeetingURL()
        
    }
    
    //MARK:Send POST requests for online meeting call flow functions
    //  POST request to fetch ad hoc Meeting URL
    func sendPostRequestForMeetingURL(){
        
        // request to Trusted Application API Service Application endpoint
        if let url = NSURL(string: getOnlineMeetingRequestURL){
        let meetingUrlRequest = NSMutableURLRequest(URL: url)
        meetingUrlRequest.HTTPMethod = "POST"
        meetingUrlRequest.HTTPBody = "Subject=adhocMeeting&Description=adhocMeeting&AccessLevel=".dataUsingEncoding(NSUTF8StringEncoding)
        
        SendHttpRequest(meetingUrlRequest as NSURLRequest) { (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                do {
                    guard error == nil, let data = data else {
                        throw error!
                    }
                    
                    let json = try  NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: String]
                    self.meetingUrl.text = (json["JoinUrl"])!;
                    
                    print("Successful! meeting URL>> \(json["JoinUrl"])");
                    
                    // Send second POST request to get discovery URI and TOKEN based on response meeting URL
                    self.sendPostRequestForTokenAndDiscoveryURI();
                } catch {
                    print("ERROR! Getting meeting URL failed>\(error)")
                    showErrorAlert("Getting meeting URL failed. Try again later!", viewController: self)
                   
                }
                
                
            }
        }
        }
    }
    
    //  POST request to get token and discovery URI based on response meeting URL
    func sendPostRequestForTokenAndDiscoveryURI()  {
        
        // request to Trusted Application API Service Application endpoint
         if let url = NSURL(string: getTokenAndDiscoveryURIRequestURL){
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let meetintURL = meetingUrl.text!;
        request.HTTPBody = "ApplicationSessionId=AnonMeeting&AllowedOrigins=http%3a%2f%2flocalhost%2f&MeetingUrl=\(meetintURL)".dataUsingEncoding(NSUTF8StringEncoding)
        
        join.enabled = false
        SendHttpRequest(request as NSURLRequest) { (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                do {
                    guard error == nil, let data = data else {
                        throw error!
                    }
                    
                    let json = try  NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: String]
                    self.discoveryURI = json["DiscoverUri"]!
                    self.tokenAndDiscoveryURISuccessLabel.textColor = UIColor.darkGrayColor()
                    self.tokenAndDiscoveryURISuccessLabel.text = "Success! Please join online meeting"
                    self.token = json["Token"]
                    self.join.enabled = true
                    self.join.alpha = 1
                    self.activityIndicatorForServiceApplicationResponse.stopAnimating()
                    print("Successful! token and discovery URI>> \(json["Token"]),\(json["DiscoverUri"])");
                    
                } catch {
                    print("ERROR! Getting token and discovery URI failed>\(error)")
                    showErrorAlert("Getting Discover URI failed. Try again later!", viewController: self)
                    
                    
                }
                
                
            }
        }
     }
        
    }
    
    
    // Helper function to send request
    func SendHttpRequest(request:NSURLRequest, withBlock completionHandler:  completionBlock) {
        let  sessionObject: NSURLSession = NSURLSession.sharedSession()
        let task = sessionObject.dataTaskWithRequest(request) {  (data, response, error) in
            let httpResponse = response as? NSHTTPURLResponse
            let statusCode = httpResponse?.statusCode
            print("statusCode-aas>\(statusCode)")
            
            if (statusCode == 200 ) {
                
                completionHandler(data: data, error: nil)
                
            }
                
            else{
                if(error == nil){
                    let error:NSError = NSError(domain: "statusCode -\(statusCode)!", code: statusCode!, userInfo:nil)
                    completionHandler(data: nil,error: error as NSError?)
                }
                else {
                    completionHandler(data: nil,error: error as NSError?)
                }
                
            }
        }
        
        task.resume()
    }
    
    //MARK: User button actions
    // press "Join online meeting" button to join text or video online meeting
    @IBAction func JoinOnlineMeetingPressed(sender: AnyObject) {
        let alertController:UIAlertController = UIAlertController(title: "Join online meeting", message: nil, preferredStyle: .ActionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Join online chat", style: .Default, handler: { (action:UIAlertAction) in
            self.joinOnlineChat()
        }))
        
        alertController.addAction(UIAlertAction(title: "Join online video chat", style: .Default, handler: { (action:UIAlertAction) in
            self.joinOnlineVideoChat()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func joinOnlineChat()  {
        if(didJoinMeeting()){
            self.performSegueWithIdentifier("joinOnlineChat", sender: nil)
        }
    }
    
    func joinOnlineVideoChat()  {
        
        
        if let sfb = sfb{
            let config = sfb.configurationManager
            let key = "AcceptedVideoLicense"
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if defaults.boolForKey(key) {
                config.setEndUserAcceptedVideoLicense()
                if(didJoinMeeting()){
                    self.performSegueWithIdentifier("joinOnlineAudioVideoChat", sender: nil)
                }
                
            } else {
                
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MicrosoftLicenseViewController") as! MicrosoftLicenseViewController
                vc.delegate = self
                
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
        }
        
        
        
    }
    
    //MARK: Join online meeting anonymous with discover URI and token function
    
    func didJoinMeeting() -> Bool {
        do {
            
            let session = try sfb!.joinMeetingAnonymousWithDiscoverUrl(NSURL(string: discoveryURI!)!, authToken: token!, displayName: displayName.text!)
            conversation = session.conversation
            conversation?.alertDelegate = self
            return true
        } catch {
            print("ERROR! Joining online meeting>\(error)")
            showErrorAlert("Joining online meeting failed. Try again later!", viewController: self)
            return false
        }
    }
    
    //MARK: Segue navigation functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "joinOnlineChat"){
            guard let destination = segue.destinationViewController as? ChatViewController else {
                return
            }
            destination.conversation = self.conversation
            
        }
        else if(segue.identifier == "joinOnlineAudioVideoChat"){
            guard let destination = segue.destinationViewController as? VideoViewController else {
                return
            }
            destination.deviceManagerInstance = sfb!.devicesManager
            destination.conversationInstance = conversation
            destination.displayName = displayName.text!
            
            discoveryURI = nil
            token = nil
            
        }
        conversation = nil
    }
    
    //MARK: Lifecycle and helper functions
    // reset UI when leaving this screen
    override func viewDidDisappear(animated: Bool) {
        displayName.text = displayName.placeholder
        meetingUrl.textColor = UIColor.redColor()
        meetingUrl.text = "Waiting for online meeting URL!"
        tokenAndDiscoveryURISuccessLabel.textColor = UIColor.redColor()
        tokenAndDiscoveryURISuccessLabel.text = "Waiting for token and discovery URI!"
    }
    
    // Hide Keyboard on return.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    //MARK: SfBAlertDelegate alert function
    func didReceiveAlert(alert: SfBAlert) {
       alert.showSfBAlertInController(self)
    }
    
    func controller(controller: MicrosoftLicenseViewController, didAcceptLicense acceptedLicense: Bool) {
        if(acceptedLicense){
            if let sfb = self.sfb{
                let config = sfb.configurationManager
                config.setEndUserAcceptedVideoLicense()
                if(didJoinMeeting()){
                    self.performSegueWithIdentifier("joinOnlineAudioVideoChat", sender: nil)
                }
            }
        }
    }
    
}
