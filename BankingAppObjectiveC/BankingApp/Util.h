//
//  Util.h
//  BankingApp
//
//  Created by Aasveen Kaur on 1/18/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//



#define USER_MEETING_URL  "userMeetingUrl"
#define USER_DISPLAY_NAME "userDisplayName"
#define SFB_ONLINE_MEETING_STATE "SfBOnlineSwitchState"
#define ENABLE_PREVIEW_STATE  "enablePreviewSwitchState"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SkypeForBusiness/SkypeForBusiness.h>

@interface Util : NSObject
+ (bool)leaveMeetingWithSuccess:(SfBConversation *)conversation;
+(NSString*) getMeetingURLString;
+(NSString*) getMeetingDisplayName;
+(BOOL) getSfBOnlineSwitchState;
+(BOOL) getEnablePreviewSwitchState ;
+ (void)showErrorAlert:(NSError *)error inView:(UIViewController*)controller;
@end
