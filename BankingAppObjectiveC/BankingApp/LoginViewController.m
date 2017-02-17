/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "LoginViewController.h"
#import "Util.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *credentialTextFields;
@property (weak, nonatomic) IBOutlet UIButton *addURLButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@end

@implementation LoginViewController
- (IBAction)signInButtonPressed:(id)sender {
    /* Online meeting with enable preview = FALSE, chat/AV will work only WITH Trusted application API service app. Use func joinMeetingAnonymousWithDiscoverUrl(discoverUrl: NSURL, authToken: String, displayName: String)
     */
    if(([Util getSfBOnlineSwitchState] == YES) && ([Util getEnablePreviewSwitchState] == NO)){
        [self performSegueWithIdentifier:@"segueToOnlineMeetingSceneFromLoginScene" sender:nil];
    }
    /*Onprem CU4/Onprem CU3/Online-enable preview = True.
     Use func joinMeetingAnonymousWithUri(meetingUri: NSURL, displayName: String)
     */
    else{
        [self performSegueWithIdentifier:@"segueToMainSceneFromLoginScene" sender:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _addURLButton.titleLabel.textAlignment = NSTextAlignmentCenter;
     _settingsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    for (UITextField *textField in _credentialTextFields) {
        textField.delegate = self;
    }
    
    // Do any additional setup after loading the view.
}

-(bool)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"Called unwind action");
}

@end

