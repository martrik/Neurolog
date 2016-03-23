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
        
        self.visitsLabel.backgroundColor = UIColor.appLightBlue()
        self.visitsLabel.layer.cornerRadius = 15
    }
    
    func updateSettingLabelColor() {
        var labelColor = UIColor.appDarkBlue()

        switch NLSelectionDataManger.sharedInstance.clinicalSettings().indexOf(settingLabel.text!)! {
        case 0:
            labelColor = UIColor.appOrange()
            break
        case 1:
            labelColor = UIColor.appGreen()
            break
        case 2:
            labelColor = UIColor.appDarkBlue()
            break
        case 3:
            labelColor = UIColor.appBrown()
            break
        default:
            break
        }
        
        settingLabel.textColor = labelColor
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
    }
    
}
