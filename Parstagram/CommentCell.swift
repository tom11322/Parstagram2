//
//  CommentCell.swift
//  Parstagram
//
//  Created by Wade Li on 3/31/19.
//  Copyright © 2019 Wade Li. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var commentL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
