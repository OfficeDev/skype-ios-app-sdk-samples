//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: Util.h
//+----------------------------------------------------------------



#define USER_MEETING_URL  "userMeetingUrl"
#define USER_DISPLAY_NAME "userDisplayName"
#define TOKEN_AND_DISCOVERY_API_URL  "TokenAndDiscoveryURIRequestAPIURL"
#define ONLINE_MEETING_REQUEST_API_URL  "OnlineMeetingRequestAPIURL"
#define SFB_ONLINE_MEETING_STATE "SfBOnlineSwitchState"
#define ENABLE_PREVIEW_STATE  "enablePreviewSwitchState"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OnlineMeetingViewController.h"
#import <SkypeForBusiness/SkypeForBusiness.h>

@interface Util : NSObject
+ (bool)leaveMeetingWithSuccess:(SfBConversation *)conversation;
+(NSString*) getMeetingURLString;
+(NSString*) getMeetingDisplayName;
+(NSString*) getTokenAndDiscoveryURIRequestURL;
+(NSString*) getOnlineMeetingRequestURL;
+(BOOL) getSfBOnlineSwitchState;
+(BOOL) getEnablePreviewSwitchState ;
+ (void)showErrorAlert:(NSError *)error inView:(UIViewController*)controller;
@end

@interface SfBAlert(MyAdditions)

-(void)showSfBAlertInController:(UIViewController *)controller;
-(NSString*) DescriptionOfSfBAlertType;

@end

@implementation SfBAlert(MyAdditions)

-(void)showSfBAlertInController:(UIViewController *)controller{
    NSString *errorTitle = @"Error: ";
    errorTitle = [errorTitle stringByAppendingString:[self DescriptionOfSfBAlertType]];
    NSString *errorDescription = [NSString stringWithFormat: @"%@", self.error.localizedDescription];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: errorTitle
                                                                             message: errorDescription
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [controller presentViewController:alertController animated:YES completion:nil];
    
}

-(NSString*) DescriptionOfSfBAlertType{
    switch (self.type) {
            
        case SfBAlertTypeMessaging: return @"Messaging";
        case SfBAlertTypeUcwaObjectModel: return @"UcwaObjectModel";
        case SfBAlertTypeAutoDiscovery: return @"AutoDiscovery";
        case SfBAlertTypeSignIn: return @"SignIn";
        case SfBAlertTypeSignOut: return @"SignOut";
        case SfBAlertTypeConnectivity: return @"Connectivity";
        case SfBAlertTypeConferencing: return @"Conferencing";
        case SfBAlertTypeParticipantMute: return @"ParticipantMute";
        case SfBAlertTypeParticipantUnmute: return @"ParticipantUnmute";
            
        case SfBAlertTypeConferenceUnexpectedDisconnect: return @"ConferenceUnexpectedDisconnect";
        case SfBAlertTypeVideo: return @"Video";
        case SfBAlertTypeVideoOverWiFiBlocked: return @"VideoOverWiFiBlocked";
        case SfBAlertTypeVideoGenericError: return @"VideoGenericError";
        case SfBAlertTypeVoice: return @"Voice";
        case SfBAlertTypeCallFailed: return @"CallFailed";
            
            
        case SfBAlertTypeConferenceIsRecording: return @"ConferenceIsRecording";
        case SfBAlertTypeCommunication: return @"Communication";
        case SfBAlertTypeCommon: return @"Common";
            
            
    }
    return nil;
}
@end




