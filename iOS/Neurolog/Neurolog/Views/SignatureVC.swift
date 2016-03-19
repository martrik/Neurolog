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
        super.init(nibName: "ContentSignatureVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signatureView = HYPSignatureView(frame: self.view.frame)
        self.view.addSubview(signatureView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSignature() -> UIImage {
        return signatureView!.signatureImage()
    }
}
