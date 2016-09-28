/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var credentialTextFields: [UITextField]!
    @IBOutlet weak var addURLButton: UIButton!
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        
        super.viewDidLoad()
        
        credentialTextFields[0].delegate = self
        credentialTextFields[1].delegate = self
        
        self.addSwipeGesturesInDirection(UISwipeGestureRecognizerDirection.down)
        self.addSwipeGesturesInDirection(UISwipeGestureRecognizerDirection.up)
    }
    
    // Hide Keyboard on return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Handle Swipe Gestures
    func addSwipeGesturesInDirection(_ swipeDirection:UISwipeGestureRecognizerDirection)  {
        
        let swipeAction = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.respondToSwipeGesture(_:)))
        swipeAction.direction = swipeDirection
        self.view.addGestureRecognizer(swipeAction)
    }
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.down:
                
                self.showButtonWithAnimation(.curveEaseIn, button: self.addURLButton, alphaValue: 1, hiddenStatus: false)
                
            case UISwipeGestureRecognizerDirection.up:
                
                self.showButtonWithAnimation(.curveEaseOut, button: self.addURLButton, alphaValue: 0, hiddenStatus: true)
                
            default:
                break
            }
        }
    }
    
    // Show and hide AddURL button with animation.
    func showButtonWithAnimation(_ options:UIViewAnimationOptions, button:UIButton, alphaValue:CGFloat, hiddenStatus:Bool)  {
        UIView.animate(withDuration: 0.2, delay: 0.0, options:options, animations: {
            if(hiddenStatus == false){
                button.alpha = alphaValue
                button.isHidden = hiddenStatus
            }
            else{
                button.alpha = alphaValue
            }
            }, completion:  { (Bool) in
                if(hiddenStatus == true){
                    button.isHidden = true
                }
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prepareForUnwind(_ segue:UIStoryboardSegue){
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.addURLButton.isHidden = true
        self.addURLButton.alpha = 0
    }
}
