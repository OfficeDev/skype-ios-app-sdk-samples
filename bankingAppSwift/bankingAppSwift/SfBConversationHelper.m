#import "SfBConversationHelper.h"
#import <QuartzCore/CADisplayLink.h>
#import <UIKit/UIApplication.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SfBConversationHelper)

- (BOOL)isEqualToSelector:(SEL)selector;

@end

@interface SfBParticipantVideo (SfBConversationHelper)

@property (readonly) BOOL isSendingVideo;

@end

@implementation NSString (SfBConversationHelper)

- (BOOL)isEqualToSelector:(SEL)selector {
    return [self isEqualToString:NSStringFromSelector(selector)];
}

@end

@implementation SfBParticipantVideo (SfBConversationHelper)

- (BOOL)isSendingVideo {
    return self.state == SfBParticipantServiceStateConnected && !self.isPaused && self.canSubscribe;
}

+ (NSSet *)keyPathsForValuesAffectingIsSendingVideo {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(state)),
            NSStringFromSelector(@selector(isPaused)),
            NSStringFromSelector(@selector(canSubscribe)),
            nil];
}

@end

static void *kvo = &kvo;

@implementation SfBConversationHelper {
    CAEAGLLayer *_incomingVideoLayer;

    SfBHistoryService *_historyService;
    SfBChatService *_chatService;
    SfBVideoService *_videoService;
    SfBSpeaker *_speaker;
    SfBParticipantAudio *_selfAudio;
    SfBParticipantVideo *_selfVideo;

    SfBParticipantVideo *_otherVideo;
    SfBVideoStream *_videoStream;
    SfBVideoPreview *_videoPreview;
}

- (instancetype)initWithConversation:(SfBConversation *)conversation
                            delegate:(id<SfBConversationHelperDelegate>)delegate
                      devicesManager:(SfBDevicesManager *)devicesManager
                   outgoingVideoView:(UIView *)outgoingVideoView
                  incomingVideoLayer:(CAEAGLLayer *)incomingVideoLayer
                            userInfo:(nullable id)userInfo {
    if (self = [super init]) {
        _conversation = conversation;
        _delegate = delegate;
        _devicesManager = devicesManager;
        _incomingVideoLayer = incomingVideoLayer;
        _userInfo = userInfo;

        [self subscribeTo:_conversation selector:@selector(state)];
        [self subscribeTo:_conversation selector:@selector(dominantSpeaker)];
        [self subscribeTo:_conversation selector:@selector(remoteParticipants)];

        // Need NSKeyValueObservingOptionOld too
        [_conversation addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(remoteParticipants))
                           options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                           context:kvo];

        _historyService = _conversation.historyService;
        [self subscribeTo:_historyService selector:@selector(activityItems)];

        _chatService = _conversation.chatService;
        [self subscribeTo:_chatService selector:@selector(canSendMessage)];

        _videoService = _conversation.videoService;
        [self subscribeTo:_videoService selector:@selector(canStart)];
        [self subscribeTo:_videoService selector:@selector(activeCamera)];

        _speaker = _devicesManager.selectedSpeaker;
        [self subscribeTo:_speaker selector:@selector(activeEndpoint)];

        _selfAudio = _conversation.selfParticipant.audio;
        [self subscribeTo:_selfAudio selector:@selector(state)];
        [self subscribeTo:_selfAudio selector:@selector(isMuted)];

        _selfVideo = _conversation.selfParticipant.video;
        [self subscribeTo:_selfVideo selector:@selector(state)];
        [self subscribeTo:_selfVideo selector:@selector(isPaused)];

        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderFrame:)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];

        _videoPreview = [_videoService preview:outgoingVideoView error:nil];
    }

    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
    self.otherVideo = nil;

    [self unsubscribeFrom:_selfVideo selector:@selector(isPaused)];
    [self unsubscribeFrom:_selfVideo selector:@selector(state)];

    [self unsubscribeFrom:_selfAudio selector:@selector(isMuted)];
    [self unsubscribeFrom:_selfAudio selector:@selector(state)];

    [self unsubscribeFrom:_speaker selector:@selector(activeEndpoint)];

    [self unsubscribeFrom:_videoService selector:@selector(activeCamera)];
    [self unsubscribeFrom:_videoService selector:@selector(canStart)];

    [self unsubscribeFrom:_chatService selector:@selector(canSendMessage)];

    [self unsubscribeFrom:_historyService selector:@selector(activityItems)];

    [self unsubscribeFrom:_conversation selector:@selector(remoteParticipants)];
    [self unsubscribeFrom:_conversation selector:@selector(dominantSpeaker)];
    [self unsubscribeFrom:_conversation selector:@selector(state)];
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

- (void)setOtherVideo:(nullable SfBParticipantVideo *)video {
    [self unsubscribeFrom:_otherVideo selector:@selector(isSendingVideo)];
    [self unsubscribeFrom:_otherVideo selector:@selector(canSubscribe)];
    _otherVideo = video;
    [self subscribeTo:_otherVideo selector:@selector(canSubscribe)];
    [self subscribeTo:_otherVideo selector:@selector(isSendingVideo)];

    if (_otherVideo == nil && [_delegate respondsToSelector:@selector(conversationHelper:didSubscribeToVideo:)]) {
        return [_delegate conversationHelper:self didSubscribeToVideo:nil];
    }
}

- (void)setVideoEnabled:(BOOL)enabled {
    if (enabled) {
        NSError *error = nil;

        if ((_videoStream = [_otherVideo subscribe:_incomingVideoLayer error:&error])) {
            _displayLink.paused = NO;
            return;
        }

        NSLog(@"Video subscription failed with error: %@", error);
    }

    _videoStream = nil;
    _displayLink.paused = YES;
}

- (void)renderFrame:(CADisplayLink *)displayLink {
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        [_videoStream render:nil];
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *,id> *)change
                       context:(nullable void *)context {
    if (context != kvo) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

    id<SfBConversationHelperDelegate> delegate = _delegate;

    if (!delegate) {
        return;
    }

    id newValue = change[NSKeyValueChangeNewKey];

    if ([newValue isKindOfClass:NSNull.class]) {
        newValue = nil;
    }

    if (object == _conversation) {

        if ([keyPath isEqualToSelector:@selector(state)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:conversation:didChangeState:)]) {
                [delegate conversationHelper:self conversation:_conversation didChangeState:[newValue intValue]];
            }
            return;
        }

        if ([keyPath isEqualToSelector:@selector(dominantSpeaker)]) {
            // Subscribe to dominant speaker
            if (newValue && ![newValue isEqual:_conversation.selfParticipant]) {
                self.otherVideo = [newValue video];
            }
            return;
        }

        if ([keyPath isEqualToSelector:@selector(remoteParticipants)]) {
            if (_otherVideo == nil && [change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]) {
                // If we hadn't subscribed yet, subscribe to the first remote participant
                self.otherVideo = [[newValue firstObject] video];
            } else if (_otherVideo != nil && [change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]) {
                // If subscribed participant has left, subscribe to the first of remaining participants
                for (SfBParticipant *participant in change[NSKeyValueChangeOldKey]) {
                    if ([_otherVideo isEqual:participant.video]) {
                        self.otherVideo = _conversation.remoteParticipants.firstObject.video;
                        break;
                    }
                }
            }
            return;
        }

    } else if (object == _historyService) {

        if ([keyPath isEqualToSelector:@selector(activityItems)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:didReceiveMessage:)] &&
                [change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]) {
                for (id activityItem in change[NSKeyValueChangeNewKey]) {
                    if ([activityItem isKindOfClass:SfBMessageActivityItem.class] &&
                        [activityItem direction] == SfBMessageDirectionIncoming) {
                        [delegate conversationHelper:self didReceiveMessage:activityItem];
                    }
                }
            }
            return;
        }

    } else if (object == _otherVideo) {

        if ([keyPath isEqualToSelector:@selector(canSubscribe)]) {
            self.videoEnabled = [newValue boolValue];
            return;
        }

        if ([keyPath isEqualToSelector:@selector(isSendingVideo)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:didSubscribeToVideo:)]) {
                [delegate conversationHelper:self didSubscribeToVideo:[newValue boolValue] ? _otherVideo : nil];
            }
            return;
        }

    } else if (object == _chatService) {

        if ([keyPath isEqualToSelector:@selector(canSendMessage)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:chatService:didChangeCanSendMessage:)]) {
                [delegate conversationHelper:self chatService:_chatService didChangeCanSendMessage:[newValue boolValue]];
            }
            return;
        }

    } else if (object == _videoService) {

        if ([keyPath isEqualToSelector:@selector(canStart)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:videoService:didChangeCanStart:)]) {
                [delegate conversationHelper:self videoService:_videoService didChangeCanStart:[newValue boolValue]];
            }
            return;
        }

        if ([keyPath isEqualToSelector:@selector(activeCamera)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:videoService:didChangeActiveCamera:)]) {
                [delegate conversationHelper:self videoService:_videoService didChangeActiveCamera:newValue];
            }
            return;
        }

    } else if (object == _speaker) {

        if ([keyPath isEqualToSelector:@selector(activeEndpoint)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:speaker:didChangeActiveEndpoint:)]) {
                [delegate conversationHelper:self speaker:_speaker didChangeActiveEndpoint:[newValue intValue]];
            }
            return;
        }

    } else if (object == _selfAudio) {

        if ([keyPath isEqualToSelector:@selector(state)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:selfAudio:didChangeState:)]) {
                [delegate conversationHelper:self selfAudio:_selfAudio didChangeState:[newValue intValue]];
            }
            return;
        }

        if ([keyPath isEqualToSelector:@selector(isMuted)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:selfAudio:didChangeIsMuted:)]) {
                [delegate conversationHelper:self selfAudio:_selfAudio didChangeIsMuted:[newValue boolValue]];
            }
            return;
        }

    } else if (object == _selfVideo) {

        if ([keyPath isEqualToSelector:@selector(state)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:selfVideo:didChangeState:)]) {
                [delegate conversationHelper:self selfVideo:_selfVideo didChangeState:[newValue intValue]];
            }
            return;
        }

        if ([keyPath isEqualToSelector:@selector(isPaused)]) {
            if ([delegate respondsToSelector:@selector(conversationHelper:selfVideo:didChangeIsPaused:)]) {
                [delegate conversationHelper:self selfVideo:_selfVideo didChangeIsPaused:[newValue boolValue]];
            }
            return;
        }

    }

    NSLog(@"Unknown KVO notification from %@ with key %@", object, keyPath);
}

- (void)changeSpeakerEndpoint {
    switch (_speaker.activeEndpoint) {
        case SfBSpeakerEndpointLoudspeaker:
            _speaker.activeEndpoint = SfBSpeakerEndpointNonLoudspeaker;
            break;
        case SfBSpeakerEndpointNonLoudspeaker:
            _speaker.activeEndpoint = SfBSpeakerEndpointLoudspeaker;
            break;
    }
}

- (BOOL)changeActiveCamera:(NSError **)error {
    NSArray<SfBCamera *> *cameras = _devicesManager.cameras;
    NSUInteger curr = [cameras indexOfObject:_videoService.activeCamera];
    NSUInteger next = (curr == NSNotFound) ? 0 : (curr + 1) % cameras.count;
    return [_videoService setActiveCamera:cameras[next] error:error];
}

- (BOOL)toggleAudioMuted:(NSError **)error {
    return [_selfAudio setMuted:!_selfAudio.isMuted error:error];
}

- (BOOL)toggleVideoPaused:(NSError **)error {
    return [_videoService setPaused:!_selfVideo.isPaused error:error];
}

@end

NS_ASSUME_NONNULL_END
