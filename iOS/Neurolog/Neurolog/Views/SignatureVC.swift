//
//  ContentViewController.swift
//  SheetAlertExample
//
//  Created by Kyohei Ito on 2015/01/09.
//  Copyright (c) 2015年 kyohei_ito. All rights reserved.
//

import UIKit
import Signature

class SignatureVC: UIViewController {

    var signatureView: HYPSignatureView?
    
    init() {
        super.init(nibName: "SignatureVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signatureView = HYPSignatureView(frame: self.view.frame)
        signatureView?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(signatureView!)
    }
    
    func setExplainLabel(name: String) {
        self.view.setNeedsDisplay()
        self.view.updateConstraintsIfNeeded()
        
        let label = UILabel(frame: CGRectMake(0,0,0,0))
        label.text = "Ask \(name) to sign here:"
        label.font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        label.textColor = UIColor.lightGrayColor()
        label.alpha = 0.6
        label.sizeToFit()
        label.frame = CGRectMake(20, 20, CGRectGetWidth(label.frame),CGRectGetHeight(label.frame))
        self.view.addSubview(label)
        self.view.bringSubviewToFront(signatureView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSignature() -> UIImage {
        return signatureView!.signatureImage()
    }
}
