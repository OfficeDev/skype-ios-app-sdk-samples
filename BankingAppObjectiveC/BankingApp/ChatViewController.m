/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "ChatViewController.h"
#import "ChatTableViewController.h"
#import "ChatHandler.h"

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

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self registerForNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard notifications
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


- (void)leaveMeetingWhenAppTerminates:(NSNotification *)aNotification {
    if(_chatHandler.conversation != nil){
        [Util leaveMeetingWithSuccess:_chatHandler.conversation];
        
    }
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.spaceConstraint.constant = keyboardFrame.size.height;
    [self.view layoutIfNeeded];
    
    //CGPoint newOffset = CGPointMake(0, self.chatTableViewController.tableView.contentOffset.y + keyboardFrame.size.height);
    //[self.chatTableViewController.tableView setContentOffset:newOffset animated:YES];
    
    
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
    [self endMeeting];
}


#pragma mark - Skype
/**
 *  Joins a Skype meeting.
 */
- (void)joinMeeting {
//    NSError *error = nil;
//    NSString *meetingURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting URL"];
    NSString *meetingDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting display name"];
//    
//    SfBApplication *sfb = SfBApplication.sharedApplication;
//    SfBConversation *conversation = [sfb joinMeetingAnonymousWithUri:[NSURL URLWithString:meetingURLString]
//                                                         displayName:meetingDisplayName
//                                                               error:&error].conversation;
//    
//    if (conversation) {
//        [conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
//        
//        _chatHandler = [[ChatHandler alloc] initWithConversation:conversation
//                                                       delegate:self
//                                                       userInfo:@{DisplayNameInfo:meetingDisplayName}];
//    } else {
//        [self handleError:error];
//    }
    self.conversation.alertDelegate = self;
    _chatHandler = [[ChatHandler alloc] initWithConversation:self.conversation
                                                                         delegate:self
                                                                           userInfo:@{DisplayNameInfo:meetingDisplayName}];
    [_chatHandler.conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveAlert:(SfBAlert *)alert{
   [alert showSfBAlertInController:self];
}

- (void)endMeeting {
    
    if(![Util leaveMeetingWithSuccess:_chatHandler.conversation] ){
  
        NSLog(@"Error leaving meeting");
    }
    [_chatHandler.conversation removeObserver:self forKeyPath:@"canLeave"];
    bool presentedFromOnlineMeetingViewController = NO;
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *viewController in allViewControllers) {
        if ([viewController isKindOfClass:[OnlineMainViewController class]]) {
            presentedFromOnlineMeetingViewController = YES;
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
    if(!presentedFromOnlineMeetingViewController){
        [self.navigationController popViewControllerAnimated:YES];
    }
    
   

}


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
