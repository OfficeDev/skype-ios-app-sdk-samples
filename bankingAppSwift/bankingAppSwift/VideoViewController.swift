//
//  VideoViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/9/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
//

import UIKit
import GLKit

class VideoViewController: UIViewController,SfBConversationHelperDelegate {

    @IBOutlet weak var infoBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoBar: UIView!
    @IBOutlet weak var participantVideoView: GLKView!
    @IBOutlet weak var selfVideoView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var endCallButton: UIButton!
    
    var conversationHelper:SfBConversationHelper?
    let DisplayNameInfo:String = "displayName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
         // Hide back button of UINavigation
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // Set date label to current times
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        self.dateLabel.text = dateFormatter.stringFromDate(NSDate())
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.infoBarBottomConstraint.constant = -90;
        
    }
    
    /**
     *  Initialize UI.
     *  Bring information bar from bottom to the visible area of the screen.
     */
    
    override func viewDidAppear(animated: Bool) {
        self.initializeUI()
        self.joinMeeting()
    }
    
    /**
     *  Initialize UI.
     *  Bring information bar from bottom to the visible area of the screen.
     */
    
    func initializeUI()  {
        self.infoBarBottomConstraint.constant = 0
        UIView.animateWithDuration(0.5) { 
        self.infoBar.layoutIfNeeded()
        }
    }
    
    /**
     *  Joins a Skype meeting.
     */
    func joinMeeting() {
        var error: NSError?
        
        let meetingURLString:String = NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting URL")
        let meetingDisplayName:String = NSBundle.mainBundle().objectForInfoDictionaryKey("Skype meeting display name")
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
