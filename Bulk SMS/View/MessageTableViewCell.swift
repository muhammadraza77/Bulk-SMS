//
//  MessageTableViewCell.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 9/30/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var Msgtext: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
