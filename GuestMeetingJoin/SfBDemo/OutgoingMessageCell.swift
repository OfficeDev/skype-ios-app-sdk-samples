//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: OutgoingMessageCell.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class OutgoingMessageCell: UITableViewCell {

    @IBOutlet var timestamp: UILabel!
    @IBOutlet var message: UILabel!

    fileprivate var kvo = 0

    var item: SfBMessageActivityItem? {
        willSet {
            item?.removeObserver(self, forKeyPath: "timestamp", context: &kvo)
            item?.removeObserver(self, forKeyPath: "status", context: &kvo)
        }
        didSet {
            item?.addObserver(self, forKeyPath: "status", options: [.initial], context: &kvo)
            item?.addObserver(self, forKeyPath: "timestamp", options: [.initial], context: &kvo)
            message.text = item?.text
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
            timestamp.text = dateFormatter.string(from: item!.timestamp)
        case "status":
            backgroundColor = item?.status.backgroundColor
        default:
            assertionFailure()
        }

        setNeedsLayout()
    }

}
