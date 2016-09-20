/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

class MainViewController: UIViewController,SfBAlertDelegate {

    @IBOutlet weak var askAgentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self .initializeSkype()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func askAgent(_ sender: AnyObject) {
        let alertController:UIAlertController = UIAlertController(title: "Ask Agent", message: nil, preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Ask using Text Chat", style: .default, handler: { (action:UIAlertAction) in
            self.askAgentText()
        }))
        
        alertController.addAction(UIAlertAction(title: "Ask using Video Chat", style: .default, handler: { (action:UIAlertAction) in
            self.askAgentVideo()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
        }
        self.present(alertController, animated: true, completion: nil)
        
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askAgentText()  {
        self.performSegue(withIdentifier: "askAgentText", sender: nil)
    }
    
    func askAgentVideo()  {
        self.performSegue(withIdentifier: "askAgentVideo", sender: nil)
    }
    
    func initializeSkype(){
        let sfb:SfBApplication? = SfBApplication.shared()
        
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 1
            sfb.configurationManager.requireWifiForAudio = false
            sfb.configurationManager.requireWifiForVideo = false
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .loudspeaker
            sfb.alertDelegate = self
        }
        
    }
   
    //MARK - Sfb Alert Delegate
    
    func didReceive(_ alert: SfBAlert) {
        
        alert.show()
    }


}
