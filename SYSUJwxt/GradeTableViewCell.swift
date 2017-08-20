//
//  GradeTableViewCell.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/20.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class GradeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var gpaLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var rankingInTeachingClassLabel: UILabel!
    @IBOutlet weak var rankingInMajorClassLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
