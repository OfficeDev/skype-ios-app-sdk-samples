//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: ParticipantActivityCell.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class ParticipantActivityCell: UITableViewCell {

    @IBOutlet var timestamp: UILabel?
    @IBOutlet var status: UILabel?

    fileprivate var kvo = 0

    var item: SfBParticipantActivityItem? {
        willSet {
            item?.removeObserver(self, forKeyPath: "person.displayName", context: &kvo)
            item?.removeObserver(self, forKeyPath: "timestamp", context: &kvo)
        }
        didSet {
            item?.addObserver(self, forKeyPath: "timestamp", options: [.initial], context: &kvo)
            item?.addObserver(self, forKeyPath: "person.displayName", options: [.initial, .new], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "item")
    }

    override func prepareForReuse() {
        item = nil
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvo else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        switch keyPath! {
        case "timestamp":
            timestamp?.text = dateFormatter.string(from: item!.timestamp)
        case "person.displayName":
            status?.text = KeyValueChange(change: change!).new as! String + (item!.type == .participantJoined ? " joined" : " left");
        default:
            assertionFailure()
        }
    }

}
