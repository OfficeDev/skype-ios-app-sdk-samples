/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "ChatTableViewController.h"
#import "ChatCell.h"

@interface ChatTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@interface ChatMessage: NSObject

@property (nonatomic, strong, nullable) NSString *chatDisplayName;
@property (nonatomic, strong, nonnull) NSString *chatMessage;
@property (nonatomic, assign) ChatSource chatSource;

@end

@implementation ChatMessage

@end

static NSString* const ParticipantCellIdentifier = @"participantCell";
static NSString* const SelfCellIdentifier = @"selfCell";
static NSString* const StatusCellIdentifier = @"statusCell";

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableArray new];
    [self addStatus:@"Waiting for an agent"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 160.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)addStatus:(NSString *)message {
    ChatMessage *newMessage = [[ChatMessage alloc] init];
    newMessage.chatMessage = message;
    newMessage.chatSource = ChatSourceStatus;

    [self.dataSource addObject:newMessage];
    
    [self updateTable];
}

- (void)addMessage:(NSString *)message from:(NSString *)name origin:(ChatSource)source {
    ChatMessage *newMessage = [[ChatMessage alloc] init];
    newMessage.chatDisplayName = name;
    newMessage.chatMessage = message;
    newMessage.chatSource = source;
    
    [self.dataSource addObject:newMessage];
    
    [self updateTable];
}


- (void)updateTable {
    [self.tableView reloadData];
    NSIndexPath *row = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:row atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (void)setUpCell:(UITableViewCell *)cell withChatMessage:(ChatMessage *)message {
    if (message.chatSource == ChatSourceStatus) {
        cell.textLabel.text = message.chatMessage;
    }
    else {
        ((ChatCell *)cell).nameLabel.text = message.chatDisplayName;
        ((ChatCell *)cell).messageLabel.text = message.chatMessage;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatMessage *chatMessage = self.dataSource[indexPath.row];
    UITableViewCell *cell;
    
    switch (chatMessage.chatSource) {
        case ChatSourceStatus:
            cell = [tableView dequeueReusableCellWithIdentifier:StatusCellIdentifier forIndexPath:indexPath];
            break;
            
        case ChatSourceSelf:
            cell = [tableView dequeueReusableCellWithIdentifier:SelfCellIdentifier forIndexPath:indexPath];
            break;
        
        case ChatSourceParticipant:
            cell = [tableView dequeueReusableCellWithIdentifier:ParticipantCellIdentifier forIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    [self setUpCell:cell withChatMessage:chatMessage];
    
    return cell;
        
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
