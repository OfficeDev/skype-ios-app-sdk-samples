/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */


#import "VideoViewController.h"
#import "SfBConversationHelper.h"
#import <GLKit/GLKit.h>
#import "Util.h"

@interface VideoViewController () <SfBConversationHelperDelegate,SfBAlertDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoBarBottomConstraint;
@property (strong, nonatomic) IBOutlet UIView *infoBar;
@property (strong, nonatomic) IBOutlet GLKView *participantVideoView;
@property (strong, nonatomic) IBOutlet UIView *selfVideoView;
@property (strong, nonatomic) IBOutlet UIButton *muteButton;
@property (strong, nonatomic) IBOutlet UIButton *endCallButton;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) SfBConversationHelper *conversationHelper;

@end

static NSString* const DisplayNameInfo = @"displayName";

@implementation VideoViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self registerForNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide back button of UINavigation
    [self.navigationItem setHidesBackButton:YES];
    
    // Set date label to current times
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    
    self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Hide information bar to begin with.
    self.infoBarBottomConstraint.constant = -90;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initializeUI];
    [self joinMeeting];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 *  Initialize UI.
 *  Bring information bar from bottom to the visible area of the screen.
 */
- (void)initializeUI {
    self.infoBarBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [self.infoBar layoutIfNeeded];
                     }
                     completion:nil];
}


/**
 *  Joins a Skype meeting.
 */
- (void)joinMeeting {
    NSError *error = nil;
    
    NSString *meetingURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting URL"];
    NSString *meetingDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting display name"];
    
    SfBApplication *sfb = SfBApplication.sharedApplication;
    SfBConversation *conversation = [sfb joinMeetingAnonymousWithUri:[NSURL URLWithString:meetingURLString]
                                                         displayName:meetingDisplayName
                                                               error:&error];
    conversation.alertDelegate = self;
    
    if (conversation) {
               _conversationHelper = [[SfBConversationHelper alloc] initWithConversation:conversation
                                                                         delegate:self
                                                                   devicesManager:sfb.devicesManager
                                                                outgoingVideoView:self.selfVideoView
                                                               incomingVideoLayer:(CAEAGLLayer *) self.participantVideoView.layer
                                                                         userInfo:@{DisplayNameInfo:meetingDisplayName}];
         [conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        

    } else {
        
        [Util showErrorMessage:error inViewController:self];
        self.endCallButton.enabled = YES;
    }
}


#pragma mark - User button actions

- (IBAction)endCall:(id)sender {
    // Get conversation handle and call leave.
    // Need to check for canLeave property of conversation,
    // in this case happens in KVO
    [self leaveMeeting];
   }

- (void)leaveMeeting {
    if(_conversationHelper.conversation){
        [Util leaveMeetingOrLogError:_conversationHelper.conversation];
        [_conversationHelper.conversation removeObserver:self forKeyPath:@"canLeave"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)toggleMute:(id)sender {
    // Toggle audio mute. The result(updated state) is handled as a delegate callback.
    [_conversationHelper toggleAudioMuted:nil];
}

#pragma mark - Skype Delegates
// At incoming video, unhide the participant video view
- (void)conversationHelper:(SfBConversationHelper *)avHelper didSubscribeToVideo:(SfBParticipantVideo *)video {
    self.participantVideoView.hidden = NO;
}

// When video service is ready to start, unhide self video view and start the service.
- (void)conversationHelper:(SfBConversationHelper *)avHelper videoService:(SfBVideoService *)videoService didChangeCanStart:(BOOL)canStart {
    if (canStart) {
        if (self.selfVideoView.hidden) {
            self.selfVideoView.hidden = NO;
        }
        
        [videoService start:nil];
    }
}


// When the audio status changes, reflect in UI
- (void)conversationHelper:(SfBConversationHelper *)avHelper selfAudio:(SfBParticipantAudio *)audio didChangeIsMuted:(BOOL)isMuted {

    if (!isMuted) {
        [self.muteButton setTitle:@"Unmute" forState:UIControlStateNormal];
    }
    else {
        [self.muteButton setTitle:@"Mute" forState:UIControlStateNormal];
    }
}

#pragma mark - Sfb Alert Delegate

- (void)didReceiveAlert:(SfBAlert *)alert{
    
    [Util showSfbAlert:alert inViewController:self];
    
}


#pragma mark - Additional KVO
// Monitor canLeave property of a conversation to prevent leaving prematurely
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"canLeave"]) {
        self.endCallButton.enabled = _conversationHelper.conversation.canLeave;
    }
    
}



#pragma mark -  notifications
- (void)registerForNotifications

{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveMeetingWhenAppTerminates:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
    
}

-(void) leaveMeetingWhenAppTerminates:(NSNotification *)aNotification {
    [Util leaveMeetingOrLogError:_conversationHelper.conversation];
}





@end
