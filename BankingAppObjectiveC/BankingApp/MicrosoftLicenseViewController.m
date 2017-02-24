//
//  MicrosoftLicenseViewController.m
//  BankingApp
//
//  Created by Aasveen Kaur on 2/14/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//

#import "MicrosoftLicenseViewController.h"



@interface MicrosoftLicenseViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIWebView *microsoftLicensePDFWebView;

@end

@implementation MicrosoftLicenseViewController
    NSURLRequest* request;
- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)licenseAccepted:(id)sender {
    NSString *key = @"AcceptedVideoLicense";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:key];
    [self.delegate controller:self didAcceptLicense:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
            _microsoftLicensePDFWebView.delegate = self;
    if( [[NSBundle mainBundle] URLForResource:@"Skype for Business App SDK Codec End User License Terms" withExtension:@"pdf"] != nil){
        request = [[NSURLRequest alloc]initWithURL:[[NSBundle mainBundle] URLForResource:@"Skype for Business App SDK Codec End User License Terms" withExtension:@"pdf"]];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [_microsoftLicensePDFWebView loadRequest:request];
    
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_microsoftLicensePDFWebView.isLoading)
        return
    
    [_loadingIndicator stopAnimating];

}
@end
