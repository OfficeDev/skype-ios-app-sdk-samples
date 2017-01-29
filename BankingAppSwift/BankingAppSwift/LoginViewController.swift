//
//  LoginViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/9/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
//

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
        
        //self.addSwipeGesturesInDirection(UISwipeGestureRecognizerDirection.Down)
        //self.addSwipeGesturesInDirection(UISwipeGestureRecognizerDirection.Up)
    }
    
    // Hide Keyboard on return.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //    //MARK: - Handle Swipe Gestures
    //    func addSwipeGesturesInDirection(swipeDirection:UISwipeGestureRecognizerDirection)  {
    //
    //        let swipeAction = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.respondToSwipeGesture(_:)))
    //        swipeAction.direction = swipeDirection
    //        self.view.addGestureRecognizer(swipeAction)
    //    }
    //
    //    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
    //
    //        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
    //
    //            switch swipeGesture.direction {
    //
    //            case UISwipeGestureRecognizerDirection.Down:
    //
    //                self.showButtonWithAnimation(.CurveEaseIn, button: self.addURLButton, alphaValue: 1, hiddenStatus: false)
    //
    //            case UISwipeGestureRecognizerDirection.Up:
    //
    //                self.showButtonWithAnimation(.CurveEaseOut, button: self.addURLButton, alphaValue: 0, hiddenStatus: true)
    //
    //            default:
    //                break
    //            }
    //        }
    //    }
    
    //    // Show and hide AddURL button with animation.
    //    func showButtonWithAnimation(options:UIViewAnimationOptions, button:UIButton, alphaValue:CGFloat, hiddenStatus:Bool)  {
    //        UIView.animateWithDuration(0.2, delay: 0.0, options:options, animations: {
    //            if(hiddenStatus == false){
    //                button.alpha = alphaValue
    //                button.hidden = hiddenStatus
    //            }
    //            else{
    //                button.alpha = alphaValue
    //            }
    //            }, completion:  { (Bool) in
    //                if(hiddenStatus == true){
    //                    button.hidden = true
    //                }
    //        })
    //
    //    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue){
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        //self.addURLButton.hidden = true
        //self.addURLButton.alpha = 0
    }
}
