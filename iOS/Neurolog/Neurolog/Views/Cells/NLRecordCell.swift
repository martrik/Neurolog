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

        switch NLSelectionManager.sharedInstance.clinicalSettings().indexOf(settingLabel.text!)! {
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
        case 4:
            labelColor = UIColor.appViolet()
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
    
    func setRecord(record: Record) {
        settingLabel.text = record.setting
        updateSettingLabelColor()
        
        locationLabel.text = record.location
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = NSLocale.currentLocale()
        timeFormatter.dateStyle = .ShortStyle
        dateLabel.text  = timeFormatter.stringFromDate(record.date)
        
        visitsLabel.text = String(record.visits.count)
        setSigned(record.signaturePath != nil)
        
        visitsLabel.hidden = record.setting == "Teaching"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        let color = visitsLabel.backgroundColor;

        super.setSelected(selected, animated: animated)
        
        if selected {
            visitsLabel.backgroundColor = color
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = self.visitsLabel.backgroundColor;
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            visitsLabel.backgroundColor = color
        }
    }
    
}
