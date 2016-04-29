//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: HistoryViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class HistoryViewController: UITableViewController {

    private var kvo = 0

    var history: SfBHistoryService? {
        willSet {
            history?.removeObserver(self, forKeyPath: "activityItems", context: &kvo)
        }
        didSet {
            history?.addObserver(self, forKeyPath: "activityItems", options: [.Initial], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "history")
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &kvo else {
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }

        assert(keyPath == "activityItems")
        tableView.updateRowsWithChange(KeyValueChange(change: change!))
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section == 0)
        return history?.activityItems.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch history?.activityItems[indexPath.row] {
        case let textMessage as SfBMessageActivityItem:
            switch textMessage.direction {
            case .Incoming:
                let cell = tableView.dequeueReusableCellWithIdentifier("IncomingMessageCell", forIndexPath: indexPath) as! IncomingMessageCell
                cell.item = textMessage
                return cell
            case .Outgoing:
                let cell = tableView.dequeueReusableCellWithIdentifier("OutgoingMessageCell", forIndexPath: indexPath) as! OutgoingMessageCell
                cell.item = textMessage
                return cell
            }
        case let joinLeft as SfBParticipantActivityItem:
            let cell = tableView.dequeueReusableCellWithIdentifier("ParticipantActivityCell", forIndexPath: indexPath) as! ParticipantActivityCell
            cell.item = joinLeft
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("UnknownActivityCell", forIndexPath: indexPath)
        }
    }

}
