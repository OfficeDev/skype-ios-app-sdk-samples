/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <SkypeForBusiness/SkypeForBusiness.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ChatHandlerDelegate;

/** Chat functionality handler to handle all chat related operations in Skype for Business.
 *
 * Basic idea comes from the SDK included SfBConversationHelper class, but removing all non text chat features
 * so that it works for basic text chat only conversation.
 */

@interface ChatHandler : NSObject

@property (readonly) SfBConversation *conversation;
@property (readonly, weak) id<ChatHandlerDelegate> delegate;
@property (readonly, nullable) id userInfo;

/** Initialize conversation helper and subscribe to all relevant events in conversation
 * or its child objects.
 *
 * @param conversation Conversation obtained from one of SfBApplication methods.
 * @param delegate Delegate object receiving calls from conversation helper.
 * @param userInfo Any object. Exposed in the userInfo property of conversation helper.
 */
- (instancetype)initWithConversation:(SfBConversation *)conversation
                            delegate:(id<ChatHandlerDelegate>)delegate
                            userInfo:(nullable id)userInfo;

- (void)sendMessage:(NSString *)message error:(NSError **)error;
@end

@protocol ChatHandlerDelegate <NSObject>

@optional

/// @name KVO notifications

/// New incoming SfBMessageActivityItem appeared in conversation.historyService.activiyItems.
- (void)chatHandler:(ChatHandler *)chatHandler
  didReceiveMessage:(SfBMessageActivityItem *)message;

/// conversation.chatService.canSendMessage
- (void)chatHandler:(ChatHandler *)chatHandler
        chatService:(SfBChatService *)chatService
didChangeCanSendMessage:(BOOL)canSendMessage;


/// conversation.state
- (void)chatHandler:(ChatHandler *)chatHandler
       conversation:(SfBConversation *)conversation
     didChangeState:(SfBConversationState)state;


@end

NS_ASSUME_NONNULL_END
