//
//  WebViewController.swift
//  BankingAppSwift
//
//  Created by Aasveen Kaur on 2/23/17.
//  Copyright © 2017 Aasveen Kaur. All rights reserved.
//

import UIKit

class WebViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myWebView.delegate = self
        let fullURL = "https://msdn.microsoft.com/en-us/skype/appsdk/gettingstarted#next-steps"
        let url = NSURL(string:fullURL)
        let request = NSURLRequest(URL: url!)
        myWebView.loadRequest(request)
        
        // Do any additional setup after loading the view.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if (myWebView.loading){
        return
        }
       myActivityIndicator.stopAnimating()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
