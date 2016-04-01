//
//  NLSharingOptionsVC.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 01/04/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import Eureka
import MessageUI

class NLSharingOptionsVC: FormViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form  +++=
            Section(header: "Sharing options:", footer: "Tap share to email the corresponding data using a CSV document")
            
            <<< DateRow("from") {
                $0.value = NSDate().dateByAddingTimeInterval(-3600*24*30*6);
                $0.title = "Records from:"
            }
            <<< DateRow("to") {
                $0.value = NSDate();
                $0.title = "To:"
            }
            <<< SwitchRow("detailed") {
                $0.title = "Include detailed report"
                $0.value = false
            }
            <<< SwitchRow("teaching") {
                $0.title = "Include teaching"
                $0.value = false
            }
    
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject("Shared records")
        emailController.setMessageBody("", isHTML: false)
        
        // Attaching the .CSV file to the email.
        let csv = NLRecordsDataManager.sharedInstance.generateGeneralCSVWithRange(form.values()["from"] as! NSDate, toDate: form.values()["to"] as! NSDate, teaching: form.values()["teaching"] as! Bool)
        emailController.addAttachmentData(csv, mimeType: "text/csv", fileName: "GeneralStats.csv")
        
        if form.values()["detailed"] as! Bool {
            let csv = NLRecordsDataManager.sharedInstance.generateGeneralCSVWithRange(form.values()["from"] as! NSDate, toDate: form.values()["to"] as! NSDate, teaching: form.values()["teaching"] as! Bool)
            emailController.addAttachmentData(csv, mimeType: "text/csv", fileName: "DetailedStats.csv")
        }
        
        return emailController
    }
    
    @IBAction func didTapShare(sender: AnyObject) {
        let emailViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(emailViewController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        if result == MFMailComposeResultSent {
            noticeSuccess("Sent!")
        } else if result == MFMailComposeResultFailed {
            noticeError("Failed...")
        }
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(),{
            self.clearAllNotice()
        })
    }
}
