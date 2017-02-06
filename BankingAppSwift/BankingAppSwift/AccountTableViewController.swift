//
//  AccountTableViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/16/16.
// Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
// See LICENSE in the project root for license information.
//

import UIKit

class AccountTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        self.navigationItem.prompt = dateFormatter.stringFromDate(NSDate())
}

    @IBAction func logOff(sender: AnyObject) {
     
        self.parentViewController?.navigationController?.setNavigationBarHidden(false, animated: false)
        self.parentViewController?.navigationController?.popViewControllerAnimated(true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
}
