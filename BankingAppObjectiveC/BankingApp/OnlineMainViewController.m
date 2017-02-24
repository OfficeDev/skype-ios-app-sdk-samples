//
//  OnlineMainViewController.m
//  BankingApp
//
//  Created by Aasveen Kaur on 2/23/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//

#import "OnlineMainViewController.h"

@interface OnlineMainViewController ()
@end

@implementation OnlineMainViewController

SfBApplication *sfb ;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeSkype];
}

-(void)viewWillAppear:(BOOL)animated
{
 [self.navigationController setNavigationBarHidden:YES animated:YES];   
}
- (IBAction)joinOnlineMeeting:(id)sender {
    [self performSegueWithIdentifier:@"segueToOnlineMeeting" sender:nil];
}

-(void)initializeSkype{
            // Configure Shared application instance for Online meeting
    sfb = SfBApplication.sharedApplication;
    sfb.configurationManager.maxVideoChannels = 1;
    sfb.configurationManager.requireWifiForAudio = false;
    sfb.configurationManager.requireWifiForVideo = false;
    sfb.alertDelegate = self;
    sfb.devicesManager.selectedSpeaker.activeEndpoint = SfBSpeakerEndpointLoudspeaker;
    
    // For OnPrem topolgies enablePreview features should be enabled for Audio/Video.
    sfb.configurationManager.enablePreviewFeatures = [Util getEnablePreviewSwitchState];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
            if([segue.identifier  isEqual: @"segueToOnlineMeeting"]){
                OnlineMeetingViewController *vc = segue.destinationViewController;
                vc.onlineMeetingsfb = sfb;
            
            }
}

- (void)didReceiveAlert:(SfBAlert *)alert{
    [alert showSfBAlertInController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
