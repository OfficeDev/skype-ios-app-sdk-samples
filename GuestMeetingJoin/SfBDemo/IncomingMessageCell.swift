//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: IncomingMessageCell.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

class IncomingMessageCell: UITableViewCell {

    @IBOutlet var timestamp: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var message: UILabel!

    private var kvo = 0

    var item: SfBMessageActivityItem? {
        willSet {
            item?.removeObserver(self, forKeyPath: "timestamp", context: &kvo)
            item?.removeObserver(self, forKeyPath: "sender.displayName", context: &kvo)
        }
        didSet {
            item?.addObserver(self, forKeyPath: "timestamp", options: [.Initial], context: &kvo)
            item?.addObserver(self, forKeyPath: "sender.displayName", options: [.Initial, .New], context: &kvo)
            message?.text = item?.text
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
            timestamp.text = dateFormatter.stringFromDate(item!.timestamp)
        case "sender.displayName":
            let senderName = KeyValueChange(change: change!).new
            switch senderName {
            case is NSNull:
                author.attributedText = NSAttributedString(string: "Unknown",
                    attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
            default:
                author.text = senderName as? String;
            }
        default:
            assertionFailure()
        }

        setNeedsLayout()
    }

}
