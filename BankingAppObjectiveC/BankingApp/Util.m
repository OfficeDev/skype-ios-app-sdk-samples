//
//  Util.m
//  BankingApp
//
//  Created by Aasveen Kaur on 1/18/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (bool)leaveMeetingWithSuccess:(SfBConversation *)conversation{
    NSError *error = nil;
    [conversation leave:&error];
    
    if (error) {
        NSLog(@"Error leaving meeting");
        return false;
        
    }
    return true;
}

+(NSString*) getMeetingURLString  {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@USER_MEETING_URL] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting URL"];
        
    
    
}

+(NSString*) getMeetingDisplayName {
  
        
    return [[NSUserDefaults standardUserDefaults] objectForKey:@USER_DISPLAY_NAME] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting display name"];
    
    
}

+(BOOL) getEnablePreviewSwitchState {
    
    BOOL EnablePreviewSwitchStateUserDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@ENABLE_PREVIEW_STATE] ;
    BOOL EnablePreviewSwitchStateInfoList = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Enable Preview Switch State"] boolValue];
    
    
    return EnablePreviewSwitchStateUserDefault ?: EnablePreviewSwitchStateInfoList ;
    
    
}

+(BOOL) getSfBOnlineSwitchState {
    
    BOOL SfBOnlineSwitchStateUserDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@SFB_ONLINE_MEETING_STATE];
    BOOL SfBOnlineSwitchStateInfoList = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SfB Online Switch State"] boolValue];
    
    
    return SfBOnlineSwitchStateUserDefault ?: SfBOnlineSwitchStateInfoList ;
    
    
        
}


+ (void)showErrorAlert:(NSError *)error inView:(UIViewController*)controller  {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error: Try again later!"
                                                                             message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Close"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}


@end
