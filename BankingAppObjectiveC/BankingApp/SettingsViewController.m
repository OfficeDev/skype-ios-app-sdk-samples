//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: SettingsViewController.m
//+----------------------------------------------------------------

#import "SettingsViewController.h"
#import "Util.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *SfBOnlineSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *enablePreviewSwitch;
@property (weak, nonatomic) IBOutlet UITextField *meetingDisplayName;
@property (weak, nonatomic) IBOutlet UITextField *meetingUrl;
@property (weak, nonatomic) IBOutlet UITextField *TokenAndDiscoveryRequestAPIUrl;
@property (weak, nonatomic) IBOutlet UITextField *meetingRequestAPIUrl;

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIView *contentView;



@end

@implementation SettingsViewController

- (IBAction)saveSettings:(id)sender{
    [self saveSkypeForBusinessOnlineValueChange];
    [self  saveEnablePreviewValueChange];
    [self saveSettings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveSkypeForBusinessOnlineValueChange{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(_SfBOnlineSwitch.on){
        [defaults setBool:YES forKey:@SFB_ONLINE_MEETING_STATE];
        
    }else{
        [defaults setBool:NO forKey:@SFB_ONLINE_MEETING_STATE];
    }
    [defaults synchronize];
}

-(void)saveEnablePreviewValueChange{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(_enablePreviewSwitch.on){
        [defaults setBool:YES forKey:@ENABLE_PREVIEW_STATE];
        
    }else{
        [defaults setBool:NO forKey:@ENABLE_PREVIEW_STATE];
    }
    [defaults synchronize];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    self.scroller.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.meetingDisplayName.delegate = self;
    self.meetingUrl.delegate = self;
    self.meetingRequestAPIUrl.delegate = self;
    self.TokenAndDiscoveryRequestAPIUrl.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.SfBOnlineSwitch.tintColor = [UIColor whiteColor];
    self.enablePreviewSwitch.tintColor = [UIColor whiteColor];
    
    if([defaults objectForKey:@SFB_ONLINE_MEETING_STATE ] != nil){
        self.SfBOnlineSwitch.on = [defaults boolForKey:@SFB_ONLINE_MEETING_STATE ];
    }
    if([defaults objectForKey:@ENABLE_PREVIEW_STATE ] != nil){
        self.enablePreviewSwitch.on = [defaults boolForKey:@ENABLE_PREVIEW_STATE ];
        
    }
    [self showCurrentMeetingUrlAndDisplayName];
    // Do any additional setup after loading the view.
}

// Display saved meeting url on screen
- (void)showCurrentMeetingUrlAndDisplayName{
    if(![[Util getMeetingURLString]  isEqualToString: @"SkypeMeetingUrl"]){
        _meetingUrl.text = [Util getMeetingURLString] ;
    }
    if(![[Util getMeetingDisplayName]  isEqualToString: @"SkypeDisplayName"]){
        _meetingDisplayName.text = [Util getMeetingDisplayName] ;
    }
    if(![[Util getTokenAndDiscoveryURIRequestURL]  isEqualToString: @"TokenAndDiscoveryURIRequestAPIURL"]){
        _TokenAndDiscoveryRequestAPIUrl.text = [Util getTokenAndDiscoveryURIRequestURL] ;
    }
    if(![[Util getOnlineMeetingRequestURL]  isEqualToString: @"OnlineMeetingRequestAPIURL"]){
        _meetingRequestAPIUrl.text = [Util getOnlineMeetingRequestURL] ;
    }
    
}

- (void)saveSettings{
    [self hideKeyboard];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Save Skype display name and meeting url.
    if ([self checkIfTextFieldHasText:_meetingUrl] && (![_meetingUrl.text isEqualToString:_meetingUrl.placeholder]))
    {
       [prefs setObject:_meetingUrl.text forKey:@USER_MEETING_URL];
    }
    if (([self checkIfTextFieldHasText:_meetingDisplayName]) && !([_meetingDisplayName.text isEqualToString:_meetingDisplayName.placeholder])) {
        [prefs setObject:_meetingDisplayName.text forKey:@USER_DISPLAY_NAME];
    }
    if (([self checkIfTextFieldHasText:_TokenAndDiscoveryRequestAPIUrl]) && !([_TokenAndDiscoveryRequestAPIUrl.text isEqualToString:_TokenAndDiscoveryRequestAPIUrl.placeholder])) {
        [prefs setObject:_TokenAndDiscoveryRequestAPIUrl.text forKey:@TOKEN_AND_DISCOVERY_API_URL];
    }
    if (([self checkIfTextFieldHasText:_meetingRequestAPIUrl]) && !([_meetingRequestAPIUrl.text isEqualToString:_meetingRequestAPIUrl.placeholder])) {
        [prefs setObject:_meetingRequestAPIUrl.text forKey:@ONLINE_MEETING_REQUEST_API_URL];
    }
    
   
    [prefs synchronize ];

}

#pragma mark - Text field handlers

-(void)hideKeyboard{
    if(self.meetingDisplayName.isFirstResponder){
        [self.meetingDisplayName resignFirstResponder];
    }else if(self.meetingUrl.isFirstResponder){
        [self.meetingUrl resignFirstResponder];
    }else if(self.meetingRequestAPIUrl.isFirstResponder) {
        [self.meetingRequestAPIUrl resignFirstResponder];
    }else if(self.TokenAndDiscoveryRequestAPIUrl.isFirstResponder) {
        [self.TokenAndDiscoveryRequestAPIUrl resignFirstResponder];
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

    //MARK: - Scroll screen on keyboard show/hide
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if(self.view.frame.origin.y == 0){
        CGRect f = self.view.frame;
        f.origin.y -= keyboardFrame.size.height;
        self.view.frame = f;
    }
    
    
    
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if(self.view.frame.origin.y != 0){
        CGRect f = self.view.frame;
        f.origin.y += keyboardFrame.size.height;
        self.view.frame = f;
    }

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"Called unwind action");
}


@end
