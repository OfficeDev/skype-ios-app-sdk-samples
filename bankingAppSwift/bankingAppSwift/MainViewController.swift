//
//  MainViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/9/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var askAgentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self .initializeSkype()

        // Do any additional setup after loading the view.
    }

    @IBAction func askAgent(sender: AnyObject) {
        let alertController:UIAlertController = UIAlertController(title: "Ask agent", message: nil, preferredStyle: .ActionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Ask using Text Chat", style: .Default, handler: { (action:UIAlertAction) in
            self.askAgentText()
        }))
        
        alertController.addAction(UIAlertAction(title: "Ask using Video Chat", style: .Default, handler: { (action:UIAlertAction) in
            self.askAgentVideo()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
     presentViewController(alertController, animated: true, completion:nil)
        
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askAgentText()  {
        self.performSegueWithIdentifier("askAgentText", sender: nil)
    }
    
    func askAgentVideo()  {
        self.performSegueWithIdentifier("askAgentVideo", sender: nil)
    }
    
    func initializeSkype(){
        let sfb:SfBApplication? = SfBApplication.sharedApplication()
        if let sfb = sfb{
        sfb.configurationManager.maxVideoChannels = 1
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .Loudspeaker
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
