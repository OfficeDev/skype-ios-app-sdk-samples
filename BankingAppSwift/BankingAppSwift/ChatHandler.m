/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "ChatHandler.h"
#import <UIKit/UIApplication.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSString (SfBConversationHelper)

- (BOOL)isEqualToSelector:(SEL)selector;

@end

@implementation NSString (SfBConversationHelper)

- (BOOL)isEqualToSelector:(SEL)selector {
    return [self isEqualToString:NSStringFromSelector(selector)];
}

@end

static void *kvo = &kvo;

@implementation ChatHandler {
    
    SfBHistoryService *_historyService;
    SfBChatService *_chatService;
    
}

- (instancetype)initWithConversation:(SfBConversation *)conversation
                            delegate:(id<ChatHandlerDelegate>)delegate
                            userInfo:(nullable id)userInfo {
    if (self = [super init]) {
        _conversation = conversation;
        _delegate = delegate;
        _userInfo = userInfo;
        
        [self subscribeTo:_conversation selector:@selector(state)];
        
        _historyService = self.conversation.historyService;
        [self subscribeTo:_historyService selector:@selector(activityItems)];
        
        _chatService = self.conversation.chatService;
        [self subscribeTo:_chatService selector:@selector(canSendMessage)];
        
    }
    
    return self;
}

- (void)dealloc {
    [self unsubscribeFrom:_conversation selector:@selector(state)];
    
    [self unsubscribeFrom:_chatService selector:@selector(canSendMessage)];
    
    [self unsubscribeFrom:_historyService selector:@selector(activityItems)];
}

- (void)subscribeTo:(nullable NSObject *)object selector:(SEL)selector {
    [object addObserver:self
             forKeyPath:NSStringFromSelector(selector)
                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                context:kvo];
}

- (void)unsubscribeFrom:(nullable NSObject *)object selector:(SEL)selector {
    [object removeObserver:self forKeyPath:NSStringFromSelector(selector) context:kvo];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *,id> *)change
                       context:(nullable void *)context
{
    if (context != kvo) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    id<ChatHandlerDelegate> delegate = _delegate;
    
    if (!delegate) {
        return;
    }
    
    
    id newValue = change[NSKeyValueChangeNewKey];
    
    if ([newValue isKindOfClass:NSNull.class]) {
        newValue = nil;
    }

    if (object == _conversation) {
        
        if ([keyPath isEqualToSelector:@selector(state)]) {
            if ([delegate respondsToSelector:@selector(chatHandler:conversation:didChangeState:)]) {
                [delegate chatHandler:self conversation:_conversation didChangeState:[newValue intValue]];
            }
            return;
        }
    } else if (object == _historyService) {
        
        if ([keyPath isEqualToSelector:@selector(activityItems)]) {
            if ([delegate respondsToSelector:@selector(chatHandler:didReceiveMessage:)] &&
                [change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]) {
                for (id activityItem in change[NSKeyValueChangeNewKey]) {
                    if ([activityItem isKindOfClass:SfBMessageActivityItem.class] &&
                        [activityItem direction] == SfBMessageDirectionIncoming) {
                        [delegate chatHandler:self didReceiveMessage:activityItem];
                    }
                }
            }
            return;
        }
        
    } else if (object == _chatService) {
        
        if ([keyPath isEqualToSelector:@selector(canSendMessage)]) {
            if ([delegate respondsToSelector:@selector(chatHandler:chatService:didChangeCanSendMessage:)]) {
                [delegate chatHandler:self chatService:_chatService didChangeCanSendMessage:[newValue boolValue]];
            }
            return;
        }
    }
}

- (void)sendMessage:(NSString *)message error:(NSError * _Nullable __autoreleasing *)error {
    NSError *err = nil;
    [_chatService sendMessage:message error:&err];
    
    if (err) {
        *error = err;
    }
}

@end



NS_ASSUME_NONNULL_END


