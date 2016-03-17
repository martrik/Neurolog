//
//  NLVisitCellTableViewCell.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 17/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class NLVisitCellTableViewCell: UITableViewCell {

    @IBOutlet weak var disease: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
