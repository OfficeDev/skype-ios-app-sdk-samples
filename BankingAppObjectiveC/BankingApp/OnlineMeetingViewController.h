//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: OnlineMeetingViewController.h
//----------------------------------------------------------------


#import <UIKit/UIKit.h>
#import <SkypeForBusiness/SkypeForBusiness.h>
#import "MicrosoftLicenseViewController.h"
#import "Util.h"
@interface OnlineMeetingViewController : UIViewController<UITextFieldDelegate,SfBAlertDelegate, MicrosoftLicenseViewControllerDelegate>

@property (strong, nonatomic) SfBApplication *onlineMeetingsfb ;
@end
