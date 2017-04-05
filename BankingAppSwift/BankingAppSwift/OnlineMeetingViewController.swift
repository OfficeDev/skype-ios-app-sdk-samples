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
    /** Called when new alert appears in the context where this delegate is attached.
     *
     * Each alert is passed to a delegate once and dismissed unconditionally.
     * If no delegate is attached, alerts are accumulated and reported as soon
     * as delegate is set. Accumulated alerts of the same category and type
     * are coalesced, only the last one will be reported.
     */

    
    var sfb: SfBApplication?
    fileprivate var conversation: SfBConversation?
    fileprivate var token: String?
    fileprivate var discoveryURI: String?
    
    @IBOutlet var meetingUrl: UITextView!
    @IBOutlet var displayName: UITextField!
    @IBOutlet var join: UIButton!
    @IBOutlet var tokenAndDiscoveryURISuccessLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorForServiceApplicationResponse: UIActivityIndicatorView!
    //MARK: Lifecycle and helper functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI
        join.titleLabel?.textAlignment = NSTextAlignment.center
        displayName.text = getMeetingDisplayName
        displayName.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // First POST request to fetch meeting URL
        sendPostRequestForMeetingURL()
        
    }
    
    //MARK:Send POST requests for online meeting call flow functions
    //  POST request to fetch ad hoc Meeting URL
    func sendPostRequestForMeetingURL(){
        
        // request to Trusted Application API Service Application endpoint
        if let url = URL(string: getOnlineMeetingRequestURL){
        let meetingUrlRequest = NSMutableURLRequest(url: url)
        meetingUrlRequest.httpMethod = "POST"
        meetingUrlRequest.httpBody = "Subject=adhocMeeting&Description=adhocMeeting&AccessLevel=".data(using: String.Encoding.utf8)
        
        SendHttpRequest(meetingUrlRequest as URLRequest) { (data, error) in
            DispatchQueue.main.async {
                do {
                    guard error == nil, let data = data else {
                        throw error!
                    }
                    
                    let json = try  JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
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
         if let url = URL(string: getTokenAndDiscoveryURIRequestURL){
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        let meetintURL = meetingUrl.text!;
        request.httpBody = "ApplicationSessionId=AnonMeeting&AllowedOrigins=http%3a%2f%2flocalhost%2f&MeetingUrl=\(meetintURL)".data(using: String.Encoding.utf8)
        
        join.isEnabled = false
        SendHttpRequest(request as URLRequest) { (data, error) in
            DispatchQueue.main.async {
                do {
                    guard error == nil, let data = data else {
                        throw error!
                    }
                    
                    let json = try  JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
                    self.discoveryURI = json["DiscoverUri"]!
                    self.tokenAndDiscoveryURISuccessLabel.textColor = UIColor.darkGray
                    self.tokenAndDiscoveryURISuccessLabel.text = "Success! Please join online meeting"
                    self.token = json["Token"]
                    self.join.isEnabled = true
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
    func SendHttpRequest(_ request:URLRequest, withBlock completionHandler:  @escaping completionBlock) {
        let  sessionObject: URLSession = URLSession.shared
        let task = sessionObject.dataTask(with: request, completionHandler: {  (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            print("statusCode-aas>\(statusCode)")
            
            if (statusCode == 200 ) {
                
                completionHandler(data, nil)
                
            }
                
            else{
                if(error == nil){
                    let error:NSError = NSError(domain: "statusCode -\(statusCode)!", code: statusCode!, userInfo:nil)
                    completionHandler(nil,error as NSError?)
                }
                else {
                    completionHandler(nil,error as NSError?)
                }
                
            }
        }) 
        
        task.resume()
    }
    
    //MARK: User button actions
    // press "Join online meeting" button to join text or video online meeting
    @IBAction func JoinOnlineMeetingPressed(_ sender: AnyObject) {
        let alertController:UIAlertController = UIAlertController(title: "Join online meeting", message: nil, preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Join online chat", style: .default, handler: { (action:UIAlertAction) in
            self.joinOnlineChat()
        }))
        
        alertController.addAction(UIAlertAction(title: "Join online video chat", style: .default, handler: { (action:UIAlertAction) in
            self.joinOnlineVideoChat()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func joinOnlineChat()  {
        if(didJoinMeeting()){
            self.performSegue(withIdentifier: "joinOnlineChat", sender: nil)
        }
    }
    
    func joinOnlineVideoChat()  {
        
        
        if let sfb = sfb{
            let config = sfb.configurationManager
            let key = "AcceptedVideoLicense"
            let defaults = UserDefaults.standard
            
            if defaults.bool(forKey: key) {
                config.setEndUserAcceptedVideoLicense()
                if(didJoinMeeting()){
                    self.performSegue(withIdentifier: "joinOnlineAudioVideoChat", sender: nil)
                }
                
            } else {
                
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrosoftLicenseViewController") as! MicrosoftLicenseViewController
                vc.delegate = self
                
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        
        
        
    }
    
    //MARK: Join online meeting anonymous with discover URI and token function
    
    func didJoinMeeting() -> Bool {
        do {
            
            let session = try sfb!.joinMeetingAnonymous(withDiscover: URL(string: discoveryURI!)!, authToken: token!, displayName: displayName.text!)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "joinOnlineChat"){
            guard let destination = segue.destination as? ChatViewController else {
                return
            }
            destination.conversation = self.conversation
            
        }
        else if(segue.identifier == "joinOnlineAudioVideoChat"){
            guard let destination = segue.destination as? VideoViewController else {
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
    override func viewDidDisappear(_ animated: Bool) {
        displayName.text = displayName.placeholder
        meetingUrl.textColor = UIColor.red
        meetingUrl.text = "Waiting for online meeting URL!"
        tokenAndDiscoveryURISuccessLabel.textColor = UIColor.red
        tokenAndDiscoveryURISuccessLabel.text = "Waiting for token and discovery URI!"
    }
    
    // Hide Keyboard on return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    //MARK: SfBAlertDelegate alert function
    func didReceive(_ alert: SfBAlert) {
       alert.showSfBAlertInController(self)
    }
    
    func controller(_ controller: MicrosoftLicenseViewController, didAcceptLicense acceptedLicense: Bool) {
        if(acceptedLicense){
            if let sfb = self.sfb{
                let config = sfb.configurationManager
                config.setEndUserAcceptedVideoLicense()
                if(didJoinMeeting()){
                    self.performSegue(withIdentifier: "joinOnlineAudioVideoChat", sender: nil)
                }
            }
        }
    }
    
}
