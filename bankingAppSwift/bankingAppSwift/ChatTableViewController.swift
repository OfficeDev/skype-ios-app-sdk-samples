//
//  ChatTableViewController.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/12/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
//

import UIKit

/**
 *  Enum to identify type of chat source.
 *  They can be status message, chat from self, or chat from others
 */
enum ChatSource : Int {
    case Status
    case MySelf
    case Participant
}

class ChatMessage: NSObject {
    var chatDisplayName: String = ""
    var chatMessage: String = ""
    var chatSource: ChatSource?
}

let ParticipantCellIdentifier: String = "participantCell"
let SelfCellIdentifier: String = "selfCell"
let StatusCellIdentifier: String = "statusCell"

/**
 *  Handles UI of chat table
 */
class ChatTableViewController: UITableViewController {
    
    var myDataSource:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addStatus("Waiting for an agent")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - ACTIONS
    
    // Add a status type message
    func addStatus(message: String) {
        let newMessage: ChatMessage = ChatMessage()
        newMessage.chatMessage = message
        newMessage.chatSource = .Status
        self.myDataSource.addObject(newMessage)
        self.updateTable()
    }
    
    
    // Add a chat message
    func addMessage(message: String, from name: String, origin source: ChatSource) {
        let newMessage: ChatMessage = ChatMessage()
        newMessage.chatDisplayName = name
        newMessage.chatMessage = message
        newMessage.chatSource = source
        self.myDataSource.addObject(newMessage)
        self.updateTable()
    }
    
    func updateTable() {
        self.tableView.reloadData()
        let row: NSIndexPath = NSIndexPath(forRow: self.myDataSource.count - 1, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(row, atScrollPosition: .Top, animated: true)
    }
    
    
// MARK: - TABLE VIEW DATA SOURCE
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myDataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chatMessage: ChatMessage = self.myDataSource[indexPath.row] as! ChatMessage
        var cell: UITableViewCell
        switch (chatMessage.chatSource!) {
            
        case .Status:
            cell = tableView.dequeueReusableCellWithIdentifier(StatusCellIdentifier, forIndexPath: indexPath)
        case .MySelf:
            cell = tableView.dequeueReusableCellWithIdentifier(SelfCellIdentifier, forIndexPath: indexPath)
        case .Participant:
            cell = tableView.dequeueReusableCellWithIdentifier(ParticipantCellIdentifier, forIndexPath: indexPath)
            
        }
        
        self.setUpCell(cell, withChatMessage: chatMessage)
        return cell
    }
    
    func setUpCell(cell: UITableViewCell, withChatMessage message: ChatMessage) {
        if message.chatSource == .Status {
            cell.textLabel?.text = message.chatMessage
        }
        else {
            ((cell as! ChatCell)).nameLabel.text = message.chatDisplayName
            ((cell as! ChatCell)).messageLabel.text = message.chatMessage
        }
    }
    
}
