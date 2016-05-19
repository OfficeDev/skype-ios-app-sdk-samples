//
//  ChatCell.swift
//  bankingAppSwift
//
//  Created by Aasveen Kaur on 5/13/16.
//  Copyright © 2016 Aasveen Kaur. All rights reserved.
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
