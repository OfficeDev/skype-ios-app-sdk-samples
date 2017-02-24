/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <UIKit/UIKit.h>
#import <SkypeForBusiness/SkypeForBusiness.h>
#import "OnlineMainViewController.h"
#import "Util.h"
@interface ChatViewController : UIViewController
@property (strong, nonatomic) SfBConversation *conversation;
@end
