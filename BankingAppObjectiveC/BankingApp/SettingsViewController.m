//
//  SettingsViewController.m
//  BankingApp
//
//  Created by Aasveen Kaur on 1/29/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//

#import "SettingsViewController.h"
#import "Util.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *SfBOnlineSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *enablePreviewSwitch;

@end

@implementation SettingsViewController

- (IBAction)skypeForBusinessOnlineValueChangeAction:(id)sender {
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(_SfBOnlineSwitch.on){
            [defaults setBool:YES forKey:@SFB_ONLINE_MEETING_STATE];
        
    }else{
        [defaults setBool:NO forKey:@SFB_ONLINE_MEETING_STATE];
    }
    [defaults synchronize];
    
}
- (IBAction)enablePreviewValueChangeAction:(id)sender {
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
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.SfBOnlineSwitch.tintColor = [UIColor whiteColor];
    self.enablePreviewSwitch.tintColor = [UIColor whiteColor];
    
    if([defaults objectForKey:@SFB_ONLINE_MEETING_STATE ] != nil){
        self.SfBOnlineSwitch.on = [defaults boolForKey:@SFB_ONLINE_MEETING_STATE ];
    }
    if([defaults objectForKey:@ENABLE_PREVIEW_STATE ] != nil){
        self.enablePreviewSwitch.on = [defaults boolForKey:@ENABLE_PREVIEW_STATE ];
        
    }
    
    // Do any additional setup after loading the view.
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
