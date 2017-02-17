/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "MainViewController.h"
#import "ChatViewController.h"
#import "VideoViewController.h"
#import "Util.h"


@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UIButton *askAgentButton;
@end

@implementation MainViewController
SfBConversation* mainConversation;
SfBApplication * mainSfb;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSkype];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)askAgent:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ask agent" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ask using Text Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self askAgentText];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ask using Video Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self askAgentVideo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
 UIPopoverPresentationController *popoverController =  alertController.popoverPresentationController;
    if(popoverController != nil){
        popoverController.sourceView = sender;
        popoverController.sourceRect = sender.bounds;
        
    }
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    

}

- (void)askAgentVideo {
    
    SfBConfigurationManager *config = mainSfb.configurationManager;
    NSString *key = @"AcceptedVideoLicense";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   
    if([defaults boolForKey:key]){
        [config setEndUserAcceptedVideoLicense];
        if([self didJoinMeeting]){
            [self performSegueWithIdentifier:@"askAgentVideo" sender:nil];
        }
    }else{
        MicrosoftLicenseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MicrosoftLicenseViewController"];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)askAgentText {
     if([self didJoinMeeting]){
    [self performSegueWithIdentifier:@"askAgentText" sender:nil];
     }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveAlert:(SfBAlert *)alert{
    [alert showSfBAlertInController:self];
}


/**
 *  Initialize Skype
 */
- (void)initializeSkype {
    mainSfb = SfBApplication.sharedApplication;
    mainSfb.configurationManager.maxVideoChannels = 1;
    mainSfb.configurationManager.requireWifiForAudio = false;
    mainSfb.configurationManager.requireWifiForVideo = false;
    mainSfb.devicesManager.selectedSpeaker.activeEndpoint = SfBSpeakerEndpointLoudspeaker;
    mainSfb.configurationManager.enablePreviewFeatures = [Util getEnablePreviewSwitchState];
    mainSfb.alertDelegate = self;
}

-(bool)didJoinMeeting{
    
    NSError *error = nil;
    NSString *meetingURLString =  [Util getMeetingURLString];
    NSString *meetingDisplayName = [Util getMeetingDisplayName];
  
        mainConversation = [mainSfb joinMeetingAnonymousWithUri:[NSURL URLWithString:meetingURLString]
                                                             displayName:meetingDisplayName
                                                                   error:&error].conversation;
    
        if (mainConversation) {
            return true;
        } else {
            [Util showErrorAlert:error inView:self ];
        }
    return false;
}

#pragma mark -Segue navigation functions
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"askAgentText"]){
        ChatViewController* destination = segue.destinationViewController;
        destination.conversation = mainConversation;
        
       
    }
    else if([segue.identifier isEqualToString:@"askAgentVideo"]){
        VideoViewController* destination = segue.destinationViewController;
        destination.deviceManagerInstance = mainSfb.devicesManager;
        destination.conversationInstance = mainConversation;
        destination.displayName = [Util getMeetingDisplayName];
       
    }
     mainConversation = nil;
}

#pragma mark - MicrosoftLicenseViewController delegate function
- (void)controller:(MicrosoftLicenseViewController* )controller
  didAcceptLicense:(BOOL)acceptedLicense{
    if(acceptedLicense){
        SfBConfigurationManager *config = mainSfb.configurationManager;
        [config setEndUserAcceptedVideoLicense];
        if([self didJoinMeeting]){
            [self performSegueWithIdentifier:@"askAgentVideo" sender:nil];
        }
    }
}

@end
