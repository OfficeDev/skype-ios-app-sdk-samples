//
//  Utils.h
//  BankingApp
//
//  Created by Aasveen Kaur on 8/23/16.
//  Copyright © 2016 Jason Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkypeForBusiness/SkypeForBusiness.h>

#import <UIKit/UIKit.h>

@interface Util : NSObject
+ (void)showErrorMessage:(NSError *)error inViewController:(UIViewController*)viewController;
+ (void)showSfbAlert:(SfBAlert *)alert  inViewController:(UIViewController*)viewController;
+ (void) leaveMeetingOrLogError:(SfBConversation*) conversation;

@end

