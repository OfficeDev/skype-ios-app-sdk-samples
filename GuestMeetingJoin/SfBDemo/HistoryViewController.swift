//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: HistoryViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class HistoryViewController: UITableViewController {

    fileprivate var kvo = 0

    var history: SfBHistoryService? {
        willSet {
            history?.removeObserver(self, forKeyPath: "activityItems", context: &kvo)
        }
        didSet {
            history?.addObserver(self, forKeyPath: "activityItems", options: [.initial], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "history")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvo else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        assert(keyPath == "activityItems")
        tableView.updateRowsWithChange(KeyValueChange(change: change!))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section == 0)
        return history?.activityItems.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch history?.activityItems[indexPath.row] {
        case let textMessage as SfBMessageActivityItem:
            switch textMessage.direction {
            case .incoming:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMessageCell", for: indexPath) as! IncomingMessageCell
                cell.item = textMessage
                return cell
            case .outgoing:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingMessageCell", for: indexPath) as! OutgoingMessageCell
                cell.item = textMessage
                return cell
            }
        case let joinLeft as SfBParticipantActivityItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantActivityCell", for: indexPath) as! ParticipantActivityCell
            cell.item = joinLeft
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "UnknownActivityCell", for: indexPath)
        }
    }

}
