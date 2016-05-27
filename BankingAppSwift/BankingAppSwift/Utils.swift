//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: Utils.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

var dateFormatter: NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}

class KeyValueChange {

    private let change: [String : AnyObject]

    init(change: [String : AnyObject]) {
        self.change = change
    }

    var kind: NSKeyValueChange? {
        guard let value = change[NSKeyValueChangeKindKey] as? NSNumber else {
            return nil
        }

        return NSKeyValueChange(rawValue: value.unsignedLongValue)
    }

    var indexSet: NSIndexSet? {
        return change[NSKeyValueChangeIndexesKey] as? NSIndexSet
    }

    var new: AnyObject? {
        return change[NSKeyValueChangeNewKey]
    }

}

extension NSIndexSet {

    var indexPaths: [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []

        for index in self {
            indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
        }

        return indexPaths
    }

}

extension UITableView {

    func updateRowsWithChange(change: KeyValueChange) {
        switch change.kind! {
        case .Setting:
            reloadData()
        case .Insertion:
            insertRowsAtIndexPaths(change.indexSet!.indexPaths, withRowAnimation: .Automatic)
        case .Removal:
            deleteRowsAtIndexPaths(change.indexSet!.indexPaths, withRowAnimation: .Automatic)
        case .Replacement:
            reloadRowsAtIndexPaths(change.indexSet!.indexPaths, withRowAnimation: .Automatic)
        }
    }

}

extension SfBAlertType: CustomStringConvertible {

    public var description: String {
        switch (self) {
        case .SignIn:
            return "SignIn"
        case .ParticipantMute:
            return "ParticipantMute"
        case .ParticipantUnmute:
            return "ParticipantUnmute"
        case .Messaging:
            return "Messaging"
        case .ConferenceIsRecording:
            return "ConferenceIsRecording"
        case .ConferenceUnexpectedDisconnect:
            return "ConferenceUnexpectedDisconnect"
        default:
            return "Type \(self.rawValue)"
        }
    }

}

extension SfBAlertLevel: CustomStringConvertible {

    public var description: String {
        switch (self) {
        case .Error:
            return "Error"
        case .Warning:
            return "Warning"
        case .Info:
            return "Info"
        }
    }

}

extension SfBAlert {

    func show() {
        UIAlertView(title: "\(level): \(type)",
            message: "\(error.localizedDescription)", delegate: nil, cancelButtonTitle: "OK").show()
    }

}
