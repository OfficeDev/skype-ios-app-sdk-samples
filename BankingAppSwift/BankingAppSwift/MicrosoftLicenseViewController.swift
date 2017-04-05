//
//  MicrosoftLicenseViewController.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 2/13/17.
//  Copyright © 2017 Aasveen Kaur. All rights reserved.
//

import UIKit

protocol MicrosoftLicenseViewControllerDelegate {
    func controller(_ controller: MicrosoftLicenseViewController , didAcceptLicense acceptedLicense:Bool)
}

class MicrosoftLicenseViewController: UIViewController,UIWebViewDelegate  {
    var delegate: MicrosoftLicenseViewControllerDelegate?
    var request:URLRequest?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var microsoftLicensePDFWebView: UIWebView!
    
    @IBAction func licenseAccepted(_ sender: AnyObject) {
        let key = "AcceptedVideoLicense"
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: key)
        delegate?.controller(self, didAcceptLicense: true)
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        microsoftLicensePDFWebView.delegate = self
        if let licensePDFPath = Bundle.main.url(forResource: "Skype for Business App SDK Codec End User License Terms", withExtension: "pdf"){
             request = URLRequest(url: licensePDFPath)
            
            
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        microsoftLicensePDFWebView.loadRequest(request!)
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if (microsoftLicensePDFWebView.isLoading){
            return
        }
        loadingIndicator.stopAnimating()
        
    }
    
    
    
}
