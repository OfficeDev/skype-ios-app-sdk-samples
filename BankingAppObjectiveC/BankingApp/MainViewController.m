/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "MainViewController.h"
#import "VideoViewController.h"

#import <SkypeForBusiness/SkypeForBusiness.h>

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UIButton *askAgentButton;
@end

@implementation MainViewController

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
    [self performSegueWithIdentifier:@"askAgentVideo" sender:nil];
}

- (void)askAgentText {
    [self performSegueWithIdentifier:@"askAgentText" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

/**
 *  Initialize Skype
 */
- (void)initializeSkype {
    SfBApplication *sfb = SfBApplication.sharedApplication;
    sfb.configurationManager.maxVideoChannels = 1;
    sfb.devicesManager.selectedSpeaker.activeEndpoint = SfBSpeakerEndpointLoudspeaker;
    sfb.configurationManager.enablePreviewFeatures = true;
}


@end
