/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */


#import <UIKit/UIKit.h>
#import "Util.h"
#import "OnlineMainViewController.h"
#import <SkypeForBusiness/SkypeForBusiness.h>
/**
 *  ViewViewControllers handles AV chat using Skype for Business SDK.
 *  Namely, it uses a convenient helper SfBConversationHelper.h included in the 
 *  Helpers folder of the SDK.
 */
@interface VideoViewController : UIViewController
@property (strong, nonatomic) SfBConversation *conversationInstance;
@property (strong, nonatomic) SfBDevicesManager *deviceManagerInstance;
@property (strong, nonatomic) NSString *displayName;

@end
