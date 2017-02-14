//
//  MicrosoftLicenseViewController.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 2/13/17.
//  Copyright © 2017 Aasveen Kaur. All rights reserved.
//

import UIKit

protocol MicrosoftLicenseViewControllerDelegate {
    func controller(controller: MicrosoftLicenseViewController , didAcceptLicense acceptedLicense:Bool)
}

class MicrosoftLicenseViewController: UIViewController {
    var delegate: MicrosoftLicenseViewControllerDelegate?
    var request:NSURLRequest?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBAction func closeButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var microsoftLicensePDFWebView: UIWebView!
    
    @IBAction func licenseAccepted(sender: AnyObject) {
        let key = "AcceptedVideoLicense"
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: key)
        delegate?.controller(self, didAcceptLicense: true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let licensePDFPath = NSBundle.mainBundle().URLForResource("Skype for Business App SDK Codec End User License Terms", withExtension: "pdf"){
             request = NSURLRequest(URL: licensePDFPath)
            
            
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        microsoftLicensePDFWebView.loadRequest(request!)
        loadingIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
