//
//  MeetingDetailsViewCellTableViewCell.swift
//  TodayExtensionDemo
//
//  Created by Kamal Ahuja on 7/25/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import UIKit

class MeetingDetailsViewCellTableViewCell: UITableViewCell {

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var subject: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
