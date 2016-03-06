//
//  CustomField.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 06/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class CustomField: UITextField {

    override func awakeFromNib() {
        let paddingView = UIView(frame: CGRectMake(0, 0, 10, 0))
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.Always
    }

}
