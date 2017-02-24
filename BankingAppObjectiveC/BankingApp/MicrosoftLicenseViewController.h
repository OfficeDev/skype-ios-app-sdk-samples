//
//  MicrosoftLicenseViewController.h
//  BankingApp
//
//  Created by Aasveen Kaur on 2/14/17.
//  Copyright © 2017 Jason Kim. All rights reserved.
//




#import <UIKit/UIKit.h>
@class MicrosoftLicenseViewController;

@protocol MicrosoftLicenseViewControllerDelegate

- (void)controller:(MicrosoftLicenseViewController* )controller
  didAcceptLicense:(BOOL)acceptedLicense;

@end

@interface MicrosoftLicenseViewController : UIViewController<UIWebViewDelegate>
@property (weak)  id<MicrosoftLicenseViewControllerDelegate> delegate;
@end

