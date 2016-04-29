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

    private var kvo = 0

    var item: SfBParticipantActivityItem? {
        willSet {
            item?.removeObserver(self, forKeyPath: "person.displayName", context: &kvo)
            item?.removeObserver(self, forKeyPath: "timestamp", context: &kvo)
        }
        didSet {
            item?.addObserver(self, forKeyPath: "timestamp", options: [.Initial], context: &kvo)
            item?.addObserver(self, forKeyPath: "person.displayName", options: [.Initial, .New], context: &kvo)
        }
    }

    deinit {
        setValue(nil, forKey: "item")
    }

    override func prepareForReuse() {
        item = nil
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &kvo else {
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }

        switch keyPath! {
        case "timestamp":
            timestamp?.text = dateFormatter.stringFromDate(item!.timestamp)
        case "person.displayName":
            status?.text = KeyValueChange(change: change!).new as! String + (item!.type == .ParticipantJoined ? " joined" : " left");
        default:
            assertionFailure()
        }
    }

}
