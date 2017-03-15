#import <SkypeForBusiness/SkypeForBusiness.h>

NS_ASSUME_NONNULL_BEGIN

@class CADisplayLink;
@protocol SfBConversationHelperDelegate;

/** This is a convenience object.  It simplifies interaction with the core Conversation interface
 * and its children.
 * <li> It provides a flat delegate interface for the most useful property notifications,
 *      removing the need to write verbose KVO code.
 * <li> It provides simple methods to toggle audio mute and video pause states.
 * <li> It provides simple methods to cycle through available cameras and speaker endpoints.
 * <li> It can automatically subscribe to the video stream of the (or a) remote participant.
 */
@interface SfBConversationHelper : NSObject

@property (readonly) SfBConversation *conversation;
@property (readonly, weak) id<SfBConversationHelperDelegate> delegate;
@property (readonly) SfBDevicesManager *devicesManager;
@property (readonly, nullable) id userInfo;

/// A display link used to update incoming video picture.
@property (readonly) CADisplayLink *displayLink;

/** Initialize the helper, subscribe to all relevant events in the provided conversation
 * and its children, and automatically subscribe to the video stream of the remote participant.
 * (If there are multiple remote participants, one is automatically chosen.) 
 *
 * @param conversation Conversation obtained from one of SfBApplication methods.
 * @param delegate Delegate object that should receive callbacks from this conversation helper.
 * @param devicesManager Devices manager obtained from SfBApplication.
 * @param outgoingVideoView An UIView used to draw outgoing video stream.
 * @param incomingVideoLayer A CAEAGLLayer used to draw incoming video stream.
 * @param userInfo Any object. Exposed in the userInfo property of conversation helper.
 */
- (instancetype)initWithConversation:(SfBConversation *)conversation
                            delegate:(id<SfBConversationHelperDelegate>)delegate
                      devicesManager:(SfBDevicesManager *)devicesManager
                   outgoingVideoView:(UIView *)outgoingVideoView
                  incomingVideoLayer:(CAEAGLLayer *)incomingVideoLayer
                            userInfo:(nullable id)userInfo;

/// Change speaker endpoint between SfBSpeakerEndpointLoudspeaker and SfBSpeakerEndpointNonLoudspeaker
- (void)changeSpeakerEndpoint;

/// Change active camera between all available cameras.
- (BOOL)changeActiveCamera:(NSError **)error;

/// Toggle outgoing audio isMuted
- (BOOL)toggleAudioMuted:(NSError **)error;

/// Toggle outgoing video isPaused
- (BOOL)toggleVideoPaused:(NSError **)error;

@end

@protocol SfBConversationHelperDelegate <NSObject>

@optional

/** Subscribed or unsubcribed to incoming video
 *
 * @param video If not nil, the conversation helper is subscribed to this participant's video using
 * the CAEAGLLayer passed to the SfBConversationHelper initializer. If nil, no incoming video is
 * currently subscribed.
 */
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
       didSubscribeToVideo:(nullable SfBParticipantVideo *)video;

/// New incoming SfBMessageActivityItem appeared in conversation.historyService.activityItems.
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
         didReceiveMessage:(SfBMessageActivityItem *)message;

/// @name KVO notifications

/// conversation.state has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
              conversation:(SfBConversation *)conversation
            didChangeState:(SfBConversationState)state;

/// conversation.chatService.canSendMessage has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
               chatService:(SfBChatService *)chatService
   didChangeCanSendMessage:(BOOL)canSendMessage;

/// conversation.selfParticipant.audio.state has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
                 selfAudio:(SfBParticipantAudio *)audio
            didChangeState:(SfBParticipantServiceState)state;

/// conversation.selfParticipant.audio.isMuted has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
                 selfAudio:(SfBParticipantAudio *)audio
          didChangeIsMuted:(BOOL)isMuted;

/// devicesManager.selectedSpeaker.activeEndpoint has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
                   speaker:(SfBSpeaker *)speaker
   didChangeActiveEndpoint:(SfBSpeakerEndpoint)endpoint;

/// conversation.videoService.canStart has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
              videoService:(SfBVideoService *)videoService
         didChangeCanStart:(BOOL)canStart;

/// conversation.videoService.activeCamera has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
              videoService:(SfBVideoService *)videoService
     didChangeActiveCamera:(SfBCamera *)camera;

/// conversation.selfParticipant.video.state has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
                 selfVideo:(SfBParticipantVideo *)video
            didChangeState:(SfBParticipantServiceState)state;

/// conversation.selfParticipant.video.isPaused has changed
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
                 selfVideo:(SfBParticipantVideo *)video
         didChangeIsPaused:(BOOL)isPaused;

@end

NS_ASSUME_NONNULL_END
