/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "ChatViewController.h"
#import "ChatTableViewController.h"
#import "ChatHandler.h"
#import "Util.h"

@interface ChatViewController () <ChatHandlerDelegate,SfBAlertDelegate>

@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spaceConstraint;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *endButton;

@property (weak, nonatomic) ChatTableViewController *chatTableViewController;

@property (strong, nonatomic) ChatHandler *chatHandler;

@end

static NSString* const DisplayNameInfo = @"displayName";

@implementation ChatViewController


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
    // Do any additional setup after loading the view.
     [self joinMeeting];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -  notifications
- (void)registerForNotifications

{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveMeetingWhenAppTerminates:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

-(void) leaveMeetingWhenAppTerminates:(NSNotification *)aNotification {
    [Util leaveMeetingOrLogError:_chatHandler.conversation];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.spaceConstraint.constant = keyboardFrame.size.height;
    [self.view layoutIfNeeded];
    
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    self.spaceConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - User actions
- (IBAction)sendMessage:(id)sender {
    [self.messageTextField resignFirstResponder];
    [self sendChatMessage:self.messageTextField.text];
}


- (IBAction)endChat:(id)sender {
    [self leaveMeeting];
}

- (void)sendChatMessage:(NSString *)message {
    
    NSError *error = nil;
    [_chatHandler sendMessage:message error:&error];
    
    if (error) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        self.messageTextField.text = @"";
        [self.chatTableViewController addMessage:message from:_chatHandler.userInfo[DisplayNameInfo] origin:ChatSourceSelf];
    }
    
}

- (void)leaveMeeting {
    if(_chatHandler.conversation){
            [Util leaveMeetingOrLogError:_chatHandler.conversation];
            [_chatHandler.conversation removeObserver:self forKeyPath:@"canLeave"];
    }
            [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Skype
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
        
        _chatHandler = [[ChatHandler alloc] initWithConversation:conversation
                                                        delegate:self
                                                        userInfo:@{DisplayNameInfo:meetingDisplayName}];
        [conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        

    } else {
        [Util showErrorMessage:error inViewController:self];
        self.endButton.enabled = YES;
    }

}

#pragma mark - Skype Delegates
- (void)chatHandler:(ChatHandler *)chatHandler conversation:(SfBConversation *)conversation didChangeState:(SfBConversationState)state {
    
}

- (void)chatHandler:(ChatHandler *)chatHandler chatService:(SfBChatService *)chatService didChangeCanSendMessage:(BOOL)canSendMessage {

    if (canSendMessage) {
        self.sendButton.enabled = YES;
        self.sendButton.alpha = 1;
        [self.chatTableViewController addStatus:@"Now you can send a message"];
    }
    else {
        self.sendButton.enabled = NO;
    }
}

- (void)chatHandler:(ChatHandler *)chatHandler didReceiveMessage:(SfBMessageActivityItem *)message {
    [self.chatTableViewController addMessage:message.text from:message.sender.displayName origin:ChatSourceParticipant];
}

//MARK - Sfb Alert Delegate

- (void)didReceiveAlert:(SfBAlert *)alert{
    
    [Util showSfbAlert:alert inViewController:self];
    
}


#pragma mark - Additional KVO

// Monitor canLeave property of a conversation to prevent leaving prematurely
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"canLeave"]) {
        self.endButton.enabled = _chatHandler.conversation.canLeave;
    }
    
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"chatTable"]) {
        _chatTableViewController = segue.destinationViewController;
        
    }
}


@end
