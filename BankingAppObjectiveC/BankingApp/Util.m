//
//  Utils.m
//  BankingApp
//
//  Created by Aasveen Kaur on 8/23/16.
//  Copyright © 2016 Jason Kim. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (void)showErrorMessage:(NSError *)error inViewController:(UIViewController*)viewController {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Close"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [viewController presentViewController:alertController animated:YES completion:nil];
}



+ (void)showSfbAlert:(SfBAlert *)alert  inViewController:(UIViewController*)viewController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%d%d",alert.level,alert.type]
                                                                             message:alert.error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [viewController presentViewController:alertController animated:YES completion:nil];
    
    
}

+ (void) leaveMeetingOrLogError:(SfBConversation*) conversation {
    
    NSError *error = nil;
    [conversation leave:&error];
    if (error){
        NSLog(@"%@",error.localizedDescription);
    }
}

@end
