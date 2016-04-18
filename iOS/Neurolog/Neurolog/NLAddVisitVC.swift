//
//  NLAddVisit.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 15/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import Eureka


class NLAddVisitVC: FormViewController {
    
    var record: Record!
    var edittingVisit: Visit?    
    var didDismiss:(()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form  +++=
            
            Section(footer: "Tap on save to store this Case")
            
            <<< TimeRow("time") {
                $0.title = "Time:"
                
                if edittingVisit != nil {
                    $0.value = edittingVisit!.time
                } else {
                    $0.value = NSDate();
                }
                    
            }
            <<< PushRow<String>("disease") { (row : PushRow<String>) -> Void in
                row.title = "Disease:"
                
                row.options = NLSelectionManager.sharedInstance.portfolioTopics()
                
                if edittingVisit != nil {
                    row.value = edittingVisit!.topic
                }
            }
            <<< PushRow<String>("age") { (row : PushRow<String>) -> Void in
                row.title = "Age:"
                let ages: [Int] = Array(1...110)
                let stringAges = ages.map { String($0) }
                row.options = stringAges
                
                if edittingVisit != nil {
                    row.value = String(edittingVisit!.age)
                }
            }
            <<< ActionSheetRow<String>("sex") { (row : ActionSheetRow<String>) -> Void in
                row.title = "Sex:"
                row.options = ["Female", "Male"]
                
                if edittingVisit != nil {
                    row.value = edittingVisit!.sex
                }
            }
    }

    @IBAction func didTapSave(sender: AnyObject) {
        if form.values()["disease"]! != nil && form.values()["age"]! != nil && form.values()["sex"]! != nil {
            if edittingVisit != nil {
                NLVisitsManager.sharedInstance.updateVisit(edittingVisit!, record: record, info: form.values())
                if let completion = didDismiss {
                    self.noticeSuccess("Updated!")
                    completion()
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                NLVisitsManager.sharedInstance.saveVisitInRecord(record, info: form.values())
                self.noticeSuccess("Saved!")
                self.navigationController?.popViewControllerAnimated(true)
            }

        } else {
            self.noticeInfo("Missing info")
        }
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(),{
            self.clearAllNotice()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
