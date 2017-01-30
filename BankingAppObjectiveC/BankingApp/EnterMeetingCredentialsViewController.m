//
//  EnterMeetingCredentialsViewController.m
//  BankingApp
//
//  Created by Aasveen Kaur on 1/18/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//

#import "EnterMeetingCredentialsViewController.h"
#import "Util.h"

@interface EnterMeetingCredentialsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *meetingDisplayName;
@property (weak, nonatomic) IBOutlet UITextField *meetingUrl;

@end

@implementation EnterMeetingCredentialsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.meetingDisplayName.delegate = self;
    self.meetingUrl.delegate = self;
    [self showCurrentMeetingUrlAndDisplayName];
    // Do any additional setup after loading the view.
}

-(void)showCurrentMeetingUrlAndDisplayName{
   
    if([[NSUserDefaults standardUserDefaults] objectForKey:@USER_MEETING_URL] != nil){
        _meetingUrl.text = [[NSUserDefaults standardUserDefaults] objectForKey:@USER_MEETING_URL];
    }
    else{
        _meetingUrl.text = _meetingUrl.placeholder;
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@USER_DISPLAY_NAME] != nil){
        _meetingDisplayName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@USER_DISPLAY_NAME];
    }
    else{
        _meetingDisplayName.text = _meetingDisplayName.placeholder;
    }
    
}
- (IBAction)okButtonPressed:(id)sender {
    [self hideKeyboard];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Save Skype display name and meeting url.
    if (([self checkIfTextFieldHasText:_meetingUrl]) && !([_meetingUrl.text isEqualToString:_meetingUrl.placeholder])) {
        if (([self checkIfTextFieldHasText:_meetingDisplayName]) && !([_meetingDisplayName.text isEqualToString:_meetingDisplayName.placeholder])) {
            [prefs setObject:_meetingDisplayName.text forKey:@USER_DISPLAY_NAME];
        }
        [prefs setObject:_meetingUrl.text forKey:@USER_MEETING_URL];
        [prefs synchronize];
        
        // show saved message and dismiss EnterMeetingCredentialsViewController
       UIAlertController*   alertController =    [UIAlertController
                                                alertControllerWithTitle:@"SAVED!"
                                                message:nil
                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alertController addAction:ok];
       
        [self presentViewController:alertController animated:YES completion:nil];
    }

}

#pragma mark - Text field handlers

-(void)hideKeyboard{
    if(self.meetingDisplayName.isFirstResponder){
        [self.meetingDisplayName resignFirstResponder];
    }else if(self.meetingUrl.isFirstResponder){
        [self.meetingUrl resignFirstResponder];
    }
}

-(bool)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:true];
    return false;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField.text isEqualToString:textField.placeholder]){
        textField.placeholder = @"";
        textField.text = @"";
    }
}

-(bool)checkIfTextFieldHasText:(UITextField*)textField{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [textField.text stringByTrimmingCharactersInSet:charSet];
    if ([trimmedString isEqualToString:@""]) {
        // it's empty or contains only white spaces
        return false;
    }
    return true;
}

#pragma mark - Hide status bar

-(bool)prefersStatusBarHidden{
    return true;
}

@end
