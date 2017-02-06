//
//  LoginViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/9/16.
// Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
// See LICENSE in the project root for license information.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var credentialTextFields: [UITextField]!
    @IBOutlet weak var addURLButton: UIButton!
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        
        super.viewDidLoad()
        
        credentialTextFields[0].delegate = self
        credentialTextFields[1].delegate = self
        
        self.addSwipeGesturesInDirection(UISwipeGestureRecognizerDirection.Down)
        self.addSwipeGesturesInDirection(UISwipeGestureRecognizerDirection.Up)
    }
    
    // Hide Keyboard on return.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Handle Swipe Gestures
    func addSwipeGesturesInDirection(swipeDirection:UISwipeGestureRecognizerDirection)  {
        
        let swipeAction = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.respondToSwipeGesture(_:)))
        swipeAction.direction = swipeDirection
        self.view.addGestureRecognizer(swipeAction)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Down:
                
                self.showButtonWithAnimation(.CurveEaseIn, button: self.addURLButton, alphaValue: 1, hiddenStatus: false)
                
            case UISwipeGestureRecognizerDirection.Up:
                
                self.showButtonWithAnimation(.CurveEaseOut, button: self.addURLButton, alphaValue: 0, hiddenStatus: true)
                
            default:
                break
            }
        }
    }
    
    // Show and hide AddURL button with animation.
    func showButtonWithAnimation(options:UIViewAnimationOptions, button:UIButton, alphaValue:CGFloat, hiddenStatus:Bool)  {
        UIView.animateWithDuration(0.2, delay: 0.0, options:options, animations: {
            if(hiddenStatus == false){
                button.alpha = alphaValue
                button.hidden = hiddenStatus
            }
            else{
                button.alpha = alphaValue
            }
            }, completion:  { (Bool) in
                if(hiddenStatus == true){
                    button.hidden = true
                }
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue){
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.addURLButton.hidden = true
        self.addURLButton.alpha = 0
    }
}
