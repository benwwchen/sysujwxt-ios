//
//  CourseTableViewCell.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/18.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
