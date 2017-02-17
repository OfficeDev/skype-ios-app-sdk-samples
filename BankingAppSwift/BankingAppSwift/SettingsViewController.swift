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

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var SfBOnlineSwitch: UISwitch!
    @IBOutlet weak var enablePreviewSwitch: UISwitch!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    @IBAction func skypeForBusinessOnlineValueChangeAction(sender: AnyObject) {
        
        if SfBOnlineSwitch.on {
            defaults.setBool(true, forKey:SFB_ONLINE_MEETING_STATE)
        } else {
            defaults.setBool(false, forKey:SFB_ONLINE_MEETING_STATE)
        }
        defaults.synchronize()
        
    }
    @IBAction func enablePreviewValueChangeAction(sender: AnyObject) {
        if enablePreviewSwitch.on {
            defaults.setBool(true, forKey: ENABLE_PREVIEW_STATE)
        } else {
            defaults.setBool(false, forKey: ENABLE_PREVIEW_STATE)
        }
        defaults.synchronize()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SfBOnlineSwitch.tintColor = UIColor.whiteColor()
        self.enablePreviewSwitch.tintColor = UIColor.whiteColor()
        
        if let SfBOnlineSwitchState:Bool = defaults.objectForKey(SFB_ONLINE_MEETING_STATE) as? Bool {
            self.SfBOnlineSwitch.on = SfBOnlineSwitchState
        }
        if let enablePreviewSwitchState:Bool = defaults.objectForKey(ENABLE_PREVIEW_STATE) as? Bool {
            self.enablePreviewSwitch.on = enablePreviewSwitchState
        }
    }
    
    
}
