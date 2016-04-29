/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <UIKit/UIKit.h>

/**
 *  Enum to identify type of chat source.
 *  They can be status message, chat from self, or chat from others
 */
typedef NS_ENUM(int, ChatSource) {
    ChatSourceStatus,
    ChatSourceSelf,
    ChatSourceParticipant
};

/**
 *  Handles UI of chat table
 */
@interface ChatTableViewController : UITableViewController

// Add a status type message
- (void)addMessage:(NSString *)message from:(NSString *)name origin:(ChatSource)source;

// Add a chat message
- (void)addStatus:(NSString *)message;

@end







