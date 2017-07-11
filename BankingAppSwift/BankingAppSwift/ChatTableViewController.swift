//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Module name: ChatTableViewController.swift
//----------------------------------------------------------------


import UIKit

/**
 *  Enum to identify type of chat source.
 *  They can be status message, chat from self, or chat from others
 */
enum ChatSource : Int {
    case status
    case mySelf
    case participant
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
    func addStatus(_ message: String) {
        let newMessage: ChatMessage = ChatMessage()
        newMessage.chatMessage = message
        newMessage.chatSource = .status
        self.myDataSource.add(newMessage)
        self.updateTable()
    }
    
    
    // Add a chat message
    func addMessage(_ message: String, from name: String, origin source: ChatSource) {
        let newMessage: ChatMessage = ChatMessage()
        newMessage.chatDisplayName = name
        newMessage.chatMessage = message
        newMessage.chatSource = source
        self.myDataSource.add(newMessage)
        self.updateTable()
    }
    
    func updateTable() {
        self.tableView.reloadData()
        let row: IndexPath = IndexPath(row: self.myDataSource.count - 1, section: 0)
        self.tableView.scrollToRow(at: row, at: .top, animated: true)
    }
    
    
// MARK: - TABLE VIEW DATA SOURCE
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage: ChatMessage = self.myDataSource[indexPath.row] as! ChatMessage
        var cell: UITableViewCell
        switch (chatMessage.chatSource!) {
            
        case .status:
            cell = tableView.dequeueReusableCell(withIdentifier: StatusCellIdentifier, for: indexPath)
        case .mySelf:
            cell = tableView.dequeueReusableCell(withIdentifier: SelfCellIdentifier, for: indexPath)
        case .participant:
            cell = tableView.dequeueReusableCell(withIdentifier: ParticipantCellIdentifier, for: indexPath)
            
        }
        
        self.setUpCell(cell, withChatMessage: chatMessage)
        return cell
    }
    
    func setUpCell(_ cell: UITableViewCell, withChatMessage message: ChatMessage) {
        if message.chatSource == .status {
            cell.textLabel?.text = message.chatMessage
        }
        else {
            ((cell as! ChatCell)).nameLabel.text = message.chatDisplayName
            ((cell as! ChatCell)).messageLabel.text = message.chatMessage
        }
    }
    
}
