//
//  NLRecordCell.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 19/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class NLRecordCell: UITableViewCell {

    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var signedBadge: UIImageView!
    @IBOutlet weak var visitsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.visitsLabel.layer.cornerRadius = 15
    }
    
    func setSigned(signed: Bool) {
        if signed {
            signedBadge.image = UIImage(named: "signedBadge")
        } else {
            signedBadge.image = nil
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
