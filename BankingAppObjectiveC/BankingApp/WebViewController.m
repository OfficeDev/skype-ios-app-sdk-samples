//
//  WebViewController.m
//  BankingApp
//
//  Created by Aasveen Kaur on 2/23/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myActivityIndicator;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _myWebView.delegate = self;
   NSString *urlString = @"https://msdn.microsoft.com/en-us/skype/appsdk/gettingstarted#next-steps";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_myWebView loadRequest:urlRequest];

}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_myWebView.isLoading)
        return;
        
        [_myActivityIndicator stopAnimating];
    
}

@end
