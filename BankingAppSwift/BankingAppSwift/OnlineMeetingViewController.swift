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

// Trusted Application API Service Application's endpoints
let TOKEN_AND_DISCOVERYURI_REQUEST_URL = "https://metiobank.cloudapp.net/GetAnonTokenJob"
let MEETING_URL_REQUEST_URL = "https://imbridge.cloudapp.net/GetAdhocMeetingJob"

typealias completionBlock = (   data: NSData?, error: NSError?) -> Void

import Foundation
import UIKit
import SkypeForBusiness


class OnlineMeetingViewController: UIViewController, SfBAlertDelegate,UITextFieldDelegate {
    
    private var kvo = 0
    
    private var sfb: SfBApplication?
    private var conversation: SfBConversation?
    private var token: String?
    private var discoveryURI: String?
    
    @IBOutlet var meetingUrl: UITextView!
    @IBOutlet var displayName: UITextField!
    @IBOutlet var join: UIButton!
    @IBOutlet var tokenAndDiscoveryURISuccessLabel: UILabel!
    
     //MARK: Lifecycle and helper functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Shared application instance for Online meeting
        sfb = SfBApplication.sharedApplication()
        
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 1
            sfb.configurationManager.requireWifiForAudio = false
            sfb.configurationManager.requireWifiForVideo = false
            sfb.alertDelegate = self
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .Loudspeaker
            
            // For OnPrem topolgies enablePreview features should be enabled for Audio/Video.
            sfb.configurationManager.enablePreviewFeatures = false
            
        }
        // Setup UI
        join.titleLabel?.textAlignment = NSTextAlignment.Center
        displayName.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        // First POST request to fetch meeting URL
        sendPostRequestForMeetingURL()
        
    }
    
     //MARK:Send POST requests for online meeting call flow functions
    //  POST request to fetch ad hoc Meeting URL
    func sendPostRequestForMeetingURL(){
        
        // request to Trusted Application API Service Application endpoint
        let meetingUrlRequest = NSMutableURLRequest(URL: NSURL(string: MEETING_URL_REQUEST_URL)!)
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
                    UIAlertView(title: "Getting meeting URL failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
                }
                
                
            }
        }
    }
    
    //  POST request to get token and discovery URI based on response meeting URL
    func sendPostRequestForTokenAndDiscoveryURI()  {
        
        // request to Trusted Application API Service Application endpoint
        let request = NSMutableURLRequest(URL: NSURL(string: TOKEN_AND_DISCOVERYURI_REQUEST_URL)!)
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
                    print("Successful! token and discovery URI>> \(json["Token"]),\(json["DiscoverUri"])");
                    
                } catch {
                    print("ERROR! Getting token and discovery URI failed>\(error)")
                    UIAlertView(title: "Getting Discover URI failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
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
            print("statusCode->\(statusCode)")
            
            if (statusCode! == 200 ) {
                
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
    
    //MARK: Join online meeting anonymous with discover URI and token function
    
    func shouldJoinMeeting() -> Bool {
        do {
            
            let session = try sfb!.joinMeetingAnonymousWithDiscoverUrl(NSURL(string: discoveryURI!)!, authToken: token!, displayName: displayName.text!)
            conversation = session.conversation
            conversation?.alertDelegate = self
            return true
        } catch {
            print("ERROR! Joining online meeting>\(error)")
            UIAlertView(title: "Joining online meeting failed", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
            return false
        }
    }
    
    //MARK: SfBAlertDelegate alert function
    func didReceiveAlert(alert: SfBAlert) {
        alert.show()
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
        if(shouldJoinMeeting()){
            self.performSegueWithIdentifier("joinOnlineChat", sender: nil)
        }
    }
    
    func joinOnlineVideoChat()  {
        if(shouldJoinMeeting()){
            self.performSegueWithIdentifier("joinOnlineAudioVideoChat", sender: nil)
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
            conversation = nil
            discoveryURI = nil
            token = nil
            
        }
        
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
    
}
