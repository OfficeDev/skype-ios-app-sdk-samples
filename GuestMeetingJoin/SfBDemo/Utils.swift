//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: Utils.swift
//----------------------------------------------------------------

import Foundation
import UIKit
import SkypeForBusiness

var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}

class KeyValueChange {

    fileprivate let change: [NSKeyValueChangeKey : Any]

    init(change: [NSKeyValueChangeKey : Any]) {
        self.change = change
    }

    var kind: NSKeyValueChange? {
        guard let value = change[.kindKey] as? NSNumber else {
            return nil
        }

        return NSKeyValueChange(rawValue: value.uintValue)
    }

    var indexSet: IndexSet? {
        return change[.indexesKey] as? IndexSet
    }

    var new: Any? {
        return change[.newKey]
    }

}

extension IndexSet {

    var indexPaths: [IndexPath] {
        var indexPaths: [IndexPath] = []

        for index in self {
            indexPaths.append(IndexPath(row: index, section: 0))
        }

        return indexPaths
    }

}

extension UITableView {

    func updateRowsWithChange(_ change: KeyValueChange) {
        switch change.kind! {
        case .setting:
            reloadData()
        case .insertion:
            insertRows(at: change.indexSet!.indexPaths, with: .automatic)
        case .removal:
            deleteRows(at: change.indexSet!.indexPaths, with: .automatic)
        case .replacement:
            reloadRows(at: change.indexSet!.indexPaths, with: .automatic)
        }
    }

}

extension SfBAlertType: CustomStringConvertible {

    public var description: String {
        switch (self) {
        case .signIn:
            return "SignIn"
        case .participantMute:
            return "ParticipantMute"
        case .participantUnmute:
            return "ParticipantUnmute"
        case .messaging:
            return "Messaging"
        case .conferenceIsRecording:
            return "ConferenceIsRecording"
        case .conferenceUnexpectedDisconnect:
            return "ConferenceUnexpectedDisconnect"
        default:
            return "Type \(self.rawValue)"
        }
    }

}

extension SfBAlertLevel: CustomStringConvertible {

    public var description: String {
        switch (self) {
        case .error:
            return "Error"
        case .warning:
            return "Warning"
        case .info:
            return "Info"
        }
    }

}

extension SfBAlert {

    func show() {
        UIAlertView(title: "\(level): \(type)",
            message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
    }

}

extension SfBMessageStatus {

    public var backgroundColor: UIColor {
        switch (self) {
        case .failed:
            return UIColor.red
        case .pending:
            return UIColor.yellow
        case .succeeded:
            return UIColor.clear
        }
    }

}

extension SfBAudioServiceMuteState: CustomStringConvertible {

    public var description: String {
        switch self {
        case .unmuted:
            return "Unmuted"
        case .muted:
            return "Muted"
        case .unmuting:
            return "Unmuting"
        }
    }

}
