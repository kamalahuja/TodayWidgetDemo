//
//  TodayMeetingTableViewCell.swift
//  TodayExtensionDemo
//
//  Created by Kamal Ahuja on 8/5/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import UIKit

class TodayMeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
