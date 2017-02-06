//
//  ChatCell.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/13/16.
// Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
// See LICENSE in the project root for license information.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
